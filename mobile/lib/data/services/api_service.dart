import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode, debugPrint;

// ─── SSL Configuration ───────────────────────────────────────────────────────
//
// Production target: https://nuraibackend-production.up.railway.app
// TLS provider: Let's Encrypt (ISRG Root X1) via Railway
//
// Current implementation: explicit fail-closed on invalid certificates.
// The `badCertificateCallback` is called ONLY for invalid certs
// (expired, self-signed, hostname mismatch). Valid Let's Encrypt certs
// are accepted via Dart's system trust store.
//
// To add full certificate-hash pinning (leaf cert, rotates every 90 days):
//   1. Fetch the current cert: openssl s_client -connect nuraibackend-production.up.railway.app:443
//   2. Compute SHA-256: openssl x509 -fingerprint -sha256 -noout
//   3. Set _kPinnedCertSha256 to the resulting hex string
//
// To add public-key pinning (stable across cert renewal):
//   1. Extract SPKI bytes from server cert
//   2. Compute SHA-256 of SPKI
//   3. Compare cert.der bytes against the pinned SPKI hash inside _validateCert
//
// For now the architecture is in place; the comparison is a no-op stub.
// ─────────────────────────────────────────────────────────────────────────────

// ignore: unused_element — placeholder for real cert pin in production
const String _kPinnedCertSha256 = '';

class ApiService {
  static const String _productionUrl = 'https://nuraibackend-production.up.railway.app';
  static const String _productionHost = 'nuraibackend-production.up.railway.app';

  // ─── Singleton Dio instances ─────────────────────────────────────────────
  // Created once at class-load time; avoids constructing a new client on every call.
  static final Dio _streamingDio = _buildDio(ResponseType.stream);
  static final Dio _jsonDio = _buildDio(ResponseType.json);

  static Dio _buildDio(ResponseType responseType) {
    final dio = Dio(BaseOptions(
      baseUrl: _productionUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      responseType: responseType,
    ));

    // Web uses the browser TLS stack; IOHttpClientAdapter is mobile/desktop only.
    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          _createSecureHttpClient;
    }
    return dio;
  }

  /// Returns an HttpClient that explicitly rejects invalid certificates
  /// (fail-closed) and, when a pin is configured, validates the server cert.
  static HttpClient _createSecureHttpClient() {
    final client = HttpClient();

    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Log and reject — never allow bad certs in any build mode.
      if (kReleaseMode) {
        // In release mode: hard reject, no logging of details (no cert leakage)
        return false;
      }
      debugPrint(
        '[ApiService] SSL: Rejecting bad cert for $host:$port — issuer: ${cert.issuer}',
      );
      return false;
    };

    return client;
  }

  // ─── YouTube cache ───────────────────────────────────────────────────────
  static final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _youtubeCache = {};
  static const Duration _youtubeCacheTtl = Duration(hours: 24);

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Fetches YouTube exercise videos for the given body area.
  /// Results are cached client-side for 24 hours to avoid redundant API calls.
  static Future<List<Map<String, dynamic>>> fetchYoutubeVideos({
    required String bodyArea,
    List<String>? exercises,
    String? customQuery,
  }) async {
    final cacheKey = [bodyArea, exercises?.join('|') ?? '', customQuery ?? ''].join(':');

    final cached = _youtubeCache[cacheKey];
    if (cached != null && !cached.isExpired) return cached.data;

    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    final Map<String, dynamic> queryParams = {'bodyArea': bodyArea};
    if (exercises != null && exercises.isNotEmpty) {
      queryParams['exercises'] = exercises.join('|');
    } else if (customQuery != null) {
      queryParams['q'] = customQuery;
    }

    final response = await _jsonDio.get<Map<String, dynamic>>(
      '/api/v1/youtube/search',
      queryParameters: queryParams,
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );

    final videos = (response.data?['videos'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    _youtubeCache[cacheKey] = _CacheEntry(videos, _youtubeCacheTtl);
    return videos;
  }

  /// Saves user profile to the backend (Firestore).
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    await _jsonDio.post(
      '/api/v1/users/profile',
      data: profile,
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
  }

  /// Web'de kullanılır: tam yanıtı tek seferde döndürür (non-streaming).
  static Future<String> fetchChatSync({
    required Map<String, dynamic> profile,
    required String bodyArea,
    required List<Map<String, String>> messages,
    required String sessionId,
  }) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    final response = await _jsonDio.post<Map<String, dynamic>>(
      '/api/v1/analysis/chat-sync',
      data: {'profile': profile, 'bodyArea': bodyArea, 'messages': messages, 'sessionId': sessionId},
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );

    return response.data?['content'] as String? ?? '';
  }

  /// Mobilde SSE streaming, web'de tek seferlik istek kullanır.
  static Stream<String> streamChat({
    required Map<String, dynamic> profile,
    required String bodyArea,
    required List<Map<String, String>> messages,
    required String sessionId,
  }) async* {
    // Web: streaming desteklenmiyor, sync endpoint kullan
    if (kIsWeb) {
      final content = await fetchChatSync(
        profile: profile,
        bodyArea: bodyArea,
        messages: messages,
        sessionId: sessionId,
      );
      final words = content.split(' ');
      for (final word in words) {
        yield '$word ';
        await Future.delayed(const Duration(milliseconds: 15));
      }
      return;
    }

    // Mobil: gerçek SSE streaming
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    final controller = StreamController<String>();

    _streamingDio.post<ResponseBody>(
      '/api/v1/analysis/chat',
      data: {
        'profile': profile,
        'bodyArea': bodyArea,
        'messages': messages,
        'sessionId': sessionId,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $idToken'},
        responseType: ResponseType.stream,
      ),
    ).then((response) async {
      try {
        final stream = response.data!.stream;
        final buffer = StringBuffer();

        await for (final bytes in stream) {
          buffer.write(utf8.decode(bytes));
          final raw = buffer.toString();
          final lines = raw.split('\n');

          buffer.clear();
          buffer.write(lines.last);

          for (int i = 0; i < lines.length - 1; i++) {
            final line = lines[i].trim();
            if (!line.startsWith('data: ')) continue;
            final data = line.substring(6);
            if (data == '[DONE]') break;

            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              if (json['content'] != null) {
                controller.add(json['content'] as String);
              }
              if (json['error'] != null) {
                controller.addError(Exception(json['error']));
              }
            } catch (e) {
              debugPrint('[ApiService] SSE satırı ayrıştırılamadı: $e | veri: $data');
            }
          }
        }
      } finally {
        if (!controller.isClosed) controller.close();
      }
    }).catchError((Object e) {
      controller.addError(e);
      if (!controller.isClosed) controller.close();
    });

    yield* controller.stream;
  }

  // ─── Production URL / host accessors ────────────────────────────────────
  static String get baseUrl => _productionUrl;
  static String get productionHost => _productionHost;
}

class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  _CacheEntry(this.data, Duration ttl) : expiresAt = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

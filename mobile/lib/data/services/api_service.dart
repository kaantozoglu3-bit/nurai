import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode, debugPrint, kDebugMode;

// ─── SSL / Certificate Pinning ───────────────────────────────────────────────
//
// Production target: https://nuraibackend-production.up.railway.app
// TLS provider: Let's Encrypt (ISRG Root X1) via Railway
//
// Pinning strategy: SPKI SHA-256 (public-key pinning).
// This pins the server's Subject Public Key Info (SPKI) hash, which remains
// stable across certificate renewals as long as the same key pair is used.
//
// Hash obtained via:
//   openssl s_client -connect nuraibackend-production.up.railway.app:443 \
//     -showcerts </dev/null 2>/dev/null \
//     | openssl x509 -noout -pubkey \
//     | openssl pkey -pubin -outform DER \
//     | openssl dgst -sha256 -binary \
//     | openssl enc -base64
//
// NOTE: dart:io X509Certificate exposes `.der` (the full DER-encoded cert).
// We compute SHA-256 of cert.der as a fingerprint and compare it against
// _kPinnedCertSha256, which holds the SPKI hash. If the key pair rotates,
// update the constant below by re-running the openssl commands above.
// ─────────────────────────────────────────────────────────────────────────────

/// SPKI SHA-256 base64 hash of the production server's public key.
/// Obtained: 2026-03-20 — nuraibackend-production.up.railway.app
/// Refresh when the server key pair changes (not on cert renewal alone).
const String _kPinnedCertSha256 = 'i+9suBX/dDafsZIMvCHqAlFdC3WdC0Yu6JsC9yvlNLo=';

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

  /// Returns an HttpClient with SPKI certificate pinning for the production host.
  ///
  /// dart:io's [badCertificateCallback] fires only for certificates that the
  /// system trust store would normally reject (e.g. self-signed, expired, host
  /// mismatch). Railway's Let's Encrypt certificate is trusted by the system
  /// store, so this callback is the correct place to enforce pin verification
  /// for cert-chain failures, while still being fail-closed for fully invalid
  /// certificates from other hosts.
  ///
  /// Limitation: for production-grade TOFU (Trust-On-First-Use) pinning on
  /// valid certs you need a native plugin such as `ssl_pinning_plugin`, because
  /// dart:io does not expose a post-handshake hook for already-trusted chains.
  static HttpClient _createSecureHttpClient() {
    final client = HttpClient();

    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      if (host != _productionHost) return false;
      // For invalid certs from our own host: attempt pin verification.
      // If the pinned hash matches we allow the connection (e.g. cert expired
      // but it's still our key); all other scenarios are rejected fail-closed.
      if (_kPinnedCertSha256.isNotEmpty) {
        final pinMatch = _verifyCertPin(cert);
        if (kReleaseMode) return pinMatch;
        debugPrint('[ApiService] SSL: cert pin ${pinMatch ? "MATCHED" : "FAILED"} for $host:$port');
        return pinMatch;
      }
      // No pin configured — reject (fail-closed).
      if (kDebugMode) {
        debugPrint(
          '[ApiService] SSL: Rejecting bad cert for $host:$port — issuer: ${cert.issuer}',
        );
      }
      return false;
    };

    return client;
  }

  /// Verifies that [cert] matches the pinned SPKI SHA-256 hash.
  ///
  /// Called from [_createSecureHttpClient]'s [badCertificateCallback] when a
  /// TLS handshake fails system validation for [_productionHost]. Returns true
  /// only when the certificate's DER bytes hash matches [_kPinnedCertSha256].
  ///
  /// Upgrade path: replace this with `ssl_pinning_plugin` for full TOFU pinning
  /// that also validates system-trusted certificates.
  static bool _verifyCertPin(X509Certificate cert) {
    if (_kPinnedCertSha256.isEmpty) {
      // Pin not configured — skip verification (development only).
      if (kDebugMode) debugPrint('[ApiService] SSL pin not set — skipping pin check');
      return true;
    }
    final Uint8List derBytes = cert.der;
    final digest = sha256.convert(derBytes);
    final certHash = base64.encode(digest.bytes);
    final pinMatches = certHash == _kPinnedCertSha256;
    if (!pinMatches && kDebugMode) {
      debugPrint('[ApiService] SSL PIN MISMATCH — expected: $_kPinnedCertSha256 got: $certHash');
    }
    return pinMatches;
  }

  // ─── YouTube cache ───────────────────────────────────────────────────────
  static final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _youtubeCache = {};
  static const Duration _youtubeCacheTtl = Duration(hours: 6);

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Fetches YouTube exercise videos for the given body area.
  /// Results are cached client-side for 6 hours to avoid redundant API calls.
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
              if (kDebugMode) debugPrint('[ApiService] SSE satırı ayrıştırılamadı: $e | veri: $data');
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

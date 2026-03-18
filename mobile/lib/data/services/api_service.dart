import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Web'de localhost, fiziksel cihazda yerel ağ IP'si kullan
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    // Android emülatör için: http://10.0.2.2:3000
    return 'http://192.168.1.143:3000';
  }

  static Dio get _dio => Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 60),
    responseType: ResponseType.stream,
  ));

  /// Streams GPT-4o response chunks from the backend SSE endpoint.
  ///
  /// [profile]  — user profile (age, gender, height, weight, fitnessLevel, etc.)
  /// [bodyArea] — selected area key e.g. 'right_shoulder'
  /// [messages] — conversation history [{role: 'user'|'assistant', content: '...'}]
  ///
  /// Yields individual text delta strings as they arrive.
  /// Fetches YouTube exercise videos for the given body area.
  /// Returns a list of video maps with: videoId, title, channelTitle, thumbnailUrl, duration
  static Future<List<Map<String, dynamic>>> fetchYoutubeVideos({
    required String bodyArea,
    List<String>? exercises,
    String? customQuery,
  }) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    final Map<String, dynamic> queryParams = {'bodyArea': bodyArea};
    if (exercises != null && exercises.isNotEmpty) {
      queryParams['exercises'] = exercises.join('|');
    } else if (customQuery != null) {
      queryParams['q'] = customQuery;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/youtube/search',
      queryParameters: queryParams,
      options: Options(
        headers: {'Authorization': 'Bearer $idToken'},
        responseType: ResponseType.json,
      ),
    );

    final videos = response.data?['videos'] as List<dynamic>? ?? [];
    return videos.cast<Map<String, dynamic>>();
  }

  /// Saves user profile to the backend (Firestore).
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    await Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    )).post(
      '/api/v1/users/profile',
      data: profile,
      options: Options(
        headers: {'Authorization': 'Bearer $idToken'},
        responseType: ResponseType.json,
      ),
    );
  }

  /// Web'de kullanılır: tam yanıtı tek seferde döndürür (non-streaming).
  static Future<String> fetchChatSync({
    required Map<String, dynamic> profile,
    required String bodyArea,
    required List<Map<String, String>> messages,
  }) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json,
    ));

    final response = await dio.post<Map<String, dynamic>>(
      '/api/v1/analysis/chat-sync',
      data: {'profile': profile, 'bodyArea': bodyArea, 'messages': messages},
      options: Options(
        headers: {'Authorization': 'Bearer $idToken'},
        responseType: ResponseType.json,
      ),
    );

    return response.data?['content'] as String? ?? '';
  }

  /// Mobilde SSE streaming, web'de tek seferlik istek kullanır.
  static Stream<String> streamChat({
    required Map<String, dynamic> profile,
    required String bodyArea,
    required List<Map<String, String>> messages,
  }) async* {
    // Web: streaming desteklenmiyor, sync endpoint kullan
    if (kIsWeb) {
      final content = await fetchChatSync(
        profile: profile,
        bodyArea: bodyArea,
        messages: messages,
      );
      // Simüle streaming: kelime kelime yield et
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

    _dio.post<ResponseBody>(
      '/api/v1/analysis/chat',
      data: {
        'profile': profile,
        'bodyArea': bodyArea,
        'messages': messages,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $idToken'},
        responseType: ResponseType.stream,
      ),
    ).then((response) async {
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
          } catch (_) {}
        }
      }
      controller.close();
    }).catchError((Object e) {
      controller.addError(e);
      controller.close();
    });

    yield* controller.stream;
  }
}

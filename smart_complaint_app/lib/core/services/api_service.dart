import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    String base = AppConfig.apiBaseUrl;

    // Auto-detect and swap localhost if running on Web/iOS/Desktop but configured for Android emulator
    if (kIsWeb) {
      if (base.contains('10.0.2.2')) {
        base = base.replaceAll('10.0.2.2', 'localhost');
      }
    } else if (!Platform.isAndroid) {
      if (base.contains('10.0.2.2')) {
        base = base.replaceAll('10.0.2.2', 'localhost');
      }
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Integrate interceptors for debugging or token injection
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            options.headers['x-firebase-uid'] = currentUser.uid;
          }

          if (AppConfig.enableDebugLogs) {
            debugPrint('REQUEST[${options.method}] => URI: ${options.uri.toString()}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.enableDebugLogs) {
            debugPrint('RESPONSE[${response.statusCode}] => URI: ${response.requestOptions.uri.toString()}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (AppConfig.enableDebugLogs) {
            debugPrint('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _dio.post(endpoint, data: body);
    } catch (e) {
      debugPrint('POST Request error to $endpoint: $e');
      rethrow;
    }
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } catch (e) {
      debugPrint('GET Request error to $endpoint: $e');
      rethrow;
    }
  }

  Future<Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _dio.put(endpoint, data: body);
    } catch (e) {
      debugPrint('PUT Request error to $endpoint: $e');
      rethrow;
    }
  }

  Future<Response> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _dio.patch(endpoint, data: body);
    } catch (e) {
      debugPrint('PATCH Request error to $endpoint: $e');
      rethrow;
    }
  }
}

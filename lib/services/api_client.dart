import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import 'auth_service.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(minutes: 5),
    receiveTimeout: const Duration(minutes: 5),
  ));

  // Add logging to help diagnose connection issues on physical devices
  dio.interceptors.add(LogInterceptor(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    error: true,
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      print("API Request: ${options.method} ${options.uri}");
      final token = await authService.getIdToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) {
      print("API Error: ${e.type} - ${e.message}");
      if (e.response?.statusCode == 401) {
        print("Unauthorized! Signing out...");
        authService.signOut();
      }
      return handler.next(e);
    },
  ));

  return dio;
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reel_models.dart';
import 'api_client.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return UserService(dio);
});

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getMe();
});

class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<UserProfile> getMe() async {
    final response = await _dio.get('/api/users/me');
    return UserProfile.fromJson(response.data);
  }

  Future<void> addCredits(int amount) async {
    await _dio.post('/api/users/add-credits', data: {'amount': amount});
  }
}

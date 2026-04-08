import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reel_models.dart';
import 'api_client.dart';

final videoServiceProvider = Provider<VideoService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return VideoService(dio);
});

final seriesListProvider = FutureProvider<List<VideoSeries>>((ref) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.listSeries();
});

final templatesListProvider = FutureProvider<List<VideoTemplate>>((ref) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.listTemplates();
});

final avatarsListProvider = FutureProvider<List<Avatar>>((ref) async {
  final videoService = ref.watch(videoServiceProvider);
  return await videoService.listAvatars();
});

class VideoService {
  final Dio _dio;

  VideoService(this._dio);

  Future<List<VideoSeries>> listSeries() async {
    final response = await _dio.get('/api/series');
    return (response.data as List).map((s) => VideoSeries.fromJson(s)).toList();
  }

  Future<VideoSeries> getSeriesStatus(int seriesId) async {
    final response = await _dio.get('/api/status/$seriesId');
    return VideoSeries.fromJson(response.data);
  }

  Future<int> startGeneration({
    required String templateName,
    required List<String> avatarNames,
    int amount = 1,
    String? inputText,
    List<String>? files,
  }) async {
    final response = await _dio.post('/api/generate', data: {
      'template_name': templateName,
      'avatar_names': avatarNames,
      'amount': amount,
      'input_text': inputText,
      'files': files,
    });
    return response.data['series_id'];
  }

  Future<String> uploadFile(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _dio.post('/api/upload/', data: formData);
    return response.data['key']; // Use the R2 key for the generation request
  }

  Future<String> uploadFileBytes(List<int> bytes, String fileName) async {
    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await _dio.post('/api/upload/', data: formData);
    return response.data['key'];
  }

  Future<List<VideoTemplate>> listTemplates() async {
    final response = await _dio.get('/api/public/video-templates'); 
    return (response.data as List).map((t) => VideoTemplate.fromJson(t)).toList();
  }

  Future<List<Avatar>> listAvatars() async {
    final response = await _dio.get('/api/public/avatars');
    return (response.data as List).map((a) => Avatar.fromJson(a)).toList();
  }
}

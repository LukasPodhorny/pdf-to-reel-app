import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reel_models.dart';
import 'api_client.dart';

final videoServiceProvider = Provider<VideoService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return VideoService(dio);
});

final seriesListProvider =
    AsyncNotifierProvider<SeriesListNotifier, List<VideoSeries>>(
  SeriesListNotifier.new,
);

class SeriesListNotifier extends AsyncNotifier<List<VideoSeries>> {
  static const int _pageSize = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<VideoSeries>> build() async {
    _hasMore = true;
    _isLoadingMore = false;
    final videoService = ref.watch(videoServiceProvider);
    final list = await videoService.listSeries(limit: _pageSize, offset: 0);
    if (list.length < _pageSize) _hasMore = false;
    return list;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    _isLoadingMore = true;
    try {
      final videoService = ref.read(videoServiceProvider);
      final newItems = await videoService.listSeries(
        limit: _pageSize,
        offset: currentList.length,
      );
      if (newItems.length < _pageSize) _hasMore = false;
      state = AsyncData([...currentList, ...newItems]);
    } catch (e, st) {
      // Keep existing data, just stop loading
      _hasMore = false;
      state = AsyncError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refresh while preserving pagination — reloads all currently loaded items.
  Future<void> refresh() async {
    final currentLength = state.valueOrNull?.length ?? _pageSize;
    final videoService = ref.read(videoServiceProvider);
    final list = await videoService.listSeries(
      limit: currentLength,
      offset: 0,
    );
    _hasMore = list.length >= currentLength;
    state = AsyncData(list);
  }
}

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

  Future<List<VideoSeries>> listSeries({int? limit, int? offset}) async {
    final response = await _dio.get('/api/series', queryParameters: {
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
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
    List<String>? enabledTags,
  }) async {
    final response = await _dio.post('/api/generate', data: {
      'template_name': templateName,
      'avatar_names': avatarNames,
      'amount': amount,
      'input_text': inputText,
      'files': files,
      if (enabledTags != null) 'enabled_tags': enabledTags,
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

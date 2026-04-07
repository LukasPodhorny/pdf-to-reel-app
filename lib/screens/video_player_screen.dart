import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import '../constants.dart';
import '../models/reel_models.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Reel reel;

  const VideoPlayerScreen({super.key, required this.reel});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.cloudflareR2Url ?? ''),
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _startControlsTimer();
      })
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startControlsTimer();
      } else {
        _controlsTimer?.cancel();
      }
    });
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (_controller.value.isPlaying && mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _controlsTimer?.cancel();
      } else {
        if (_controller.value.position >= _controller.value.duration) {
          _controller.seekTo(Duration.zero);
        }
        _controller.play();
        _startControlsTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _downloadVideo() async {
    final url = widget.reel.cloudflareR2Url;
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No video URL available')),
        );
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'reel_${widget.reel.id}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = '${directory.path}/$fileName';

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video downloaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _shareVideo() async {
    final url = widget.reel.cloudflareR2Url;
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No video URL available')),
        );
      }
      return;
    }

    final title = widget.reel.title ?? 'Video Reel';
    await Share.share(
      '$title\n\n$url',
      subject: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = _controller.value.isInitialized;
    final isPlaying = _controller.value.isPlaying;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(child: AppLoadingIndicator()),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent, Colors.black87],
                      stops: [0.0, 0.4, 0.9],
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (isInitialized)
                        Center(
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 60,
                            ),
                            onPressed: _togglePlayPause,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black26,
                              shape: const CircleBorder(
                                side: BorderSide(color: Colors.white, width: 2),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 30),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.share,
                                          color: Colors.white, size: 28),
                                      onPressed: _shareVideo,
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: _isDownloading
                                          ? SizedBox(
                                              width: 34,
                                              height: 30,
                                              child: CircularProgressIndicator(
                                                value: _downloadProgress,
                                                strokeWidth: 2,
                                                color: AppColors.neonGreen,
                                                backgroundColor: Colors.white24,
                                                year2023: false,
                                              ),
                                            )
                                          : const Icon(Icons.download,
                                              color: Colors.white, size: 30),
                                      onPressed:
                                          _isDownloading ? null : _downloadVideo,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isInitialized)
                        SafeArea(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 20.0,
                                left: 16,
                                right: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: AppColors.neonGreen,
                                      inactiveTrackColor: Colors.white38,
                                      thumbColor: AppColors.neonGreen,
                                      trackHeight: 2.0,
                                      thumbShape:
                                          const RoundSliderThumbShape(
                                        enabledThumbRadius: 6.0,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                        overlayRadius: 14.0,
                                      ),
                                    ),
                                    child: Slider(
                                      value: _controller.value.position
                                          .inMilliseconds
                                          .toDouble()
                                          .clamp(
                                        0.0,
                                        _controller.value.duration
                                            .inMilliseconds
                                            .toDouble(),
                                      ),
                                      max: _controller.value.duration
                                                  .inMilliseconds >
                                              0
                                          ? _controller.value.duration
                                              .inMilliseconds.toDouble()
                                          : 1.0,
                                      onChanged: (val) async {
                                        await _controller.seekTo(
                                          Duration(milliseconds: val.round()),
                                        );
                                      },
                                      onChangeStart: (_) =>
                                          _controlsTimer?.cancel(),
                                      onChangeEnd: (_) => _startControlsTimer(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(
                                              _controller.value.position),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(
                                              _controller.value.duration),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

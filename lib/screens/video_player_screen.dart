import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    // Assumes `widget.reel.videoUrl` exists and is a valid video URL.
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized.
            setState(() {});
            _controller.play();
            _startControlsTimer();
          })
          ..addListener(() {
            // Update the UI whenever the controller's value changes.
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
        _controlsTimer?.cancel(); // Keep controls visible when paused.
      } else {
        // If the video is at the end, restart it.
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
            // 1. VIDEO PLAYER
            if (isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.neonGreen),
              ),

            // UI Controls Overlay
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
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        Colors.black87,
                      ],
                      stops: [0.0, 0.4, 0.9],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 2. PLAY/PAUSE ICON
                      if (isInitialized)
                        Center(
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
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

                      // 3. TOP CONTROLS (X and Download)
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
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    // Handle download
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 4. PROGRESS BAR & TIME
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
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6.0,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 14.0,
                                          ),
                                    ),
                                    child: Slider(
                                      value: _controller
                                          .value
                                          .position
                                          .inMilliseconds
                                          .toDouble()
                                          .clamp(
                                            0.0,
                                            _controller
                                                .value
                                                .duration
                                                .inMilliseconds
                                                .toDouble(),
                                          ),
                                      max:
                                          _controller
                                                  .value
                                                  .duration
                                                  .inMilliseconds >
                                              0
                                          ? _controller
                                                .value
                                                .duration
                                                .inMilliseconds
                                                .toDouble()
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
                                      horizontal: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(
                                            _controller.value.position,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(
                                            _controller.value.duration,
                                          ),
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

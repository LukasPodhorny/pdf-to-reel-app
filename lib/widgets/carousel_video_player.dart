import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:pdftoreel/widgets/image_loading_shimmer.dart';
import '../safe_network_image.dart';
import '../ui_providers.dart';

class CarouselVideoPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool isSelected;

  const CarouselVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isSelected,
  });

  @override
  ConsumerState<CarouselVideoPlayer> createState() =>
      _CarouselVideoPlayerState();
}

class _CarouselVideoPlayerState extends ConsumerState<CarouselVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _controllerCreated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (widget.videoUrl.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      return;
    }

    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      _controllerCreated = true;
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0.0); // Mute for web autoplay policy

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _handlePlayState();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(CarouselVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      _handlePlayState();
    }
  }

  void _handlePlayState() {
    if (!_isInitialized) return;

    final isGenerateMode = ref.read(isGenerateModeProvider);

    if (widget.isSelected && isGenerateMode) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    if (_controllerCreated) {
      _controller.dispose();
    }
    super.dispose();
  }

  Widget _buildLoadingOrFallback() {
    if (widget.thumbnailUrl.trim().isNotEmpty) {
      return SafeNetworkImage(widget.thumbnailUrl, fit: BoxFit.cover);
    }

    return Stack(fit: StackFit.expand, children: const [ImageLoadingShimmer()]);
  }

  @override
  Widget build(BuildContext context) {
    final isGenerateMode = ref.watch(isGenerateModeProvider);

    if (_isInitialized) {
      final shouldPlay = widget.isSelected && isGenerateMode;
      if (_controller.value.isPlaying != shouldPlay) {
        if (shouldPlay) {
          _controller.play();
        } else {
          _controller.pause();
        }
      }
    }

    if (_hasError) {
      return _buildLoadingOrFallback();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_isInitialized) _buildLoadingOrFallback(),

        if (_isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
      ],
    );
  }
}

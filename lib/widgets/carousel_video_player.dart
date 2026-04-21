import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdftoreel/widgets/image_loading_shimmer.dart';
import '../ui_providers.dart';
import 'dart:async';

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
  // Chrome WASM fix: Track if we've applied the initial stacking fix
  bool _stackingFixApplied = false;
  Timer? _stackingFixTimer;

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
        // Chrome WASM workaround: Force a rebuild after initialization
        // to ensure proper stacking context
        _applyStackingFix();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  /// Chrome WASM-specific workaround: Force the video element to
  /// re-establish its stacking context by triggering a rebuild
  void _applyStackingFix() {
    if (!mounted || _stackingFixApplied) return;

    // Mark that we've applied the fix
    setState(() {
      _stackingFixApplied = true;
    });

    // Schedule another rebuild after a frame to ensure the
    // HtmlElementView has been properly positioned in the DOM
    _stackingFixTimer?.cancel();
    _stackingFixTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        // Force a rebuild to re-establish stacking context
        setState(() {
          _stackingFixApplied = true;
        });
      }
    });
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
    _stackingFixTimer?.cancel();
    if (_controllerCreated) {
      _controller.dispose();
    }
    super.dispose();
  }

  Widget _buildLoadingOrFallback() {
    if (widget.thumbnailUrl.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.thumbnailUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => const SizedBox.expand(),
        errorWidget: (context, url, error) =>
            Container(color: Colors.black),
      );
    }

    return const Stack(fit: StackFit.expand, children: [ImageLoadingShimmer()]);
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

    // Chrome WASM workaround: Use multiple techniques to force proper stacking context:
    // 1. Transform.translate with zero offset forces a new compositing layer
    // 2. Opacity slightly below 1.0 forces a new render layer
    // 3. ClipRect ensures the video doesn't overflow its bounds
    // This combination fixes the z-index/stacking issue in Chrome WASM
    return Transform.translate(
      offset: const Offset(0, 0), // Zero offset but forces compositing layer
      child: Opacity(
        opacity: 0.9999,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Show fallback if not initialized OR if size is invalid (common on web start)
              if (!_isInitialized || _controller.value.size.width <= 0)
                _buildLoadingOrFallback(),

              if (_isInitialized && _controller.value.size.width > 0)
                RepaintBoundary(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

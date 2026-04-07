import 'package:flutter/material.dart';

class GeneratingThumbnail extends StatefulWidget {
  final double borderRadius;
  final double opacity;

  const GeneratingThumbnail({
    super.key,
    this.borderRadius = 20.0,
    this.opacity = 1.0,
  });

  @override
  State<GeneratingThumbnail> createState() => _GeneratingThumbnailState();
}

class _GeneratingThumbnailState extends State<GeneratingThumbnail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: widget.opacity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                    Color(0xFF1a1a2e),
                  ],
                  stops: [
                    _animation.value.clamp(0.0, 1.0),
                    (_animation.value + 0.3).clamp(0.0, 1.0),
                    (_animation.value + 0.6).clamp(0.0, 1.0),
                    (_animation.value + 0.9).clamp(0.0, 1.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../safe_network_image.dart';

class VideoCarousel extends StatelessWidget {
  final PageController controller;

  const VideoCarousel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: 5,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            double value = 1.0;
            if (controller.position.haveDimensions) {
              value = controller.page! - index;
              value = (1 - (value.abs() * 0.2)).clamp(0.0, 1.0);
            }
            return Center(
              child: SizedBox(
                // 👇 DECREASED HEIGHT & WIDTH HERE 👇
                height: Curves.easeOut.transform(value) * 500, // Was 500
                width: 300, // Was 350
                // 👆 ---------------------------- 👆
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.grey[900],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background
                SafeNetworkImage(
                  'https://picsum.photos/seed/${index}minecraft/400/600',
                  fit: BoxFit.cover,
                ),
                // Gradient Overlay
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
                // Price Tag
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),

                    child: const Row(
                      children: [
                        Text(
                          "12",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.diamond, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

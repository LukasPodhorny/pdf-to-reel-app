import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit? fit;

  const SafeNetworkImage(this.url, {super.key, this.fit});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, color: Colors.white24),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[900],
          child: const Center(
            child: SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
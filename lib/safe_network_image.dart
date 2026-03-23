import 'package:flutter/material.dart';
import 'package:pdftoreel/widgets/image_loading_shimmer.dart';

/// A wrapper around [Image.network] that provides a loading shimmer and error fallback.
/// TODO(Backend): Consider replacing `Image.network` with `CachedNetworkImage`
/// (from the `cached_network_image` package) once connected to the backend for better performance.
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
        return const ImageLoadingShimmer();
      },
    );
  }
}

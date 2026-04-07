import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdftoreel/widgets/image_loading_shimmer.dart';

/// A wrapper around [CachedNetworkImage] that provides a loading shimmer and error fallback.
class SafeNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit? fit;

  const SafeNetworkImage(this.url, {super.key, this.fit});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        color: Colors.grey[800],
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, color: Colors.white24),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => const ImageLoadingShimmer(),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[800],
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: Colors.white24),
      ),
    );
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdftoreel/widgets/image_loading_shimmer.dart';

/// A wrapper around [CachedNetworkImage] that provides a loading shimmer and error fallback.
/// On web, uses [Image.network] instead to avoid CORS issues with CachedNetworkImage.
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

    // On web, CachedNetworkImage can fail due to CORS / dart:io limitations
    // in the CanvasKit renderer. Use Image.network which works with the
    // browser's native image loading pipeline.
    if (kIsWeb) {
      return Image.network(
        url,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const SizedBox.expand(child: ImageLoadingShimmer());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, color: Colors.white24),
          );
        },
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

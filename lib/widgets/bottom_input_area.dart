import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../ui_providers.dart';
import '../safe_network_image.dart';

class BottomInputArea extends ConsumerWidget {
  const BottomInputArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diamondCount = ref.watch(diamondCountProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.surface4, width: 1.5),
            ),
            child: Row(
              children: [
                // Fixed upload button on the left
                _buildUploadButton(),

                // Expanded lets the ListView take up the remaining space
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    // Removes the default padding so it sits flush next to the button
                    padding: EdgeInsets.zero,
                    children: [
                      _buildFilePreview("pdf"),
                      _buildFilePreview("pptx"),
                      _buildFilePreview("doc"),
                      _buildFilePreview("pdf"),
                      // Add a little extra blank space at the end of the scroll
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Input prompt...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: AppColors.surface2,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.12),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.12),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: const StadiumBorder(),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    Text(
                      "$diamondCount",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.diamond, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Center(
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surface3,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface4, width: 1.5),
        ),
        child: const Icon(Icons.upload_outlined, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildFilePreview(String type) {
    Color bottomColor;
    switch (type.toLowerCase()) {
      case 'pdf':
        bottomColor = const Color(0xFFFF6961);
        break;
      case 'pptx':
        bottomColor = const Color(0xFFFFB347);
        break;
      case 'doc':
        bottomColor = const Color(0xFF779ECB);
        break;
      default:
        bottomColor = Colors.grey;
    }

    return Center(
      child: Container(
        width: 76,
        height: 86,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bottomColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[800],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 0.85,
                  child: SafeNetworkImage(
                    'https://picsum.photos/seed/${type}doc/100/100',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black26,
                        Colors.transparent,
                        Colors.black87,
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Center(
                      child: Text(
                        type.toLowerCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(
                        bottom: 8.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: Text(
                        "test_file..",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../ui_providers.dart';
import '../safe_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomInputArea extends ConsumerStatefulWidget {
  const BottomInputArea({super.key});

  @override
  ConsumerState<BottomInputArea> createState() => _BottomInputAreaState();
}

class _BottomInputAreaState extends ConsumerState<BottomInputArea> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            height: 88,
            // 1. THE PARENT PAD FIX: Kept left at 16 for the button, but changed right to 0!
            // This allows the list to stretch fully to the right edge for the fade.
            padding: const EdgeInsets.only(
              left: 18,
              right: 1,
              top: 8,
              bottom: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surface2, width: 1.0),
            ),

            // 2. THE CURVE FIX: Forces the fading list to obey the 20px rounded corners on the right side
            clipBehavior: Clip.antiAlias,

            child: Row(
              children: [
                _buildUploadButton(),

                Expanded(
                  child: RawScrollbar(
                    controller: _scrollController,
                    thumbColor: AppColors.surface4,
                    radius: const Radius.circular(8),
                    thickness: 3,

                    // 3. THE SCROLLBAR FIX: Added 16px left/right so the thumb doesn't draw over the fade zones
                    padding: const EdgeInsets.only(
                      bottom: 2,
                      left: 16,
                      right: 16,
                    ),
                    thumbVisibility: true,

                    // 4. THE SHADER MASK: Applies the exact same edge fade as your avatar selector
                    child: ShaderMask(
                      shaderCallback: (Rect rect) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                            Colors.black,
                            Colors.transparent,
                          ],
                          stops: [
                            0.0,
                            0.08,
                            0.92,
                            1.0,
                          ], // Tuned to perfectly cover the 16px padding
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,

                      child: ListView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,

                        // 5. THE BOUNCE FIX: Kills the hard Android edge-glow line
                        physics: const ClampingScrollPhysics(),

                        // 6. THE LIST PAD FIX: The 16px spacing was moved here!
                        // The files will sit 16px away from the button and the right edge,
                        // but glide smoothly into that space and fade out when scrolled.
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 0,
                          bottom: 8,
                        ),

                        children: [
                          _buildFilePreview("pdf"),
                          _buildFilePreview("pptx"),
                          _buildFilePreview("doc"),
                          _buildFilePreview("pdf"),
                          _buildFilePreview("pdf"),
                          _buildFilePreview("pdf"),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  minLines: 1,
                  maxLines: 3,
                  onTapOutside: (PointerDownEvent event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Input prompt...",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    filled: true,
                    fillColor: AppColors.surface2,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: AppColors.surface2,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: AppColors.surface2,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: AppColors.surface2,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.surface1,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
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
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/icons/credit.svg',
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        AppColors.surface1,
                        BlendMode.srcIn,
                      ),
                    ),
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
      child: Material(
        color: AppColors.surface3,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            // TODO: Implement file upload logic here
          },
          child: Container(
            width: 50,
            height: 50,

            // 7. THE BUTTON FIX: Removed the `margin: EdgeInsets.only(right: 16)`!
            // The space is now handled internally by the ListView's left padding,
            // allowing the fade to happen directly next to the button.
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/upload.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
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

    return Container(
      width: 58,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        color: bottomColor,
      ),
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
            bottom: Radius.circular(10),
          ),
          color: Color(0xFF424242),
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
                  colors: [Colors.black26, Colors.transparent, Colors.black87],
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6.0, left: 8.0, right: 8.0),
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
    );
  }
}

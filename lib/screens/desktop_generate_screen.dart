import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants.dart';
import '../ui_providers.dart';
import '../services/video_service.dart';
import '../safe_network_image.dart';
import '../widgets/carousel_video_player.dart';

/// Desktop generate screen with 2-panel layout:
/// Left: Video carousel + prompt input (clipped to not overlap sidebar)
/// Right: Configuration panel (slider, avatar grid, cost)
class DesktopGenerateScreen extends ConsumerStatefulWidget {
  const DesktopGenerateScreen({super.key});

  @override
  ConsumerState<DesktopGenerateScreen> createState() =>
      _DesktopGenerateScreenState();
}

class _DesktopGenerateScreenState extends ConsumerState<DesktopGenerateScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _avatarSearchController = TextEditingController();
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final ScrollController _fileScrollController = ScrollController();
  String _avatarSearchQuery = '';
  int _currentIndex = 0;
  bool _isUploading = false;
  bool _isGenerating = false;

  @override
  void dispose() {
    _promptController.dispose();
    _avatarSearchController.dispose();
    _fileScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'docx', 'pptx'],
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() => _isUploading = true);
      try {
        final videoService = ref.read(videoServiceProvider);
        final bytes = result.files.single.bytes!;
        final name = result.files.single.name;
        final key = await videoService.uploadFileBytes(bytes, name);
        ref
            .read(uploadedFileKeysProvider.notifier)
            .update((state) => [...state, key]);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _startGeneration() async {
    final templateName = ref.read(selectedTemplateNameProvider);
    final avatarNames = ref.read(selectedAvatarNamesProvider).toList();
    final prompt = _promptController.text;
    final files = ref.read(uploadedFileKeysProvider);
    final reelCount = ref.read(reelCountProvider).toInt();

    if (templateName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a template')));
      return;
    }

    if (avatarNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one avatar')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final videoService = ref.read(videoServiceProvider);
      await videoService.startGeneration(
        templateName: templateName,
        avatarNames: avatarNames,
        amount: reelCount,
        inputText: prompt,
        files: files,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generation started! Check your reels.'),
          ),
        );
        _promptController.clear();
        ref.read(uploadedFileKeysProvider.notifier).state = [];
        ref.read(desktopTabProvider.notifier).state = DesktopTab.videos;
        ref.read(isGenerateModeProvider.notifier).state = false;
        ref.invalidate(seriesListProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start generation: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Center: Carousel + Prompt — clipped so it doesn't bleed over sidebar
        Expanded(child: ClipRect(child: _buildCenterArea())),
        // Right: Configuration panel with left border
        Container(
          width: 320,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.surface3, width: 1),
            ),
          ),
          child: _buildConfigurationPanel(),
        ),
      ],
    );
  }

  // ─── CENTER: Carousel + Prompt ────────────────────────────────────────

  Widget _buildCenterArea() {
    final templatesAsync = ref.watch(templatesListProvider);
    final uploadedKeys = ref.watch(uploadedFileKeysProvider);

    return Column(
      children: [
        // Carousel
        Expanded(
          child: templatesAsync.when(
            data: (templates) {
              if (templates.isEmpty) {
                return const Center(
                  child: Text(
                    'No templates available',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (ref.read(selectedTemplateNameProvider) == null &&
                    templates.isNotEmpty) {
                  ref.read(selectedTemplateNameProvider.notifier).state =
                      templates[_currentIndex].name;
                  ref.read(selectedTemplateProvider.notifier).state =
                      templates[_currentIndex];
                }
              });

              return LayoutBuilder(
                builder: (context, constraints) {
                  // Shrink carousel to ~75% of available height to match Figma
                  final carouselHeight = constraints.maxHeight * 0.78;
                  final cardWidth = carouselHeight * (9 / 16);
                  const desiredGap = 20.0;
                  double dynamicFraction =
                      (cardWidth + desiredGap) / constraints.maxWidth;
                  dynamicFraction = dynamicFraction.clamp(0.15, 0.55);

                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Center(
                        child: CarouselSlider.builder(
                          carouselController: _carouselController,
                          itemCount: templates.length,
                          options: CarouselOptions(
                            height: carouselHeight,
                            enlargeCenterPage: true,
                            viewportFraction: dynamicFraction,
                            enableInfiniteScroll: true,
                            enlargeFactor: 0.18,
                            clipBehavior: Clip.none,
                            onPageChanged: (index, reason) {
                              setState(() => _currentIndex = index);
                              ref
                                  .read(selectedTemplateNameProvider.notifier)
                                  .state = templates[index]
                                  .name;
                              ref
                                      .read(selectedTemplateProvider.notifier)
                                      .state =
                                  templates[index];
                            },
                          ),
                          itemBuilder: (context, index, realIndex) {
                            final template = templates[index];
                            double diff = (_currentIndex - index)
                                .abs()
                                .toDouble();
                            if (diff > templates.length / 2) {
                              diff = templates.length - diff;
                            }
                            const double fade = 0.6;
                            final fadeOpacity = (diff * fade).clamp(0.0, fade);

                            return Center(
                              child: AspectRatio(
                                aspectRatio: 9 / 16,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey[900],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CarouselVideoPlayer(
                                        isSelected: _currentIndex == index,
                                        videoUrl: template.previewUrl,
                                        thumbnailUrl: '',
                                      ),
                                      // Credit badge
                                      Positioned(
                                        top: 11,
                                        right: 9,
                                        child: Row(
                                          children: [
                                            Text(
                                              '${template.credits}',
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 10,
                                                    color: Color.fromARGB(
                                                      150,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            SvgPicture.asset(
                                              'assets/icons/credit.svg',
                                              width: 12,
                                              height: 12,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    AppColors.textPrimary,
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Fade overlay for non-center items
                                      IgnorePointer(
                                        child: Container(
                                          color: AppColors.background
                                              .withValues(alpha: fadeOpacity),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Left arrow — flip the SVG (it points right by default)
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _CarouselArrow(
                            svgAsset: 'assets/icons/carousel_arrow.svg',
                            flipped: true,
                            onTap: () => _carouselController.previousPage(),
                          ),
                        ),
                      ),

                      // Right arrow — natural direction
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _CarouselArrow(
                            svgAsset: 'assets/icons/carousel_arrow.svg',
                            flipped: false,
                            onTap: () => _carouselController.nextPage(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (err, _) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),

        // Prompt input area
        _buildPromptInput(uploadedKeys),
      ],
    );
  }

  Widget _buildPromptInput(List<String> uploadedKeys) {
    final selectedTemplate = ref.watch(selectedTemplateProvider);
    final reelCount = ref.watch(reelCountProvider).toInt();
    final totalCost = selectedTemplate != null
        ? selectedTemplate.credits * reelCount
        : 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(48, 0, 48, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (uploadedKeys.isNotEmpty) ...[
            SizedBox(
              height: 60,
              child: ListView.builder(
                controller: _fileScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: uploadedKeys.length,
                itemBuilder: (context, index) {
                  final key = uploadedKeys[index];
                  final ext = key.split('.').last;
                  return _buildFileChip(ext, key, () {
                    ref.read(uploadedFileKeysProvider.notifier).update((state) {
                      final updated = [...state];
                      if (index >= 0 && index < updated.length) {
                        updated.removeAt(index);
                      }
                      return updated;
                    });
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: _promptController,
            minLines: 1,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Input prompt...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 12),
            ),
          ),
          Row(
            children: [
              // Upload button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadFile,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: _isUploading
                          ? const AppLoadingIndicator(size: 24, strokeWidth: 2)
                          : const Icon(
                              Icons.add,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Generate button with cost
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (_isUploading || _isGenerating)
                      ? null
                      : _startGeneration,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface1,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$totalCost',
                                style: const TextStyle(
                                  color: AppColors.surface1,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileChip(String type, String key, VoidCallback onRemove) {
    Color bottomColor;
    switch (type.toLowerCase()) {
      case 'pdf':
        bottomColor = const Color(0xFFFF6961);
        break;
      case 'pptx':
        bottomColor = const Color(0xFFFFB347);
        break;
      case 'docx':
      case 'doc':
        bottomColor = const Color(0xFF779ECB);
        break;
      case 'txt':
        bottomColor = Colors.green;
        break;
      default:
        bottomColor = Colors.grey;
    }

    final filename = key.split('/').last;

    return Container(
      width: 50,
      height: 56,
      margin: const EdgeInsets.only(right: 10),
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
            Container(color: AppColors.surface2),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, size: 11, color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Text(
                type.toLowerCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              left: 6,
              right: 6,
              child: Text(
                filename,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── RIGHT: Configuration Panel ───────────────────────────────────────

  Widget _buildConfigurationPanel() {
    final avatarsAsync = ref.watch(avatarsListProvider);
    final selectedNames = ref.watch(selectedAvatarNamesProvider);
    final selectedTemplate = ref.watch(selectedTemplateProvider);
    final reelCount = ref.watch(reelCountProvider);
    final totalCost = selectedTemplate != null
        ? selectedTemplate.credits * reelCount.toInt()
        : 0;

    return Container(
      color: AppColors.surface1,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Configuration',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // Reel count slider — thin track
          _buildReelSlider(reelCount),
          const SizedBox(height: 24),

          // Avatar selection grid
          Expanded(child: _buildAvatarGrid(avatarsAsync, selectedNames)),
          const SizedBox(height: 16),

          // Cost breakdown
          _buildCostBreakdown(selectedTemplate, reelCount.toInt(), totalCost),
        ],
      ),
    );
  }

  Widget _buildReelSlider(double value) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.neonGreen,
            inactiveTrackColor: AppColors.surface3,
            thumbColor: AppColors.textPrimary,
            trackHeight: 4, // thinner to match Figma
            tickMarkShape: SliderTickMarkShape.noTickMark,
            overlayShape: SliderComponentShape.noOverlay,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 7,
            divisions: 6,
            onChanged: (val) {
              ref.read(reelCountProvider.notifier).state = val;
            },
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${value.toInt()} reels',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarGrid(AsyncValue avatarsAsync, Set<String> selectedNames) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surface3, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Search field
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _avatarSearchController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              onChanged: (val) => setState(() => _avatarSearchQuery = val),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'search for avatars...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Avatar grid — 4 columns to match Figma, with scrollbar
          Expanded(
            child: avatarsAsync.when(
              data: (avatars) {
                final filtered = _avatarSearchQuery.isEmpty
                    ? avatars
                    : avatars
                          .where(
                            (a) => a.name.toLowerCase().contains(
                              _avatarSearchQuery.toLowerCase(),
                            ),
                          )
                          .toList();

                return Scrollbar(
                  thumbVisibility: true,
                  child: GridView.builder(
                    padding: const EdgeInsets.only(right: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final avatar = filtered[index];
                      final isSelected = selectedNames.contains(avatar.name);

                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            final current = ref.read(
                              selectedAvatarNamesProvider,
                            );
                            if (current.contains(avatar.name)) {
                              ref
                                  .read(selectedAvatarNamesProvider.notifier)
                                  .state = {...current}
                                ..remove(avatar.name);
                            } else {
                              ref
                                  .read(selectedAvatarNamesProvider.notifier)
                                  .state = {...current}
                                ..add(avatar.name);
                            }
                          },
                          // Selection style matching mobile: white ring + green checkmark
                          child: AnimatedScale(
                            scale: isSelected ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 0),
                              margin: EdgeInsets.all(isSelected ? 0.0 : 1.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: isSelected ? 2.5 : 1.0,
                                ),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.background,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: SafeNetworkImage(
                                      avatar.staticFaceUrl ??
                                          avatar.faceUrl ??
                                          '',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.neonGreen,
                                          shape: BoxShape.circle,
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/icons/checkmark.svg',
                                          width: 8,
                                          height: 8,
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.surface1,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (err, _) =>
                  const Center(child: Icon(Icons.error, color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdown(
    dynamic selectedTemplate,
    int reelCount,
    int totalCost,
  ) {
    final templateCost = selectedTemplate?.credits ?? 0;

    return Column(
      children: [
        // Wrap only the top rows in padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              _costRow('template cost:', '$templateCost', showCredit: true),
              const SizedBox(height: 8),
              _costRow('number of reels:', 'x$reelCount', showCredit: false),
            ],
          ),
        ),

        // Divider is now free to span the full width of the parent container
        Divider(color: AppColors.surface3, height: 24, thickness: 1),

        // Wrap the bottom row in padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _costRow(
            'total:',
            '$totalCost',
            showCredit: true,
            isBold: true,
          ),
        ),
      ],
    );
  }

  Widget _costRow(
    String label,
    String value, {
    bool showCredit = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (showCredit) ...[
              const SizedBox(width: 4),
              SvgPicture.asset(
                'assets/icons/credit.svg',
                width: 10,
                height: 10,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CarouselArrow extends StatefulWidget {
  final String svgAsset;
  final bool flipped;
  final VoidCallback onTap;

  const _CarouselArrow({
    required this.svgAsset,
    required this.flipped,
    required this.onTap,
  });

  @override
  State<_CarouselArrow> createState() => _CarouselArrowState();
}

class _CarouselArrowState extends State<_CarouselArrow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? AppColors.surface3
                : AppColors.surface2.withValues(alpha: 0.8),
          ),
          child: Center(
            child: Transform.flip(
              flipX: widget.flipped,
              child: SvgPicture.asset(
                widget.svgAsset,
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
      ),
    );
  }
}

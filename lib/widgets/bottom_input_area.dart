import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants.dart';
import '../ui_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/video_service.dart';

class BottomInputArea extends ConsumerStatefulWidget {
  const BottomInputArea({super.key, this.onHeightChanged});

  final ValueChanged<double>? onHeightChanged;

  @override
  ConsumerState<BottomInputArea> createState() => _BottomInputAreaState();
}

class _BottomInputAreaState extends ConsumerState<BottomInputArea> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _promptController = TextEditingController();
  bool _isUploading = false;
  bool _isGenerating = false;
  double? _lastReportedHeight;

  @override
  void dispose() {
    _scrollController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'docx', 'pptx'],
    );

    if (result != null) {
      setState(() => _isUploading = true);
      try {
        final pickedFile = result.files.single;
        final videoService = ref.read(videoServiceProvider);
        final String key;
        if (kIsWeb) {
          key = await videoService.uploadFileBytes(
            pickedFile.bytes!,
            pickedFile.name,
          );
        } else {
          final file = File(pickedFile.path!);
          key = await videoService.uploadFile(file);
        }

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
        ref.read(selectedSeriesProvider.notifier).state = null;
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
    final uploadedKeys = ref.watch(uploadedFileKeysProvider);
    final selectedTemplate = ref.watch(selectedTemplateProvider);
    final reelCount = ref.watch(reelCountProvider).toInt();
    final totalCost = selectedTemplate != null
        ? selectedTemplate.credits * reelCount
        : 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.onHeightChanged == null) return;
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox) return;
      final height = renderObject.size.height;
      if (_lastReportedHeight == null ||
          (height - _lastReportedHeight!).abs() > 1) {
        _lastReportedHeight = height;
        widget.onHeightChanged!(height);
      }
    });

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (uploadedKeys.isNotEmpty) ...[
              SizedBox(
                height: 60,
                child: RawScrollbar(
                  controller: _scrollController,
                  thumbColor: AppColors.surface4,
                  radius: const Radius.circular(8),
                  thickness: 3,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: uploadedKeys.length,
                    itemBuilder: (context, index) {
                      final key = uploadedKeys[index];
                      final ext = key.split('.').last;
                      return _buildFilePreview(
                        type: ext,
                        key: key,
                        onRemove: () {
                          ref
                              .read(uploadedFileKeysProvider.notifier)
                              .update((state) {
                            final updated = [...state];
                            if (index >= 0 && index < updated.length) {
                              updated.removeAt(index);
                            }
                            return updated;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _promptController,
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
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: "Input prompt...",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 12),
                ),
              ),
            ),
            Row(
              children: [
                _buildUploadButton(),
                const Spacer(),
                SizedBox(
                  width: 75,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: AppColors.surface1,
                      disabledBackgroundColor: AppColors.neonGreen,
                      disabledForegroundColor: AppColors.surface1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: (_isUploading || _isGenerating)
                        ? () {}
                        : _startGeneration,
                    child: _isGenerating
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.surface1,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$totalCost",
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
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Material(
      color: AppColors.surface1,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _isUploading ? null : _pickAndUploadFile,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: _isUploading
                ? const AppLoadingIndicator(size: 24, strokeWidth: 2)
                : const Icon(Icons.add, color: AppColors.textPrimary, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview({
    required String type,
    required String key,
    required VoidCallback onRemove,
  }) {
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
            Container(
              color: AppColors.surface2,
              child: Center(
                child: Icon(
                  _getIconForType(type),
                  color: Colors.white24,
                  size: 24,
                ),
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
                  child: const Icon(
                    Icons.close,
                    size: 11,
                    color: Colors.white,
                  ),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 5.0,
                    left: 6.0,
                    right: 6.0,
                  ),
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
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'pptx':
        return Icons.slideshow;
      case 'docx':
      case 'doc':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}

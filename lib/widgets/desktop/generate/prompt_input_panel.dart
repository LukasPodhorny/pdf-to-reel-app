import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import '../../../constants.dart';
import '../../../ui_providers.dart';
import '../../../services/video_service.dart';

/// Prompt text field, uploaded-file chip strip, upload button, generate button.
/// Self-contained: owns the text controller, upload/generate state, and
/// the upload/generate callbacks.
class PromptInputPanel extends ConsumerStatefulWidget {
  const PromptInputPanel({super.key});

  @override
  ConsumerState<PromptInputPanel> createState() => _PromptInputPanelState();
}

class _PromptInputPanelState extends ConsumerState<PromptInputPanel> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _fileScrollController = ScrollController();
  bool _isUploading = false;
  bool _isGenerating = false;

  @override
  void dispose() {
    _promptController.dispose();
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
        ref.read(selectedSeriesProvider.notifier).state = null;
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
    final uploadedKeys = ref.watch(uploadedFileKeysProvider);
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
                  return _FileChip(
                    type: ext,
                    fileKey: key,
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
              _UploadButton(
                isUploading: _isUploading,
                onTap: _pickAndUploadFile,
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (_isUploading || _isGenerating)
                      ? null
                      : _startGeneration,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 75),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: const ShapeDecoration(
                      color: AppColors.neonGreen,
                      shape: StadiumBorder(),
                    ),
                    child: SizedBox(
                      height: 19,
                      child: _isGenerating
                          ? const Center(
                              child: SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.surface1,
                                ),
                              ),
                            )
                          : Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$totalCost',
                                    style: const TextStyle(
                                      color: AppColors.surface1,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      height: 1.0,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final String type;
  final String fileKey;
  final VoidCallback onRemove;

  const _FileChip({
    required this.type,
    required this.fileKey,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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

    final filename = fileKey.split('/').last;

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
}

class _UploadButton extends StatefulWidget {
  final bool isUploading;
  final VoidCallback onTap;

  const _UploadButton({required this.isUploading, required this.onTap});

  @override
  State<_UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<_UploadButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isUploading ? null : widget.onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.surface2 : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: widget.isUploading
                ? const AppLoadingIndicator(size: 24, strokeWidth: 2)
                : const Icon(Icons.add, color: AppColors.textPrimary, size: 24),
          ),
        ),
      ),
    );
  }
}

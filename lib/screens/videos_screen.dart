import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdftoreel/screens/video_player_screen.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../models/reel_models.dart';
import '../widgets/video_card.dart';
import '../widgets/generating_thumbnail.dart';
import '../widgets/responsive_grid_delegate.dart';
import '../safe_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/video_service.dart';
import '../widgets/action_pill_button.dart';

class VideosScreen extends ConsumerStatefulWidget {
  const VideosScreen({super.key});

  @override
  ConsumerState<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends ConsumerState<VideosScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _updatePolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _updatePolling() {
    final isGenerateMode = ref.read(isGenerateModeProvider);

    // Stop polling if in generate mode
    if (isGenerateMode) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }

    // Start polling if not already running
    if (_pollTimer == null || !_pollTimer!.isActive) {
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    // Poll every 5 seconds to check for updates
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshIfNeeded();
    });
  }

  void _refreshIfNeeded() {
    final seriesList = ref.read(seriesListProvider);

    seriesList.whenData((list) {
      // Check if any series or their reels are still generating or failed
      final needsRefresh = list.any(
        (series) =>
            series.status != JobStatus.done ||
            series.reels.any((reel) => reel.status != JobStatus.done),
      );

      if (needsRefresh) {
        // Store the selected series ID if viewing one
        final selectedSeriesId = ref.read(selectedSeriesProvider)?.id;

        // Invalidate the provider to trigger a refresh
        ref.invalidate(seriesListProvider);

        // Schedule a post-frame callback to update selected series with new data
        if (selectedSeriesId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final newList = ref.read(seriesListProvider);
            newList.whenData((newData) {
              final updatedSeries = newData
                  .where((s) => s.id == selectedSeriesId)
                  .firstOrNull;
              if (updatedSeries != null) {
                ref.read(selectedSeriesProvider.notifier).state = updatedSeries;
              }
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedSeries = ref.watch(selectedSeriesProvider);

    // Watch for changes in generate mode to update polling
    ref.watch(isGenerateModeProvider);

    // Update polling when generate mode changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePolling();
    });

    return PopScope(
      canPop: selectedSeries == null,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // If the route didn't pop, it means we are in the reels grid.
        // Clear the selected series to navigate back to the series grid!
        ref.read(selectedSeriesProvider.notifier).state = null;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedSeries != null)
                      Transform.translate(
                        offset: const Offset(
                          -12,
                          0,
                        ), // Aligns the icon visually with the text below
                        child: IconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/arrow.svg',
                            height: 15,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () {
                            ref.read(selectedSeriesProvider.notifier).state =
                                null;
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (selectedSeries == null)
                            const SizedBox(height: 48),
                          Text(
                            _getHeaderTitle(selectedSeries),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: selectedSeries != null
                    ? _buildReelsGrid(context, selectedSeries)
                    : _buildSeriesGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header title at the top of the screen
  String _getHeaderTitle(VideoSeries? series) {
    if (series == null) return 'All reels';
    if (series.status == JobStatus.failed &&
        (series.topic == null || series.topic!.isEmpty)) {
      return 'Failed';
    }
    if (series.topic == null || series.topic!.isEmpty) {
      return 'Generating...';
    }
    return series.topic!;
  }

  // Title displayed on the series card
  String _getSeriesCardTitle(VideoSeries series) {
    // Failed without topic
    if (series.status == JobStatus.failed &&
        (series.topic == null || series.topic!.isEmpty)) {
      return 'Failed';
    }
    // Generating without topic
    if (series.topic == null || series.topic!.isEmpty) {
      return 'Generating...';
    }
    return series.topic!;
  }

  // Subtitle for series card
  String _getSeriesCardSubtitle(VideoSeries series) {
    if (series.status == JobStatus.failed) {
      return 'Failed';
    }
    return '${series.reels.length} reels';
  }

  // Title displayed on the reel card
  String _getReelCardTitle(Reel reel) {
    // Failed without title
    if (reel.status == JobStatus.failed &&
        (reel.title == null || reel.title!.isEmpty)) {
      return 'Failed';
    }
    // Generating without title
    if (reel.title == null || reel.title!.isEmpty) {
      return 'Generating...';
    }
    return reel.title!;
  }

  // Subtitle for reel card
  String _getReelCardSubtitle(Reel reel) {
    // Show duration if available and done
    if (reel.status == JobStatus.done &&
        reel.duration != null &&
        reel.duration!.isNotEmpty) {
      return reel.duration!;
    }
    // Show status if not done
    if (reel.status != JobStatus.done) {
      return _formatStatus(reel.status);
    }
    return '';
  }

  String _formatStatus(JobStatus status) {
    switch (status) {
      case JobStatus.queued:
        return 'Queued';
      case JobStatus.processing:
        return 'Processing...';
      case JobStatus.done:
        return '';
      case JobStatus.failed:
        return 'Failed';
    }
  }

  // Check if series is still generating (not done yet, excluding failed)
  bool _isSeriesGenerating(VideoSeries series) {
    return series.status != JobStatus.done && series.status != JobStatus.failed;
  }

  // Check if reel is still generating (not done yet, excluding failed)
  bool _isReelGenerating(Reel reel) {
    return reel.status != JobStatus.done && reel.status != JobStatus.failed;
  }

  Widget _buildSeriesGrid() {
    final seriesAsync = ref.watch(seriesListProvider);

    return seriesAsync.when(
      data: (seriesList) {
        if (seriesList.isEmpty) {
          return _buildEmptyReelsState();
        }

        return GridView.builder(
          key: const ValueKey('seriesGrid'),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          gridDelegate: const ResponsiveGridDelegate(
            minItemWidth: 180,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.6,
            minColumns: 2,
            maxColumns: 6,
          ),
          itemCount: seriesList.length,
          itemBuilder: (context, index) {
            final series = seriesList[index];
            final isGenerating = _isSeriesGenerating(series);
            final isFailed = series.status == JobStatus.failed;
            final hasThumbnail =
                series.thumbnailUrl != null && series.thumbnailUrl!.isNotEmpty;

            return Stack(
              fit: StackFit.expand,
              children: [
                if (isFailed)
                  // Failed: always show placeholder icon regardless of thumbnail
                  VideoCardPlaceholder(
                    title: _getSeriesCardTitle(series),
                    subtitle: _getSeriesCardSubtitle(series),
                    isFailed: true,
                  )
                else if (isGenerating && !hasThumbnail)
                  // Generating without thumbnail: show animated gradient
                  GeneratingThumbnailWithOverlay(
                    title: _getSeriesCardTitle(series),
                    subtitle: _getSeriesCardSubtitle(series),
                    titleFontSize: 16.0,
                  )
                else if (isGenerating && hasThumbnail)
                  // Generating WITH thumbnail: show thumbnail with gradient overlay animation
                  ThumbnailWithGeneratingOverlay(
                    thumbnailUrl: series.thumbnailUrl!,
                    title: _getSeriesCardTitle(series),
                    subtitle: _getSeriesCardSubtitle(series),
                    titleFontSize: 16.0,
                  )
                else if (!hasThumbnail)
                  // Done but missing thumbnail: show placeholder icon
                  VideoCardPlaceholder(
                    title: _getSeriesCardTitle(series),
                    subtitle: _getSeriesCardSubtitle(series),
                  )
                else
                  // Done with thumbnail: show actual thumbnail
                  VideoCard(
                    thumbnailUrl: series.thumbnailUrl!,
                    title: _getSeriesCardTitle(series),
                    subtitle: _getSeriesCardSubtitle(series),
                  ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        ref.read(selectedSeriesProvider.notifier).state =
                            series;
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (err, stack) => Center(
        child: Text(
          'Error loading reels: $err',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildEmptyReelsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.video_collection_outlined,
                  size: 38,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No reels yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your first video in Generate mode and it will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ActionPillButton(
                  text: 'Generate your first reel',
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  borderColor: AppColors.textSecondary,
                  onPressed: () {
                    ref.read(isGenerateModeProvider.notifier).state = true;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReelsGrid(BuildContext context, VideoSeries series) {
    return GridView.builder(
      key: const ValueKey('reelsGrid'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const ResponsiveGridDelegate(
        minItemWidth: 180,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.6,
        minColumns: 2,
        maxColumns: 6,
      ),
      itemCount: series.reels.length,
      itemBuilder: (context, index) {
        final reel = series.reels[index];
        final isGenerating = _isReelGenerating(reel);
        final isFailed = reel.status == JobStatus.failed;
        final hasThumbnail =
            reel.thumbnailUrl != null && reel.thumbnailUrl!.isNotEmpty;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (isFailed)
              // Failed: show placeholder with red tint
              VideoCardPlaceholder(
                title: _getReelCardTitle(reel),
                subtitle: _getReelCardSubtitle(reel),
                titleFontSize: 14.0,
                isFailed: true,
              )
            else if (isGenerating && !hasThumbnail)
              // Generating without thumbnail: show animated gradient
              GeneratingThumbnailWithOverlay(
                title: _getReelCardTitle(reel),
                subtitle: _getReelCardSubtitle(reel),
                titleFontSize: 14.0,
              )
            else if (isGenerating && hasThumbnail)
              // Generating WITH thumbnail: show thumbnail with gradient overlay animation
              ThumbnailWithGeneratingOverlay(
                thumbnailUrl: reel.thumbnailUrl!,
                title: _getReelCardTitle(reel),
                subtitle: _getReelCardSubtitle(reel),
                titleFontSize: 14.0,
              )
            else if (!hasThumbnail)
              // Done but missing thumbnail: show placeholder icon
              VideoCardPlaceholder(
                title: _getReelCardTitle(reel),
                subtitle: _getReelCardSubtitle(reel),
                titleFontSize: 14.0,
              )
            else
              // Done with thumbnail: show actual thumbnail
              VideoCard(
                thumbnailUrl: reel.thumbnailUrl!,
                title: _getReelCardTitle(reel),
                subtitle: _getReelCardSubtitle(reel),
                titleFontSize: 14.0,
              ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  onTap: reel.status == JobStatus.done
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoPlayerScreen(reel: reel),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget for thumbnail with generating overlay (gradient animation on top of thumbnail)
class ThumbnailWithGeneratingOverlay extends StatelessWidget {
  final String thumbnailUrl;
  final String title;
  final String subtitle;
  final double titleFontSize;

  const ThumbnailWithGeneratingOverlay({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.subtitle,
    this.titleFontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base thumbnail image
          SafeNetworkImage(thumbnailUrl, fit: BoxFit.cover),
          // Semi-transparent animated gradient overlay
          const GeneratingThumbnail(opacity: 0.4),
          // Dark gradient at bottom for text
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color.fromARGB(180, 0, 0, 0)],
                stops: [0.3, 1.0],
              ),
            ),
          ),
          // Text overlay
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    height: 1.1,
                    shadows: const [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 10.0,
                        color: Color.fromARGB(150, 0, 0, 0),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      shadows: [
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 10.0,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for generating state with animated thumbnail and text overlay
class GeneratingThumbnailWithOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final double titleFontSize;

  const GeneratingThumbnailWithOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleFontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const GeneratingThumbnail(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color.fromARGB(146, 0, 0, 0)],
                stops: [0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    height: 1.1,
                    shadows: const [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 10.0,
                        color: Color.fromARGB(150, 0, 0, 0),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      shadows: [
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 10.0,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for done state but missing thumbnail - shows placeholder icon
class VideoCardPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  final double titleFontSize;
  final bool isFailed;

  const VideoCardPlaceholder({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleFontSize = 16.0,
    this.isFailed = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: isFailed
                ? AppColors.surface2.withRed(65) // Add red tint for failed
                : AppColors.surface2,
            child: Center(
              child: Icon(
                isFailed ? Icons.error_outline : Icons.broken_image_outlined,
                size: 48,
                color: isFailed
                    ? Colors.red.withAlpha(180)
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color.fromARGB(146, 0, 0, 0)],
                stops: [0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    height: 1.1,
                    shadows: const [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 10.0,
                        color: Color.fromARGB(150, 0, 0, 0),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isFailed
                          ? Colors.red.withAlpha(200)
                          : AppColors.textPrimary,
                      fontSize: 12,
                      shadows: const [
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 10.0,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

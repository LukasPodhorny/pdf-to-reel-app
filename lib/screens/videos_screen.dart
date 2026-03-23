import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdftoreel/screens/video_player_screen.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../models/reel_models.dart';
import '../widgets/video_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VideosScreen extends ConsumerWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSeries = ref.watch(selectedSeriesProvider);

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
                            selectedSeries?.title ?? 'All reels',
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
                    : _buildSeriesGrid(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesGrid(WidgetRef ref) {
    return GridView.builder(
      key: const ValueKey('seriesGrid'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemCount: mockSeriesList.length,
      itemBuilder: (context, index) {
        final series = mockSeriesList[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            VideoCard(
              thumbnailUrl: series.thumbnailUrl,
              title: series.title,
              subtitle: '${series.reels.length} reels',
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Adjust to match VideoCard's corner radius
                  onTap: () {
                    ref.read(selectedSeriesProvider.notifier).state = series;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReelsGrid(BuildContext context, VideoSeries series) {
    return GridView.builder(
      key: const ValueKey('reelsGrid'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemCount: series.reels.length,
      itemBuilder: (context, index) {
        final reel = series.reels[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            VideoCard(
              thumbnailUrl: reel.thumbnailUrl,
              title: reel.title,
              subtitle: reel.duration,
              titleFontSize: 14.0,
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(reel: reel),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

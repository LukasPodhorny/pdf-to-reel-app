class Reel {
  final String id;
  final String? title;
  final String? duration;
  final String thumbnailUrl;
  final String videoUrl;

  Reel({
    required this.id,
    this.title,
    this.duration,
    required this.thumbnailUrl,
    required this.videoUrl,
  });
}

class VideoSeries {
  final String id;
  final String? title;
  final List<Reel> reels;
  final String thumbnailUrl;

  VideoSeries({
    required this.id,
    this.title,
    required this.reels,
    required this.thumbnailUrl,
  });
}

// Mock Data
final List<VideoSeries> mockSeriesList = [
  VideoSeries(
    id: '1',
    title: 'Explaining Photosynthesis',
    thumbnailUrl: 'https://picsum.photos/seed/biden1/400/800',
    reels: [
      Reel(
        id: 'r1',
        title: 'Chloroplasts and stomata',
        duration: '2:31',
        thumbnailUrl: 'https://picsum.photos/seed/biden1/400/800',
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      ),
      Reel(
        id: 'r2',
        title: 'Chloroplasts and stomata',
        duration: '2:31',
        thumbnailUrl: 'https://picsum.photos/seed/biden2/400/800',
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      ),
      Reel(
        id: 'r3',
        title: 'Chloroplasts and stomata',
        duration: '2:31',
        thumbnailUrl: 'https://picsum.photos/seed/biden3/400/800',
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      ),
    ],
  ),
  VideoSeries(
    id: '2',
    title: 'Explaining Photosynthesis',
    thumbnailUrl: 'https://picsum.photos/seed/biden4/400/800',
    reels: [
      Reel(
        id: 'r4',
        title: 'Light Reactions',
        duration: '1:45',
        thumbnailUrl: 'https://picsum.photos/seed/biden4/400/800',
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      ),
    ],
  ),
];

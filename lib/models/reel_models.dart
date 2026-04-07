enum JobStatus {
  queued,
  processing,
  done,
  failed;

  static JobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'queued':
        return JobStatus.queued;
      case 'processing':
        return JobStatus.processing;
      case 'done':
        return JobStatus.done;
      case 'failed':
        return JobStatus.failed;
      default:
        return JobStatus.failed;
    }
  }
}

class Reel {
  final int id;
  final int sequenceNumber;
  final JobStatus status;
  final String? cloudflareR2Url;
  final String? localPath;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? duration;

  Reel({
    required this.id,
    required this.sequenceNumber,
    required this.status,
    this.cloudflareR2Url,
    this.localPath,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.duration,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'],
      sequenceNumber: json['sequence_number'],
      status: JobStatus.fromString(json['status']),
      cloudflareR2Url: json['cloudflare_r2_url'],
      localPath: json['local_path'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      duration: json['duration'],
    );
  }
}

class VideoSeries {
  final int id;
  final String userId;
  final DateTime createdAt;
  final JobStatus status;
  final String? topic;
  final String? thumbnailUrl;
  final List<Reel> reels;

  VideoSeries({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.status,
    this.topic,
    this.thumbnailUrl,
    required this.reels,
  });

  factory VideoSeries.fromJson(Map<String, dynamic> json) {
    return VideoSeries(
      id: json['id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      status: JobStatus.fromString(json['status']),
      topic: json['topic'],
      thumbnailUrl: json['thumbnail_url'],
      reels: (json['reels'] as List).map((r) => Reel.fromJson(r)).toList(),
    );
  }

  String get displayTitle => topic ?? 'Generation #$id';
  
  String? get firstVideoUrl {
    for (var reel in reels) {
      if (reel.cloudflareR2Url != null) return reel.cloudflareR2Url;
    }
    return null;
  }
}

class UserProfile {
  final String id;
  final String? email;
  final int credits;

  UserProfile({
    required this.id,
    this.email,
    required this.credits,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      credits: json['credits'],
    );
  }
}

class VideoTemplate {
  final int id;
  final String name;
  final int credits;
  final String previewUrl;

  VideoTemplate({
    required this.id,
    required this.name,
    required this.credits,
    required this.previewUrl,
  });

  factory VideoTemplate.fromJson(Map<String, dynamic> json) {
    return VideoTemplate(
      id: json['id'],
      name: json['name'],
      credits: json['credits'] ?? 1,
      previewUrl: json['preview_url'] ?? '',
    );
  }
}

class Avatar {
  final int id;
  final String name;
  final Map<String, dynamic> data;

  Avatar({
    required this.id,
    required this.name,
    required this.data,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['id'],
      name: json['name'],
      data: json['data'],
    );
  }

  String? get faceUrl {
    final face = data['face_url'];
    if (face is Map) return face['url'];
    return face as String?;
  }

  String? get staticFaceUrl {
    final face = data['static_face_url'];
    if (face is Map) return face['url'];
    return face as String?;
  }
}

class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelName;
  final String channelImageUrl;
  final String viewCount;
  final String publishedAt;
  final Duration duration;

  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelName,
    required this.channelImageUrl,
    required this.viewCount,
    required this.publishedAt,
    required this.duration,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      channelName: json['channelName'],
      channelImageUrl: json['channelImageUrl'],
      viewCount: json['viewCount'],
      publishedAt: json['publishedAt'],
      duration: Duration(seconds: json['duration']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'channelName': channelName,
      'channelImageUrl': channelImageUrl,
      'viewCount': viewCount,
      'publishedAt': publishedAt,
      'duration': duration.inSeconds,
    };
  }
}

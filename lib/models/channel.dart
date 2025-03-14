class Channel {
  final String id;
  final String name;
  final String imageUrl;
  final String channelUrl;
  List<Video> videos;

  Channel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.channelUrl,
    this.videos = const [],
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      channelUrl: json['channelUrl'],
      videos: json['videos'] != null
          ? List<Video>.from(json['videos'].map((x) => Video.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'channelUrl': channelUrl,
      'videos': videos.map((x) => x.toJson()).toList(),
    };
  }
}

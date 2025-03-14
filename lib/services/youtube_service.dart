class YouTubeService {
  static String _apiKey = 'YOUR_API_KEY'; // Add your YouTube Data API key here
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  // Extract channel ID from URL
  static String? extractChannelId(String url) {
    RegExp regExp;

    // youtube.com/channel/UC...
    regExp = RegExp(r'youtube\.com\/channel\/([\w-]+)');
    var match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    // youtube.com/@username format (new format)
    regExp = RegExp(r'youtube\.com\/@([\w\.-]+)');
    match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      String username = match.group(1) ?? '';
      // We'll handle this by looking up the channel by custom URL
      print('Found username: $username from new @username format');
      return '@$username'; // Return with @ to indicate this is a custom URL/handle
    }

    // youtube.com/c/username or youtube.com/user/username (older formats)
    regExp = RegExp(r'youtube\.com\/(c|user)\/([^\/\?]+)');
    match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 2) {
      String username = match.group(2) ?? '';
      print('Found username: $username from c/ or user/ format');
      // Need to use channel lookup by username API
      return 'user/$username'; // Return with prefix to indicate lookup method
    }

    return null;
  }

  // Fetch channel info by ID or custom URL
  static Future<Channel?> fetchChannelInfo(String channelIdOrUsername) async {
    try {
      String endpoint;

      if (channelIdOrUsername.startsWith('@')) {
        // Handle @username format (new format)
        String username = channelIdOrUsername.substring(1); // Remove the @ prefix
        endpoint = '$_baseUrl/search?part=snippet&q=$username&type=channel&key=$_apiKey';

        final response = await http.get(Uri.parse(endpoint));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['items'] != null && data['items'].isNotEmpty) {
            // Get the channel ID from search results
            final channelId = data['items'][0]['snippet']['channelId'];
            // Now fetch the channel details with this ID
            return await fetchChannelInfoById(channelId);
          }
        }
      } else if (channelIdOrUsername.startsWith('user/')) {
        // Handle username from /user/ format (older format)
        String username = channelIdOrUsername.substring(5); // Remove the user/ prefix
        endpoint = '$_baseUrl/channels?part=snippet,contentDetails&forUsername=$username&key=$_apiKey';

        final response = await http.get(Uri.parse(endpoint));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['items'] != null && data['items'].isNotEmpty) {
            final channelData = data['items'][0];
            final channelId = channelData['id'];
            final snippet = channelData['snippet'];

            return Channel(
              id: channelId,
              name: snippet['title'],
              imageUrl: snippet['thumbnails']['default']['url'],
              channelUrl: 'https://www.youtube.com/channel/$channelId',
              videos: [],
            );
          }
        }
      } else {
        // Direct channel ID
        return await fetchChannelInfoById(channelIdOrUsername);
      }

      return null;
    } catch (e) {
      print('Error fetching channel info: $e');
      return null;
    }
  }

  // Helper method to fetch channel by direct ID
  static Future<Channel?> fetchChannelInfoById(String channelId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/channels?part=snippet,contentDetails&id=$channelId&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final channelData = data['items'][0];
          final snippet = channelData['snippet'];

          return Channel(
            id: channelId,
            name: snippet['title'],
            imageUrl: snippet['thumbnails']['default']['url'],
            channelUrl: 'https://www.youtube.com/channel/$channelId',
            videos: [],
          );
        }
      }
      return null;
    } catch (e) {
      print('Error fetching channel info by ID: $e');
      return null;
    }
  }

  // Fetch videos for a channel
  static Future<List<Video>> fetchChannelVideos(Channel channel) async {
    try {
      // First, get playlist ID for uploads
      final response = await http.get(
        Uri.parse('$_baseUrl/channels?part=contentDetails&id=${channel.id}&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final uploadPlaylistId = data['items'][0]['contentDetails']['relatedPlaylists']['uploads'];

          // Now get videos from this playlist
          final videosResponse = await http.get(
            Uri.parse('$_baseUrl/playlistItems?part=snippet,contentDetails&maxResults=50&playlistId=$uploadPlaylistId&key=$_apiKey'),
          );

          if (videosResponse.statusCode == 200) {
            final videosData = json.decode(videosResponse.body);
            List<Video> videos = [];

            if (videosData['items'] != null) {
              // Get video IDs for fetching additional info
              final videoIds = videosData['items']
                  .map<String>((item) => item['contentDetails']['videoId'].toString())
                  .toList()
                  .join(',');

              // Get video details (duration, view count, etc.)
              final videoDetailsResponse = await http.get(
                Uri.parse('$_baseUrl/videos?part=contentDetails,statistics&id=$videoIds&key=$_apiKey'),
              );

              if (videoDetailsResponse.statusCode == 200) {
                final videoDetailsData = json.decode(videoDetailsResponse.body);
                final videoDetails = Map.fromIterable(
                  videoDetailsData['items'],
                  key: (item) => item['id'],
                  value: (item) => item,
                );

                // Create video objects
                for (var item in videosData['items']) {
                  final videoId = item['contentDetails']['videoId'];
                  final snippet = item['snippet'];
                  final details = videoDetails[videoId];

                  if (details != null) {
                    // Parse ISO 8601 duration
                    final durationString = details['contentDetails']['duration'];
                    final duration = _parseIsoDuration(durationString);

                    videos.add(Video(
                      id: videoId,
                      title: snippet['title'],
                      thumbnailUrl: snippet['thumbnails']['high']['url'],
                      channelName: channel.name,
                      channelImageUrl: channel.imageUrl,
                      viewCount: _formatViewCount(details['statistics']['viewCount']),
                      publishedAt: _formatPublishedDate(snippet['publishedAt']),
                      duration: duration,
                    ));
                  }
                }
              }
            }

            return videos;
          }
        }
      }
      return [];
    } catch (e) {
      print('Error fetching channel videos: $e');
      return [];
    }
  }

  // Parse ISO 8601 duration to Duration object
  static Duration _parseIsoDuration(String iso8601duration) {
    RegExp regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    Match? match = regex.firstMatch(iso8601duration);

    if (match != null) {
      int hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      int minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      int seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }

    return Duration.zero;
  }

  // Format view count
  static String _formatViewCount(String viewCountStr) {
    int viewCount = int.tryParse(viewCountStr) ?? 0;

    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    } else {
      return viewCount.toString();
    }
  }

  // Format published date
  static String _formatPublishedDate(String publishedAt) {
    DateTime publishDate = DateTime.parse(publishedAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(publishDate);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

import 'dart:convert';
import 'package:mytube/models/channel.dart';
import 'package:mytube/services/youtube_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelManager {
  static final ChannelManager _instance = ChannelManager._internal();
  factory ChannelManager() => _instance;
  ChannelManager._internal();

  List<Channel> _channels = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Channel> get channels => _channels;

  Future<void> loadChannels() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      // Load from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final channelsJson = prefs.getString('channels');

      if (channelsJson != null) {
        final List<dynamic> channelsList = json.decode(channelsJson);
        _channels = channelsList.map((e) => Channel.fromJson(e)).toList();

        // Fetch latest videos for each channel
        await refreshChannelVideos();
      }
    } catch (e) {
      print('Error loading channels: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> saveChannels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final channelsJson = json.encode(_channels.map((e) => e.toJson()).toList());
      await prefs.setString('channels', channelsJson);
    } catch (e) {
      print('Error saving channels: $e');
    }
  }

  Future<bool> addChannel(String channelUrl) async {
    if (_isLoading) return false;

    _isLoading = true;

    try {
      // Extract channel ID or username from URL
      String? channelIdOrUsername = YouTubeService.extractChannelId(channelUrl);

      if (channelIdOrUsername == null) {
        // If extraction failed, try to handle the URL as is
        // This helps with direct URLs like youtube.com/@Fireship
        if (channelUrl.contains('youtube.com/')) {
          // Extract the part after youtube.com/
          Uri uri = Uri.parse(channelUrl);
          String path = uri.path;
          if (path.startsWith('/')) {
            path = path.substring(1);
          }
          channelIdOrUsername = path;
        }
      }

      if (channelIdOrUsername != null) {
        // Fetch channel info
        Channel? channel = await YouTubeService.fetchChannelInfo(channelIdOrUsername);

        if (channel != null) {
          // Check if channel already exists
          if (_channels.any((c) => c.id == channel.id)) {
            return false;
          }

          // Fetch videos for the channel
          List<Video> videos = await YouTubeService.fetchChannelVideos(channel);
          channel.videos = videos;

          // Add to list and save
          _channels.add(channel);
          await saveChannels();

          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error adding channel: $e');
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refreshChannelVideos() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      for (int i = 0; i < _channels.length; i++) {
        List<Video> videos = await YouTubeService.fetchChannelVideos(_channels[i]);
        _channels[i].videos = videos;
      }

      await saveChannels();
    } catch (e) {
      print('Error refreshing videos: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> removeChannel(String channelId) async {
    if (_isLoading) return false;

    try {
      _channels.removeWhere((c) => c.id == channelId);
      await saveChannels();
      return true;
    } catch (e) {
      print('Error removing channel: $e');
      return false;
    }
  }

  List<Video> getAllVideos() {
    final List<Video> allVideos = [];

    for (var channel in _channels) {
      allVideos.addAll(channel.videos);
    }

    // Sort by published date (newest first)
    allVideos.sort((a, b) {
      // Convert relative time strings to approximate dates for sorting
      // This is a simple approach - for production, store actual DateTime objects
      final aWeight = _getTimeWeight(a?.publishedAt);
      final bWeight = _getTimeWeight(b?.publishedAt);
      return aWeight.compareTo(bWeight);
    });

    return allVideos;
  }

  // Helper to assign weight for sorting by published date
  int _getTimeWeight(String publishedAt) {
    if (publishedAt.contains('years'))
      return int.parse(publishedAt.split(' ')[0]) * 365;
    else if (publishedAt.contains('months'))
      return int.parse(publishedAt.split(' ')[0]) * 30;
    else if (publishedAt.contains('weeks'))
      return int.parse(publishedAt.split(' ')[0]) * 7;
    else if (publishedAt.contains('days'))
      return int.parse(publishedAt.split(' ')[0]);
    else if (publishedAt.contains('hours'))
      return 0;
    else
      return -1; // Most recent ("Just now" or "minutes ago")
  }
}

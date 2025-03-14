
import 'package:flutter/material.dart';
import 'package:mytube/models/channel.dart';
import 'package:mytube/services/channel_manager.dart';
import 'package:mytube/services/youtube_service.dart';
import 'package:mytube/widgets/adaptive_grid_card.dart';

class ChannelDetailPage extends StatefulWidget {
  final Channel channel;

  const ChannelDetailPage({super.key, required this.channel});

  @override
  _ChannelDetailPageState createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  bool _isLoading = false;

  Future<void> _refreshChannelVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      widget.channel.videos = await YouTubeService.fetchChannelVideos(widget.channel);
      await ChannelManager().saveChannels();
    } catch (e) {
      print('Error refreshing channel videos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshChannelVideos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Channel Header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1F1F1F),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.channel.imageUrl),
                  radius: 40,
                  backgroundColor: Colors.grey[800],
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.channel.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${widget.channel.videos.length} videos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Open in YouTube'),
                            onPressed: () {
                              // Open URL in browser (For a real app, use url_launcher package)
                              print('Opening ${widget.channel.channelUrl}');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Channel Videos
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
                : widget.channel.videos.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No videos available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : AdaptiveVideoGrid(videos: widget.channel.videos),
          ),
        ],
      ),
    );
  }
}
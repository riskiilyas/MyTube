
class HomeTab extends StatelessWidget {
  final ChannelManager channelManager;

  const HomeTab({super.key, required this.channelManager});

  @override
  Widget build(BuildContext context) {
    final videos = channelManager.getAllVideos();

    return Container(
      color: const Color(0xFF121212),
      child: videos.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No videos available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add channels to see videos here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : AdaptiveVideoGrid(videos: videos),
    );
  }
}

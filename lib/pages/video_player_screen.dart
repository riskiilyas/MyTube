class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF121212),
      body: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
      ),
      // body: SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       // YouTube Player
      //       YoutubePlayer(
      //         controller: _controller,
      //         aspectRatio: 16 / 9,
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.all(16.0),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             // Video title
      //             Text(
      //               widget.video.title,
      //               style: TextStyle(
      //                 fontSize: 18,
      //                 fontWeight: FontWeight.bold,
      //                 color: Colors.white,
      //               ),
      //             ),
      //             SizedBox(height: 8),
      //
      //             // Video metadata
      //             Row(
      //               children: [
      //                 Text(
      //                   '${widget.video.viewCount} views · ${widget.video.publishedAt}',
      //                   style: TextStyle(
      //                     fontSize: 14,
      //                     color: Colors.grey[400],
      //                   ),
      //                 ),
      //               ],
      //             ),
      //
      //             Divider(color: Colors.grey[800], height: 32),
      //
      //             // Channel info
      //             Row(
      //               children: [
      //                 CircleAvatar(
      //                   backgroundImage: NetworkImage(widget.video.channelImageUrl),
      //                   radius: 24,
      //                   backgroundColor: Colors.grey[800],
      //                   onBackgroundImageError: (_, __) {},
      //                 ),
      //                 SizedBox(width: 16),
      //                 Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(
      //                       widget.video.channelName,
      //                       style: TextStyle(
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w500,
      //                         color: Colors.white,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //                 Spacer(),
      //                 ElevatedButton(
      //                   onPressed: () {
      //                     // Navigate to channel page
      //                     // This would require you to have the Channel object
      //                   },
      //                   child: Text('Visit Channel'),
      //                   style: ElevatedButton.styleFrom(
      //                     backgroundColor: Colors.red,
      //                     foregroundColor: Colors.white,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
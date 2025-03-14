class AdaptiveVideoGrid extends StatelessWidget {
  final List<Video> videos;

  const AdaptiveVideoGrid({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    // Calculate number of columns based on screen width
    return LayoutBuilder(
        builder: (context, constraints) {
          // Determine how many columns based on available width
          // Assuming minimum card width of 320 pixels
          const double cardWidth = 320;
          final int crossAxisCount = max(1, (constraints.maxWidth / cardWidth).floor());

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 16 / 14, // Adjusted for video card + metadata
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return VideoGridCard(video: videos[index]);
            },
          );
        }
    );
  }
}

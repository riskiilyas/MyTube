class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final channelManager = ChannelManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
    });

    await channelManager.loadChannels();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    await channelManager.refreshChannelVideos();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addChannel() async {
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add YouTube Channel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter YouTube channel URL'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'https://www.youtube.com/channel/...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);

                setState(() {
                  _isLoading = true;
                });

                bool success = await channelManager.addChannel(controller.text.trim());

                setState(() {
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Channel added successfully!'
                        : 'Failed to add channel. Please check the URL.'),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeTab(channelManager: channelManager),
      ChannelsTab(channelManager: channelManager),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.play_circle_fill, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Custom YouTube',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isLoading ? null : _addChannel,
          ),
        ],
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text('Loading content...'),
          ],
        ),
      )
          : _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1F1F1F),
        indicatorColor: Colors.red.withOpacity(0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.red),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.subscriptions_outlined),
            selectedIcon: Icon(Icons.subscriptions, color: Colors.red),
            label: 'Channels',
          ),
        ],
      ),
    );
  }
}
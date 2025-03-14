import 'package:flutter/material.dart';
import 'package:mytube/pages/home_page.dart';
import 'package:mytube/services/channel_manager.dart';
import 'package:mytube/widgets/channel_card.dart';

class ChannelsTab extends StatelessWidget {
  final ChannelManager channelManager;

  const ChannelsTab({super.key, required this.channelManager});

  @override
  Widget build(BuildContext context) {
    final channels = channelManager.channels;

    return Container(
      color: const Color(0xFF121212),
      child: channels.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.subscriptions, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No channels added',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add YouTube channels',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final homePage = context.findAncestorStateOfType<HomePageState>();
                homePage?.addChannel();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Channel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return ChannelCard(
            channel: channels[index],
            onDelete: () async {
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove Channel'),
                  content: Text('Are you sure you want to remove "${channels[index].name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await channelManager.removeChannel(channels[index].id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Channel removed')),
                );

                // Refresh the page
                final homePage = context.findAncestorStateOfType<HomePageState>();
                homePage?.loadChannels();
              }
            },
          );
        },
      ),
    );
  }
}

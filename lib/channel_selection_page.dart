import 'package:flutter/material.dart';
import 'main.dart';

class ChannelSelectionPage extends StatefulWidget {
  final String username;

  const ChannelSelectionPage({super.key, required this.username});

  @override
  State<ChannelSelectionPage> createState() => _ChannelSelectionPageState();
}

class _ChannelSelectionPageState extends State<ChannelSelectionPage> {
  final List<String> channels = ['Channel 1', 'Channel 2', 'Channel 3'];
  String? selectedChannel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Channel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text('Select a Channel'),
              value: selectedChannel,
              onChanged: (String? newValue) {
                setState(() {
                  selectedChannel = newValue;
                });
              },
              items: channels.map((String channel) {
                return DropdownMenuItem<String>(
                  value: channel,
                  child: Text(channel),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedChannel != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WalkieTalkieHome(
                            username: widget.username,
                            channel: selectedChannel!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
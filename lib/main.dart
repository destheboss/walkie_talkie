import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';
import 'dart:typed_data';
import 'username_page.dart';
import 'dart:async';

void main() {
  runApp(const WalkieTalkieApp());
}

class WalkieTalkieApp extends StatelessWidget {
  const WalkieTalkieApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walkie Talkie',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UsernamePage(),
    );
  }
}

class WalkieTalkieHome extends StatefulWidget {
  const WalkieTalkieHome({super.key, required this.username, required this.channel});
  final String username;
  final String channel;

  @override
  State<WalkieTalkieHome> createState() => _WalkieTalkieHomeState();
}

class _WalkieTalkieHomeState extends State<WalkieTalkieHome> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isStreaming = false;
  final ApiService _apiService = ApiService();
  StreamController<Uint8List>? _audioStreamController;

  @override
  void initState() {
    super.initState();
    _audioStreamController = StreamController<Uint8List>();
    _openRecorder();
    _apiService.connectToWebSocket(widget.channel);

    _audioStreamController!.stream.listen((audioChunk) {
      _apiService.sendAudioStream(audioChunk);
    });
  }

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      await _recorder.openRecorder();
    } else {
      return;
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _apiService.closeWebSocket();
    _audioStreamController?.close();
    super.dispose();
  }

  void _startStreaming() async {
    await _recorder.startRecorder(
      codec: Codec.pcm16,
      toStream: _audioStreamController!.sink,
    );

    setState(() {
      isStreaming = true;
    });
  }

  void _stopStreaming() async {
    await _recorder.stopRecorder();

    setState(() {
      isStreaming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walkie Talkie'),
      ),
      body: Column(
        children: [
          Text('Channel: ${widget.channel}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isStreaming ? _stopStreaming : _startStreaming,
            child: Text(isStreaming ? 'Stop Talking' : 'Start Talking'),
          ),
          const SizedBox(height: 20),
          const Text(
            'You are now in a live audio channel. Press the button to talk.',
          ),
        ],
      ),
    );
  }
}
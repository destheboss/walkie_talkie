import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class ApiService {
  WebSocketChannel? _channel;
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamSubscription? _recordingDataSubscription;
  Function(Uint8List)? onAudioDataReceived;

  ApiService() {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      await _player.openPlayer();
    } catch (e) {
      return;
    }
    await _recorder.openRecorder();
  }

  void connectToWebSocket(String channel) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.157.167:8080/ws/audio/$channel'),
    );

    _channel!.stream.listen(
      (message) {
        if (message is Uint8List) {
          _feedAudioStream(message);
          if (onAudioDataReceived != null) {
            onAudioDataReceived!(message);
          }
        }
      },
      onError: (error) {
      },
      onDone: () {
      },
    );
  }

  void setOnAudioDataReceived(Function(Uint8List) callback) {
    onAudioDataReceived = callback;
  }

  Future<void> recordToWebSocket() async {
    var recordingDataController = StreamController<Uint8List>();

    _recordingDataSubscription = recordingDataController.stream.listen(
      (buffer) {
        sendAudioStream(buffer);
      },
    );

    await _recorder.startRecorder(
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
      bufferSize: 4096,
    );
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    await _recordingDataSubscription?.cancel();
    _recordingDataSubscription = null;
  }

  void sendAudioStream(Uint8List audioChunk) {
    if (_channel != null) {
      _channel!.sink.add(audioChunk);
    }
  }

  void _feedAudioStream(Uint8List audioData) async {
    if (_player.isStopped) {
      try {
        await _player.startPlayerFromStream(
          codec: Codec.pcm16,
          numChannels: 1,
          sampleRate: 16000,
          whenFinished: () {
          },
        );
      } catch (e) {
        return;
      }
    }

    if (_player.isPlaying && _player.foodSink != null) {
      try {
        await _player.feedFromStream(audioData);
      } catch (e) {
        return;
      }
    }
  }

  void closeWebSocket() {
    _channel?.sink.close();
    _player.closePlayer();
    _recorder.closeRecorder();
  }
}
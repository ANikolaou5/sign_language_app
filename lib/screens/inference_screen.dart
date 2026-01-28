import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sign_language_app/services/inference_service.dart';

class InferenceScreen extends StatefulWidget {
  const InferenceScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;


  @override
  State<InferenceScreen> createState() => _InferenceScreenState();
}

class _InferenceScreenState extends State<InferenceScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  bool _isSending = false;
  String _resultText = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  Future<void> _captureAndSend() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
      _resultText = 'Processing...';
    });

    try {
      final XFile photo = await _controller.takePicture();
      final bytes = await photo.readAsBytes();

      final result = await InferenceService.classifyFromCameraBytes(bytes);

      final predictions = result['predictions'] as List<dynamic>;

      if (predictions.isNotEmpty) {
        final top = predictions.first;
        setState(() {
          _resultText =
          '${top['class']} (${(top['confidence'] * 100).toStringAsFixed(1)}%)';
        });
      } else {
        setState(() {
          _resultText = 'No confident prediction';
        });
      }
    } catch (e) {
      setState(() {
        _resultText = 'Error: $e';
      });
    } finally {
      _isSending = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASL Capture')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.black,
            child: Column(
              children: [
                Text(
                  _resultText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isSending ? null : _captureAndSend,
                  icon: const Icon(Icons.camera),
                  label: const Text('Capture & Analyze'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

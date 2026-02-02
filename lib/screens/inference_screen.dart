
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sign_language_app/services/inference_service.dart';

import '../classes/user_class.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class InferenceScreen extends StatefulWidget {
  const InferenceScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;


  @override
  State<InferenceScreen> createState() => _InferenceScreenState();
}

class _InferenceScreenState extends State<InferenceScreen> {
  final UserService userService = UserService();
  final GeneralService generalService = GeneralService();
  UserClass? user;

  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  bool _isSending = false;
  String _resultText = 'Make a sign through your camera and press "Check" to check it.';

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _loadUserLocalStorage().then((_) async {
      await generalService.loginPrompt(user, context, widget.changeIndex, true);
    });

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

    if (mounted) {
      setState(() {});
    }
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
          _resultText = 'Please try again.\nThe sign you used is not recognized.';
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
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(title: const Text('ASL Capture')),
        body: Column(
          children: [
            Expanded(
              child: _initializeControllerFuture == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder(
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
              child: Column(
                children: [
                  Text(
                    _resultText,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
                      onPressed: _isSending ? null : _captureAndSend,
                      icon: const Icon(Icons.camera, size: 20,),
                      label: const Text('Check', style: TextStyle(fontSize: 20),),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

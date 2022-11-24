import 'dart:async';
import 'dart:developer';

import 'dart:io';

import 'package:camsecurity/api_connector.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

import 'package:intl/intl.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  Color colorOn = Colors.red;
  Color colorOff = Colors.green;

  Color? buttonColor;

  String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  var textLog = "\n\r";
  int contador = 0;
  bool isSendingInProgress = false;
  int everyXseconds = 7;

  @override
  void initState() {
    super.initState();

    buttonColor = colorOff;
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.camera,
        // Define the resolution to use.
        ResolutionPreset.high, // 1280 X 720
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg);

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Widget containerWithPictAndLog(_controller) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Center(child: CameraPreview(_controller))),
          Expanded(flex: 1, child: Text(textLog)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sending pictures')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return containerWithPictAndLog(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: buttonColor,
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          setState(() {
            if (buttonColor == colorOff) {
              buttonColor = colorOn;
              setLogAndSendPicture(context, stop: false);
              var contador2 = 0;
              Timer.periodic(Duration(seconds: 1), (timer) {
                contador2 = contador2 + 1;
                print("-- Contador2: $contador2");

                // When the button changes, must stop the rimer
                if (buttonColor == colorOff) {
                  timer.cancel();
                  print("-- timer.cancel: EXECUTED");
                  return;
                }
                if (contador2 >= everyXseconds) {
                  contador2 = 0;
                  print("-- inside if everyXseconds - Contador2: $contador2");
                  setLogAndSendPicture(context, stop: false);
                }
              });
            } else {
              buttonColor = colorOff;
              textLog = logEntry("done...") + "\n\r$textLog";
              _controller.setFlashMode(FlashMode.torch);
              _controller.setFlashMode(FlashMode.off);
            }
          });
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  String logEntry(text) {
    var now = DateTime.now();
    var formatter = DateFormat(dateTimeFormat);
    String formattedDate = formatter.format(now);
    return '$formattedDate: $text\n\r';
  }

  setLogAndSendPicture(BuildContext context, {required bool stop}) {
    setState(() {
      contador = contador + 1;
      textLog = logEntry("sending picture $contador ...") + "\n\r$textLog";
      sendPicture(context);
    });
  }

  sendPicture(BuildContext context) async {
    if (buttonColor == colorOff) {
      return;
    }
    if (isSendingInProgress == false) {
      try {
        isSendingInProgress = true;
        // Ensure that the camera is initialized.
        await _initializeControllerFuture;

        // Attempt to take a picture and get the file `image`
        // where it was saved.
        final image = await _controller.takePicture();
        _controller.setFlashMode(FlashMode.torch);
        _controller.setFlashMode(FlashMode.off);

        if (!mounted) return;

        // If the picture was taken, display it on a new screen.
        final api = ApiConnector();
        if (api.init()) {
          api.sendPicture(imagePath: image.path);
        }

        isSendingInProgress = false;
      } catch (e) {
        // If an error occurs, log the error to the console.
        print(e);
      }
    }
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'dart:math';

class ARScreen extends StatefulWidget {
  final Uint8List image;

  const ARScreen({Key? key, required this.image}) : super(key: key);

  @override
  _ARScreenState createState() => _ARScreenState();
}


class _ARScreenState extends State<ARScreen> {
  ARKitController? arkitController;
  String? imagePath;
  ARKitNode? node;
  vector.Vector3 position = vector.Vector3(0, 0, -0.5);
  bool joystickVisible = false;  // Add this

  @override
  void initState() {
    super.initState();
    writeImageToFile(widget.image).then((path) {
      setState(() {
        imagePath = path;
      });
    });
  }

  Future<String> writeImageToFile(Uint8List data) async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/image.png');
    await file.writeAsBytes(data);
    return file.path;
  }
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => joystickVisible = true), 
      onTapUp: (_) => setState(() => joystickVisible = false), 
      child: Stack(
        children: [
          ARKitSceneView(
            onARKitViewCreated: onARKitViewCreated,
          ),
          if(joystickVisible)  // Add this
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2 - 50,  // Adjust based on joystick size
            child: Joystick(
              mode: JoystickMode.all,
              listener: (details) {
                print('Joystick event received: $details');
                final dx = details.x * 0.1;
                final dy = details.y * 0.1;
                setState(() {
                  position.x += dx;
                  position.y += dy;
                });
                print('Before update: $position');
                arkitController?.update(
                  'Simgae',
                  node: ARKitNode(position: position),
                );
                node?.position = position;
                print('After update: $position');
              },
            ),
          ),
        ],
      ),
    );
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;

    if (imagePath != null) {
      final material = ARKitMaterial(
        diffuse: ARKitMaterialProperty.image(imagePath!),
      );
      final plane = ARKitPlane(
        materials: [material],
        width: 1.8,
        height: 1.0,
      );
      final node = ARKitNode(
        geometry: plane,
        position: vector.Vector3(0, 0, -0.5),
        name: 'Simage', 
      );
      this.arkitController?.add(node);
      this.node = node;
      }else {
      print("Image path is null");
    } 
  }

  @override
  void dispose() {
    arkitController?.dispose();
    super.dispose();
  }
}

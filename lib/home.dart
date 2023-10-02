// ignore_for_file: non_constant_identifier_names, avoid_unnecessary_containers, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late bool _loading = true;
  late File _image;
  final imagepicker = ImagePicker();
  List _predictions = [];

  @override
  void initState() {
    super.initState();
    loadmodel();
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  detect_image(File image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _loading = false;
      _predictions = prediction!;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadimage_gallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      // setState(() {
      // _loading = false;
      // });
      _image = File(image.path);
    }
    detect_image(_image);
  }

  _loadimage_camera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      //setState(() {
      // _loading = false;
      //});
      _image = File(image.path);
    }
    detect_image(_image);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic'),
        backgroundColor: Colors.green,
      ),
      body: SizedBox(
        height: h,
        width: w,
        //color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 180,
              width: 180,
              padding: const EdgeInsets.all(10),
              // color: Colors.white,
              child: Image.asset('assets/images/nature.png'),
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _loadimage_gallery();
                    },
                    child: Text(
                      'Gallery',
                      style: GoogleFonts.roboto(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            _loading == false
                ? Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: Image.file(_image),
                        ),
                        Text(_predictions[0]['labels'].toString().substring(5))
                      ],
                    ),
                  )
                : SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _loadimage_camera();
                          },
                          child: Text(
                            'Camera',
                            style: GoogleFonts.roboto(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

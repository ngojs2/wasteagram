import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

class AddPage extends StatefulWidget {
  @override
  _AddPage createState() => _AddPage();
}

class _AddPage extends State<AddPage> {
  final ImagePicker _picker = ImagePicker();

  final formKey = GlobalKey<FormState>();

  int? quantity;
  File? file;

  Future imageFromCamera() async {
    XFile? xfile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      file = File(xfile!.path);
    });
  }

  Future imageFromGallery() async {
    XFile? xfile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      file = File(xfile!.path);
    });
  }

  Future uploadImage() async {
    String fileName = DateTime.now().toString() + '.jpg';
    var task =
        await FirebaseStorage.instance.ref().child(fileName).putFile(file!);
    String downloadURL = await task.ref.getDownloadURL();
    print('URL is: $downloadURL');
    return downloadURL;
  }

  Future uploadPost() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    if (file != null) {
      String url = await uploadImage();
      FirebaseFirestore.instance.collection('posts').add({
        'date': DateTime.now(),
        'imageURL': url,
        'quantity': quantity,
        'latitude': _locationData.latitude,
        'longitude': _locationData.longitude,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('New Post'),
      ),
      body: Center(
          //padding: const EdgeInsets.all(8),
          child: ListView(
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Semantics(
                    label: 'Image from Camera',
                    onTapHint: 'Image from Camera',
                    button: true,
                    enabled: true,
                    child: FloatingActionButton(
                      heroTag: "button1",
                      onPressed: () {
                        imageFromCamera();
                      },
                      child: Icon(
                        Icons.camera_alt,
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Image from Gallery',
                    onTapHint: 'Image from Gallery',
                    button: true,
                    enabled: true,
                    child: FloatingActionButton(
                      heroTag: "button2",
                      onPressed: () {
                        imageFromGallery();
                      },
                      child: Icon(
                        Icons.folder_open,
                      ),
                    ),
                  ),
                ]),
          ),
          Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 280.0,
                  child: Center(
                      child: file == null
                          ? CircularProgressIndicator()
                          : Image.file(File(file!.path))))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Semantics(
                          textField: true,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            autofocus: true,
                            decoration: InputDecoration(
                                hintText: 'Number of wasted items',
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            onSaved: (value) {
                              quantity = int.parse(value!);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter number of items';
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(170.0),
                          child: Semantics(
                            label: 'Upload Image',
                            onTapHint: 'Upload Image',
                            button: true,
                            enabled: true,
                            child: FloatingActionButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  uploadPost();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Icon(
                                Icons.cloud_upload_outlined,
                              ),
                            ),
                          ),
                        )

                        //dateEntry(labelText: 'date'),
                      ],
                    ))),
          ),
        ],
      )),
    );
  }
}

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class AddPost extends StatefulWidget {
  static const routeName = 'add_post';
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  File? image;
  final picker = ImagePicker();
  int waste = -1;
  LocationData? locationData;
  var locationService = Location();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    retrieveLocation();
  }

  void getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    image = File(pickedFile!.path);
    setState(() {});
  }

  Future setImage() async {
    var fileName = DateTime.now().toString() + '.jpg';
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageReference.putFile(image!);
    await uploadTask;
    final url = await storageReference.getDownloadURL();
    return url;
  }

  void uploadData() async {
    final url = await setImage();
    final date = DateFormat.yMMMd().format(DateTime.now());
    FirebaseFirestore.instance.collection('wasteagram_posts').add({
      'date': date,
      'waste': waste,
      'url': url,
      'latitude': locationData!.latitude,
      'longitude': locationData!.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updateTotalWaste() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('wasteagram_posts')
          .doc('totalWaste');
      DocumentSnapshot snapshot = await transaction.get(postRef);
      var snapshotData = snapshot.data() as Map;
      int totalWaste = snapshotData['totalWaste'];
      transaction.update(postRef, {'totalWaste': totalWaste + waste});
    });
  }

  void retrieveLocation() async {
    try {
      var _serviceEnabled = await locationService.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await locationService.requestService();
        if (!_serviceEnabled) {
          print('Failed to enable service. Returning.');
          return;
        }
      }

      var _permissionGranted = await locationService.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await locationService.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          print('Location service permission not granted. Returning.');
        }
      }

      locationData = await locationService.getLocation();
    } on PlatformException catch (e) {
      print('Error: ${e.toString()}, code: ${e.code}');
      locationData = null;
    }
    locationData = await locationService.getLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Scaffold(
          appBar: AppBar(),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Semantics(
                    button: true,
                    enabled: true,
                    onTapHint: 'Select a photo from gallery',
                    child: ElevatedButton(
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                        child: const Text('Select Photo From Gallery'))),
                const SizedBox(height: 20),
                Semantics(
                    button: true,
                    enabled: true,
                    onTapHint: 'Take a photo with camera',
                    child: ElevatedButton(
                        onPressed: () {
                          getImage(ImageSource.camera);
                        },
                        child: const Text('Take Photo'))),
              ])));
    } else {
      if (locationData == null) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.file(image!),
                      const SizedBox(height: 40),
                      Semantics(
                          onTapHint:
                              'Text input box for number of wasted items',
                          textField: true,
                          child: TextFormField(
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Number of Items',
                                  border: OutlineInputBorder()),
                              onSaved: (value) {
                                waste = int.parse(value!);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a number for required value';
                                }
                                return null;
                              })),
                      Semantics(
                          button: true,
                          enabled: true,
                          onTapHint: 'Upload this post',
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  uploadData();
                                  await updateTotalWaste();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Post It!'))),
                    ],
                  )),
            )));
      }
    }
  }
}

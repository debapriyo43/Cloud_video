import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_video/screens/videos_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
  }

  XFile? videoFile;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userid = FirebaseAuth.instance.currentUser?.uid;
  String currentAddress = 'My address';
  late Position currentPosition;

  _video() async {
    final ImagePicker picker = ImagePicker();
    final XFile? theVideo = await picker.pickVideo(
      source: ImageSource.camera,
    );
    setState(() {
      videoFile = theVideo!;
    });
  }

  Future<Position> _determinePostion() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please keep your location on.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Permission is denied forever');
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        currentPosition = position;
        currentAddress =
            "${place.locality},${place.postalCode},${place.country}";
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    return position;
  }

  Future videoUploadTask(String videoId) async {
    final storageRef = FirebaseStorage.instance.ref();

// Create a reference to "mountains.jpg"
    final videoRef = storageRef.child("videos/$videoId");

    try {
      await videoRef.putFile(File(videoFile!.path));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> uploadVideo(
    String title,
    String description,
    String category,
  ) async {
    try {
      String videoId = const Uuid().v1();
      await videoUploadTask(videoId);
      // String downloadUrl = await snapshot.ref.getDownloadURL();
      _firestore.collection('videos').doc(videoId).set({
        'title': title,
        'description': description,
        'category': category,
        'uid': userid,
        'videoId': videoId,
        // 'downloadURL': downloadUrl,
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    _determinePostion();
    super.initState();
  }

  void showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Success",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Screen'),
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 50,
                    ),
                    //Video preview
                    Container(
                      color: Colors.brown,
                      height: MediaQuery.of(context).size.height * (30 / 100),
                      width: double.infinity,
                      child: videoFile == null
                          ? const Center(
                              child: Icon(
                                Icons.videocam,
                                color: Colors.red,
                                size: 50.0,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.cover,
                              child: mounted
                                  ? Chewie(
                                      controller: ChewieController(
                                        videoPlayerController:
                                            VideoPlayerController.file(
                                          File(videoFile!.path),
                                        ),
                                        aspectRatio: 3 / 2,
                                        looping: true,
                                      ),
                                    )
                                  : Container(),
                            ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _video();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("Record"),
                          SizedBox(width: 5),
                          Icon(Icons.videocam),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                            hintText: "Enter the title of the video"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Enter a description for the video"),
                      ),
                    ),
                    //category
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                            hintText: "Enter a catergory for the video"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    //video location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                uploadVideo(
                                  titleController.text,
                                  descriptionController.text,
                                  categoryController.text,
                                );
                                showSuccessSnackbar(context);
                              },
                              child: const Text("Post")),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FirestoreVideoList()),
                                );
                              },
                              child: const Text("My videos")),
                        ),
                      ],
                    ),
                    // post botton
                  ],
                )
              ],
            )),
      ),
    );
  }
}

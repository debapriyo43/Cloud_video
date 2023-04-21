import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_video/screens/videos_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

  _video() async {
    final ImagePicker picker = ImagePicker();
    final XFile? theVideo = await picker.pickVideo(
      source: ImageSource.camera,
    );
    setState(() {
      videoFile = theVideo!;
    });
  }

  Future<void> uploadVideo(
    String title,
    String description,
    String category,
  ) async {
    String res = "Something going wrong";
    try {
      String videoId = const Uuid().v1();
      UploadTask videoUploadTask = FirebaseStorage.instance
          .ref()
          .child("All videos")
          .child(videoId)
          .putFile(File(videoFile!.path));
      // TaskSnapshot snapshot = await videoUploadTask;
      // String downloadUrl = await snapshot.ref.getDownloadURL();
      // return downloadUrl;
      _firestore.collection('videos').doc(videoId).set({
        'title': title,
        'description': description,
        'category': category,
        'uid': userid,
        'videoId': videoId,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Screen'),
      ),
      body: Container(
          padding: EdgeInsets.all(10),
          child: ListView(
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
                            )),

                  ElevatedButton(
                    onPressed: () {
                      _video();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("Record"),
                        Icon(Icons.videocam),
                      ],
                    ),
                  ),
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
                  //video location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                uploadVideo(
                                    titleController.text,
                                    descriptionController.text,
                                    categoryController.text);
                              },
                              child: const Text("Post"))),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => VideoScreen()),
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
    );
  }
}

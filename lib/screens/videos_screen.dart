import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:video_player/video_player.dart';

import 'package:firebase_storage/firebase_storage.dart';

class FirestoreVideoList extends StatefulWidget {
  @override
  _FirestoreVideoListState createState() => _FirestoreVideoListState();
}

class _FirestoreVideoListState extends State<FirestoreVideoList> {
  List<String> videoUrls = [];

  @override
  void initState() {
    super.initState();
    _getVideos();
  }

  Future<void> _getVideos() async {
    final ListResult result =
        await FirebaseStorage.instance.ref('All videos').listAll();
    for (final ref in result.items) {
      final url = await ref.getDownloadURL();
      print(url);
      setState(
        () {
          videoUrls.add(url);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
      ),
      body: ListView.builder(
        itemCount: videoUrls.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future:
                VideoPlayerController.network(videoUrls[index]).initialize(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                print(videoUrls[index]);
                return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Column(
                      children: [
                        Chewie(
                          controller: ChewieController(
                            videoPlayerController:
                                VideoPlayerController.network(videoUrls[index]),
                            aspectRatio: 3 / 2,
                            looping: true,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        )
                      ],
                    ));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Center(
                  child: Text('Something Wrong has occured'),
                );
              }
            },
          );
        },
      ),
    );
  }
}

// class VideoScreen extends StatefulWidget {
//   const VideoScreen({super.key});

//   @override
//   State<VideoScreen> createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   final userid = FirebaseAuth.instance.currentUser?.uid;
//   final _db = FirebaseFirestore.instance;
//   Future<List<VideoModel>>  getVideoDetails(String uid) async {
//     final snapshot =
//         await _db.collection("videos").where("uid", isEqualTo: uid).get();
//     final videoDetails   =
//         snapshot.docs.map((e) => VideoModel.toListId(e)).toList();
    
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("Uploaded videos"),
//         ),
//         body: ListView.builder(
//           itemCount: str?.length,
//           prototypeItem: ListTile(
//             title: Text(str![0]),
//           ),
//           itemBuilder: (context, index) {
//             return ListTile(
//               title: Text(![0]),
//             );
//           },
//         )
//         body: FutureBuilder(
//           future: getVideoDetails(userid!),
//           builder: (context, snapshot) {
//             if (snapshot.hasData &&
//                 snapshot.connectionState == ConnectionState.done) {
//               return ListView.builder(
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                       color: Colors.brown,
//                       height: MediaQuery.of(context).size.height * (30 / 100),
//                       width: double.infinity,
//                       child: FittedBox(
//                         fit: BoxFit.cover,
//                         child: mounted
//                             ? Chewie(
//                                 controller: ChewieController(
//                                   videoPlayerController:
//                                       VideoPlayerController.file(
//                                     File(videoFile!.path),
//                                   ),
//                                   aspectRatio: 3 / 2,
//                                   looping: true,
//                                 ),
//                               )
//                             : Container(),
//                       ));
//                 },
//               );
//             }

//             /// handles others as you did on question
//             else {
//               return CircularProgressIndicator();
//             }
//           },
//         ),
//         );
//   }
// }

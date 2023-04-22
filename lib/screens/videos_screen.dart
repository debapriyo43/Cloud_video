import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:firebase_storage/firebase_storage.dart';

class FirestoreVideoList extends StatefulWidget {
  const FirestoreVideoList({super.key});

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
    print('----------------------------');
    final ListResult result =
        await FirebaseStorage.instance.ref('videos').listAll();
    for (final ref in result.items) {
      final url = await ref.getDownloadURL();
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
        title: const Text('Videos'),
      ),
      body: ListView.builder(
        itemCount: videoUrls.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future:
                VideoPlayerController.network(videoUrls[index]).initialize(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chewie(
                      controller: ChewieController(
                        videoPlayerController:
                            VideoPlayerController.network(videoUrls[index]),
                        aspectRatio: 3 / 2,
                        looping: true,
                      ),
                    ),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return const Center(
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

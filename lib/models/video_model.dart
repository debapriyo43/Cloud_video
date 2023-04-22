import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String title;
  final String description;
  final String category;
  final String uid;
  final String videoId;
  final String downloadUrl;
  const VideoModel({
    required this.title,
    required this.description,
    required this.category,
    required this.uid,
    required this.videoId,
    required this.downloadUrl,
  });
  factory VideoModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return VideoModel(
      title: data!["title"],
      category: data["category"],
      description: data["description"],
      uid: data["uid"],
      videoId: data["videoId"],
      downloadUrl: data["downloadUrl"],
    );
  }
  factory VideoModel.toListId(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return data!["videoId"];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class PostData {
  PostData({
    this.ownerId,
    this.userName,
    this.profession,
    this.title,
    this.body,
    this.postId,
    this.date,
    this.category,
    this.likes,
  });
  final String? ownerId;
  final String? userName;
  final String? profession;
  final String? title;
  final String? body;
  final Timestamp? date;
  final List? category;
  final String? postId;
  final List? likes;

  factory PostData.setData(doc) {
    return PostData(
      ownerId: doc.data()['ownerId'],
      userName: doc.data()['userName'],
      profession: doc.data()['profession'],
      title: doc.data()['title'],
      body: doc.data()['body'],
      postId: doc.data()['postId'],
      date: doc.data()['date'],
      category: doc.data()['category'],
      likes: doc.data()['likes'],
    );
  }
}

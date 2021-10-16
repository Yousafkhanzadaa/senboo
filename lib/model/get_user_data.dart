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
    this.photoUrl,
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
  final String? photoUrl;

  factory PostData.setData(doc) {
    return PostData(
      ownerId: doc.data()['ownerId'],
      userName: doc.data()['userName'],
      profession: doc.data()['profession'],
      title: doc.data()['title'],
      body: doc.data()['body'],
      postId: doc.data()['postId'],
      photoUrl: doc.data()['photoUrl'] ??
          "https://i.pinimg.com/originals/0c/3b/3a/0c3b3adb1a7530892e55ef36d3be6cb8.png",
      date: doc.data()['date'],
      category: doc.data()['category'],
      likes: doc.data()['likes'],
    );
  }
}

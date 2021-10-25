import 'package:cloud_firestore/cloud_firestore.dart';

class FeedData {
  FeedData({
    this.userId,
    this.userName,
    this.photoUrl,
    this.date,
    this.type,
    this.postId,
    this.ownerId,
  });
  final String? userId;
  final String? postId;
  final String? ownerId;
  final String? type;
  final String? userName;
  final String? photoUrl;
  final Timestamp? date;

  factory FeedData.setData(doc) {
    return FeedData(
      userId: doc.data()['userId'],
      postId: doc.data()['postId'],
      userName: doc.data()['userName'],
      type: doc.data()['type'],
      photoUrl: doc.data()['photoUrl'],
      ownerId: doc.data()['ownerId'],
      date: doc.data()['timeStamp'],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentData {
  CommentData(
      {this.ownerId,
      this.userName,
      this.comment,
      this.date,
      this.photoUrl,
      this.profession});
  final String? ownerId;
  final String? profession;
  final String? userName;
  final String? photoUrl;
  final String? comment;
  final Timestamp? date;

  factory CommentData.setData(doc) {
    return CommentData(
      ownerId: doc.data()['ownerId'],
      userName: doc.data()['userName'],
      profession: doc.data()['profession'],
      comment: doc.data()['comment'],
      photoUrl: doc.data()['photoUrl'] ?? null,
      date: doc.data()['date'],
    );
  }
}

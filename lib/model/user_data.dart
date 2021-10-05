import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  UserData(
      {this.userId,
      this.userName,
      this.profession,
      this.socialLinks,
      this.photoUrl,
      this.date,
      this.userEmail,
      this.bio,
      this.savedPosts});
  final String? userId;
  final String? userName;
  final String? profession;
  final List? socialLinks;
  final String? photoUrl;
  final Timestamp? date;
  final String? userEmail;
  final String? bio;
  final List? savedPosts;

  factory UserData.setData(doc) {
    return UserData(
      userId: doc.data['userId'],
      userName: doc.data['userName'],
      profession: doc.data['profession'],
      socialLinks: doc.data['socialLinks'],
      photoUrl: doc.data['photoUrl'],
      date: doc.data['date'],
      userEmail: doc.data['userEmail'],
      bio: doc.data['bio'],
      savedPosts: doc.data['savedPosts'],
    );
  }
}

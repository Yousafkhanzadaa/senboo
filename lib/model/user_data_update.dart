import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataUpdate {
  UserDataUpdate(
      {this.userId,
      this.userName,
      this.profession,
      this.socialLinks,
      this.photoUrl,
      this.date,
      this.userEmail,
      this.bio,
      this.savedPosts,
      this.interested});
  final String? userId;
  final String? userName;
  final String? profession;
  final List? socialLinks;
  final String? photoUrl;
  final Timestamp? date;
  final String? userEmail;
  final String? bio;
  final List? savedPosts;
  final List<dynamic>? interested;

  factory UserDataUpdate.setData(doc) {
    return UserDataUpdate(
      userId: doc.get('userId'),
      userName: doc.get('userName'),
      profession: doc.get('profession'),
      socialLinks: doc.get('socialLinks'),
      photoUrl: doc.get('photoUrl'),
      date: doc.get('date'),
      userEmail: doc.get('userEmail'),
      bio: doc.get('bio'),
      savedPosts: doc.get('savedPosts'),
      interested: doc.get('interested'),
    );
  }
}

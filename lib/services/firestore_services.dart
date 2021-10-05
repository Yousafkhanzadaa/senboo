import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class FirestoreServices extends ChangeNotifier {
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");

  // SavedPosts collection
  CollectionReference savedPosts =
      FirebaseFirestore.instance.collection("savedPosts");

  //Comments
  CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');

  // Unique Id
  Uuid uid = Uuid();

  // Date and time
  DateTime dateTime = DateTime.now();

  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Add User details when signed in -----------------------
  // Future<void> addUserDetails() async {
  //   try {
  //     await users.doc(currentUser!.uid).set({
  //       "userId": currentUser!.uid,
  //       "userName": currentUser!.displayName,
  //       "profession": "profession!",
  //       "socialLinks": ["@instagram", "@twitter"],
  //       "date": dateTime,
  //       "photoUrl": currentUser!.photoURL,
  //       "userEmail": currentUser!.email,
  //       "bio": "bio is not added yet!",
  //       "savedPosts": [],
  //       "interested": []
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Update user informatoin --------------------------------------------
  Future? updateUserDetails({
    String? userName,
    String? profession,
    String? bio,
    List<String>? socialLinks,
    List<dynamic>? interested,
  }) async {
    await users.doc(currentUser!.uid).update({
      'userName': userName,
      'profession': profession,
      'bio': bio,
      'socialLinks': socialLinks,
      'interested': interested,
    });
    notifyListeners();
  }

  // setSearchParam(
  //   String title,
  // ) {
  //   List<String> caseSearchList = [];
  //   String temp = '';
  //   for (int i = 0; i < title.length; i++) {
  //     temp = temp + title[i];
  //     caseSearchList.add(temp);
  //   }
  //   return caseSearchList;
  // }

  // Add post --------------------------------------------
  // Future<void> addPost({
  //   required String userName,
  //   required String profession,
  //   required List<String> category,
  //   required String title,
  //   required String body,
  //   required List searchKeywords,
  //   required DateTime date,
  // }) async {
  //   var uidV4 = uid.v4();
  //   try {
  //     await posts.doc(uidV4).set({
  //       "ownerId": currentUser!.uid,
  //       "userName": userName,
  //       "profession": profession,
  //       "date": date,
  //       "category": category,
  //       "title": title,
  //       "body": body,
  //       "searchKeywords": searchKeywords,
  //       "postId": uidV4,
  //       "likes": [],
  //     });
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  // Update post --------------------------------------------
  Future<void> updatePost({
    required List category,
    required String title,
    required String body,
    required List searchKeywords,
    required String postId,
  }) async {
    try {
      await posts.doc(postId).update({
        "category": category,
        "title": title,
        "body": body,
        "searchKeywords": searchKeywords,
      });
    } catch (e) {
      throw e;
    }
  }

  // Future<void> addComment({
  //   required String userName,
  //   required String profession,
  //   required String comment,
  //   required String postId,
  //   required DateTime date,
  // }) async {
  //   // var uidV4 = uid.v4();
  //   try {
  //     await comments.doc(postId).collection("postComments").add({
  //       "ownerId": currentUser!.uid,
  //       "userName": userName,
  //       "profession": profession,
  //       "date": date,
  //       "comment": comment,
  //     });
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  Future<void> savePost({
    required String userId,
    required String postId,
    required String userName,
    required String profession,
    required List category,
    required String title,
    required String body,
    required DateTime date,
    required List likes,
  }) async {
    try {
      await savedPosts.doc(userId).collection("saved").doc(postId).set({
        "ownerId": userId,
        "userName": userName,
        "profession": profession,
        "date": date,
        "category": category,
        "title": title,
        "body": body,
        "postId": postId,
        "likes": likes,
      });
    } catch (e) {
      throw e;
    }
  }
}

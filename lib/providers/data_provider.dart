import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // Current User
  // User? currentUser = FirebaseAuth.instance.currentUser;
  // userData modal
  int totalLikes = 0;
  int totalPosts = 0;

  get getlikes => totalLikes;
  get getPosts => totalPosts;

  getTotalLikes({required String ownerId}) async {
    int likesCount = 0;
    await posts.where('ownerId', isEqualTo: ownerId).get().then((value) {
      totalPosts = value.docs.length;
      value.docs.forEach((val) {
        // totalLikes += val.get()
        List list = val.get("likes");
        likesCount += list.length;
      });
    });
    totalLikes = likesCount;
    notifyListeners();
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:senboo/screens/comment_screen.dart';
import 'package:intl/intl.dart';
import 'package:senboo/screens/post_view_screen.dart';
import 'package:senboo/screens/visitor_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PostCard extends StatefulWidget {
  PostCard({
    Key? key,
    required this.userName,
    required this.profession,
    required this.title,
    required this.body,
    required this.date,
    required this.category,
    required this.likes,
    required this.postId,
    required this.photoUrl,
    required this.ownerId,
    required this.currentUserName,
    required this.currentUserPhotoUrl,
  }) : super(key: key);
  final String userName;
  final String profession;
  final String title;
  final String body;
  final DateTime date;
  final List category;
  final List likes;
  final String postId;
  final String photoUrl;
  final String ownerId;
  final String currentUserName;
  final String currentUserPhotoUrl;

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  // Feeds
  CollectionReference feeds = FirebaseFirestore.instance.collection("feeds");
  //comments
  CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');
  // saved posts
  CollectionReference savedPosts =
      FirebaseFirestore.instance.collection("savedPosts");

  ScreenshotController screenshotController = ScreenshotController();
  bool? liked;
  Uuid uid = Uuid();
  // bool? saved;
  int likesCounter = 0;
  List likeList = [];
  bool loaded = false;

  // List commentList = [];

  bool? _saved;
  List? _savedList = [];
  final DateFormat formatter = DateFormat.yMMMd('en_US');

  @override
  void initState() {
    super.initState();
    _getPostDetails();
  }

  // getting card data
  _getPostDetails() async {
    var getSavedList = await users.doc(currentUser!.uid).get();
    // var getCommentsList =
    //     await comments.doc(widget.postId).collection("postComments").get();
    setState(() {
      _savedList = getSavedList.get("savedPosts");
      _saved = _savedList!.contains(widget.postId);
    });
  }

  // gettting like
  void _handlePostLike() {
    bool _liked = likeList.contains(currentUser!.uid);
    if (_liked) {
      likeList.remove(currentUser!.uid);
      setState(() {
        likesCounter -= 1;
        liked = false;
      });
      posts.doc(widget.postId).update({"likes": likeList}).then((value) {
        _removeFeedItem();
      });
    }
    if (!_liked) {
      likeList.add(currentUser!.uid);

      setState(() {
        likesCounter += 1;
        liked = true;
      });
      posts.doc(widget.postId).update({"likes": likeList}).then((value) {
        _addFeedItem();
      });
    }
  }

  _addFeedItem() {
    if (currentUser!.uid != widget.ownerId) {
      feeds.doc(widget.ownerId).collection("feedItems").doc(widget.postId).set({
        "type": "like",
        "userName": widget.currentUserName,
        "userId": currentUser!.uid,
        "postId": widget.postId,
        "ownerId": widget.ownerId,
        "timeStamp": DateTime.now(),
        "photoUrl": widget.currentUserPhotoUrl,
      });
    }
  }

  _removeFeedItem() {
    feeds
        .doc(widget.ownerId)
        .collection("feedItems")
        .doc(widget.postId)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        snapshot.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostViewScreen(
                postId: widget.postId,
                ownerId: widget.ownerId,
                reverse: 1,
              ),
            ),
          );
        },
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.97,
            decoration: _cardDecoration(),
            child: Column(
              children: [
                _headingBox(),
                _bodyBox(),
                _actionBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // CardDecoration --------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          // color: Theme.of(context).primaryColor.withOpacity(0.40),
          color: Theme.of(context).shadowColor,
          blurRadius: 3,
          offset: Offset(0, 0),
          // spreadRadius: 1,
        ),
      ],
    );
  }

  // Profile pic.-------------------------------
  Widget _profilePic(String photoUrl) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          // border: Border.all(color: Theme.of(context).primaryColor, width: 2),

          borderRadius: BorderRadius.circular(35),
          color: Colors.white.withOpacity(0.5),
          image: DecorationImage(image: NetworkImage(photoUrl))),
    );
  }

  // First Part
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Upper HeadingBox -------------------------------------------
  Widget _headingBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        bottom: 5,
        right: 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _userNameHeading(),
          SizedBox(
            height: 5,
          ),
          _categoryText(),
          _timerText(),
        ],
      ),
    );
  }

  // UserName and Profession Text here ------------------------------------
  Widget _userNameHeading() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisitorProfileScreen(ownerId: widget.ownerId),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _profilePic(widget.photoUrl),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 16),
                ),
                Text(
                  widget.profession,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Timer Text under UserName here -----------------------------------------
  Widget _timerText() {
    return Row(
      children: [
        Text(
          formatter.format(widget.date),
          style: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  // Category Text under TimerText here ----------------------------------
  Widget _categoryText() {
    return Text(
      "${widget.category.join(", ").toUpperCase()}",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 10),
    );
  }

  //Second Part
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Lower BodyBox --------------------------------------------------
  Widget _bodyBox() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: EdgeInsets.only(top: 0, bottom: 5),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textTitle(),
          // SizedBox(
          //   height: 15,
          // ),
          // _bodyText(),
        ],
      ),
    );
  }

  // TextTitle is here ---------------------------------------------------
  Widget _textTitle() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        widget.title,
        textAlign:
            widget.category.contains("Urdu") ? TextAlign.end : TextAlign.start,
        maxLines: 5,
        overflow: TextOverflow.fade,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
      ),
    );
  }

  // bodyText is Here -----------------------------------------------------
  // Widget _bodyText() {
  //   return Text(
  //     widget.body,
  //     maxLines: 6,
  //     textAlign: TextAlign.start,
  //     overflow: TextOverflow.ellipsis,
  //     style: Theme.of(context).textTheme.bodyText1,
  //   );
  // }

  // Third Part
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // ActionBar goes here -------------------------------------------
  Widget _actionBar() {
    return Container(
      padding: EdgeInsets.only(top: 0, bottom: 5, left: 10, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _likeButton(),
          SizedBox(
            width: 10,
          ),
          _commentButton(),
          Spacer(),
          _saveButton(),
          SizedBox(
            width: 10,
          ),
          _screenshot(),
        ],
      ),
    );
  }

  // LikeButton goes here -------------------------------------------
  Widget _likeButton() {
    return StreamBuilder<DocumentSnapshot>(
      stream: posts.doc(widget.postId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          likeList = snapshot.data!['likes'];
          liked = likeList.contains(currentUser!.uid);

          likesCounter = likeList.length;
          return GestureDetector(
            onTap: _handlePostLike,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: _buttonDecorations(),
              child: Column(
                children: [
                  _buttonsIcon(
                      liked! ? Icons.favorite : Icons.favorite_outline),
                  Text(
                    NumberFormat.compact().format(likesCounter).toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(fontSize: 10),
                  )
                ],
              ),
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(5),
          decoration: _buttonDecorations(),
          child: _buttonsIcon(Icons.favorite_outline),
        );
      },
    );
  }

  Widget _commentButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentScreen(
              postId: widget.postId,
              ownerId: widget.ownerId,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: _buttonDecorations(),
        child: _buttonsIcon(
          Icons.chat_bubble_outline_rounded,
        ),
      ),
    );
  }

  Widget _screenshot() {
    return GestureDetector(
      onTap: () async {
        final image = await screenshotController.capture();
        if (image == null) return;

        await _shareScreenshot(image);
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: _buttonDecorations(),
        child: _buttonsIcon(
          Icons.share,
        ),
      ),
    );
  }

  _shareScreenshot(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/screenshot.png');
    image.writeAsBytesSync(bytes);

    var text = "Shared form Senboo";
    await Share.shareFiles([image.path], text: text);
  }

// Save button and its functions

  _handleSavePost() async {
    if (_saved!) {
      _savedList!.remove(widget.postId);
      setState(() {
        _saved = !_saved!;
      });
      await users.doc(currentUser!.uid).update({"savedPosts": _savedList});
    } else if (!_saved!) {
      _savedList!.add(widget.postId);
      setState(() {
        _saved = !_saved!;
      });
      await users.doc(currentUser!.uid).update({"savedPosts": _savedList});
    }
  }

  // CommentButton goes here -------------------------------------------
  Widget _saveButton() {
    if (_saved != null) {
      return GestureDetector(
        onTap: _handleSavePost,
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: _buttonDecorations(),
          child: _buttonsIcon(
              _saved! ? Icons.bookmark_added : Icons.bookmark_add_outlined),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _handleSavePost,
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: _buttonDecorations(),
          child: _buttonsIcon(Icons.bookmark_outline),
        ),
      );
    }
  }

  // All Button Decoration -------------------------------
  BoxDecoration _buttonDecorations() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),

      // border: Border.all(color: Theme.of(context).primaryColor, width: 1),
      boxShadow: [
        BoxShadow(
          // color: Theme.of(context).primaryColor.withOpacity(0.40),
          color: Theme.of(context).shadowColor,
          blurRadius: 2,
          offset: Offset(0, 0),
          // spreadRadius: 1,
        ),
      ],
    );
  }

  // button icons ------------------------------------------
  Widget _buttonsIcon(IconData icon) {
    return Icon(
      icon,
      size: 22,
      color: Theme.of(context).primaryColor,
    );
  }
}

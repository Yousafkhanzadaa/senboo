import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:senboo/model/get_user_data.dart';
import 'package:senboo/screens/comment_screen.dart';
import 'package:intl/intl.dart';
import 'package:senboo/screens/visitor_screen.dart';
import 'package:share_plus/share_plus.dart';

class PostViewScreen extends StatefulWidget {
  PostViewScreen(
      {Key? key, required this.postId, required this.ownerId, this.reverse})
      : super(key: key);
  final String postId;
  final String ownerId;
  final int? reverse;

  @override
  _PostViewScreenState createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // User collection
  CollectionReference users =
      FirebaseFirestore.instance.collection("users"); // saved posts
  CollectionReference savedPosts =
      FirebaseFirestore.instance.collection("savedPosts");
  // Feeds
  CollectionReference feeds = FirebaseFirestore.instance.collection("feeds");

  //comments
  CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');
  ScreenshotController screenshotController = ScreenshotController();
  bool? liked;
  bool? _saved;
  List? _savedList;
  int likesCounter = 0;
  bool loaded = false;
  List likeList = [];
  List saveList = [];
  List commentList = [];
  PostData? postData;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  Map currentUserInfo = {
    'currentUserName': "Someone",
    'currentUserPhotoUrl': "null",
  };

  @override
  void initState() {
    super.initState();
    _getPostDetails();
  }

  // Getting postDetails
  _getPostDetails() {
    posts.doc(widget.postId).get().then((snapshot) async {
      var getUserInfo = await users.doc(currentUser!.uid).get();
      var getCommentsList =
          await comments.doc(widget.postId).collection("postComments").get();
      setState(() {
        _savedList = getUserInfo.get("savedPosts");
        commentList = getCommentsList.docs;
        currentUserInfo['currentUserName'] = getUserInfo.get('userName');
        currentUserInfo['currentUserPhotoUrl'] = getUserInfo.get('photoUrl');

        _saved = _savedList!.contains(widget.postId);
        postData = PostData.setData(snapshot);
        likeList = postData!.likes!;
        loaded = true;
      });
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
        "userName": currentUserInfo['currentUserName'],
        "userId": currentUser!.uid,
        "ownerId": widget.ownerId,
        "postId": widget.postId,
        "timeStamp": DateTime.now(),
        "photoUrl": currentUserInfo['currentUserPhotoUrl'],
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
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 0,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: !loaded
            ? _searching()
            : Container(
                // decoration: _cardDecoration(),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    _headingBox(),
                    _bodyBox(),
                    _actionBar(),
                  ],
                ),
              ),
      ),
    );
  }

  // Load Screen ---------------------------------------------
  Widget _searching() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      // decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/svgs/post.png")),
              )),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 60),
            child: LinearProgressIndicator(
              color: Theme.of(context).primaryColor,
              minHeight: 2,
            ),
          )
        ],
      ),
    );
  }

  // First Part
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Upper HeadingBox -------------------------------------------
  Widget _headingBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profilePic(postData!.photoUrl!),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.reverse != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VisitorProfileScreen(ownerId: widget.ownerId),
                            ),
                          );
                        }
                      },
                      child: _userNameHeading(),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
          _categoryText(),
          _timerText(),
        ],
      ),
    );
  }

  // Profile pic.-------------------------------
  Widget _profilePic(String photoUrl) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          // border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          borderRadius: BorderRadius.circular(35),
          color: Colors.white.withOpacity(0.5),
          image: DecorationImage(image: NetworkImage(photoUrl))),
    );
  }

  // UserName and Profession Text here ------------------------------------
  Widget _userNameHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          postData!.userName!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline1,
        ),
        Text(
          postData!.profession!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subtitle2,
        )
      ],
    );
  }

  // Timer Text under UserName here -----------------------------------------
  Widget _timerText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon(
        //   Icons.watch_later_outlined,
        //   size: 16,
        //   color: Colors.white,
        // ),
        // SizedBox(
        //   width: 5,
        // ),
        Text(
          formatter.format(postData!.date!.toDate()),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }

  // Category Text under TimerText here ----------------------------------
  Widget _categoryText() {
    return Text(
      "${postData!.category!.join(", ").toUpperCase()}",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.subtitle2,
    );
  }

  //Second Part
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Lower BodyBox --------------------------------------------------
  Widget _bodyBox() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textTitle(),
              SizedBox(
                height: 15,
              ),
              _bodyText(),
            ],
          ),
        ),
      ),
    );
  }

  // TextTitle is here ---------------------------------------------------
  Widget _textTitle() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        postData!.title!,
        textAlign: postData!.category!.contains("Urdu")
            ? TextAlign.end
            : TextAlign.start,
        style: Theme.of(context).textTheme.headline3,
      ),
    );
  }

  // bodyText is Here -----------------------------------------------------
  Widget _bodyText() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        postData!.body!,
        textAlign: postData!.category!.contains("Urdu")
            ? TextAlign.end
            : TextAlign.start,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  // Third Part
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // ActionBar goes here -------------------------------------------
  Widget _actionBar() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _likeButton(),
          SizedBox(width: 10),
          _commentButton(),
          Spacer(),
          _saveButton(),
          SizedBox(width: 10),
          _screenshot(),
          SizedBox(width: 10),
          _backButton(),
        ],
      ),
    );
  }

  // LikeButton goes here -------------------------------------------
  Widget _likeButton() {
    liked = likeList.contains(currentUser!.uid);
    likesCounter = likeList.length;
    return GestureDetector(
      onTap: _handlePostLike,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: _buttonDecorations(),
        child: Column(
          children: [
            _buttonsIcon(liked! ? Icons.favorite : Icons.favorite_outline),
            Text(
              NumberFormat.compact().format(likesCounter).toString(),
              style: Theme.of(context).textTheme.bodyText2,
            )
          ],
        ),
      ),
    );
  }

  // CommentButton goes here -------------------------------------------
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
        child: Column(
          children: [
            _buttonsIcon(
              FontAwesomeIcons.comment,
            ),
            Text(
              NumberFormat.compact().format(commentList.length).toString(),
              style: Theme.of(context).textTheme.bodyText2,
            )
          ],
        ),
      ),
    );
  }

  _handleSavePost() async {
    if (_saved!) {
      _savedList!.remove(widget.postId);
      await users
          .doc(currentUser!.uid)
          .update({"savedPosts": _savedList}).then((value) {
        setState(() {
          _saved = !_saved!;
        });
      });
    } else if (!_saved!) {
      _savedList!.add(widget.postId);
      await users
          .doc(currentUser!.uid)
          .update({"savedPosts": _savedList}).then((value) {
        setState(() {
          _saved = !_saved!;
        });
      });
    }
  }

  // CommentButton goes here -------------------------------------------
  Widget _saveButton() {
    return GestureDetector(
      onTap: _handleSavePost,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: _buttonDecorations(),
        child: _buttonsIcon(
            _saved! ? Icons.bookmark_added : Icons.bookmark_add_outlined),
      ),
    );
  }

  // CommentButton goes here -------------------------------------------
  Widget _backButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(5),
          decoration: _buttonDecorations(),
          child: _buttonsIcon(Icons.arrow_back)),
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

  // All Button Decoration -------------------------------
  BoxDecoration _buttonDecorations() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      // border: Border.all(color: Theme.of(context).primaryColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor,
          blurRadius: 3,
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
      size: 26,
      color: Theme.of(context).primaryColor,
    );
  }
}

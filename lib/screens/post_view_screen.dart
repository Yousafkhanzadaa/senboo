import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senboo/screens/comment_screen.dart';
import 'package:intl/intl.dart';
import 'package:senboo/screens/visitor_screen.dart';
import 'package:senboo/services/firestore_services.dart';

class PostViewScreen extends StatefulWidget {
  PostViewScreen(
      {Key? key,
      required this.userName,
      required this.profession,
      required this.title,
      required this.body,
      required this.date,
      required this.category,
      required this.postId,
      required this.ownerId,
      this.reverse})
      : super(key: key);
  final String userName;
  final String profession;
  final String title;
  final String body;
  final DateTime date;
  final List category;
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
  bool? liked;
  bool? _saved;
  int likesCounter = 0;
  List likeList = [];
  List saveList = [];
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
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
      posts.doc(widget.postId).update({"likes": likeList});
    }
    if (!_liked) {
      likeList.add(currentUser!.uid);

      setState(() {
        likesCounter += 1;
        liked = true;
      });
      posts.doc(widget.postId).update({"likes": likeList});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 0,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
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
          _timerText(),
          SizedBox(
            height: 5,
          ),
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
          _categoryText(),
        ],
      ),
    );
  }

  // UserName and Profession Text here ------------------------------------
  Widget _userNameHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.userName,
          style: Theme.of(context).textTheme.headline1,
        ),
        Text(
          widget.profession,
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
          formatter.format(widget.date),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }

  // Category Text under TimerText here ----------------------------------
  Widget _categoryText() {
    return Text(
      "${widget.category.toString()}".toUpperCase(),
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
    return Text(
      widget.title,
      maxLines: 7,
      style: Theme.of(context).textTheme.headline3,
    );
  }

  // bodyText is Here -----------------------------------------------------
  Widget _bodyText() {
    return Text(
      widget.body,
      style: Theme.of(context).textTheme.bodyText1,
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
          _backButton(),
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
              padding: EdgeInsets.all(10),
              decoration: _buttonDecorations(),
              child: Column(
                children: [
                  _buttonsIcon(
                      liked! ? Icons.favorite : Icons.favorite_outline),
                  Text(
                    NumberFormat.compact().format(likesCounter).toString(),
                    style: Theme.of(context).textTheme.bodyText2,
                  )
                ],
              ),
            ),
          );
        }
        return Container();
      },
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
            ),
          ),
        );
      },
      child: Container(
          padding: EdgeInsets.all(10),
          decoration: _buttonDecorations(),
          child: _buttonsIcon(
            Icons.chat_bubble_outline,
          )),
    );
  }

  // CommentButton goes here -------------------------------------------
  Widget _saveButton() {
    return StreamBuilder<DocumentSnapshot>(
        stream: savedPosts
            .doc(currentUser!.uid)
            .collection("saved")
            .doc(widget.postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _saved = snapshot.data!.exists;
            return GestureDetector(
              onTap: () async {
                // _handlePostSave(saved!);

                FirestoreServices firestoreServices =
                    Provider.of<FirestoreServices>(context, listen: false);

                if (_saved!) {
                  await savedPosts
                      .doc(currentUser!.uid)
                      .collection("saved")
                      .doc(widget.postId)
                      .delete();
                } else if (!_saved!) {
                  await firestoreServices.savePost(
                    userId: currentUser!.uid,
                    postId: widget.postId,
                    userName: widget.userName,
                    body: widget.body,
                    category: widget.category,
                    date: widget.date,
                    likes: likeList,
                    profession: widget.profession,
                    title: widget.title,
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: _buttonDecorations(),
                child: _buttonsIcon(_saved!
                    ? Icons.bookmark_added
                    : Icons.bookmark_add_outlined),
              ),
            );
          }
          return Container(
              padding: EdgeInsets.all(10),
              decoration: _buttonDecorations(),
              child: _buttonsIcon(
                Icons.bookmark_outline,
              ));
        });
  }

  // CommentButton goes here -------------------------------------------
  Widget _backButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
          padding: EdgeInsets.all(10),
          decoration: _buttonDecorations(),
          child: _buttonsIcon(Icons.arrow_back)),
    );
  }

  // All Button Decoration -------------------------------
  BoxDecoration _buttonDecorations() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
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

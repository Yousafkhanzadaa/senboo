import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senboo/components/comment_card.dart';
import 'package:senboo/components/custom_text_field.dart';
import 'package:intl/intl.dart';
import 'package:senboo/model/comment_data.dart';

class CommentScreen extends StatefulWidget {
  CommentScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  final String postId;

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _commentTextContaller = TextEditingController();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  CommentData? commentData;

  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Date and time
  DateTime? dateTime;

  Map commentMap = {
    "userName": "userName",
    "profession": "profession",
    "title": "title",
    "date": null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: posts.doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            commentMap['title'] = snapshot.data!['title'];
            commentMap['date'] = snapshot.data!['date'].toDate();
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  _headingBox(),
                  _commentsList(),
                  _writeComment(),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  // First Part
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Upper HeadingBox -------------------------------------------
  Widget _headingBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 5, bottom: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.40),
            blurRadius: 5,
            offset: Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textTitle(),
          SizedBox(height: 5),
          // _timerText(),
        ],
      ),
    );
  }

  // TextTitle is here ---------------------------------------------------
  Widget _textTitle() {
    return Text(
      commentMap['title'],
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .bodyText1!
          .copyWith(color: Colors.white, fontSize: 16),
    );
  }

  // Comments view goes here ---------------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _commentsList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: comments
            .doc(widget.postId)
            .collection("postComments")
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List postsList = snapshot.data!.docs.toList();
            return postsList.isEmpty
                ? _cardNotFount()
                : ListView.builder(
                    itemCount: postsList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs;
                      commentData = CommentData.setData(data[index]);
                      return CommentCard(
                        comment: commentData!.comment!,
                        date: commentData!.date!.toDate(),
                        userName: commentData!.userName!,
                        ownerId: commentData!.ownerId!,
                        profession: commentData!.profession!,
                      );
                    },
                  );
          }

          return _loadingComments();
        },
      ),
    );
  }

  // comment not found

  Widget _cardNotFount() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.2,
            margin: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/svgs/comments.png")),
            )),
        Center(
          child: Text(
            "No comments",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingComments() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: 150,
            margin: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/svgs/comments.png")),
            )),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 60),
            child: LinearProgressIndicator(
              color: Theme.of(context).primaryColor,
              minHeight: 2,
            )),
      ],
    );
  }

  // Comments write goes here ---------------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Widget _writeComment() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _commentTextContaller,
              hint: 'comment',
            ),
          ),
          SizedBox(
            width: 4,
          ),
          _sendButton()
        ],
      ),
    );
  }

  // Send button goes here ---------------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _sendButton() {
    dateTime = DateTime.now();
    return StreamBuilder<DocumentSnapshot>(
        stream: users.doc(currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            commentMap['userName'] = snapshot.data!.get("userName");
            commentMap['profession'] = snapshot.data!.get("profession");
            return GestureDetector(
              onTap: () {
                if (_commentTextContaller.text.isNotEmpty) {
                  addComment(
                    postId: widget.postId,
                    userName: commentMap['userName'],
                    profession: commentMap['profession'],
                    comment: _commentTextContaller.text,
                    date: dateTime!,
                  );
                  setState(() {
                    _commentTextContaller.clear();
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: _buttonDecorations(),
                child: _buttonsIcon(
                  Icons.send_outlined,
                ),
              ),
            );
          }
          return Container(
              padding: EdgeInsets.all(10),
              decoration: _buttonDecorations(),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ));
        });
  }

  // Adding Comments ==================================================
  Future<void> addComment({
    required String userName,
    required String profession,
    required String comment,
    required String postId,
    required DateTime date,
  }) async {
    // var uidV4 = uid.v4();
    try {
      await comments.doc(postId).collection("postComments").add({
        "ownerId": currentUser!.uid,
        "userName": userName,
        "profession": profession,
        "date": date,
        "comment": comment,
      });
    } catch (e) {
      throw e;
    }
  }

  // All Button Decoration -------------------------------
  BoxDecoration _buttonDecorations() {
    return BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(35),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withOpacity(0.40),
          blurRadius: 5,
          offset: Offset(0, 0),
          spreadRadius: 1,
        ),
      ],
    );
  }

  // button icons ------------------------------------------
  Widget _buttonsIcon(IconData icon) {
    return Icon(
      icon,
      size: 26,
      color: Colors.white,
    );
  }
}

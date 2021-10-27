import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:senboo/components/comment_card.dart';
import 'package:senboo/components/custom_text_field.dart';
import 'package:intl/intl.dart';
import 'package:senboo/model/comment_data.dart';

class CommentScreen extends StatefulWidget {
  CommentScreen({
    Key? key,
    required this.postId,
    required this.ownerId,
  }) : super(key: key);

  final String postId;
  final String ownerId;

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
    'currentUserPhotoUrl': null,
    "profession": "profession",
    "title": "title",
    "date": null,
  };
  bool loaded = false;
  // Feeds
  CollectionReference feeds = FirebaseFirestore.instance.collection("feeds");

  @override
  void initState() {
    super.initState();
    _getPostDetails();
  }

  // Getting postDetails
  _getPostDetails() {
    users.doc(currentUser!.uid).get().then((snapshot) async {
      var currentPost = await posts.doc(widget.postId).get();
      setState(() {
        commentMap['userName'] = snapshot.get('userName');
        commentMap['profession'] = snapshot.get('profession');
        commentMap['currentUserPhotoUrl'] = snapshot.get('photoUrl');

        commentMap['title'] = currentPost.get('title');
        commentMap['date'] = currentPost.get('date');
        loaded = true;
      });
    });
  }

  removeComment({required String postId, required String commentId}) async {
    // DataProvider dataProvider =
    //     Provider.of<DataProvider>(context, listen: false);
    Navigator.pop(context);
    _showLoading();
    await comments
        .doc(postId)
        .collection('postComments')
        .doc(commentId)
        .delete();
    // dataProvider.getTotalLikes(ownerId: currentUser!.uid);
    Navigator.pop(context);
  }

  _addFeedItem() {
    if (currentUser!.uid != widget.ownerId) {
      feeds.doc(widget.ownerId).collection("feedItems").doc(widget.postId).set({
        "type": "comment",
        "userName": commentMap['userName'],
        "userId": currentUser!.uid,
        "postId": widget.postId,
        "ownerId": widget.ownerId,
        "timeStamp": DateTime.now(),
        "photoUrl": commentMap['currentUserPhotoUrl'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: !loaded
            ? _loadingComments()
            : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    _headingBox(),
                    _commentsList(),
                    _writeComment(),
                  ],
                ),
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
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .bodyText1!
          .copyWith(color: Colors.white, fontSize: 14),
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
                        postOwnerId: widget.ownerId,
                        photoUrl: commentData!.photoUrl,
                        removeComment: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Confirm Removing Comment'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      removeComment(
                                          postId: widget.postId,
                                          commentId: data[index].id);
                                    },
                                    child: Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
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
            "No comments yet.",
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

    return GestureDetector(
      onTap: () {
        if (_commentTextContaller.text.isNotEmpty) {
          addComment(
            postId: widget.postId,
            userName: commentMap['userName'],
            profession: commentMap['profession'],
            comment: _commentTextContaller.text,
            photoUrl: commentMap['currentUserPhotoUrl'],
            date: dateTime!,
          ).then((value) {
            _addFeedItem();
            setState(() {
              _commentTextContaller.clear();
            });

            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: _buttonDecorations(),
        alignment: Alignment.center,
        child: Center(
          child: _buttonsIcon(
            FontAwesomeIcons.paperPlane,
          ),
        ),
      ),
    );
  }

  // Adding Comments ==================================================
  Future<void> addComment({
    required String userName,
    required String profession,
    required String comment,
    required String postId,
    required String photoUrl,
    required DateTime date,
  }) async {
    // var uidV4 = uid.v4();
    try {
      await comments.doc(postId).collection("postComments").add({
        "ownerId": currentUser!.uid,
        "userName": userName,
        "profession": profession,
        "photoUrl": photoUrl,
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
      size: 20,
      color: Colors.white,
    );
  }

  _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 70,
            height: 200,
            decoration: _cardDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/svgs/loading.png")),
                    )),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 9.0, horizontal: 60),
                  child: LinearProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    minHeight: 2,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

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
}

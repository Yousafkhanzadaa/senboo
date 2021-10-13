import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senboo/model/get_user_data.dart';
import 'package:senboo/screens/post_view_screen.dart';

class SearchCard extends StatefulWidget {
  SearchCard({
    Key? key,
    required this.userName,
    required this.profession,
    required this.title,
    required this.body,
    required this.date,
    required this.category,
    required this.postId,
    required this.likes,
    required this.ownerId,
    required this.postData,
  }) : super(key: key);
  final String userName;
  final String profession;
  final String title;
  final String body;
  final DateTime date;
  final List category;
  final String postId;
  final List likes;
  final String ownerId;
  final PostData postData;

  @override
  _SearchCardState createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  Map cardData = {
    "userName": null,
    "profession": null,
    'photoUrl': null,
  };
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: users.doc(widget.ownerId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.exists) {
            cardData['profession'] = snapshot.data!['profession'];
            cardData['userName'] = snapshot.data!['userName'];
            cardData['photoUrl'] = snapshot.data!['photoUrl'];
          }
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostViewScreen(
                    userName: widget.postData.userName!,
                    profession: widget.postData.profession!,
                    title: widget.postData.title!,
                    body: widget.postData.body!,
                    date: widget.postData.date!.toDate(),
                    category: widget.postData.category!,
                    postId: widget.postData.postId!,
                    photoUrl: cardData['photoUrl'],
                    ownerId: widget.postData.ownerId!,
                    reverse: 1,
                  ),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              decoration: _cardDecoration(),
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
        return _loadingScreen();
      },
    );
  }

  // CardDecoration --------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(25),
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

  // First Part
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Upper HeadingBox -------------------------------------------
  Widget _headingBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _timerText(),
          SizedBox(height: 5),
          _userNameHeading(),
          SizedBox(
            height: 10,
          ),
          _categoryText(),
        ],
      ),
    );
  }

  Widget _loadingScreen() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      decoration: _cardDecoration(),
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  // UserName and Profession Text here ------------------------------------
  Widget _userNameHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cardData['userName'],
          style: Theme.of(context).textTheme.headline2,
        ),
        Text(
          cardData['profession'],
          style: Theme.of(context).textTheme.subtitle2,
        )
      ],
    );
  }

  // Timer Text under UserName here -----------------------------------------
  Widget _timerText() {
    return Row(
      children: [
        Icon(
          Icons.watch_later_outlined,
          size: 16,
          color: Colors.white,
        ),
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
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // Lower BodyBox --------------------------------------------------
  Widget _bodyBox() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(10),
      child: _textTitle(),
    );
  }

  // TextTitle is here ---------------------------------------------------
  Widget _textTitle() {
    return Text(
      widget.title,
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  //Second Part
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // action bar ----------------------
  Widget _actionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: _likeIndication(),
    );
  }

  // Like Indicaton ---------------------------
  Widget _likeIndication() {
    return Row(
      children: [
        Icon(
          Icons.favorite,
          size: 18,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          NumberFormat.compact().format(widget.likes.length).toString(),
          style: Theme.of(context).textTheme.bodyText2,
        )
      ],
    );
  }
}

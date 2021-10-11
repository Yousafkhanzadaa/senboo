import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senboo/screens/post_view_screen.dart';

class ProfilePostCard extends StatefulWidget {
  const ProfilePostCard(
      {Key? key,
      required this.userName,
      required this.title,
      required this.date,
      required this.category,
      required this.likes,
      required this.postId,
      this.options,
      this.updateFunction,
      this.deleteFunction,
      required this.body,
      required this.profession,
      required this.ownerId,
      required this.reverse})
      : super(key: key);
  final String userName;
  final String title;
  final String postId;
  final DateTime date;
  final List category;
  final List likes;
  final String body;
  final String profession;
  final String ownerId;
  final int? reverse;
  final Function? updateFunction;
  final Function? deleteFunction;

  final int? options;

  @override
  _ProfilePostCardState createState() => _ProfilePostCardState();
}

class _ProfilePostCardState extends State<ProfilePostCard> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');

  Map cardData = {
    "userName": "userName",
    "profession": "profession",
  };
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: users.doc(widget.ownerId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            cardData['userName'] = snapshot.data!['userName'];
            cardData['profession'] = snapshot.data!['profession'];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostViewScreen(
                      userName: cardData['userName'],
                      profession: cardData['profession'],
                      title: widget.title,
                      body: widget.body,
                      date: widget.date,
                      category: widget.category,
                      postId: widget.postId,
                      ownerId: widget.ownerId,
                      reverse: widget.reverse,
                    ),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.47,
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
          return Container(
            width: MediaQuery.of(context).size.width * 0.47,
            margin: EdgeInsets.all(10),
            decoration: _cardDecoration(),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        });
  }

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

  Widget popUpButton() => Container(
        width: 30,
        child: PopupMenuButton(
          color: Colors.white,
          icon: Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text(
                'Edit',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              value: 1,
            ),
            PopupMenuItem(
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              value: 2,
            ),
          ],
          onSelected: (value) {
            if (value == 1) {
              widget.updateFunction!();
            }
            if (value == 2) {
              widget.deleteFunction!();
            }
          },
        ),
      );

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _timerText(),
                    SizedBox(
                      height: 5,
                    ),
                    _userNameHeading(),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
              widget.options != null ? popUpButton() : SizedBox(),
            ],
          ),
          _categoryText(),
        ],
      ),
    );
  }

  Widget _userNameHeading() {
    return Text(
      cardData['userName'],
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .bodyText1!
          .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
    );
  }

  Widget _timerText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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

  Widget _categoryText() {
    return Text(
      "${widget.category.toString()}".toUpperCase(),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: Theme.of(context).textTheme.subtitle2,
    );
  }

  Widget _bodyBox() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.topLeft,
        child: _textTitle(),
      ),
    );
  }

  Widget _textTitle() {
    return Text(
      widget.title,
      overflow: TextOverflow.ellipsis,
      maxLines: 6,
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  Widget _actionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: _likeIndication(),
    );
  }

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

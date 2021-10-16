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
      required this.photoUrl,
      this.options,
      this.updateFunction,
      this.deleteFunction,
      this.likeFun,
      required this.body,
      required this.profession,
      required this.ownerId,
      required this.reverse})
      : super(key: key);
  final String userName;
  final String title;
  final String postId;
  final String photoUrl;
  final DateTime date;
  final List category;
  final List likes;
  final String body;
  final String profession;
  final String ownerId;
  final int? reverse;
  final Function? updateFunction;
  final Function? deleteFunction;
  final Function? likeFun;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostViewScreen(
              userName: widget.userName,
              profession: widget.profession,
              title: widget.title,
              body: widget.body,
              date: widget.date,
              category: widget.category,
              postId: widget.postId,
              ownerId: widget.ownerId,
              photoUrl: widget.photoUrl,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withOpacity(0.40),
          blurRadius: 3,
          offset: Offset(0, 0),
          // spreadRadius: 1,
        ),
      ],
    );
  }

  // Widget _loadingScreen() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.47,
  //     margin: EdgeInsets.symmetric(
  //       vertical: 10,
  //       horizontal: 10,
  //     ),
  //     decoration: _cardDecoration(),
  //     child: Center(
  //       child: CircularProgressIndicator(
  //         color: Theme.of(context).primaryColor,
  //       ),
  //     ),
  //   );
  // }

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
      widget.userName,
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
    return GestureDetector(
      onTap: () {
        widget.likeFun!();
      },
      child: Container(
        // height: 20,
        child: Row(
          children: [
            Icon(
              Icons.favorite,
              size: 22,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(
              width: 5,
            ),
            widget.likes.length == 0
                ? Container()
                : _showLikedImages(widget.likes.length),
            SizedBox(
              width: 3,
            ),
            Text(
              NumberFormat.compact().format(widget.likes.length).toString(),
              style:
                  Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 12),
            )
          ],
        ),
      ),
    );
  }

  _showLikedImages(int count) {
    if (count >= 3) {
      return Container(
        width: 35,
        child: Stack(
          children: [
            Positioned(child: _likedImages("assets/images/dps/02.jpg")),
            Positioned(
                left: 5, child: _likedImages("assets/images/dps/01.jpg")),
            Positioned(
                left: 10, child: _likedImages("assets/images/dps/03.jpg")),
          ],
        ),
      );
    } else if (count == 2) {
      return Container(
        width: 25,
        child: Stack(
          children: [
            Positioned(child: _likedImages("assets/images/dps/02.jpg")),
            Positioned(
                left: 5, child: _likedImages("assets/images/dps/01.jpg")),
          ],
        ),
      );
    } else {
      return Container(
        width: 20,
        child: Stack(
          children: [
            Positioned(child: _likedImages("assets/images/dps/02.jpg")),
          ],
        ),
      );
    }
  }

  Widget _likedImages(String link) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
            image: AssetImage(link),
            alignment: Alignment.center,
            fit: BoxFit.cover),
      ),
    );
  }
}

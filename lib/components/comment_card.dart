import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senboo/screens/visitor_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends StatefulWidget {
  CommentCard(
      {Key? key,
      required this.userName,
      required this.profession,
      required this.comment,
      required this.ownerId,
      required this.postOwnerId,
      this.photoUrl,
      this.removeComment,
      required this.date})
      : super(key: key);
  final String userName;
  final String profession;
  final String comment;

  final Function? removeComment;
  final String ownerId;
  final String? photoUrl;
  final String postOwnerId;
  final DateTime date;

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  // bool liked = false;
  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.97,
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _headingBox(),
          _commentbox(),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
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

  // HEader box goes here-----------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _headingBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        top: 5,
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
          Row(
            children: [
              widget.photoUrl == null
                  ? SizedBox()
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(widget.photoUrl!)),
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
              SizedBox(
                width: 5,
              ),
              Expanded(child: _userNameHeading()),
              widget.ownerId == currentUser!.uid ||
                      widget.postOwnerId == currentUser!.uid
                  ? popUpButton()
                  : SizedBox(),
            ],
          ),
          // SizedBox(
          //   height: 5,
          // ),
          _timeAgo(),
        ],
      ),
    );
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16),
          ),
          Text(
            widget.profession,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ],
      ),
    );
  }

  Widget _timeAgo() {
    return Row(
      children: [
        // Icon(
        //   Icons.watch_later_outlined,
        //   size: 16,
        //   color: Colors.white,
        // ),
        Text(
          timeago.format(widget.date),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }

  // Comment Box goes here-----------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _commentbox() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      alignment: Alignment.topLeft,
      child: _textTitle(),
    );
  }

  Widget _textTitle() {
    return Text(
      widget.comment,
      style: Theme.of(context).textTheme.bodyText1,
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
                'Remove comment',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              value: 1,
            ),
          ],
          onSelected: (value) {
            if (value == 1) {
              widget.removeComment!();
            }
          },
        ),
      );
}

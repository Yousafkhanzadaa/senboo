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
      required this.date})
      : super(key: key);
  final String userName;
  final String profession;
  final String comment;
  final String ownerId;
  final DateTime date;

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool liked = false;
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

  // HEader box goes here-----------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
          _timeAgo(),
          _userNameHeading(),
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
            style: Theme.of(context).textTheme.headline2,
          ),
          Text(
            widget.profession,
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
      padding: EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
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
}

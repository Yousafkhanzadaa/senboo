import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senboo/screens/post_view_screen.dart';
import 'package:senboo/screens/visitor_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatefulWidget {
  NotificationCard({
    Key? key,
    required this.userName,
    required this.date,
    required this.type,
    required this.postId,
    required this.ownerId,
    // required this.date,
  }) : super(key: key);
  final String userName;
  final Timestamp date;
  final String type;
  final String postId;
  final String ownerId;
  // final DateTime date;

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: _headingBox(),
    );
  }

  // BoxDecoration _cardDecoration() {
  //   return BoxDecoration(
  //     color: Theme.of(context).cardColor,
  //     borderRadius: BorderRadius.circular(15),
  //     boxShadow: [
  //       BoxShadow(
  //         color: Theme.of(context).shadowColor,
  //         blurRadius: 3,
  //         offset: Offset(0, 0),
  //         // spreadRadius: 1,
  //       ),
  //     ],
  //   );
  // }

  // HEader box goes here-----------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _headingBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.97,
      margin: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _userNameHeading(),
          SizedBox(
            height: 5,
          ),
          _timeAgo(),
        ],
      ),
    );
  }

  Widget _userNameHeading() {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => VisitorProfileScreen(ownerId: widget.ownerId),
        //   ),
        // );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.userName,
            style:
                Theme.of(context).textTheme.headline2!.copyWith(fontSize: 18),
          ),
          Text(
            widget.type == 'like'
                ? "Liked you post"
                : (widget.type == 'comment'
                    ? "Commented on your post."
                    : "Saved your post."),
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
          timeago.format(widget.date.toDate()),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }

  // Comment Box goes here-----------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//   Widget _commentbox() {
//     return Container(
//       padding: EdgeInsets.only(top: 10, bottom: 30, left: 10, right: 10),
//       alignment: Alignment.topLeft,
//       child: _textTitle(),
//     );
//   }

//   Widget _textTitle() {
//     return Text(
//       widget.comment,
//       style: Theme.of(context).textTheme.bodyText1,
//     );
//   }
}

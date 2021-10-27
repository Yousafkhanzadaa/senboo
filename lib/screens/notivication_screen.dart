import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senboo/components/notification_card.dart';
import 'package:senboo/model/feed_data.dart';
import 'package:senboo/model/get_user_data.dart';
import 'package:senboo/providers/notiry_provider.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Feeds
  CollectionReference feeds = FirebaseFirestore.instance.collection("feeds");
  FeedData? feedData;

  @override
  void initState() {
    super.initState();

    NotifyProvider notifyProvider =
        Provider.of<NotifyProvider>(context, listen: false);
    if (notifyProvider.getNotifyCount != 0) {
      notifyProvider.setNotifyCount(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showNotifications();
  }

  _showNotifications() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: StreamBuilder<QuerySnapshot>(
        stream: feeds
            .doc(currentUser!.uid)
            .collection("feedItems")
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List postsList = snapshot.data!.docs;
            return postsList.isEmpty
                ? _blankField()
                : ListView.builder(
                    itemCount: postsList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs.toList();
                      feedData = FeedData.setData(data[index]);
                      return NotificationCard(
                        // comment: feedData!.comment!,
                        // date: feedData!.date!.toDate(),
                        ownerId: feedData!.ownerId!,
                        userName: feedData!.userName!,
                        photoUrl: feedData!.photoUrl!,
                        postId: feedData!.postId!,
                        type: feedData!.type!,
                        date: feedData!.date!,
                      );
                    },
                  );
          }

          return _loadingNotifications();
        },
      ),
    );
  }

  // field is empty
  Widget _blankField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // height: MediaQuery.of(context).size.height * 0.2,
          margin: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          child: Icon(
            Icons.notifications,
            color: Theme.of(context).primaryColor,
            size: 170,
          ),
        ),
        Center(
          child: Text(
            "No Feeds",
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

  Widget _loadingNotifications() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // height: MediaQuery.of(context).size.height * 0.2,
          margin: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          child: Icon(
            Icons.notifications,
            color: Theme.of(context).primaryColor,
            size: 170,
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 60),
            child: LinearProgressIndicator(
              color: Theme.of(context).primaryColor,
              minHeight: 2,
            )),
      ],
    );
  }
}

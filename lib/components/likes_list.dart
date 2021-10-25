import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senboo/model/user_data.dart';
import 'package:senboo/screens/visitor_screen.dart';

class LikeList extends StatefulWidget {
  LikeList({Key? key, required this.likeList}) : super(key: key);
  final List likeList;

  @override
  _LikeListState createState() => _LikeListState();
}

class _LikeListState extends State<LikeList> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  UserData? userData;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: _cardDecoration(),
      child: GridView.builder(
        itemCount: widget.likeList.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          return _showLikeCard(index: index, ownerId: widget.likeList[index]);
        },
      ),
    );
  }

  Widget _showLikeCard({required int index, required String ownerId}) {
    return FutureBuilder(
      future: users.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          userData = UserData.setData(snapshot);
          return _likeCard(
            imgUrl: userData!.photoUrl!,
            userName: userData!.userName!,
            ownerId: ownerId,
            profession: userData!.profession!,
          );
        }
        return Container(
          margin: EdgeInsets.symmetric(vertical: 25),
          child: LinearProgressIndicator(
            color: Theme.of(context).primaryColor,
            minHeight: 1,
          ),
        );
      },
    );
  }

  Widget _likeCard({
    required String imgUrl,
    required String userName,
    required String profession,
    required String ownerId,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisitorProfileScreen(ownerId: ownerId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imgUrl)),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // CardDecoration --------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor,
          blurRadius: 3,
          offset: Offset(0, 0),
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:senboo/model/user_data.dart';
// import 'package:senboo/screens/edit_profile.dart';
import 'package:intl/intl.dart';

class VisitorProfileCard extends StatefulWidget {
  VisitorProfileCard(
      {Key? key,
      required this.totalPosts,
      required this.totalLikes,
      required this.ownerId})
      : super(key: key);

  final int totalPosts;
  final int totalLikes;
  final String ownerId;

  @override
  _VisitorProfileCardState createState() => _VisitorProfileCardState();
}

class _VisitorProfileCardState extends State<VisitorProfileCard> {
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  // // Current User
  // User? currentUser = FirebaseAuth.instance.currentUser;
  // userData modal
  UserData? userData;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: users.doc(widget.ownerId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorScreen();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          userData = UserData.setData(snapshot);
          return Container(
            width: MediaQuery.of(context).size.width * 0.97,
            // height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _profilePic(userData!.photoUrl!),
                _basicDetails(
                  userName: userData!.userName!,
                  profession: userData!.profession!,
                ),
                SizedBox(height: 15),
                _socialLinks(
                  instagram: userData!.socialLinks![0],
                  twitter: userData!.socialLinks![1],
                ),
                Divider(
                  color: Theme.of(context).primaryColor,
                  height: 10,
                ),
                SizedBox(height: 10),
                _postLikeInd(),
                SizedBox(height: 20),
                _bio(bio: userData!.bio!),
                SizedBox(height: 25),
                Icon(
                  Icons.arrow_downward,
                  size: 22,
                  color: Theme.of(context).primaryColor,
                )
              ],
            ),
          );
        }
        return _loadingScreen();
      },
    );
  }

  // Error Screen ----------------------------------------------------
  Widget _errorScreen() {
    return Center(
        child: Text(
      "Something went wrong\nCheck you internet connection",
      style: Theme.of(context)
          .textTheme
          .headline1!
          .copyWith(color: Colors.white70),
    ));
  }

  // Load Screen ---------------------------------------------
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

  //_profile Pic is here--------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _profilePic(String photoUrl) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: Colors.black26,
          image: DecorationImage(image: NetworkImage(photoUrl))),
    );
  }

  //UserName ,Profession and location is here-----------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _basicDetails({required String userName, required String profession}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10),
          Text(
            profession.toUpperCase(),
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  //social links are here----------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _socialLinks({String? instagram, String? twitter}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _linkIconButton(FontAwesomeIcons.instagram, "0xFF833AB4", instagram!),
          SizedBox(
            height: 10,
          ),
          _linkIconButton(FontAwesomeIcons.twitter, "0xFF1DA1F2", twitter!),
        ],
      ),
    );
  }

  Widget _linkIconButton(IconData icon, String colorCode, String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          userName,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Color(0xFF616161),
              ),
        ),
      ],
    );
  }

  //Post and like indicator are here----------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _postLikeInd() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _inds("Posts", widget.totalPosts),
          SizedBox(width: MediaQuery.of(context).size.width * 0.25),
          _inds("Likes", widget.totalLikes),
        ],
      ),
    );
  }

  Widget _inds(String ind, int count) {
    return Column(
      children: [
        Text(
          ind.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontWeight: FontWeight.w700, color: Color(0xFF616161)),
        ),
        Text(
          NumberFormat.compact().format(count).toString(),
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Color(0xFF616161)),
        ),
      ],
    );
  }

  //bio are here----------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Widget _bio({required String bio}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Bio",
            style: Theme.of(context)
                .textTheme
                .headline3!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            bio,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: Color(0xFF3B3B3B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  //Profile Edit button are here----------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  // Widget _profileEditButton() {
  //   return ElevatedButton(
  //     onPressed: () {
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => EditProfile()));
  //     },
  //     style: ButtonStyle(
  //         backgroundColor:
  //             MaterialStateProperty.all(Theme.of(context).primaryColor),
  //         shadowColor:
  //             MaterialStateProperty.all(Theme.of(context).primaryColor),
  //         padding: MaterialStateProperty.all(
  //             EdgeInsets.symmetric(vertical: 15, horizontal: 25)),
  //         shape: MaterialStateProperty.all(
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)))),
  //     child: Text(
  //       "edit profile".toUpperCase(),
  //       style: Theme.of(context).textTheme.subtitle2,
  //     ),
  //   );
  // }
}

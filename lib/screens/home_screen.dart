import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senboo/components/Ads.dart';
import 'package:senboo/components/interest_button.dart';
import 'package:senboo/components/post_card.dart';
import 'package:senboo/model/get_user_data.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  PostData? postData;
  bool gotList = false;
  int limit = 100;
  List postsList = [];
  bool loaded = false;

  final List<String> _fieldButtonNames = [
    "Quote",
    "Motivation",
    "Idea",
    "Poetry",
    "Story",
    "philosophy",
    "Science & Technology",
    "News",
    "Lifestyle",
    "Finance & Economics",
    "Business",
    "Health & Medicine",
    "Art & Culture",
    "Entertainment",
    "Urdu",
  ];
  List<dynamic> _interestedList = [];
  List<dynamic> _newInterestedList = [];

  Map currentUserInfo = {
    'currentUserName': null,
    'currentUserPhotoUrl': null,
  };
  // List interestList = [];

  @override
  void initState() {
    super.initState();

    // getInterested();
    getTimeLine();
  }

  Widget showAd(bool show) {
    if (show) {
      return Ads();
    } else {
      return Container();
    }
  }

  Future<dynamic> getTimeLine() async {
    // List iList = [];
    setState(() {
      loaded = false;
    });
    users.doc(currentUser!.uid).get().then((userSnapshot) {
      // EditListController editListController =
      //     Provider.of<EditListController>(context, listen: false);

      _interestedList = userSnapshot.get('interested');

      if (_interestedList.isNotEmpty) {
        posts
            .where(
              "category",
              arrayContainsAny: _interestedList,
            )
            .orderBy('date', descending: true)
            .limit(35)
            .get()
            .then((postSnapshot) {
          setState(() {
            postsList = postSnapshot.docs;
            currentUserInfo['currentUserName'] = userSnapshot.get('userName');
            currentUserInfo['currentUserPhotoUrl'] =
                userSnapshot.get('photoUrl');
            loaded = true;
          });
        });
      } else {
        setState(() {
          _interestedList = userSnapshot.get('interested');
          loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loaded) {
      if (_interestedList.isNotEmpty) {
        return postsList.isEmpty
            ? _noPosts()
            : RefreshIndicator(
                onRefresh: getTimeLine,
                child: ListView.builder(
                  shrinkWrap: true,
                  // scrollDirection: Axis.vertical,

                  itemCount: postsList.length,
                  itemBuilder: (context, index) {
                    // var data = snapshot.data!.docs;
                    postData = PostData.setData(postsList[index]);

                    return Column(
                      children: [
                        PostCard(
                          userName: postData!.userName!,
                          profession: postData!.profession!,
                          title: postData!.title!,
                          body: postData!.body!,
                          date: postData!.date!.toDate(),
                          category: postData!.category!,
                          likes: postData!.likes!,
                          postId: postData!.postId!,
                          ownerId: postData!.ownerId!,
                          photoUrl: postData!.photoUrl!,
                          currentUserName:
                              currentUserInfo['currentUserName'] ?? "Someone",
                          currentUserPhotoUrl: currentUserInfo[
                                  'currentUserPhotoUrl'] ??
                              "https://i.pinimg.com/originals/0c/3b/3a/0c3b3adb1a7530892e55ef36d3be6cb8.png",
                        ),
                        showAd(index % 3 == 0),
                      ],
                    );
                  },
                ),
              );
      }
      return _editPro();
    }
    return _searching();
  }

  // Error Screen ----------------------------------------------------
  Widget _errorScreen() {
    return Center(
        child: Text(
      "Something went wrong\nCheck you internet connection",
      style: Theme.of(context)
          .textTheme
          .headline1!
          .copyWith(color: Theme.of(context).primaryColor),
    ));
  }

  // Load Screen ---------------------------------------------
  Widget _searching() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      // decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/svgs/post.png")),
              )),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 60),
            child: LinearProgressIndicator(
              color: Theme.of(context).primaryColor,
              minHeight: 2,
            ),
          )
        ],
      ),
    );
  }

  // Load Screen ---------------------------------------------
  Widget _editPro() {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.4,

      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 10,
      ),
      decoration: _cardDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/svgs/welcome.png")),
                )),
            SizedBox(
              height: 10,
            ),
            Text(
              "Please first select your fields of interests and then save.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _intrestButtonsField(),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              child: _saveInterestsButton(),
            ),
          ],
        ),
      ),
    );
  }

// mo posts found
  Widget _noPosts() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 10,
      ),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.25,
              margin: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/svgs/inbox.png")),
              )),
          Center(
            child: Text(
              "No posts available for your fields of interests yet!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveInterestsButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_newInterestedList.isNotEmpty) {
          await users.doc(currentUser!.uid).update({
            "interested": _newInterestedList,
          }).then((value) {
            setState(() {
              _interestedList = _newInterestedList;
            });
          });
        } else {
          var snackBar = SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text('Please select fields of interests'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          shadowColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 15, horizontal: 25)),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)))),
      child: Text(
        "save".toUpperCase(),
        style: Theme.of(context).textTheme.subtitle2,
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
          color: Theme.of(context).primaryColor.withOpacity(0.40),
          blurRadius: 3,
          offset: Offset(0, 0),
          // spreadRadius: 1,
        ),
      ],
    );
  }

  // intrust Fields -----------------------------------------
  Widget _intrestButtonsField() {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      // width: MediaQuery.of(context).size.width,
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _fieldButtonNames.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InterestButton(
              name: _fieldButtonNames[index],
              onPressed: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                currentFocus.unfocus();

                setState(() {
                  if (_newInterestedList.contains(_fieldButtonNames[index])) {
                    _newInterestedList.remove(_fieldButtonNames[index]);
                  } else {
                    if (_newInterestedList.length < 10) {
                      _newInterestedList.add(_fieldButtonNames[index]);
                    } else {
                      var snackBar = SnackBar(
                          backgroundColor: Theme.of(context).primaryColor,
                          content: Text(
                              'You can select only ten fields of interests'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                });
              },
              interested: _newInterestedList.contains(_fieldButtonNames[index])
                  ? true
                  : false,
            ),
          );
        },
      ),
    );
  }
}

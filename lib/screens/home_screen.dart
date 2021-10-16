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
  // List interestList = [];

  @override
  void initState() {
    super.initState();

    getInterested();
  }

  getInterested() {
    users.doc(currentUser!.uid).get().then((snapshot) {
      // EditListController editListController =
      //     Provider.of<EditListController>(context, listen: false);

      setState(() {
        _interestedList = snapshot['interested'];
        gotList = true;
      });
    });
  }

  Widget showAd(bool show) {
    if (show) {
      return Ads();
    } else {
      return Container();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      limit += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gotList) {
      return _interestedList.isEmpty
          ? _editPro()
          : StreamBuilder<QuerySnapshot>(
              stream: posts
                  .where(
                    "category",
                    arrayContainsAny: _interestedList,
                  )
                  .orderBy('date', descending: true)
                  .limit(limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _errorScreen();
                }
                if (snapshot.hasData) {
                  var postsList = snapshot.data!.docs;
                  return postsList.isEmpty
                      ? _noPosts()
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          color: Theme.of(context).primaryColor,
                          child: ListView.builder(
                            shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
                            physics: ScrollPhysics(),
                            addRepaintBoundaries: false,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data!.docs;
                              postData = PostData.setData(data[index]);

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
                                  ),
                                  showAd(index % 3 == 0),
                                ],
                              );
                              // : PostCard(
                              //     userName: postData!.userName!,
                              //     profession: postData!.profession!,
                              //     title: postData!.title!,
                              //     body: postData!.body!,
                              //     date: postData!.date!.toDate(),
                              //     category: postData!.category!,
                              //     likes: postData!.likes!,
                              //     postId: postData!.postId!,
                              //     ownerId: postData!.ownerId!,
                              //   );
                            },
                          ),
                        );
                }
                return _loadingScreen();
              },
            );
    }
    return _loadingScreen();
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

  // Load Screen ---------------------------------------------
  Widget _editPro() {
    return Column(
      children: [
        Container(
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
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "We're glad you decide to join the Senboo family!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Please first select your fields of interests and then save.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18,
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
        ),
      ],
    );
  }

// mo posts found
  Widget _noPosts() {
    return Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
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

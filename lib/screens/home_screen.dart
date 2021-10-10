import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senboo/components/Ads.dart';
import 'package:senboo/components/post_card.dart';
import 'package:senboo/model/get_user_data.dart';
import 'package:senboo/providers/edit_list_controller.dart';
import 'package:senboo/screens/edit_profile.dart';

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
  // List interestList = [];

  @override
  void initState() {
    super.initState();

    getInterested();
  }

  getInterested() {
    users.doc(currentUser!.uid).get().then((snapshot) {
      EditListController editListController =
          Provider.of<EditListController>(context, listen: false);

      setState(() {
        editListController.setList = snapshot.get('interested');
        gotList = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    EditListController editListController =
        Provider.of<EditListController>(context);
    if (gotList) {
      return editListController.getList.isEmpty
          ? _editPro()
          : StreamBuilder<QuerySnapshot>(
              stream: posts
                  .where(
                    "category",
                    arrayContainsAny: editListController.getList,
                  )
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _errorScreen();
                }
                if (snapshot.hasData) {
                  var postsList = snapshot.data!.docs;
                  return postsList.isEmpty
                      ? _noPosts()
                      : Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data!.docs;
                              postData = PostData.setData(data[index]);
                              return index % 3 == 0
                                  ? Column(
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
                                        ),
                                        SizedBox(height: 5),
                                        Ads(),
                                      ],
                                    )
                                  : PostCard(
                                      userName: postData!.userName!,
                                      profession: postData!.profession!,
                                      title: postData!.title!,
                                      body: postData!.body!,
                                      date: postData!.date!.toDate(),
                                      category: postData!.category!,
                                      likes: postData!.likes!,
                                      postId: postData!.postId!,
                                      ownerId: postData!.ownerId!,
                                    );
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      decoration: _cardDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Please first edit your profile.",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Text(
            //   "No interests selected.",
            //   style: TextStyle(
            //     color: Theme.of(context).primaryColor,
            //     fontSize: 18,
            //   ),
            // ),
            SizedBox(
              height: 10,
            ),
            _profileEditButton(),
          ],
        ),
      ),
    );
  }

  // Load Screen ---------------------------------------------
  Widget _noPosts() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "No Posts available for your interests yet!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileEditButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
                context, MaterialPageRoute(builder: (context) => EditProfile()))
            .then((value) => setState(() {}));
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
        "edit profile".toUpperCase(),
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
          blurRadius: 5,
          offset: Offset(0, 0),
          spreadRadius: 1,
        ),
      ],
    );
  }
}

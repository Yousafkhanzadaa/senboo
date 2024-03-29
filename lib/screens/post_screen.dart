import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:senboo/components/custom_text_field.dart';
import 'package:senboo/components/interest_button.dart';
import 'package:senboo/model/user_data_update.dart';
// import 'package:senboo/services/firestore_services.dart';
import 'package:uuid/uuid.dart';

class PostScreen extends StatefulWidget {
  PostScreen({Key? key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _mainTitleController = TextEditingController();
  final TextEditingController _bodyTextController = TextEditingController();
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // userPosts collection
  CollectionReference userPosts =
      FirebaseFirestore.instance.collection("usersPosts");
  UserDataUpdate? userData;
  List<String> _categories = [];

  Uuid uid = Uuid();
  DateTime? dateTime;

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _mainTitleController.dispose();
    _bodyTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Post"),
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: _editForm(),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: postButton,
            isExtended: true,
            backgroundColor: Theme.of(context).primaryColor,
            extendedPadding: EdgeInsets.symmetric(horizontal: 60),
            heroTag: "post@@",
            label: Text(
              "Post".toUpperCase(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          )),
    );
  }

  postButton() async {
    dateTime = DateTime.now();
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.unfocus();
    if (_categories.isEmpty) {
      var snackBar = SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text('please select post category.\nscroll horizontal.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    if (_categories.isNotEmpty) {
      if (_formKey.currentState!.validate()) {
        _showLoading();
        await users.doc(currentUser!.uid).get().then((snapshot) {
          userData = UserDataUpdate.setData(snapshot);
          List searchKeywords =
              _mainTitleController.text.toLowerCase().split(" ") +
                  userData!.userName!.toLowerCase().split(" ") +
                  [userData!.userName!.toLowerCase()];

          while (searchKeywords.contains("")) {
            searchKeywords.remove("");
          }
          while (searchKeywords.contains(" ")) {
            searchKeywords.remove(" ");
          }
          addPost(
            userName: userData!.userName!,
            profession: userData!.profession!,
            photoUrl: userData!.photoUrl!,
            category: _categories,
            title: _mainTitleController.text,
            body: _bodyTextController.text,
            searchKeywords: searchKeywords,
            date: dateTime!,
          );
        }).whenComplete(() {
          setState(() {
            _mainTitleController.text = "";
            _bodyTextController.text = "";
            _categories.clear();
          });
          Navigator.pop(context);
        });
      }
    }
  }

  // form goes here -------------------------------------
  Widget _editForm() {
    return Container(
      // width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: _formBackDecoration(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _categoryButtonsField(),
            _basicFields(),
            SizedBox(
              height: 20,
            ),
            // SizedBox(
            //   width: MediaQuery.of(context).size.width * 0.80,
            //   child: _postButton(),
            // ),
          ],
        ),
      ),
    );
  }

  // formback decoration ---------------------------------
  BoxDecoration _formBackDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      // borderRadius: BorderRadius.only(
      //   topLeft: Radius.circular(25),
      //   topRight: Radius.circular(25),
      // ),
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

  // basic fields ---------------------------------
  Widget _basicFields() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _mainTitleController,
              hint: "Title",
              label: "Main Title",
              maxLines: 6,
              validator: (value) {
                // if (value!.length > 140) {
                //   return "Title is too long";
                // }
                if (value!.isEmpty) {
                  return "Field must not be empty";
                }
                return null;
              },
            ),
            SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: _bodyTextController,
              hint: "Body text (optional)",
              label: "Body text (optional)",
              maxLines: 10,
            ),
          ],
        ),
      ),
    );
  }

  // intrust Fields -----------------------------------------
  Widget _categoryButtonsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15,
        ),
        RichText(
          text: TextSpan(
            text: "Select Post Category",
            style: Theme.of(context).textTheme.bodyText1,
            children: <TextSpan>[],
          ),
        ),
        Container(
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
                      if (_categories.contains(_fieldButtonNames[index])) {
                        _categories.remove(_fieldButtonNames[index]);
                      } else {
                        if (_categories.length < 3) {
                          _categories.add(_fieldButtonNames[index]);
                        } else {
                          var snackBar = SnackBar(
                              backgroundColor: Theme.of(context).primaryColor,
                              content:
                                  Text('You can select only three categories'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    });
                  },
                  interested: _categories.contains(_fieldButtonNames[index])
                      ? true
                      : false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // show loading
  _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 70,
            height: 200,
            decoration: _cardDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/svgs/loading.png")),
                    )),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 9.0, horizontal: 60),
                  child: LinearProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    minHeight: 2,
                  ),
                )
              ],
            ),
          ),
        );
      },
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
        ),
      ],
    );
  }

  // save buttan goes here -0------------------------------------
  // Widget _postButton() {
  //   dateTime = DateTime.now();

  //   return ElevatedButton(
  //     onPressed: () async {
  //       FocusScopeNode currentFocus = FocusScope.of(context);
  //       currentFocus.unfocus();
  //       if (_categories.isEmpty) {
  //         var snackBar = SnackBar(
  //             backgroundColor: Theme.of(context).primaryColor,
  //             content:
  //                 Text('please select post category.\nscroll horizontal.'));
  //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //       }
  //       if (_categories.isNotEmpty) {
  //         if (_formKey.currentState!.validate()) {
  //           _showLoading();
  //           await users.doc(currentUser!.uid).get().then((snapshot) {
  //             userData = UserDataUpdate.setData(snapshot);
  //             List searchKeywords =
  //                 _mainTitleController.text.toLowerCase().split(" ") +
  //                     userData!.userName!.toLowerCase().split(" ") +
  //                     [userData!.userName!.toLowerCase()];

  //             while (searchKeywords.contains("")) {
  //               searchKeywords.remove("");
  //             }
  //             while (searchKeywords.contains(" ")) {
  //               searchKeywords.remove(" ");
  //             }
  //             addPost(
  //               userName: userData!.userName!,
  //               profession: userData!.profession!,
  //               photoUrl: userData!.photoUrl!,
  //               category: _categories,
  //               title: _mainTitleController.text,
  //               body: _bodyTextController.text,
  //               searchKeywords: searchKeywords,
  //               date: dateTime!,
  //             );
  //           }).whenComplete(() {
  //             setState(() {
  //               _mainTitleController.text = "";
  //               _bodyTextController.text = "";
  //               _categories.clear();
  //             });
  //             Navigator.pop(context);
  //           });
  //         }
  //       }
  //     },
  //     style: ButtonStyle(
  //         backgroundColor:
  //             MaterialStateProperty.all(Theme.of(context).primaryColor),
  //         shadowColor:
  //             MaterialStateProperty.all(Theme.of(context).primaryColor),
  //         padding: MaterialStateProperty.all(
  //             EdgeInsets.symmetric(vertical: 15, horizontal: 65)),
  //         shape: MaterialStateProperty.all(
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)))),
  //     child: Text(
  //       "Post".toUpperCase(),
  //       style: Theme.of(context).textTheme.subtitle2,
  //     ),
  //   );
  // }

  // Adding Posts...............................................
  Future<void> addPost({
    required String userName,
    required String profession,
    required List<String> category,
    required String title,
    required String body,
    required String photoUrl,
    required List searchKeywords,
    required DateTime date,
  }) async {
    var uidV4 = uid.v4();
    try {
      // await posts.doc(uidV4).set({
      //   "ownerId": currentUser!.uid,
      //   "userName": userName,
      //   "profession": profession,
      //   "date": date,
      //   "category": category,
      //   "title": title,
      //   "body": body,
      //   "searchKeywords": searchKeywords,
      //   "postId": uidV4,
      //   "photoUrl": photoUrl,
      //   "likes": [],
      // });
      await userPosts
          .doc(currentUser!.uid)
          .collection("userPost")
          .doc(uidV4)
          .set({
        "ownerId": currentUser!.uid,
        "userName": userName,
        "profession": profession,
        "date": date,
        "category": category,
        "title": title,
        "body": body,
        "searchKeywords": searchKeywords,
        "postId": uidV4,
        "photoUrl": photoUrl,
        "likes": [],
      });
    } catch (e) {
      throw e;
    }
  }
}

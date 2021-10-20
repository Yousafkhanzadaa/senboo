import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senboo/components/custom_text_field.dart';
import 'package:senboo/components/interest_button.dart';

class UpdatePostScreen extends StatefulWidget {
  UpdatePostScreen(
      {Key? key,
      required this.postId,
      required this.category,
      required this.title,
      required this.userName,
      required this.profession,
      required this.body})
      : super(key: key);
  final String postId;
  final List category;
  final String title;
  final String body;
  final String userName;
  final String profession;

  @override
  _UpdatePostScreenState createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _mainTitleController = TextEditingController();
  final TextEditingController _bodyTextController = TextEditingController();
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // Post collection
  CollectionReference usersPosts =
      FirebaseFirestore.instance.collection("usersPosts");
  List _categories = [];
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
    _mainTitleController.text = widget.title;
    _bodyTextController.text = widget.body;
    _categories = widget.category;
  }

  @override
  void dispose() {
    super.dispose();
    _mainTitleController.dispose();
    _bodyTextController.dispose();
  }

  Future<void> updatePost({
    required List category,
    required String title,
    required String body,
    required List searchKeywords,
    required String postId,
  }) async {
    try {
      await posts.doc(postId).update({
        "category": category,
        "title": title,
        "body": body,
        "searchKeywords": searchKeywords,
      });
      await usersPosts
          .doc(currentUser!.uid)
          .collection("userPost")
          .doc(postId)
          .update({
        "category": category,
        "title": title,
        "body": body,
        "searchKeywords": searchKeywords,
      });
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          actions: [
            // _topSaveButton(),
          ],
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: _editForm(),
            ),
          ),
        ));
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
            _postEditButton(),
          ],
        ),
      ),
    );
  }

  // formback decoration ---------------------------------
  BoxDecoration _formBackDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
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
              maxLines: 5,
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
              height: 15,
            ),
            CustomTextField(
              controller: _bodyTextController,
              hint: "Optional body text",
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
            text: "Select category",
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
      borderRadius: BorderRadius.circular(25),
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
  Widget _postEditButton() {
    dateTime = DateTime.now();
    return Builder(
      builder: (context) {
        List searchKeywords =
            _mainTitleController.text.toLowerCase().split(" ") +
                widget.userName.toLowerCase().split(" ");

        while (searchKeywords.contains("")) {
          searchKeywords.remove("");
        }
        return ElevatedButton(
          onPressed: () async {
            FocusScopeNode currentFocus = FocusScope.of(context);
            currentFocus.unfocus();
            if (_categories.isEmpty) {
              var snackBar = SnackBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  content: Text(
                      'please select your post category on top. scroll horizontal.'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            if (_categories.isNotEmpty) {
              if (_formKey.currentState!.validate()) {
                _showLoading();
                List searchKeywords =
                    _mainTitleController.text.toLowerCase().split(" ") +
                        widget.userName.toLowerCase().split(" ");

                while (searchKeywords.contains("")) {
                  searchKeywords.remove("");
                }
                // userData = UserDataUpdate.setData(snapshot);
                updatePost(
                  title: _mainTitleController.text,
                  body: _bodyTextController.text,
                  searchKeywords: searchKeywords,
                  category: _categories,
                  postId: widget.postId,
                ).whenComplete(() {
                  Navigator.pop(context);
                  setState(() {
                    _mainTitleController.text = "";
                    _bodyTextController.text = "";
                    _categories.clear();
                  });
                  Navigator.pop(context);
                });
              }
            }
          },
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor),
              shadowColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor),
              padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(vertical: 15, horizontal: 65)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35)))),
          child: Text(
            "Update".toUpperCase(),
            style: Theme.of(context).textTheme.subtitle2,
          ),
        );
      },
    );
  }
}

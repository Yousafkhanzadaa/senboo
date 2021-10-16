import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senboo/components/custom_text_field.dart';
import 'package:senboo/components/interest_button.dart';
import 'package:senboo/model/user_data_update.dart';

class EditProfile extends StatefulWidget {
  EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _instaController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
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
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // Current User
  User? currentUser = FirebaseAuth.instance.currentUser;
  // userData modal
  UserDataUpdate? userData;
  bool waiting = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    getUserDetails();
  }

  Future getUserDetails() async {
    await users.doc(currentUser!.uid).get().then((snapshot) {
      setState(() {
        userData = UserDataUpdate.setData(snapshot);
        _nameController.text = userData!.userName!;
        _professionController.text = userData!.profession!;
        _bioController.text = userData!.bio!;
        _instaController.text = userData!.socialLinks![0];
        _twitterController.text = userData!.socialLinks![1];
        _interestedList = userData!.interested!;
        waiting = false;
      });
    });
  }

  Future updateUserDetails({
    String? userName,
    String? profession,
    String? bio,
    List<String>? socialLinks,
    List<dynamic>? interested,
  }) async {
    await users.doc(currentUser!.uid).update({
      'userName': userName,
      'profession': profession,
      'bio': bio,
      'socialLinks': socialLinks,
      'interested': interested,
    });
  }

  Future updatePostsData({
    String? userName,
    String? profession,
  }) async {
    posts.where("ownerId", isEqualTo: currentUser!.uid).get().then((value) {
      value.docs.forEach((DocumentSnapshot element) async {
        var postId = element.get('postId');
        await posts.doc(postId).update({
          'userName': userName,
          'profession': profession,
        });
      });
    });
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
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          actions: [
            _topSaveButton(),
          ],
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: waiting
            ? _loadingScreen()
            : Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                decoration: _formBackDecoration(),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _basicFields(),
                        _soiclaLinks(),
                        _intrestButtonsField(),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: _saveEditButton(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );

    // return ;
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
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            hint: "Jhon Doe",
            label: "Name",
            validator: (value) {
              if (value!.length > 27) {
                return "Too long";
              }
              if (value.isEmpty) {
                return "Please enter your name";
              }
              return null;
            },
          ),
          SizedBox(
            height: 15,
          ),
          CustomTextField(
            controller: _professionController,
            hint: "Manager",
            label: "Profession",
            validator: (value) {
              if (value!.length > 37) {
                return "It's too long";
              }
              if (value.isEmpty) {
                return "Please enter what you do?";
              }
              return null;
            },
          ),
          SizedBox(
            height: 15,
          ),
          CustomTextField(
            controller: _bioController,
            hint: "Bio",
            label: "Bio",
            maxLines: 6,
            validator: (value) {
              if (value!.length > 225) {
                return "Too long";
              }
              if (value.isEmpty) {
                return "Please enter your name";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Social links ---------------------------------------
  Widget _soiclaLinks() {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Social Links",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    child: CustomTextField(
                      controller: _instaController,
                      hint: "@_jhondoe",
                      label: "Instagram",
                      validator: (value) {
                        if (value!.isEmpty) {
                          value = "@instagram";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    child: CustomTextField(
                      controller: _twitterController,
                      hint: "@jhon_doe",
                      label: "Twitter",
                      validator: (value) {
                        if (value!.isEmpty) {
                          value = "@twitter";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // intrust Fields -----------------------------------------
  Widget _intrestButtonsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "Fields of Interest",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Container(
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
                      if (_interestedList.contains(_fieldButtonNames[index])) {
                        _interestedList.remove(_fieldButtonNames[index]);
                      } else {
                        if (_interestedList.length < 10) {
                          _interestedList.add(_fieldButtonNames[index]);
                        } else {
                          var snackBar = SnackBar(
                              backgroundColor: Theme.of(context).primaryColor,
                              content: Text(
                                  'You can select only ten fields of interests.'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    });
                  },
                  interested: _interestedList.contains(_fieldButtonNames[index])
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
            decoration: _cardDecoration(),
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
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
          blurRadius: 5,
          offset: Offset(0, 0),
          spreadRadius: 1,
        ),
      ],
    );
  }

  // save buttan goes here -0------------------------------------
  Widget _saveEditButton() {
    return ElevatedButton(
      onPressed: () async {
        FocusScopeNode currentFocus = FocusScope.of(context);
        currentFocus.unfocus();
        if (_interestedList.isNotEmpty) {
          if (_formKey.currentState!.validate()) {
            _showLoading();
            await updatePostsData(
              userName: _nameController.text,
              profession: _professionController.text,
            );
            await updateUserDetails(
              userName: _nameController.text,
              profession: _professionController.text,
              bio: _bioController.text,
              socialLinks: [
                _instaController.text,
                _twitterController.text,
              ],
              interested: _interestedList,
            ).whenComplete(() {
              Navigator.pop(context);

              Navigator.pop(context);
            });
          }
        }
        if (_interestedList.isEmpty) {
          var snackBar = SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text(
                  'Please select your fields of interests.\nscroll horizontal'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          shadowColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 15, horizontal: 65)),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)))),
      child: Text(
        "save".toUpperCase(),
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }

  // Top Save button in Appbar -------------------------------------
  // CommentButton goes here -------------------------------------------
  Widget _topSaveButton() {
    return GestureDetector(
      onTap: () async {
        FocusScopeNode currentFocus = FocusScope.of(context);
        currentFocus.unfocus();
        if (_interestedList.isNotEmpty) {
          if (_formKey.currentState!.validate()) {
            _showLoading();
            await updatePostsData(
              userName: _nameController.text,
              profession: _professionController.text,
            );
            await updateUserDetails(
              userName: _nameController.text,
              profession: _professionController.text,
              bio: _bioController.text,
              socialLinks: [
                _instaController.text,
                _twitterController.text,
              ],
              interested: _interestedList,
            ).whenComplete(() {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          }
        }
        if (_interestedList.isEmpty) {
          var snackBar = SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text(
                  'Please select your fields of interests.\nscroll horizontal'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5, right: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
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
          ),
          child: _buttonsIcon(
            Icons.done,
          )),
    );
  }

  // button icons ------------------------------------------
  Widget _buttonsIcon(IconData icon) {
    return Icon(
      icon,
      size: 26,
      color: Theme.of(context).primaryColor,
    );
  }

  // Load Screen ---------------------------------------------
  Widget _loadingScreen() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: _formBackDecoration(),
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

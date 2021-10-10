import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:senboo/components/color_palette.dart';
import 'package:senboo/components/custom_animated_bottom_bar.dart';
import 'package:senboo/screens/home_screen.dart';
import 'package:senboo/screens/post_screen.dart';
import 'package:senboo/screens/profile_screen.dart';
import 'package:senboo/screens/search_screen.dart';
// import 'package:senboo/screens/support_screen.dart';
import 'package:senboo/services/firebase_auth_services.dart';
// import 'package:senboo/services/firestore_services.dart';
// import 'package:senboo/services/firestore_services.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');

  // saved posts
  CollectionReference savedPosts =
      FirebaseFirestore.instance.collection("savedPosts");
  bool added = false;
  int _currentIndex = 0;
  final _inactiveColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _handleAddData();
    _initGoogleMobileAds();
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  _handleAddData() {
    DateTime dateTime = DateTime.now();

    users.doc(currentUser!.uid).get().then((value) async {
      if (!value.exists) {
        await users.doc(currentUser!.uid).set({
          "userId": currentUser!.uid,
          "userName": currentUser!.displayName,
          "profession": "profession!",
          "socialLinks": ["@instagram", "@twitter"],
          "date": dateTime,
          "photoUrl": currentUser!.photoURL,
          "userEmail": currentUser!.email,
          "bio": "bio is not added yet!",
          "savedPosts": [],
          "interested": []
        }).whenComplete(() {
          setState(() {
            added = true;
          });
        });
      }
      if (value.exists) {
        setState(() {
          added = true;
        });
      }
    }).catchError((error) {
      // print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _appBarSwitcher(),
      body: added ? _getBody() : _loadingScreen(),
      endDrawer: _profileDrawer(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  // Appbar switcher ---------------------------------
  AppBar _appBarSwitcher() {
    switch (_currentIndex) {
      case 0:
      case 1:
        return AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        );
      case 2:
        return AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
        );
      default:
        return AppBar(
          toolbarHeight: 0,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
        );
    }
  }

  // Profile drawer ---------------------------------
  Drawer? _profileDrawer() {
    switch (_currentIndex) {
      case 0:
      case 1:
        return null;
      case 3:
        return null;

      default:
        return Drawer(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.16,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: _actionButtons(Icons.logout, "Sign out", 0),
                    ),
                    // Container(
                    //   child: _actionButtons(
                    //       Icons.stop_outlined, "delete account", 1),
                    // ),
                    Container(
                      margin: EdgeInsets.only(bottom: 15, top: 15),
                      child: _actionButtons(Icons.support, "Your support", 2),
                    ),
                    Spacer(),
                    Container(
                      margin: EdgeInsets.only(bottom: 25),
                      child: _chooseColorButton(),
                    )
                  ],
                ),
              )
            ],
          ),
        );
    }
  }

  // ActionButtons -----------------------------------
  Widget _actionButtons(IconData icon, String text, int btnType) {
    FirebaseAuthServices _auth = Provider.of<FirebaseAuthServices>(context);
    return ElevatedButton.icon(
      onPressed: () {
        switch (btnType) {
          case 0:
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    'Confirm Signing Out',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigator.pop(context);
                        _auth.signOut();
                        Navigator.pop(context);
                      },
                      child: Text('Confirm'),
                    ),
                  ],
                );
              },
            );
            break;
          case 1:
          // delUser();
          // break;
          case 2:
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => SupportScreen()));
            break;
          default:
            Navigator.pop(context);
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Theme.of(context).cardColor),
        shadowColor: btnType != 2
            ? MaterialStateProperty.all(
                Theme.of(context).primaryColor.withOpacity(0.3))
            : MaterialStateProperty.all(Colors.grey.withOpacity(0.3)),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 15, horizontal: 35)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
      ),
      label: Text(
        text.toUpperCase(),
        style: btnType != 2
            ? Theme.of(context).textTheme.bodyText2
            : Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: Colors.grey.withOpacity(0.4)),
      ),
      icon: Icon(
        icon,
        size: 22,
        color: btnType != 2
            ? Theme.of(context).primaryColor
            : Colors.grey.withOpacity(0.4),
      ),
    );
  }

  // // Delete Usere and his content
  // delUser() {
  //   FirebaseAuthServices _auth =
  //       Provider.of<FirebaseAuthServices>(context, listen: false);
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text(
  //           'Confirm Deleting Your Account \n\nWe will delete you all posts, saved posts and personal information \n',
  //           style: Theme.of(context).textTheme.bodyText1,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.pop(context);
  //               _showLoading();
  //               try {
  //                 posts
  //                     .where("ownerId", isEqualTo: currentUser!.uid)
  //                     .get()
  //                     .then((value) {
  //                   for (var i in value.docs) {
  //                     posts.doc(i.id).delete();
  //                     try {
  //                       comments.doc(i.id).delete();
  //                     } catch (e) {
  //                       continue;
  //                     }
  //                   }
  //                 });
  //                 savedPosts.doc(currentUser!.uid).delete();

  //                 users.doc(currentUser!.uid).delete();
  //                 FirebaseAuth.instance.currentUser!.delete();
  //                 _auth.signOut();
  //                 Navigator.pop(context);
  //               } on FirebaseAuthException catch (e) {
  //                 if (e.code == 'requires-recent-login') {
  //                   print(
  //                       'The user must reauthenticate before this operation can be executed.');
  //                 }
  //               }
  //             },
  //             child: Text('Confirm'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // ActionButtons -----------------------------------
  Widget _chooseColorButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(context);
        showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => ColorPalette());
      },
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          shadowColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 15, horizontal: 35)),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)))),
      label: Text(
        "choose color".toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(color: Colors.white),
      ),
      icon: Icon(
        Icons.support,
        size: 22,
        color: Colors.white,
      ),
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

  // showing Pages ----------------------------------
  Widget _getBody() {
    List pages = [
      HomeScreen(),
      SearchScreen(),
      ProfileScreen(),
      PostScreen(),
    ];
    switch (_currentIndex) {
      case 0:
        return pages[0];
      case 1:
        return pages[1];
      case 2:
        return pages[2];
      case 3:
        return pages[3];
      default:
        return pages[0];
    }
  }

  //bottom navigation bar --------------------------
  Widget _buildBottomBar() {
    return CustomAnimatedBottomBar(
      containerHeight: 50,
      backgroundColor: Colors.white,
      selectedIndex: _currentIndex,
      showElevation: true,
      itemCornerRadius: 24,
      curve: Curves.easeIn,
      onItemSelected: (index) => setState(() => _currentIndex = index),
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.search),
          title: Text('Search'),
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.person),
          title: Text(
            'Profile ',
          ),
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
          icon: Icon(Icons.post_add),
          title: Text('Post'),
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: _inactiveColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

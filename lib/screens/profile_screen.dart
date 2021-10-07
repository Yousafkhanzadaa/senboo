import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senboo/components/profile_card.dart';
import 'package:senboo/components/profile_post_card.dart';
// import 'package:senboo/components/update_post.dart';
import 'package:senboo/model/get_user_data.dart';
import 'package:senboo/providers/data_provider.dart';
import 'package:senboo/screens/edit_card.dart';
// import 'package:senboo/screens/post_view_screen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  PostData? postData;
  int totalPosts = 0;
  int totalLikes = 0;

  List? savedPostsList;
  bool waiting = true;

  @override
  void initState() {
    super.initState();

    DataProvider dataProvider =
        Provider.of<DataProvider>(context, listen: false);
    dataProvider.getTotalLikes(ownerId: currentUser!.uid);
  }

  deletePost(postId) async {
    DataProvider dataProvider =
        Provider.of<DataProvider>(context, listen: false);
    Navigator.pop(context);
    _showLoading();
    await comments.doc(postId).delete();
    await posts.doc(postId).delete();
    dataProvider.getTotalLikes(ownerId: currentUser!.uid);
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    totalLikes = dataProvider.getlikes;
    totalPosts = dataProvider.getPosts;
    return Container(
      // height: MediaQuery.of(context).size.height,
      child: Stack(
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
          ListView(
            scrollDirection: Axis.vertical,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child:
                    ProfileCard(totalPosts: totalPosts, totalLikes: totalLikes),
              ),
              _postHead("Posts", Icons.grid_4x4_outlined),
              _postCards(),
              SizedBox(
                height: 20,
              ),
              _postHead("Saved Posts", Icons.bookmark_added),
              _savedCards(),
            ],
          ),
        ],
      ),
    );
  }

  // Post title goes here ---------------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _postHead(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: Color(0xFF3B3B3B),
          ),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Color(0xFF3B3B3B), fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }

  // your Post goes here ---------------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _postCards() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<QuerySnapshot>(
        stream: posts
            .where('ownerId', isEqualTo: currentUser!.uid)
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List dataList = snapshot.data!.docs.toList();

            return dataList.isEmpty
                ? _noPosts()
                : ListView.builder(
                    itemCount: dataList.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs;
                      postData = PostData.setData(dataList[index]);
                      return _cardView(postData!, data, index, null, 1);
                    },
                  );
          }
          return _loadingScreen();
        },
      ),
    );
  }

  // Saved posts goes here ---------------------------------------------
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Widget _savedCards() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<QuerySnapshot>(
        stream:
            savedPosts.doc(currentUser!.uid).collection("saved").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List dataList = snapshot.data!.docs.toList();
            return dataList.isEmpty
                ? _noPosts()
                : ListView.builder(
                    itemCount: dataList.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs;
                      postData = PostData.setData(dataList[index]);
                      return _cardView(postData!, data, index, 1, null);
                    },
                  );
          }
          return _loadingScreen();
        },
      ),
    );
  }

  // cardView
  Widget _cardView(
    PostData postData,
    List<QueryDocumentSnapshot<Object?>> data,
    int index,
    int? reverse,
    int? option,
  ) {
    return ProfilePostCard(
      reverse: reverse,
      profession: postData.profession!,
      ownerId: postData.ownerId!,
      userName: postData.userName!,
      body: postData.body!,
      title: postData.title!,
      date: postData.date!.toDate(),
      category: postData.category!,
      likes: postData.likes!,
      postId: postData.postId!,
      options: option,
      deleteFunction: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirm Deleting Post'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    deletePost(data[index].id);
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
      updateFunction: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UpdatePostScreen(
                    postId: data[index].id,
                    category: postData.category!,
                    title: postData.title!,
                    userName: postData.userName!,
                    body: postData.body!)));
        // showBottomSheet(
        //     context: context,
        //     backgroundColor: Colors.transparent,
        //     elevation: 2,
        //     builder: (context) => UpdatePostScreen(
        //         postId: data[index].id,
        //         category: postData.category!,
        //         title: postData.title!,
        //         userName: postData.userName!,
        //         body: postData.body!));
      },
    );
  }

  // Load Screen ---------------------------------------------

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
  Widget _noPosts() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      decoration: _cardDecoration(),
      child: Center(
        child: Text(
          "No Posts",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
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
}

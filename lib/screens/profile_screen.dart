import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senboo/components/likes_list.dart';
import 'package:senboo/components/profile_card.dart';
import 'package:senboo/components/profile_post_card.dart';
import 'package:senboo/model/get_user_data.dart';
import 'package:senboo/screens/edit_post.dart';
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
  // userPosts collection
  CollectionReference userPosts =
      FirebaseFirestore.instance.collection("usersPosts");
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');

  // saved posts
  CollectionReference savedPosts =
      FirebaseFirestore.instance.collection("savedPosts");
  PostData? postData;
  List? _savedDataList;
  // TabController _tabController = TabController(length: 2, vsync: TickerProvider());

  // List? savedPostsList;
  bool waiting = true;

  @override
  void initState() {
    super.initState();
  }

  deletePost(postId) async {
    // DataProvider dataProvider =
    //     Provider.of<DataProvider>(context, listen: false);
    Navigator.pop(context);
    _showLoading();
    // await comments.doc(postId).delete();
    // await posts.doc(postId).delete();
    await userPosts
        .doc(currentUser!.uid)
        .collection("userPost")
        .doc(postId)
        .delete();
    // dataProvider.getTotalLikes(ownerId: currentUser!.uid);
    Navigator.pop(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                child: ProfileCard(),
              ),
              _tabView(),
              // _postHead("Posts", Icons.read_more),
              // _postCards(),
              // SizedBox(
              //   height: 20,
              // ),
              // _postHead("Saved Posts", Icons.bookmark_added),
              // _savedCards(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabView() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DefaultTabController(
            length: 2, // length of tabs
            initialIndex: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _tabs(),
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.65, //height of TabBarView
                  padding: EdgeInsets.only(top: 5),
                  child: TabBarView(children: [
                    _postCards(),
                    _savedCards(),
                  ]),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      child: TabBar(
        labelColor: Theme.of(context).primaryColor,
        indicatorColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.black54,
        tabs: [
          Tab(
            icon: Icon(Icons.post_add_outlined),
          ),
          Tab(icon: Icon(Icons.bookmark_added)),
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
        stream: userPosts
            .doc(currentUser!.uid)
            .collection("userPost")
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List dataList = snapshot.data!.docs.toList();

            return dataList.isEmpty
                ? _noPosts()
                : GridView.builder(
                    itemCount: dataList.length,

                    // scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                      childAspectRatio: (0.7),
                    ),
                    // shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs;
                      postData = PostData.setData(dataList[index]);
                      return _cardView(
                          postData: postData!,
                          data: data,
                          index: index,
                          option: 1,
                          reverse: 1);
                    },
                  );
          }
          return _searching();
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
      child: StreamBuilder<DocumentSnapshot>(
        stream: users.doc(currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _savedDataList = snapshot.data!.get("savedPosts");
            return _savedDataList!.isEmpty
                ? _noPosts()
                : GridView.builder(
                    itemCount: _savedDataList!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                      childAspectRatio: (0.7),
                    ),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return _savedcardView(_savedDataList![index], 1, null);
                    },
                  );
          }
          return _searching();
        },
      ),
    );
  }

  // cardView
  Widget _savedcardView(
    // PostData postData,
    String postId,
    int? reverse,
    int? option,
  ) {
    return StreamBuilder<DocumentSnapshot>(
        stream: posts.doc(postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.exists) {
              postData = PostData.setData(snapshot.data);
              return ProfilePostCard(
                reverse: reverse,
                profession: postData!.profession!,
                ownerId: postData!.ownerId!,
                userName: postData!.userName!,
                body: postData!.body!,
                title: postData!.title!,
                date: postData!.date!.toDate(),
                category: postData!.category!,
                likes: postData!.likes!,
                postId: postData!.postId!,
                photoUrl: postData!.photoUrl!,
                options: option,
                deleteFunction: () {},
                updateFunction: () {},
                likeFun: () {},
              );
            } else {
              return Container(
                width: MediaQuery.of(context).size.width * 0.47,
                // height: 200,
                // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                margin: EdgeInsets.all(10),
                decoration: _cardDecoration(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Original Post is Deleted.",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          // fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _removePost(postId),
                    ],
                  ),
                ),
              );
            }
          }
          return Container(
            width: MediaQuery.of(context).size.width * 0.47,
            // height: 200,
            // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
            margin: EdgeInsets.all(10),
            decoration: _cardDecoration(),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        });
  }

  // cardView
  Widget _cardView(
      {required PostData postData,
      required List<QueryDocumentSnapshot<Object?>> data,
      required int index,
      int? reverse,
      int? option}) {
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
      photoUrl: postData.photoUrl!,
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
                    profession: postData.profession!,
                    userName: postData.userName!,
                    body: postData.body!)));
      },
      likeFun: () {
        showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => LikeList(likeList: postData.likes!));
      },
    );
  }

  Widget _removePost(String postID) {
    return ElevatedButton(
      onPressed: () async {
        _savedDataList!.remove(postID);
        await users
            .doc(currentUser!.uid)
            .update({"savedPosts": _savedDataList});
      },
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          shadowColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor),
          padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 10, horizontal: 25)),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)))),
      child: Text(
        "Remove post".toUpperCase(),
        style: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 12),
      ),
    );
  }

  // Load Screen ---------------------------------------------
  Widget _noPosts() {
    return Container(
      decoration: _cardDecoration(),
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/svgs/inbox.png")),
              )),
          SizedBox(
            height: 10,
          ),
          Text(
            "No posts yet.",
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

  // Load Screen ---------------------------------------------
  Widget _searching() {
    return Column(
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
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor,
          blurRadius: 3,
          offset: Offset(0, 0),
          // spreadRadius: 1,
        ),
      ],
    );
  }
}

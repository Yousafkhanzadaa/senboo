import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senboo/components/profile_post_card.dart';
import 'package:senboo/components/visitor_profile_card.dart';
import 'package:senboo/model/get_user_data.dart';

class VisitorProfileScreen extends StatefulWidget {
  VisitorProfileScreen({Key? key, required this.ownerId}) : super(key: key);
  final String ownerId;

  @override
  _VisitorProfileScreenState createState() => _VisitorProfileScreenState();
}

class _VisitorProfileScreenState extends State<VisitorProfileScreen> {
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  // User collection
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  PostData? postData;
  int totalPosts = 0;
  int totalLikes = 0;

  // List? savedPostsList;
  bool waiting = true;

  @override
  void initState() {
    super.initState();

    // getUserDetails();
  }

  // Future getUserDetails() async {
  //   await users.doc(widget.ownerId).get().then((snapshot) {
  //     setState(() {
  //       savedPostsList = snapshot.get('savedPosts');
  //       waiting = false;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Visitor",
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Container(
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
                  child: VisitorProfileCard(
                    ownerId: widget.ownerId,
                  ),
                ),
                _postHead("Posts", Icons.read_more),
                _postCards(),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
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
            size: 18,
            color: Color(0xFF3B3B3B),
          ),
          SizedBox(
            width: 10,
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
      child: waiting
          ? _loadingScreen()
          : StreamBuilder<QuerySnapshot>(
              stream:
                  posts.where('ownerId', isEqualTo: widget.ownerId).snapshots(),
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
                            return _cardView(postData!, data, index);
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
      PostData postData, List<QueryDocumentSnapshot<Object?>> data, int index) {
    return ProfilePostCard(
      reverse: null,
      profession: postData.profession!,
      ownerId: postData.ownerId!,
      userName: postData.userName!,
      body: postData.body!,
      title: postData.title!,
      date: postData.date!.toDate(),
      category: postData.category!,
      likes: postData.likes!,
      postId: postData.postId!,
    );
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senboo/components/custom_text_field.dart';
import 'package:senboo/components/search_card.dart';
import 'package:senboo/model/get_user_data.dart';
import 'package:senboo/screens/post_view_screen.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  // Post collection
  CollectionReference posts = FirebaseFirestore.instance.collection("posts");
  PostData? postData;

  List _keyWords = [];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: CustomTextField(
                controller: _searchController,
                hint: 'Search by keywords or name',
                onChange: (value) {
                  setState(() {
                    _keyWords = value.toString().toLowerCase().split(" ");
                  });
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: _keyWords.isEmpty
                    ? Center(
                        child: _blankField(),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: posts
                            .where("searchKeywords",
                                arrayContainsAny: _keyWords)
                            .limit(100)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List searchList = snapshot.data!.docs.toList();
                            return searchList.isEmpty &&
                                    _searchController.text.isNotEmpty
                                ? _cardNotFount()
                                : ListView.builder(
                                    itemCount: searchList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      var data = snapshot.data!.docs;
                                      postData = PostData.setData(data[index]);
                                      return _funCard(postData!);
                                    },
                                  );
                          }
                          return _loadingScreen();
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // func card
  Widget _funCard(PostData postData) {
    return SearchCard(
      userName: postData.userName!,
      profession: postData.profession!,
      title: postData.title!,
      body: postData.body!,
      date: postData.date!.toDate(),
      category: postData.category!,
      likes: postData.likes!,
      postId: postData.postId!,
      ownerId: postData.ownerId!,
      postData: postData,
    );
  }

  // search not found
  Widget _cardNotFount() {
    return Text(
      "No Result",
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // field is empty
  Widget _blankField() {
    return Text(
      "Search",
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
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

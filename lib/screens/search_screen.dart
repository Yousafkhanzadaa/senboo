import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senboo/components/custom_text_field.dart';
import 'package:senboo/components/search_card.dart';
import 'package:senboo/model/get_user_data.dart';

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
                hint: 'Search by keyword or name',
                onChange: (value) {
                  if (value!.split(" ").length <= 10) {
                    setState(() {
                      _keyWords = value.toString().toLowerCase().split(" ");
                    });
                  }
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
                child: _searchController.text == ""
                    ? _blankField()
                    : FutureBuilder<QuerySnapshot>(
                        future: posts
                            .where("searchKeywords",
                                arrayContainsAny: _keyWords)
                            .limit(100)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            List searchList = snapshot.data!.docs.toList();
                            return searchList.isEmpty &&
                                    _searchController.text != ""
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
                          return _searching();
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
      photoUrl: postData.photoUrl!,
      ownerId: postData.ownerId!,
    );
  }

  // search not found
  Widget _cardNotFount() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
            "No posts found.",
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

  // field is empty
  Widget _blankField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.2,
            margin: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/svgs/search.png")),
            )),
      ],
    );
  }

  // field is empty
  Widget _searching() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.2,
            margin: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/svgs/search.png")),
            )),
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
}

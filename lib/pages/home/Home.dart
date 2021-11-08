import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futcrick_user/Extension.dart';
import 'package:futcrick_user/constants.dart';
import 'package:futcrick_user/datamodel/MatchCard.dart';
import 'package:futcrick_user/datamodel/MatchDataModel.dart';
import 'package:futcrick_user/datamodel/Post.dart';
import 'package:futcrick_user/datamodel/PostItem.dart';
import 'package:futcrick_user/main.dart';

class MyHomePage extends StatefulWidget {
  final User user;

  const MyHomePage({Key key, this.user}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin<MyHomePage> {
  List<MatchCard> liveMatches = [];
  List<PostItem> postItems = [];
  List<DocumentSnapshot> documents = [];
  ScrollController _scrollController;
  bool isMore = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(scrollListener);
    fetchPosts(widget.user);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  scrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        fetchPosts(widget.user);
      }
    }
  }

  Future<void> fetchPosts(User user) async {
    if (isMore) {
      QuerySnapshot snapshot;
      if (postItems.length == 0) {
        try {
          snapshot = await postRef
              .limit(10)
              .orderBy('timeStamp', descending: true)
              .get();
          for (QueryDocumentSnapshot document in snapshot.docs) {
            documents.add(document);
            postItems.add(PostItem(user, post: Post.fromDocument(document)));
          }
        } catch (e) {
          print('error in fetch data in if block and more is $isMore');
          print(e.toString());
        }
      } else {
        try {
          snapshot = await postRef
              .limit(10)
              .orderBy('timeStamp', descending: true)
              .startAfterDocument(documents[documents.length - 1])
              .get()
              .then((value) {
            for (QueryDocumentSnapshot document in value.docs) {
              documents.add(document);
              postItems.add(PostItem(
                widget.user,
                post: Post.fromDocument(document),
              ));
            }
            return;
          });
        } catch (e) {
          print('error in fetch data in else block and more is $isMore');
          print(e.toString());
        }
      }
      if (snapshot.docs.length < 10) {
        setState(() {
          isMore = false;
        });
      }
    }
  }

  Future<void> refresh() async {
    setState(() {
      isMore = true;
      postItems.clear();
    });
    await fetchPosts(widget.user);
  }

  Widget headingText(String text) {
    return Text(
      text,
      style:
          TextStyle(fontSize: 20, fontFamily: 'Ubuntu', color: Colors.white70),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
            controller: _scrollController,
            child: postItems.length == 0
                ? circularProgressIndicator().center()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                        color: backgroundColor.withOpacity(0.5),
                        child: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Ubuntu'),
                              children: [
                                TextSpan(text: 'Fut'),
                                TextSpan(
                                    text: 'crick.',
                                    style: TextStyle(color: secondaryColor))
                              ]),
                        ).center(),
                      ),
                      StreamBuilder(
                        stream: matchesRef.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: circularProgressIndicator());
                          }
                          liveMatches.clear();
                          snapshot.data.docs.forEach((doc) {
                            MatchDataModel matchData =
                                MatchDataModel.fromDocument(doc);
                            switch (matchData.stateOfMatch) {
                              case 'Live':
                                liveMatches.add(MatchCard(
                                    matchData: matchData, isLive: true));
                                break;
                            }
                          });
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Live matches',
                                      style: TextStyle(
                                          fontFamily: 'Ubuntu', fontSize: 22)),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: ListView.separated(
                                        padding: EdgeInsets.only(
                                            left: 30, right: 30),
                                        separatorBuilder: (context, index) =>
                                            SizedBox(width: 20),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) =>
                                            liveMatches.elementAt(index),
                                        itemCount: liveMatches.length,
                                      ),
                                    )),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 50),
                      Text('Latest news',
                          style: TextStyle(fontFamily: 'Ubuntu', fontSize: 22)),
                      SizedBox(height: 20),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: postItems.length,
                        itemBuilder: (context, index) {
                          return Column(children: [
                            postItems[index],
                            SizedBox(
                              height: 30,
                            )
                          ]);
                        },
                      ),
                      SizedBox(height: 20),
                      Text(isMore ? 'Loading...' : 'End of page.').center(),
                      SizedBox(height: isMore ? 10 : 50),
                    ],
                  )),
      ),
    );
  }
}

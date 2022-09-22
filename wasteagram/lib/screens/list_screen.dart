import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wasteagram/models/dto_model.dart';
import 'package:wasteagram/screens/add_post.dart';
import 'package:wasteagram/screens/view_post.dart';

class ListScreen extends StatefulWidget {
  static const routeName = 'list_screen';

  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  num? totalWaste;

  void loadTotalWaste() {
    FirebaseFirestore.instance
        .collection('wasteagram_posts')
        .doc('totalWaste')
        .get()
        .then((DocumentSnapshot snapshot) {
      totalWaste = snapshot['totalWaste'];
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    loadTotalWaste();
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(document['date'],
                  style: Theme.of(context).textTheme.headline5),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                document['waste'].toString(),
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ],
        ),
        onTap: () {
          var fbData = DTOModel();

          fbData.date = document['date'];
          fbData.waste = document['waste'];
          fbData.url = document['url'];
          fbData.latitude = document['latitude'];
          fbData.longitude = document['longitude'];
          pushViewPost(context, fbData);
        });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('wasteagram_posts')
        .orderBy('timestamp')
        .snapshots();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Wasteagram'),
          actions: [
            Center(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text(totalWaste.toString(),
                        style: Theme.of(context).textTheme.headline3)))
          ],
        ),
        body: StreamBuilder(
            stream: _usersStream,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Semantics(
                    onTapHint: 'Loading page',
                    child: const Center(child: CircularProgressIndicator()));
              } else {
                if (snapshot.data!.docs.isEmpty) {
                  return Semantics(
                      onTapHint: 'There are no posts to display',
                      child: const Center(child: CircularProgressIndicator()));
                }
                return ListView.builder(
                  itemExtent: 80.0,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => _buildListItem(
                      context,
                      snapshot
                          .data!.docs[snapshot.data!.docs.length - index - 1]),
                );
              }
            }),
        bottomNavigationBar: BottomAppBar(
          child: Container(height: 50),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
            height: 70,
            width: 70,
            child: FittedBox(
                child: Semantics(
                    button: true,
                    enabled: true,
                    onTapHint: 'Select an image',
                    child: FloatingActionButton(
                        onPressed: () {
                          pushAddPost(context);
                        },
                        child: const Icon(Icons.camera_alt))))));
  }

  void pushAddPost(BuildContext context) {
    Navigator.of(context)
        .pushNamed(AddPost.routeName)
        .then((value) => loadTotalWaste());
  }

  void pushViewPost(BuildContext context, DTOModel object) {
    Navigator.of(context).pushNamed(ViewPost.routeName, arguments: object);
  }
}

import 'package:flutter/material.dart';
import 'package:wasteagram/screens/add_post.dart';
import 'package:wasteagram/screens/list_screen.dart';
import 'package:wasteagram/screens/view_post.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final routes = {
    ListScreen.routeName: (context) => ListScreen(),
    ViewPost.routeName: (context) => const ViewPost(),
    AddPost.routeName: (context) => const AddPost(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
      ),
      routes: routes,
      initialRoute: ListScreen.routeName,
    );
  }

  void pushAddPost(BuildContext context) {
    Navigator.of(context).pushNamed(AddPost.routeName);
  }

  void pushViewPost(BuildContext context) {
    Navigator.of(context).pushNamed(ViewPost.routeName);
  }
}

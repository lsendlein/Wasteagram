import 'package:flutter/material.dart';
import 'package:wasteagram/models/dto_model.dart';

class ViewPost extends StatelessWidget {
  const ViewPost({Key? key}) : super(key: key);

  static const routeName = 'view_post';

  @override
  Widget build(BuildContext context) {
    final DTOModel recievedValue =
        ModalRoute.of(context)?.settings.arguments as DTOModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Post'),
      ),
      body: Center(
          child: SingleChildScrollView(
              child: Container(
                  child: Column(children: [
        Text(
          recievedValue.date!,
          style: Theme.of(context).textTheme.headline2,
        ),
        Padding(
            padding: const EdgeInsets.all(20),
            child: Semantics(
                onTapHint: 'A user selected image',
                image: true,
                child: Image.network(recievedValue.url!))),
        Text('${recievedValue.waste} items',
            style: Theme.of(context).textTheme.displayMedium),
        Text('Location: ${recievedValue.latitude}, ${recievedValue.longitude}',
            style: Theme.of(context).textTheme.bodyMedium),
      ])))),
    );
  }
}

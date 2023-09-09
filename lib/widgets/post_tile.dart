import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../screens/view_image_screen.dart';
import 'cached_image.dart';

class PostTile extends StatefulWidget {
  final PostModel? post;

  const PostTile({super.key, this.post});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {

    // TODO: Fix margin
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => ViewImageScreen(post: widget.post),
        ));
      },
      child: SizedBox(
        height: 100,
        width: 150,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          margin: const EdgeInsets.all(0.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(0.0),
            ),
            child: cachedImage(widget.post!.mediaUrl![0]),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../posts/screens/view_post_screen.dart';
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => ViewPostScreen(post: widget.post),
        ));
      },
      child: SizedBox(
        height: 100,
        width: 150,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          margin: const EdgeInsets.all(0.5),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(0.0),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: cachedImage(widget.post!.mediaUrl![0])),
                widget.post!.mediaUrl!.length > 1 ? const Positioned(
                  left: 5,
                  top: 5,
                  child: Icon(
                    CupertinoIcons.rectangle_stack_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ) : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
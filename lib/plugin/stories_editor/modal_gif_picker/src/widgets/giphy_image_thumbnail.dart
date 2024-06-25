import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../model/giphy_repository.dart';

class GiphyImageThumbnail extends StatefulWidget {
  final GiphyRepository repo;
  final int index;
  final Widget? placeholder;

  const GiphyImageThumbnail(
      {Key? key, required this.repo, required this.index, this.placeholder})
      : super(key: key);

  @override
  State<GiphyImageThumbnail> createState() => _GiphyImageThumbnailState();
}

class _GiphyImageThumbnailState extends State<GiphyImageThumbnail> {
  late Future<Uint8List?> _loadPreview;

  @override
  void initState() {
    _loadPreview = widget.repo.getPreview(widget.index);
    super.initState();
  }

  @override
  void dispose() {
    widget.repo.cancelGetPreview(widget.index);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: _loadPreview,
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {

        if (!snapshot.hasData) {
          return widget.placeholder ??
              Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                height: 50,
                width: 50,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white54),
                  strokeWidth: 1,
                ),
              );
        }

        return Image.memory(snapshot.data!, fit: BoxFit.cover);
      });
}

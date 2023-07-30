// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import '../model/giphy_repository.dart';
import 'giphy_context.dart';
import 'giphy_image_thumbnail.dart';

class GiphyGridView extends StatelessWidget {
  final GiphyRepository repo;

  final ScrollController? scrollController;

  int crossAxisCount;
  double childAspectRatio;
  double crossAxisSpacing;
  double mainAxisSpacing;

  GiphyGridView(
      {Key? key,
      required this.repo,
      this.scrollController,
      this.childAspectRatio = 1.6,
      this.crossAxisCount = 2,
      this.crossAxisSpacing = 5,
      this.mainAxisSpacing = 5})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GridView.builder(
        padding: const EdgeInsets.all(10),
        controller: scrollController,
        itemCount: repo.totalCount,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
            child: GiphyImageThumbnail(
                key: Key('$index'), repo: repo, index: index),
            onTap: () async {
              final giphy = GiphyContext.of(context);
              final gif = await repo.get(index);
              giphy.onSelected?.call(gif);
            }),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing));
  }
}

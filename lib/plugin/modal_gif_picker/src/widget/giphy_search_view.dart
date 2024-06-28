// ignore_for_file: must_be_immutable
import 'dart:async';

import 'package:flutter/material.dart';

import '../model/giphy_repository.dart';
import '../utility/debouncer.dart';

import 'giphy_context.dart';
import 'giphy_grid_view.dart';

class GiphySearchView extends StatefulWidget {
  final ScrollController? sheetScrollController;

  int crossAxisCount;

  double childAspectRatio;
  double crossAxisSpacing;
  double mainAxisSpacing;

  GiphySearchView(
      {Key? key,
      this.sheetScrollController,
      this.childAspectRatio = 1.6,
      this.crossAxisCount = 2,
      this.crossAxisSpacing = 5,
      this.mainAxisSpacing = 5})
      : super(key: key);
  @override
  State<GiphySearchView> createState() => _GiphySearchViewState();
}

class _GiphySearchViewState extends State<GiphySearchView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _repoController = StreamController<GiphyRepository>();

  late Debouncer _debouncer;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final giphy = GiphyContext.of(context);
      _debouncer = Debouncer(
        delay: giphy.searchDelay,
      );
      _search(giphy);
    });
    super.initState();
  }

  @override
  void dispose() {
    _repoController.close();
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final giphy = GiphyContext.of(context);

    return Column(children: <Widget>[
      Material(
        elevation: 0,
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.8),
                      size: 30,
                    ),
                    border: InputBorder.none,
                    hintText: 'Search',
                    hintStyle: TextStyle(
                        color: Colors.white54.withOpacity(0.5), fontSize: 22),
                  ),
                  style: TextStyle(
                      color: Colors.white54.withOpacity(0.7), fontSize: 22),
                  onChanged: (value) {
                    _delayedSearch(giphy, value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Trending on GIPHY',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/images/giphy_logo.png',
                  height: 20,
                )),
          )
        ],
      ),
      Expanded(
          child: StreamBuilder(
              stream: _repoController.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<GiphyRepository> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.totalCount > 0
                      ? NotificationListener(
                          child: RefreshIndicator(
                              child: GiphyGridView(
                                  key: Key('${snapshot.data.hashCode}'),
                                  crossAxisCount: widget.crossAxisCount,
                                  childAspectRatio: widget.childAspectRatio,
                                  crossAxisSpacing: widget.crossAxisSpacing,
                                  mainAxisSpacing: widget.mainAxisSpacing,
                                  repo: snapshot.data!,
                                  scrollController:
                                      widget.sheetScrollController),
                              onRefresh: () =>
                                  _search(giphy, term: _textController.text)),
                          onNotification: (n) {
                            if (n is UserScrollNotification) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              return true;
                            }
                            return false;
                          },
                        )
                      : Center(
                          child: Text(
                          'No results',
                          style: TextStyle(
                              color: Colors.white54.withOpacity(0.5),
                              fontSize: 18),
                        ));
                } else if (snapshot.hasError) {
                  Center(
                      child: Text('An error occurred',
                          style: TextStyle(
                              color: Colors.white54.withOpacity(0.5),
                              fontSize: 18)));
                }

                return const Center(
                    child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.red),
                  strokeWidth: 1.2,
                ));
              }))
    ]);
  }

  void _delayedSearch(GiphyContext giphy, String term) =>
      _debouncer.call(() => _search(giphy, term: term));

  Future _search(GiphyContext giphy, {String term = ''}) async {
    if (term != _textController.text) {
      return;
    }

    try {
      final repo = await (term.isEmpty
          ? GiphyRepository.trending(
              apiKey: giphy.apiKey,
              rating: giphy.rating,
              sticker: giphy.sticker,
              previewType: giphy.previewType,
              onError: giphy.onError)
          : GiphyRepository.search(
              apiKey: giphy.apiKey,
              query: term,
              rating: giphy.rating,
              lang: giphy.language,
              sticker: giphy.sticker,
              previewType: giphy.previewType,
              onError: giphy.onError,
            ));

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      if (mounted) {
        _repoController.add(repo);
      }
    } catch (error) {
      if (mounted) {
        _repoController.addError(error);
      }
      giphy.onError?.call(error);
    }
  }
}

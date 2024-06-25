import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../module/post/screen/new_post_screen.dart';
import '../module/reels/screen/new_reels_screen.dart';
import '../module/story/screen/confirm_story.dart';
import '../plugin/story_editor/stories_editor.dart';
import '../viewmodel/user/story_view_model.dart';

Future<dynamic> chooseUpload(BuildContext context, StoryViewModel viewModel) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(20), topLeft: Radius.circular(20)),
    ),
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      return FractionallySizedBox(
          heightFactor: .75,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: const Border(
                  top: BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20))),
            child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(
                        top: 10.0,
                        bottom: 5.0,
                        left: 25.0,
                        right: 25.0,
                      ),
                      child: Text(
                        'Create a new',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    )),
                const Divider(
                  color: Colors.blue,
                  thickness: 1,
                ),
                const SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => StoriesEditor(
                                  giphyKey: 'C4dMA7Q19nqEGdpfj82T8ssbOeZIylD4',
                                  fontFamilyList: const [
                                    'Shizuru',
                                    'Aladin',
                                    'TitilliumWeb',
                                    'Varela',
                                    'Vollkorn',
                                    'Rakkas',
                                    'B612',
                                    'YatraOne',
                                    'Tangerine',
                                    'OldStandardTT',
                                    'DancingScript',
                                    'SedgwickAve',
                                    'IndieFlower',
                                    'Sacramento'
                                  ],
                                  galleryThumbnailQuality: 300,
                                  isCustomFontList: true,
                                  onDone: (uri) {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) => ConfirmStory(uri: uri),
                                      ),
                                    );
                                  },
                                )));
                  },
                  child: Container(
                      height: 30.0,
                      padding: const EdgeInsets.only(
                        left: 25.0,
                        right: 25.0,
                      ),
                      width: MediaQuery.of(context).size.width,
                      color: Theme.of(context).colorScheme.surface,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 3.0,
                            ),
                            child: Icon(
                              CupertinoIcons.time,
                              color: Colors.blue,
                              size: 25,
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Story',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                  height: 0.9))
                        ],
                      )),
                ),
                const SizedBox(height: 12.0),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                  ),
                  child: Divider(
                    color: Colors.blue,
                    thickness: 1,
                  ),
                ),
                const SizedBox(height: 12.0),
                GestureDetector(
                  onTap: () async {
                    Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const NewPostScreen(
                                  title: 'Create a Post',
                                )));
                  },
                  child: Container(
                      height: 30.0,
                      padding: const EdgeInsets.only(
                        left: 25.0,
                        right: 25.0,
                        bottom: 2,
                      ),
                      width: MediaQuery.of(context).size.width,
                      color: Theme.of(context).colorScheme.surface,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 3.0,
                            ),
                            child: Icon(
                              CupertinoIcons.plus_circle,
                              color: Colors.blue,
                              size: 25,
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Post',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                  height: 0.9))
                        ],
                      )),
                ),
                const SizedBox(height: 12.0),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                  ),
                  child: Divider(
                    color: Colors.blue,
                    thickness: 1,
                  ),
                ),
                const SizedBox(height: 12.0),
                Visibility(
                    visible: !kIsWeb,
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const NewReelsScreen()));
                      },
                      child: Container(
                          height: 30.0,
                          padding: const EdgeInsets.only(
                            left: 25.0,
                            right: 25.0,
                            bottom: 2,
                          ),
                          width: MediaQuery.of(context).size.width,
                          color: Theme.of(context).colorScheme.surface,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 3.0,
                                ),
                                child: Icon(
                                  CupertinoIcons.play_circle,
                                  color: Colors.blue,
                                  size: 25,
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text('Reel',
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue,
                                      height: 0.9))
                            ],
                          )),
                    )),
                const SizedBox(height: 12.0),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                  ),
                  child: Divider(
                    color: Colors.blue,
                    thickness: 1,
                  ),
                ),
                const SizedBox(height: 12.0),
                GestureDetector(
                  onTap: () async {
                    //
                  },
                  child: Container(
                      height: 30.0,
                      padding: const EdgeInsets.only(
                        left: 25.0,
                        right: 25.0,
                        bottom: 2,
                      ),
                      width: MediaQuery.of(context).size.width,
                      color: Theme.of(context).colorScheme.surface,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 3.0,
                            ),
                            child: Icon(
                              CupertinoIcons.equal_circle,
                              color: Colors.blue,
                              size: 25,
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Thread',
                              style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                  height: 0.9))
                        ],
                      )),
                ),
                const SizedBox(height: 12.0),
              ],
            ),
          ));
    },
  );
}

import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../view_models/screens/posts_view_model.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({Key? key}) : super(key: key);

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  @override
  Widget build(BuildContext context) {
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    return LoadingOverlay(
        isLoading: viewModel.loading,
        progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
        opacity: 0.5,
        color: Theme.of(context).colorScheme.background,
        child: Scaffold(
          extendBody: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(CupertinoIcons.chevron_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                iconSize: 30.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: GradientText(
                'New Post',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ), colors: const [
                Colors.blue,
                Colors.purple,
                Colors.pink],
              ),
              centerTitle: true,
            ),
            body: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Single Image : ",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        GestureDetector(
                          onTap : () {
                            viewModel.uploadPostSingleImage(camera: true, context: context);
                          },
                          child: Container(
                              height: 200.0,
                              width: MediaQuery.of(context).size.width * 0.42,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 1.0,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.camera,
                                    size: 40.0,
                                    color: Colors.blue
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    'Camera',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue
                                    )
                                  )
                                ],
                              )
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap : () {
                            viewModel.uploadPostSingleImage(camera: false, context: context);
                          },
                          child: Container(
                              height: 200.0,
                              width: MediaQuery.of(context).size.width * 0.42,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 1.0,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.photo_on_rectangle,
                                    size: 40.0,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                      'Gallery',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue
                                      )
                                  )
                                ],
                              )
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 40.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Multiple Images : ",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        GestureDetector(
                          onTap : () {
                            //
                          },
                          child: Container(
                              height: 200.0,
                              width: MediaQuery.of(context).size.width * 0.42,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 1.0,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.photo_on_rectangle,
                                    size: 40.0,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    'Gallery',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    )
                                  )
                                ],
                              )
                          ),
                        )
                      ],
                    ),
                  ],
                )
            )
        )
    );
  }
}

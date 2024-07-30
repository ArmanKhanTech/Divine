import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../../viewmodels/screens/posts_view_model.dart';

class PreviewImage extends StatefulWidget {
  final XFile imageFile;

  const PreviewImage({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  @override
  Widget build(BuildContext context) {
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30.0,
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 2.0),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        title: GradientText(
          'Preview',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w300,
          ),
          colors: const [
            Colors.blue,
            Colors.purple,
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.95,
                child: Image.file(
                  File(widget.imageFile.path),
                  fit: BoxFit.cover,
                )),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    await File(widget.imageFile.path).delete();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                height: 30.0,
                width: 1.0,
                color: Colors.white,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    viewModel.uploadPostSingleImage(
                        image: widget.imageFile, context: context);
                  },
                  child: const Text(
                    'Select',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      )),
    );
  }
}

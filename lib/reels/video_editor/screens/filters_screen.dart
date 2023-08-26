import 'package:colorfilter_generator/presets.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:divine/reels/video_editor/src/utilities/controller.dart';
import 'package:divine/reels/video_editor/src/widgets/cover/cover_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../src/widgets/crop/crop_grid.dart';

class FiltersScreen extends StatefulWidget{
  final VideoEditorController controller;

  const FiltersScreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filters',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () async {
              if (mounted) {
                widget.controller.setFilterOpacity(widget.controller.filterOpacity);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 1
            ),
            borderRadius: BorderRadius.circular(20),
            color: Colors.black
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColorFiltered(
              colorFilter: widget.controller.colorFilter,
              child: CropGridViewer.preview(controller: widget.controller),
            ),
          )
        )
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 160,
          child: Column(children: [
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 40,
              child: Slider(
                min: 0,
                max: 1,
                divisions: 100,
                value: widget.controller.filterOpacity,
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                thumbColor: Colors.white,
                onChanged: (value) {
                  widget.controller.filterOpacity = value;
                  setState(() {});
                },
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  for (int i = 0; i < presetFiltersList.length; i++)
                    filterPreviewButton(
                      filterColor: presetFiltersList[i],
                      name: presetFiltersList[i].name,
                    ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget filterPreviewButton({required filterColor, required String name}) {

    ColorFilterGenerator myFilter = ColorFilterGenerator(
        name: "CustomFilter",
        filters: [
          filterColor.opacity(widget.controller.filterOpacity).matrix,
        ]
    );

    return GestureDetector(
      onTap: () {
        widget.controller.colorFilter = ColorFilter.matrix(myFilter.matrix);
        setState(() {});
      },
      child: Column(
          children: [
          ColorFiltered(
            colorFilter: ColorFilter.matrix(myFilter.matrix),
            child: Container(
                height: 65,
                width: 65,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Container(// Border width
                  decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white,
                          width: 1
                      )
                  ),
                  child: ClipOval(
                    child: SizedBox.fromSize(
                      size: const Size.fromRadius(48), // Image radius
                      child: CoverViewer(controller: widget.controller),
                    ),
                  ),
                )
            ),
          ),
          Text(
            name,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ]
      ),
    );
  }
}
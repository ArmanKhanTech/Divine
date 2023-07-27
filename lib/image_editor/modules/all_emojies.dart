import 'package:flutter/material.dart';
import '../data/data.dart';
import '../data/layer.dart';
import '../image_editor_plus.dart';

class Emojies extends StatefulWidget {
  const Emojies({super.key});

  @override
  createState() => _EmojiesState();
}

class _EmojiesState extends State<Emojies> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(0.0),
        height: 400,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                i18n('Select Emoji'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
              ),
            ]),
            const SizedBox(height: 10),
            Container(
              height: 320,
              padding: const EdgeInsets.only(
                left: 20,
                right: 10,
                top: 5,
              ),
              child: GridView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 0.0,
                  maxCrossAxisExtent: 60.0,
                ),
                children: emojis.map((String emoji) {
                  return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            context,
                            EmojiLayerData(
                              text: emoji,
                              size: 32.0,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.zero,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 35),
                          ),
                        ),
                      ));
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
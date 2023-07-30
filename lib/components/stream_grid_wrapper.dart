import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/progress_indicators.dart';

typedef ItemBuilder<T> = Widget Function(
    BuildContext context,
    DocumentSnapshot doc,
    );

class StreamGridWrapper extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>? stream;
  final ItemBuilder<DocumentSnapshot> itemBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsets padding;

  const StreamGridWrapper({
    Key? key,
    required this.stream,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var list = snapshot.data!.docs.toList();

          return list.isEmpty ? const Center(
                child: Text(
                  'No Posts Yet.',
                  style: TextStyle(
                    color: Color(0xFFB2BEB5),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ) : GridView.builder(
            padding: padding,
            scrollDirection: scrollDirection,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 3 / 3,
            ),
            itemCount: list.length,
            shrinkWrap: shrinkWrap,
            physics: physics,
            itemBuilder: (BuildContext context, int index) {

              return itemBuilder(context, list[index]);
            },
          );
        } else {

          return circularProgress(context, const Color(0xFFB2BEB5));
        }
      },
    );
  }
}
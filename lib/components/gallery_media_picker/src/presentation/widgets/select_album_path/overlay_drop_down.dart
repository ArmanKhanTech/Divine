import 'package:flutter/material.dart';
import 'dropdown.dart';

class OverlayDropDown<T> extends StatelessWidget {
  final double height;

  final Function(T? value) close;

  final AnimationController animationController;

  final DropdownWidgetBuilder<T> builder;

  const OverlayDropDown({
    Key? key,
    required this.height,
    required this.close,
    required this.animationController,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double screenHeight = size.height;
    final double screenWidth = size.width;
    final double space = screenHeight - height;

    return Padding(
      padding: EdgeInsets.only(
        top: space,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => close,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (BuildContext context, child){
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () => close(null),
                      child: Container(
                        color: Colors.black,
                        height: height * animationController.value,
                        width: screenWidth,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        height: height * animationController.value,
                        width: screenWidth,
                        child: child,
                      ),
                    )
                  ],
                );
              },
              child: builder(ctx, close),
            ),
          ),
        ),
      ),
    );
  }
}

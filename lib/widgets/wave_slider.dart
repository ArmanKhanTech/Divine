import 'dart:math';
import 'package:flutter/material.dart';

typedef CallbackSelection = void Function(double duration);

class WaveSlider extends StatefulWidget {
  final double widthWaveSlider;
  final double heightWaveSlider;
  final Color wavActiveColor;
  final Color wavDeactiveColor;
  final Color sliderColor;
  final Color backgroundColor;
  final Color positionTextColor;
  final double duration;
  final CallbackSelection callbackStart;
  final CallbackSelection callbackEnd;
  const WaveSlider({
    Key? key,
    required this.duration,
    required this.callbackStart,
    required this.callbackEnd,
    this.widthWaveSlider = 0,
    required this.heightWaveSlider,
    this.wavActiveColor = Colors.deepPurple,
    this.wavDeactiveColor = Colors.blueGrey,
    this.sliderColor = Colors.red,
    this.backgroundColor = Colors.grey,
    this.positionTextColor = Colors.black,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => WaveSliderState();
}

class WaveSliderState extends State<WaveSlider> {
  double widthSlider = 300;
  double heightSlider = 100;
  static const barWidth = 5.0;
  static const selectBarWidth = 15.0;
  double barStartPosition = 0.0;
  double barEndPosition = 50;
  List<int> bars = [];

  @override
  void initState() {
    super.initState();

    var shortSize = MediaQueryData.fromView(WidgetsBinding.instance.window).size.shortestSide;

    widthSlider = (widget.widthWaveSlider < 50) ? (shortSize - 2 - 40) : widget.widthWaveSlider;
    heightSlider = (widget.heightWaveSlider < 50) ? 100 : widget.heightWaveSlider;
    barEndPosition = widthSlider - selectBarWidth;

    Random r = Random();
    for (var i = 0; i < (widthSlider / barWidth); i++) {
      int number = 1 + r.nextInt(heightSlider.toInt() - 1);
      bars.add(r.nextInt(number));
    }
  }

  double _getBarStartPosition() {

    return ((barEndPosition) < barStartPosition) ? barEndPosition : barStartPosition;
  }

  double _getBarEndPosition() {

    return ((barStartPosition + selectBarWidth) > barEndPosition) ? (barStartPosition + selectBarWidth) : barEndPosition;
  }

  int _getStartTime() {

    return _getBarStartPosition() ~/ (widthSlider / widget.duration);
  }

  int _getEndTime() {

    return ((_getBarEndPosition() + selectBarWidth) / (widthSlider / widget.duration)).ceilToDouble().toInt();
  }

  String _timeFormatter(int second) {
    Duration duration = Duration(seconds: second);

    List<int> durations = [];
    if (duration.inHours > 0) {
      durations.add(duration.inHours);
    }
    durations.add(duration.inMinutes);
    durations.add(duration.inSeconds);

    return durations.map((seg) => seg.remainder(60).toString().padLeft(2, '0')).join(':');
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;

    return SizedBox(
      width: widthSlider,
      height: widget.heightWaveSlider,
      child: Column(
        children: [
          Row(
            children: [
              Text(_timeFormatter(_getStartTime()), style: TextStyle(color: widget.positionTextColor)),
              Expanded(child: Container()),
              Text(_timeFormatter(_getEndTime()), style: TextStyle(color: widget.positionTextColor)),
            ],
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: bars.map((int height) {
                      Color color = i >= barStartPosition / barWidth && i <= barEndPosition / barWidth
                          ? widget.wavActiveColor
                          : widget.wavDeactiveColor;
                      if(i++ == bars.length - 1) {

                      }

                      return Container(
                        color: color,
                        height: Random().nextInt(40).toDouble() + 10,
                        width: 4.948,
                      );
                    }).toList(),
                  ),
                  Bar(
                    position: _getBarStartPosition(),
                    colorBG: widget.sliderColor,
                    width: selectBarWidth,
                    side: 'left',
                    callback: (DragUpdateDetails details) {
                      var tmp = barStartPosition + details.delta.dx;
                      if ((barEndPosition - selectBarWidth) > tmp && (tmp >= 0)) {
                        setState(() {
                          barStartPosition += details.delta.dx;
                        });
                      }
                    },
                    callbackEnd: (details) {
                      widget.callbackStart(_getStartTime().toDouble());
                    },
                  ),
                  CenterBar(
                    position: _getBarStartPosition() + selectBarWidth,
                    width: _getBarEndPosition() - _getBarStartPosition() - selectBarWidth,
                    callback: (details) {
                      var tmp1 = barStartPosition + details.delta.dx;
                      var tmp2 = barEndPosition + details.delta.dx;
                      if ((tmp1 > 0) && ((tmp2 + selectBarWidth) < widthSlider)) {
                        setState(() {
                          barStartPosition += details.delta.dx;
                          barEndPosition += details.delta.dx;
                        });
                      }
                    },
                    callbackEnd: (details) {
                      widget.callbackStart(_getStartTime().toDouble());
                      widget.callbackEnd(_getEndTime().toDouble());
                    },
                  ),
                  Bar(
                    position: _getBarEndPosition(),
                    colorBG: widget.sliderColor,
                    width: selectBarWidth,
                    side: 'right',
                    callback: (DragUpdateDetails details) {
                      var tmp = barEndPosition + details.delta.dx;
                      if ((barStartPosition + selectBarWidth) < tmp && (tmp + selectBarWidth) <= widthSlider) {
                        setState(() {
                          barEndPosition += details.delta.dx;
                        });
                      }
                    },
                    callbackEnd: (details) {
                      widget.callbackEnd(_getEndTime().toDouble());
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CenterBar extends StatelessWidget {
  final double position;
  final double width;
  final GestureDragUpdateCallback callback;
  final GestureDragEndCallback? callbackEnd;

  const CenterBar({Key? key, required this.position, required this.width, required this.callback, required this.callbackEnd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(left: position >= 0.0 ? position : 0.0),
      child: GestureDetector(
        onHorizontalDragUpdate: callback,
        onHorizontalDragEnd: callbackEnd,
        child: Container(
          color: Colors.black38,
          width: width,
          child: Column(
            children: [
              Container(
                height: 3,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                )
              ),
              Expanded(child: Container(
                color: Colors.transparent,
              )),
              Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Bar extends StatelessWidget {
  final double position;
  final Color? colorBG;
  final double width;
  final String? side;
  final GestureDragUpdateCallback callback;
  final GestureDragEndCallback? callbackEnd;

  const Bar(
      {Key? key, required this.side, required this.position, required this.width, required this.callback, required this.callbackEnd, this.colorBG})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(left: position >= 0.0 ? position : 0.0),
      child: GestureDetector(
        onHorizontalDragUpdate: callback,
        onHorizontalDragEnd: callbackEnd,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.blue,
                Colors.pink,
              ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp
            ),
            borderRadius: side == 'left' ? const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ) : const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          height: double.infinity,
          width: width,
          child: const Icon(Icons.menu, size: 10, color: Colors.white),
        ),
      ),
    );
  }
}
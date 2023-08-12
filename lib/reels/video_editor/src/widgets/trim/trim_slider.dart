import 'dart:math';
import 'package:divine/reels/video_editor/src/widgets/trim/thumbnail_slider.dart';
import 'package:divine/reels/video_editor/src/widgets/trim/trim_slider_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utilities/controller.dart';

enum _TrimBoundaries { left, right, inside, progress }

const _touchMargin = 24.0;

class TrimSlider extends StatefulWidget {
  const TrimSlider({
    super.key,
    required this.controller,
    this.height = 60,
    this.horizontalMargin = 0.0,
    this.child,
    this.hasHaptic = true,
    this.maxViewportRatio = 2.5,
    this.scrollController,
  });

  final VideoEditorController controller;

  final double height;
  final double horizontalMargin;

  final Widget? child;

  final bool hasHaptic;

  final double maxViewportRatio;

  final ScrollController? scrollController;

  @override
  State<TrimSlider> createState() => _TrimSliderState();
}

class _TrimSliderState extends State<TrimSlider>
    with AutomaticKeepAliveClientMixin<TrimSlider> {
  _TrimBoundaries? _boundary;

  bool _isVideoPlayerHold = false;

  double? _preComputedVideoPosition;

  Rect _rect = Rect.zero;

  Size _trimLayout = Size.zero;
  Size _fullLayout = Size.zero;

  late final double _horizontalMargin =
      widget.horizontalMargin + widget.controller.trimStyle.edgeWidth;

  late final _viewportRatio = min(
    widget.maxViewportRatio,
    widget.controller.videoDuration.inMilliseconds /
        widget.controller.maxDuration.inMilliseconds,
  );

  late final _isExtendTrim = _viewportRatio > 1;
  late final _edgesTouchMargin = max(widget.controller.trimStyle.edgeWidth, _touchMargin);
  late final _positionTouchMargin = max(widget.controller.trimStyle.positionLineWidth, _touchMargin);

  late final ScrollController _scrollController;

  double? _preSynchLeft;
  double? _preSynchRight;
  double? _lastScrollPixelsBeforeBounce;
  double _lastScrollPixels = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    widget.controller.addListener(_updateTrim);
    if (_isExtendTrim) _scrollController.addListener(attachTrimToScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTrim);
    if (_isExtendTrim) _scrollController.removeListener(attachTrimToScroll);
    _scrollController.dispose();
    super.dispose();
  }

  double _getRectToTrim(double rectVal) =>
      (rectVal + _scrollController.offset - _horizontalMargin) /
          _fullLayout.width;
  double _geTrimToRect(double trimVal) =>
      (_fullLayout.width * trimVal) + _horizontalMargin;
  double get _bounceRightOffset =>
      (_scrollController.position.maxScrollExtent - _scrollController.offset)
          .abs();

  bool get isNotScrollBouncingBack {
    final isBouncingFromLeft =
        _scrollController.offset < _scrollController.position.minScrollExtent &&
            _scrollController.offset > _lastScrollPixels;
    final isBouncingFromRight =
        _scrollController.offset > _scrollController.position.maxScrollExtent &&
            _scrollController.offset < _lastScrollPixels;

    return !(isBouncingFromLeft || isBouncingFromRight);
  }

  void _updateTrim() {
    if (widget.controller.minTrim != _getRectToTrim(_rect.left) ||
        widget.controller.maxTrim != _getRectToTrim(_rect.right)) {
      if (_isExtendTrim) {
        setState(() {
          _rect = Rect.fromLTWH(
              _horizontalMargin,
              _rect.top,
              _geTrimToRect(widget.controller.maxTrim) -
                  _geTrimToRect(widget.controller.minTrim),
              _rect.height);
        });
        _scrollController.jumpTo(
            _geTrimToRect(widget.controller.minTrim) - _horizontalMargin);
      } else {
        setState(() {
          _rect = Rect.fromLTRB(
              _geTrimToRect(widget.controller.minTrim),
              _rect.top,
              _geTrimToRect(widget.controller.maxTrim),
              _rect.height);
        });
      }
      _resetControllerPosition();
    }
  }

  void attachTrimToScroll() {
    if (_scrollController.position.outOfRange == false) {
      if (_scrollController.offset == 0.0) {
        _changeTrimRect(
          left: _rect.left - _lastScrollPixels.abs(),
          updateTrim: false,
        );
      } else if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        _changeTrimRect(
          left:
          _rect.left + (_lastScrollPixels.abs() - _scrollController.offset),
          updateTrim: false,
        );
      }
      _updateControllerTrim();
      _preSynchLeft = null;
      _preSynchRight = null;
      _lastScrollPixelsBeforeBounce = null;
      _lastScrollPixels = _scrollController.offset;

      return;
    }

    if (isNotScrollBouncingBack) {
      _lastScrollPixelsBeforeBounce = _scrollController.offset;
    } else {
      if (_scrollController.position.extentBefore == 0.0 &&
          _preSynchLeft == null) {
        _preSynchLeft = max(
          0,
          _rect.left -
              _horizontalMargin -
              (_lastScrollPixelsBeforeBounce ?? _scrollController.offset).abs(),
        );
      } else if (_scrollController.position.extentAfter == 0.0 &&
          _preSynchRight == null) {
        final scrollOffset = (_scrollController.position.maxScrollExtent -
            (_lastScrollPixelsBeforeBounce ?? _scrollController.offset))
            .abs();
        _preSynchRight = max(
          0,
          _trimLayout.width - (_rect.right - _horizontalMargin) - scrollOffset,
        );
      }
      _lastScrollPixelsBeforeBounce = null;
    }

    final rectRightOffset =
        _trimLayout.width - (_rect.right - _horizontalMargin);

    if (_scrollController.position.extentAfter == 0.0 &&
        (_preSynchRight != null || _bounceRightOffset > rectRightOffset)) {
      _changeTrimRect(
        left: _trimLayout.width -
            _bounceRightOffset -
            _rect.width +
            _horizontalMargin -
            (_preSynchRight ?? 0),
        updateTrim: false,
      );
    } else if (_scrollController.position.extentBefore == 0.0 &&
        (_preSynchLeft != null ||
            _scrollController.offset.abs() + _horizontalMargin > _rect.left)) {
      _changeTrimRect(
        left: -_scrollController.offset +
            _horizontalMargin +
            (_preSynchLeft ?? 0),
        updateTrim: false,
      );
    }

    _updateControllerTrim();
    _lastScrollPixels = _scrollController.offset;
  }

  @override
  bool get wantKeepAlive => true;

  void _onHorizontalDragStart(DragStartDetails details) {
    final pos = details.localPosition;
    final progressTrim = _getVideoPosition();

    Rect leftTouch = Rect.fromCenter(
      center: Offset(_rect.left - _edgesTouchMargin / 2, _rect.height / 2),
      width: _edgesTouchMargin,
      height: _rect.height,
    );
    Rect rightTouch = Rect.fromCenter(
      center: Offset(_rect.right + _edgesTouchMargin / 2, _rect.height / 2),
      width: _edgesTouchMargin,
      height: _rect.height,
    );
    final progressTouch = Rect.fromCenter(
      center: Offset(progressTrim, _rect.height / 2),
      width: _positionTouchMargin,
      height: _rect.height,
    );

    _boundary = _TrimBoundaries.inside;

    if (isNotScrollBouncingBack &&
        !_scrollController.position.isScrollingNotifier.value) {
      if (progressTouch.contains(pos)) {
        _boundary = _TrimBoundaries.progress;
      } else {
        leftTouch = leftTouch.expandToInclude(
            Rect.fromLTWH(_rect.left, 0, _edgesTouchMargin, 1));
        rightTouch = rightTouch.expandToInclude(Rect.fromLTWH(
            _rect.right - _edgesTouchMargin, 0, _edgesTouchMargin, 1));
      }

      if (leftTouch.contains(pos)) {
        _boundary = _TrimBoundaries.left;
      } else if (rightTouch.contains(pos)) {
        _boundary = _TrimBoundaries.right;
      }
    }

    _updateControllerIsTrimming(true);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final Offset delta = details.delta;
    final posLeft = _rect.topLeft + delta;

    switch (_boundary) {
      case _TrimBoundaries.left:
        final clampLeft = posLeft.dx.clamp(_horizontalMargin, _rect.right);
        _changeTrimRect(
            left: clampLeft,
            width: _rect.width - (clampLeft - posLeft.dx).abs() - delta.dx);
        break;
      case _TrimBoundaries.right:
        _changeTrimRect(
          width: (_rect.left + _rect.width + delta.dx)
              .clamp(_rect.left, _trimLayout.width + _horizontalMargin) -
              _rect.left,
        );
        break;
      case _TrimBoundaries.inside:
        if (_isExtendTrim) {
          _scrollController.position.moveTo(
            _scrollController.offset - delta.dx,
            clamp: false,
          );
        } else {
          _changeTrimRect(
            left: posLeft.dx.clamp(
              _horizontalMargin,
              _trimLayout.width + _horizontalMargin - _rect.width,
            ),
          );
        }
        break;
      case _TrimBoundaries.progress:
        final pos = details.localPosition.dx;
        final localRatio = pos / (_trimLayout.width + _horizontalMargin * 2);
        final localAdjust = (localRatio - 0.5) * (_horizontalMargin * 2);
        _controllerSeekTo((pos + localAdjust).clamp(
          _rect.left - _horizontalMargin,
          _rect.right + _horizontalMargin,
        ));
        break;
      default:
        break;
    }
  }

  void _onHorizontalDragEnd([_]) {
    _preComputedVideoPosition = null;
    _updateControllerIsTrimming(false);
    if (_boundary == null) return;
    if (_boundary != _TrimBoundaries.progress) {
      _updateControllerTrim();
    }
  }

  void _changeTrimRect({double? left, double? width, bool updateTrim = true}) {
    left = left ?? _rect.left;
    width = max(0, width ?? _rect.width);

    final Duration diff = _getDurationDiff(left, width);
    if (diff < widget.controller.minDuration ||
        diff > widget.controller.maxDuration) {
      if (_boundary == _TrimBoundaries.left) {
        final limitLeft = left.clamp(
            left +
                width -
                _getRectWidthFromDuration(widget.controller.maxDuration),
            left +
                width -
                _getRectWidthFromDuration(widget.controller.minDuration));
        width += left - limitLeft;
        left = limitLeft;
      } else if (_boundary == _TrimBoundaries.right) {
        width = width.clamp(
          _getRectWidthFromDuration(widget.controller.minDuration),
          _getRectWidthFromDuration(widget.controller.maxDuration),
        );
      }
    }

    bool shouldHaptic = _canDoHaptic(left, width);

    if (updateTrim) {
      _rect = Rect.fromLTWH(left, _rect.top, width, _rect.height);
      _updateControllerTrim();
    } else {
      setState(
              () => _rect = Rect.fromLTWH(left!, _rect.top, width!, _rect.height));
    }
    if (shouldHaptic) HapticFeedback.lightImpact();
  }

  void _createTrimRect() {
    _rect = Rect.fromPoints(
      Offset(widget.controller.minTrim * _fullLayout.width, 0.0),
      Offset(widget.controller.maxTrim * _fullLayout.width, widget.height),
    ).shift(Offset(_horizontalMargin, 0));
  }

  void _resetControllerPosition() async {
    if (_boundary == _TrimBoundaries.progress) return;

    if (_boundary == null ||
        _boundary == _TrimBoundaries.inside ||
        _boundary == _TrimBoundaries.left) {
      _preComputedVideoPosition = _rect.left;
      await widget.controller.video.seekTo(widget.controller.startTrim);
    } else if (_boundary == _TrimBoundaries.right) {
      _preComputedVideoPosition = _rect.right;
      await widget.controller.video.seekTo(widget.controller.endTrim);
    }
  }

  void _controllerSeekTo(double position) async {
    _preComputedVideoPosition = null;
    final to = widget.controller.videoDuration *
        ((position + _scrollController.offset) /
            (_fullLayout.width + _horizontalMargin * 2));
    await widget.controller.video.seekTo(
        to > widget.controller.endTrim ? widget.controller.endTrim : to);
  }

  void _updateControllerTrim() {
    widget.controller.updateTrim(
      _getRectToTrim(_rect.left),
      _getRectToTrim(_rect.right),
    );
    _resetControllerPosition();
  }

  void _updateControllerIsTrimming(bool value) {
    if (value && widget.controller.isPlaying) {
      _isVideoPlayerHold = true;
      widget.controller.video.pause();
    } else if (_isVideoPlayerHold) {
      _isVideoPlayerHold = false;
      widget.controller.video.play();
    }

    if (_boundary != _TrimBoundaries.progress) {
      widget.controller.isTrimming = value;
    }
    if (value == false) {
      _boundary = null;
    }
  }

  double _getVideoPosition() =>
      _preComputedVideoPosition ??
          (_fullLayout.width * widget.controller.trimPosition -
              _scrollController.offset +
              _horizontalMargin);

  Duration _getDurationDiff(double left, double width) {
    final double min = (left - _horizontalMargin) / _fullLayout.width;
    final double max = (left + width - _horizontalMargin) / _fullLayout.width;
    final Duration duration = widget.controller.videoDuration;

    return (duration * max) - (duration * min);
  }

  bool _canDoHaptic(double left, double width) {
    if (!widget.hasHaptic || !isNotScrollBouncingBack) return false;

    final checkLastSize =
        _boundary != null && _boundary != _TrimBoundaries.inside;
    final isNotMin = _rect.left !=
        (_horizontalMargin +
            (checkLastSize ? 0 : _lastScrollPixels.abs())) &&
        widget.controller.minTrim > 0.0 &&
        (checkLastSize ? left < _rect.left : true);
    final isNotMax = _rect.right != _trimLayout.width + _horizontalMargin &&
        widget.controller.maxTrim < 1.0 &&
        (checkLastSize ? (left + width) > _rect.right : true);
    final isOnLeftEdge =
        (_scrollController.offset.abs() + _horizontalMargin - left).abs() < 1.0;
    final isOnRightEdge = (_bounceRightOffset +
        left +
        width -
        _trimLayout.width -
        _horizontalMargin)
        .abs() <
        1.0;

    return (isNotMin && isOnLeftEdge) || (isNotMax && isOnRightEdge);
  }

  double _getRectWidthFromDuration(Duration duration) =>
      duration > Duration.zero
          ? _fullLayout.width /
          (widget.controller.videoDuration.inMilliseconds /
              duration.inMilliseconds)
          : 0.0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(builder: (_, constraint) {
      final Size trimLayout = Size(
        constraint.maxWidth - _horizontalMargin * 2,
        constraint.maxHeight,
      );
      _fullLayout = Size(
        trimLayout.width * (_isExtendTrim ? _viewportRatio : 1),
        constraint.maxHeight,
      );
      if (_trimLayout != trimLayout) {
        _trimLayout = trimLayout;
        _createTrimRect();
      }

      return SizedBox(
          width: _fullLayout.width,
          child: Stack(children: [
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (_boundary == null) {
                  if (scrollNotification is ScrollStartNotification) {
                    _updateControllerIsTrimming(true);
                  } else if (scrollNotification is ScrollEndNotification) {
                    _onHorizontalDragEnd();
                  }
                }

                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalMargin),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          widget.controller.trimStyle.borderRadius,
                        ),
                        child: SizedBox(
                          height: widget.height,
                          width: _fullLayout.width,
                          child: ThumbnailSlider(
                            controller: widget.controller,
                            height: widget.height,
                          ),
                        ),
                      ),
                      if (widget.child != null)
                        SizedBox(width: _fullLayout.width, child: widget.child)
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  widget.controller,
                  widget.controller.video,
                ]),
                builder: (_, __) {

                  return RepaintBoundary(
                    child: CustomPaint(
                      size: Size.fromHeight(widget.height),
                      painter: TrimSliderPainter(
                        _rect,
                        _getVideoPosition(),
                        widget.controller.trimStyle,
                        isTrimming: widget.controller.isTrimming,
                        isTrimmed: widget.controller.isTrimmed,
                      ),
                    ),
                  );
                },
              ),
            )
          ]));
    });
  }
}

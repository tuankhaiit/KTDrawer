library kt_drawer_menu;

import 'package:flutter/material.dart';

const kDuration = 180;
const kEdgeDragWidth = 20.0;
const kWidth = 300.0;
const kScale = 0.6;
const kOffset = 0.5;
const kRadius = 40.0;
const kShadow = 10.0;
const kShadowColor = Colors.black38;
const kOpacity = 0.0;
const kColorOverlay = Colors.transparent;

// ignore: must_be_immutable
class KTDrawerMenu extends StatefulWidget {
  final KTDrawerController controller;
  final Widget drawer;
  final Widget content;
  final Duration duration;

  final double edgeDragWidth;
  final double width;
  final double scale;
  final double offset;
  final double radius;
  final double shadow;
  final Color shadowColor;
  final double opacity;
  final Color colorOverlay;
  final AnimationStatusListener onStateChange;
  final ValueChanged<double> onProgressChange;

  KTDrawerMenu({
    Key key,
    @required this.drawer,
    @required this.content,
    KTDrawerController controller,
    Duration duration,
    this.width = kWidth,
    this.edgeDragWidth = kEdgeDragWidth,
    this.scale = kScale,
    this.offset = kOffset,
    this.radius = kRadius,
    this.shadow = kShadow,
    this.shadowColor = kShadowColor,
    this.opacity = kOpacity,
    this.colorOverlay = kColorOverlay,
    this.onStateChange,
    this.onProgressChange,
  })  : this.controller = controller ?? KTDrawerController(),
        this.duration = duration ?? Duration(milliseconds: kDuration),
        assert(edgeDragWidth > 0),
        assert(opacity >= 0 && opacity < 1.0),
        assert(scale > 0 && scale < 1.0),
        assert(offset > 0 && offset < 1.0),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _KTDrawerMenuState();

  static KTDrawerController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_KTDrawerInheritedWidget>()
        .data;
  }
}

class _KTDrawerMenuState extends State<KTDrawerMenu>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation, _scaleAnimation;
  Animation<double> _alphaAnimation, _shadowAnimation;
  Animation<BorderRadius> _radiusAnimation;

  static final kVelocity = 700.0;
  var _downOffset = Offset.zero;
  var _isDragging = false;
  var isOpen = false;

  @override
  void initState() {
    widget.controller._attach(this);
    super.initState();

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
          ..addListener(() {
            if (widget.onProgressChange != null) {
              widget.onProgressChange(_animation.value);
            }
            setState(() {});
          })
          ..addStatusListener((status) {
            if (widget.onStateChange != null) {
              widget.onStateChange(status);
            }
          });

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale)
        .animate(_animationController);

    _alphaAnimation = Tween<double>(begin: 0.0, end: widget.opacity)
        .animate(_animationController);

    _radiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(0.0),
      end: BorderRadius.circular(widget.radius),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.ease));

    _shadowAnimation = Tween<double>(begin: 0.0, end: widget.shadow).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.ease));
  }

  @override
  void didUpdateWidget(KTDrawerMenu oldWidget) {
    widget.controller._attach(this);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller._detach(this);
    super.dispose();
  }

  toggle() {
    _animation.isCompleted ? closeDrawer() : openDrawer();
  }

  closeDrawer() {
    _animationController.reverse();
    _isOpen = false;
  }

  openDrawer() {
    _animationController.forward();
    _isOpen = true;
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context).size;
    var width = device.width;
    var height = device.height;

    return _KTDrawerInheritedWidget(
      data: widget.controller,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onHorizontalDragDown: (DragDownDetails details) {
            var position = details.globalPosition;
            if (_isOpen || (!_isOpen && position.dx < widget.edgeDragWidth)) {
              _downOffset = position;
              _isDragging = true;
            }
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            var position = details.globalPosition;
            if (_isDragging) {
              if (_isOpen) {
                var newValue =
                    1 - (_downOffset.dx - position.dx - 15) / widget.width;
                _animationController.value = newValue;
              } else {
                var newValue =
                    (position.dx - _downOffset.dx - 15) / widget.width;
                _animationController.value = newValue;
              }
            }
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            if (_isDragging) {
              if (details != null && details.primaryVelocity != null) {
                if (details.primaryVelocity > kVelocity) {
                  openDrawer();
                } else if (details.primaryVelocity < -kVelocity) {
                  closeDrawer();
                } else {
                  if (_animationController.value > widget.offset) {
                    openDrawer();
                  } else {
                    closeDrawer();
                  }
                }
              }
            }

            _isDragging = false;
          },
          child: Stack(
            children: [
              Container(
                color: Colors.transparent,
                width: width,
                height: height,
                child: widget.drawer,
              ),
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.translate(
                  offset: Offset(widget.width * _animation.value, 0.0),
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                        borderRadius: _radiusAnimation.value,
                        boxShadow: [
                          BoxShadow(
                              color: widget.shadowColor.withOpacity(0.5),
                              spreadRadius: _shadowAnimation.value / 2.0,
                              blurRadius: _shadowAnimation.value * 2)
                        ]),
                    child: AbsorbPointer(
                      absorbing: _animationController.isCompleted,
                      child: ClipRRect(
                        borderRadius: _radiusAnimation.value,
                        child: Stack(
                          children: [
                            widget.content,
                            Container(
                              color: _animation.value == 0
                                  ? null
                                  : widget.colorOverlay
                                      .withOpacity(_alphaAnimation.value),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KTDrawerInheritedWidget extends InheritedWidget {
  final KTDrawerController data;

  _KTDrawerInheritedWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

typedef KTDrawerStateCallback = void Function(bool isOpen);
typedef KTDrawerUpdateCallback = void Function(double progress);

class KTDrawerController {
  _KTDrawerMenuState _state;

  KTDrawerController();

  bool isOpening() => _state.isOpen;

  void openDrawer() {
    if (_state != null) {
      _state.openDrawer();
    }
  }

  void closeDrawer() {
    if (_state != null) {
      _state.closeDrawer();
    }
  }

  void toggle() {
    if (_state != null) {
      _state.toggle();
    }
  }

  void _attach(_KTDrawerMenuState state) {
    _state = state;
  }

  void _detach(_KTDrawerMenuState state) {
    _state = null;
  }
}

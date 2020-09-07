library kt_drawer_menu;

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class KTDrawerMenu extends StatefulWidget {
  final KTDrawerController controller;
  final Widget drawer;
  final Widget content;
  final Duration duration;

  final double edgeDragWidth;
  final double maxWidth;
  final double minScale;
  final double offset;
  final double radius;
  final double opacity;
  final Color colorOpacity;
  final AnimationStatusListener onStateChange;
  final ValueChanged<double> onProgressChange;

  KTDrawerMenu({
    Key key,
    @required this.drawer,
    @required this.content,
    KTDrawerController controller,
    Duration duration,
    this.maxWidth = 300.0,
    this.edgeDragWidth = 20.0,
    this.minScale = 0.6,
    this.offset = 0.5,
    this.radius = 50.0,
    this.opacity = 0.0,
    this.colorOpacity = Colors.transparent,
    this.onStateChange,
    this.onProgressChange,
  })  : this.controller = controller ?? KTDrawerController(),
        this.duration = duration ?? Duration(milliseconds: 150),
        assert(edgeDragWidth > 0),
        assert(opacity >= 0 && opacity < 1),
        assert(minScale > 0 && minScale < 1),
        assert(offset > 0 && offset < 1),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _KTDrawerMenuState();
}

class _KTDrawerMenuState extends State<KTDrawerMenu>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation, _scaleAnimation, _alphaAnimation;
  Animation<BorderRadius> _radiusAnimation;

  static final kVelocity = 700;
  var downOffset = Offset.zero;
  var isDragging = false;
  var isOpen = false;
  var scale = 1.0;

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

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.minScale)
        .animate(_animationController);

    _alphaAnimation = Tween<double>(begin: 0.0, end: widget.opacity)
        .animate(_animationController);

    _radiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(0.0),
      end: BorderRadius.circular(widget.radius),
    ).animate(
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
    isOpen = false;
  }

  openDrawer() {
    _animationController.forward();
    isOpen = true;
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context).size;
    var width = device.width;
    var height = device.height;

    return Container(
      child: GestureDetector(
        onHorizontalDragDown: (DragDownDetails details) {
          var position = details.globalPosition;
          if (isOpen || (!isOpen && position.dx < widget.edgeDragWidth)) {
            downOffset = position;
            isDragging = true;
          }
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          var position = details.globalPosition;
          if (isDragging) {
            if (isOpen) {
              var newValue =
                  1 - (downOffset.dx - position.dx - 15) / widget.maxWidth;
              _animationController.value = newValue;
            } else {
              var newValue =
                  (position.dx - downOffset.dx - 15) / widget.maxWidth;
              _animationController.value = newValue;
            }
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (isDragging) {
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

          isDragging = false;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.drawer,
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.translate(
                offset: Offset(widget.maxWidth * _animation.value, 0.0),
                child: SizedBox(
                  width: width,
                  height: height,
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
                                : widget.colorOpacity
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
    );
  }
}

typedef KTDrawerStateCallback = void Function(bool isOpen);
typedef KTDrawerUpdateCallback = void Function(double progress);

class KTDrawerController {
  _KTDrawerMenuState _state;

  KTDrawerController();

  void open() {
    if (_state != null) {
      _state.openDrawer();
    }
  }

  void close() {
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

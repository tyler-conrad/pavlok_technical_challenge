import 'package:flutter/material.dart' as m;
import 'package:flutter_svg/flutter_svg.dart' as svg;

import 'package:pavlok_technical_challenge/src/constants.dart' as c;
import 'package:pavlok_technical_challenge/src/shared.dart' as s;

/// An [m.ElevatedButton] representing good and bad habits.
///
/// Used by the HabitButtonPicker that diplays a list of either good or bad
/// habits.  A [HabitButton] consists of an [svg.SvgPicture] child and a
/// [m.Text] child.  The background and text color are animated upon selection
/// and deselection.
class HabitButton extends m.StatefulWidget {
  HabitButton({
    m.Key? key,
    required void Function() onPressed,
    required String text,
    required String svgAssetPath,
    required m.Offset position,
  })  : _onPressed = onPressed,
        _text = text,
        _svgAssetPath = svgAssetPath,
        _position = position,
        super(
          key: key,
        );

  final void Function() _onPressed;
  final String _text;
  final String _svgAssetPath;
  final m.Offset _position;

  final selected = m.ValueNotifier(
    false,
  );

  @override
  m.State<HabitButton> createState() => _HabitButtonState();
}

class _HabitButtonState extends m.State<HabitButton>
    with m.TickerProviderStateMixin {
  late final m.AnimationController _outlineColorAnimationController;
  late final m.Animation<m.Color?> _outlineColorAnimation;

  late final m.AnimationController _backgroundColorAnimationController;
  late final m.Animation<m.Color?> _backgroundColorAnimation;

  late final m.AnimationController _textColorAnimationController;
  late final m.Animation<m.Color?> _textColorAnimation;

  m.Size _screenSize = m.Size.zero;

  void _setupOutlineColorAnimation() {
    _outlineColorAnimationController = m.AnimationController(
      vsync: this,
      duration: c.quarterSecond,
    )..addListener(
        () {
          setState(
            () {},
          );
        },
      );
    _outlineColorAnimation = m.ColorTween(
      begin: m.Colors.white,
      end: c.purple,
    ).animate(
      m.CurvedAnimation(
        parent: _outlineColorAnimationController,
        curve: m.Curves.easeInOut,
      ),
    );
  }

  void _setupBackgroundColorAnimation() {
    _backgroundColorAnimationController = m.AnimationController(
      vsync: this,
      duration: c.quarterSecond,
    )..addListener(
        () {
          setState(
            () {},
          );
        },
      );
    _backgroundColorAnimation = m.ColorTween(
      begin: m.Colors.white,
      end: c.lightPurple,
    ).animate(
      m.CurvedAnimation(
        parent: _outlineColorAnimationController,
        curve: m.Curves.easeInOut,
      ),
    );
  }

  void _setupTextColorAnimation() {
    _textColorAnimationController = m.AnimationController(
      vsync: this,
      duration: c.quarterSecond,
    )..addListener(
        () {
          setState(
            () {},
          );
        },
      );
    _textColorAnimation = m.ColorTween(
      begin: m.Colors.black,
      end: c.purple,
    ).animate(
      m.CurvedAnimation(
        parent: _outlineColorAnimationController,
        curve: m.Curves.easeInOut,
      ),
    );
  }

  void _setupSelectionListener() {
    widget.selected.addListener(
      () {
        if (widget.selected.value) {
          _outlineColorAnimationController.forward(
            from: _outlineColorAnimationController.value,
          );
          _backgroundColorAnimationController.forward(
            from: _backgroundColorAnimationController.value,
          );
          _textColorAnimationController.forward(
            from: _textColorAnimationController.value,
          );
        } else {
          _outlineColorAnimationController.reverse(
            from: _outlineColorAnimationController.value,
          );
          _backgroundColorAnimationController.reverse(
            from: _backgroundColorAnimationController.value,
          );
          _textColorAnimationController.reverse(
            from: _textColorAnimationController.value,
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _setupOutlineColorAnimation();
    _setupBackgroundColorAnimation();
    _setupTextColorAnimation();
    _setupSelectionListener();
  }

  @override
  void dispose() {
    widget.selected.dispose();
    _textColorAnimationController.dispose();
    _backgroundColorAnimationController.dispose();
    _outlineColorAnimationController.dispose();
    super.dispose();
  }

  m.Text _buildLabel() {
    return m.Text(
      widget._text,
      style: m.TextStyle(
        color: _textColorAnimation.value,
        fontSize: s.fromScreenSize(
          17.0,
          _screenSize,
        ),
        fontWeight: m.FontWeight.w600,
      ),
    );
  }

  m.Container _buildIcon() {
    return m.Container(
      width: s.fromScreenSize(
        52.0,
        _screenSize,
      ),
      height: s.fromScreenSize(
        52.0,
        _screenSize,
      ),
      decoration: m.BoxDecoration(
        color: c.lightPurple,
        borderRadius: m.BorderRadius.all(
          m.Radius.circular(
            s.fromScreenSize(
              c.defaultBorderRadius,
              _screenSize,
            ),
          ),
        ),
      ),
      child: m.Stack(
        children: [
          m.Positioned(
            left: widget._position.dx,
            top: widget._position.dy,
            child: svg.SvgPicture.asset(
              widget._svgAssetPath,
            ),
          ),
        ],
      ),
    );
  }

  @override
  m.Widget build(m.BuildContext context) {
    _screenSize = m.MediaQuery.of(context).size;
    return m.ElevatedButton(
      style: m.ButtonStyle(
        side: m.MaterialStateProperty.all(
          m.BorderSide(
            width: 2.0,
            color: _outlineColorAnimation.value ?? m.Colors.transparent,
          ),
        ),
        elevation: m.MaterialStateProperty.all(
          c.defaultElevation,
        ),
        shadowColor: m.MaterialStateProperty.all(
          m.Colors.black38,
        ),
        padding: m.MaterialStateProperty.all(
          m.EdgeInsets.all(
            s.fromScreenSize(
              10.0,
              _screenSize,
            ),
          ),
        ),
        backgroundColor: m.MaterialStateProperty.all(
          _backgroundColorAnimation.value,
        ),
        minimumSize: m.MaterialStateProperty.all(
          m.Size(
            0.0,
            s.fromScreenSize(
              72.0,
              _screenSize,
            ),
          ),
        ),
        shape: m.MaterialStateProperty.all<m.RoundedRectangleBorder>(
          m.RoundedRectangleBorder(
            borderRadius: m.BorderRadius.circular(
              s.fromScreenSize(
                c.defaultBorderRadius,
                _screenSize,
              ),
            ),
          ),
        ),
      ),
      onPressed: () {
        widget._onPressed();
        widget.selected.value = !widget.selected.value;
      },
      child: m.Row(
        mainAxisAlignment: m.MainAxisAlignment.start,
        children: [
          _buildIcon(),
          m.SizedBox(
            width: s.fromScreenSize(
              16.0,
              _screenSize,
            ),
          ),
          _buildLabel(),
        ],
      ),
    );
  }
}

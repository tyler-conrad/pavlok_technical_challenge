import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:io' as io;

import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:flutter/material.dart' as m;
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:collection/collection.dart';

import 'package:pavlok_technical_challenge/constants.dart' as c;
import 'package:pavlok_technical_challenge/shared.dart' as s;

/// This class represents the data needed to draw a dark hour line along with
/// the label for the line (for examples '12pm').
///
/// [List.generate] is mapped over to generate a list of [HourTick]s which are
/// then drawn to the screen as part of the [CircularDurationPickerPainter].
class HourTick {
  HourTick({
    required this.tickStart,
    required this.tickEnd,
    required this.text,
  });

  final m.Offset tickStart;
  final m.Offset tickEnd;
  final String text;
}

/// This class holds the 'bedtime' and 'wakeUp' SVG images that are
/// asynchronously loaded in the [CircularDurationPicker] class.
///
/// Using a [Future] within the [m.CustomPainter] and drawing in [Future.then]
/// callback caused a bug where the [m.Canvas] was disposed before the callback
/// was executed and the canvas that was referenced in the closure. The callback
/// was invalidated and therefore threw an exception.
///
/// To fix this issue I use a nullable [ResolvedSvgs] variable that only takes
/// on a value once the [Future] for both SVGs has been resolved.
class ResolvedSvgs {
  ResolvedSvgs({
    required this.bedtime,
    required this.wakeup,
  });

  final svg.DrawableRoot bedtime;
  final svg.DrawableRoot wakeup;
}

/// This class holds the logic for drawing a circular interval selector using a
/// [m.Canvas].
///
/// This class draws that picker using four items of input.  The first two are
/// the 'bedtime' and 'wakeUp' offsets (which can be viewed as vectors
/// representing the positions as well as radius and angle of the user draggable
/// handles.  The SVGs to be drawn on the handles are stored in the '_svgs'
/// field which becomes non-null when the SVGs have loaded.  The
/// [m.CustomPainter.paint] method is called by the framework with [m.Size] of
/// the canvas which is the fourth item of data required to draw the picker.
class CircularDurationPickerPainter extends m.CustomPainter {
  CircularDurationPickerPainter({
    m.Listenable? repaint,
    required m.Offset bedtime,
    required m.Offset wakeUp,
    required ResolvedSvgs? svgs,
  })  : _bedtime = bedtime,
        _wakeUp = wakeUp,
        _svgs = svgs,
        super(
          repaint: repaint,
        );

  static const _canvasSizeScaleFactor = 240.0;
  static const _numHourTicks = 12;
  static const _numMinuteTicks = 72;

  /// Represents the outside offset surrounding the rectangle that is drawn with
  /// a shadowed tube shape cut out of it.
  static const _rectOverdrawSize = 32.0;
  static const _hoursLabelVerticalOffsetFactor = -0.75;
  static const _minutesLabelVerticalOffsetFactor = 0.7;

  final m.Offset _bedtime;
  final m.Offset _wakeUp;
  final ResolvedSvgs? _svgs;

  /// Scales fixed sizes based on the canvas size.
  double _fromCanvasSize(
    double baseSize,
    m.Size canvasSize,
  ) =>
      math.min(
        baseSize,
        baseSize *
            math.min(canvasSize.width, canvasSize.height) /
            _canvasSizeScaleFactor,
      );

  /// Returns an [m.Path] that is a rectangle with a tube subtracted from it.
  ///
  /// This [m.Path] is used to draw the shadow for the tube and the background
  /// of the [CircularDurationPicker].
  m.Path _loopPath(m.Size size) => m.Path.combine(
        m.PathOperation.union,
        m.Path.combine(
          m.PathOperation.difference,
          m.Path()
            ..addRect(
              m.Rect.fromLTWH(
                -_rectOverdrawSize,
                -_rectOverdrawSize,
                size.width + _rectOverdrawSize * 2.0,
                size.height + _rectOverdrawSize * 2.0,
              ),
            ),
          m.Path()
            ..addOval(
              m.Rect.fromCircle(
                center: m.Offset(size.width * 0.5, size.height * 0.5),
                radius: size.width * 0.5,
              ),
            )
            ..close(),
        ),
        m.Path()
          ..addOval(
            m.Rect.fromCircle(
              center: m.Offset(size.width * 0.5, size.height * 0.5),
              radius: size.width * c.durationPickerInsideRadiusFactor,
            ),
          )
          ..close(),
      );

  /// Draws the draggable handles for the bedtime and wake up times.
  ///
  /// Uses a [ui.Gradient.radial] to fade from [c.purpleHighlight] on the
  /// outside to the standard [c.purple] on the inside.
  void _drawHandle(
    m.Canvas canvas,
    m.Size size,
    m.Offset center,
    m.Offset handlePos, [
    double radiusOverdrawFactor = 0.9,
  ]) {
    final handleCenter = center + handlePos;
    final radius =
        (0.5 - c.durationPickerInsideRadiusFactor) * handlePos.distance;
    canvas.drawCircle(
      handleCenter,
      radius * radiusOverdrawFactor,
      m.Paint()
        ..shader = ui.Gradient.radial(
          handleCenter,
          radius,
          [
            c.purple,
            c.purpleHighlight,
          ],
          [
            0.5,
            1.0,
          ],
        ),
    );
  }

  /// Draws an SVG image at the center of the handle.
  ///
  /// Two calls are made to the this method, one for the bedtime where the image
  /// is a moon and one for the wake up time where the image is a sun.
  void _drawSvg(m.Canvas canvas, m.Offset center, svg.DrawableRoot? svgRoot,
      m.Size size) {
    m.Size desiredSize = m.Size(
      _fromCanvasSize(
        16.0,
        size,
      ),
      _fromCanvasSize(
        16.0,
        size,
      ),
    );
    canvas.save();
    canvas.translate(
      center.dx - desiredSize.width / 2,
      center.dy - desiredSize.height / 2,
    );
    m.Size? svgSize = svgRoot?.viewport.size;
    var matrix = vm.Matrix4.identity();
    matrix.scale(
      desiredSize.width / (svgSize?.width ?? 1.0),
      desiredSize.height / (svgSize?.height ?? 1.0),
    );
    canvas.transform(
      matrix.storage,
    );
    svgRoot?.draw(
      canvas,
      m.Rect.zero,
    );
    canvas.restore();
  }

  /// Returns an [m.Offset] representing the position, radius and angle of an
  /// hour tick.
  ///
  /// Multiplies the [radius] and [scaleFactor] to determine the output
  /// [m.Offset.distance].  Uses [math.sin] and [math.cos] along with the
  /// [index] and [length] parameters to calculate the angle of the returned
  /// [m.Offset].
  m.Offset _hourTickOffset(
    m.Offset center,
    double radius,
    double scaleFactor,
    int index,
    int length,
  ) =>
      center +
      m.Offset(
        radius *
            scaleFactor *
            math.cos(
              2.0 * math.pi * (-index.toDouble() / length),
            ),
        radius *
            scaleFactor *
            math.sin(
              2.0 * math.pi * (-index.toDouble() / length),
            ),
      );

  /// This function returns the string 'am', 'pm' or the empty string used for
  /// labeling the tick marks that are 6 hour offsets from the beginning of the
  /// day.
  String _amPm(int index) {
    switch (index) {
      case 0:
        return 'am';
      case 3:
        return 'pm';
      case 6:
        return 'pm';
      case 9:
        return 'am';
      default:
        return '';
    }
  }

  /// Returns a [String] like '12pm' based on the index of the tick.
  String _buildHourTickText(int index) {
    final hour = (index * 2 + 6) % 12;
    final wrappedHour = hour % 12 == 0 ? 12 : hour;
    return '$wrappedHour${_amPm(
      index,
    )}';
  }

  /// Uses [_loopPath] to draw a shadowed area in the tube section cut out of
  /// the background of the canvas.
  ///
  /// The canvas has a parent [m.ClipRect] that prevents anything drawn to the
  /// canvas outside the bounds of the [m.Size] passed to [m.Canvas.paint].
  /// The shadow for a rectangle with a tube cut out of it is drawn to the
  /// [m.Canvas].  The rectangle is drawn using [_rectOverdrawSize] so it
  /// extends in all directions outside the size of the [m.ClipRect] - this is
  /// done in order to have the shadow of the tube drawn without the shadow of
  /// this outside edge of the rectangle being visible.
  void _drawTubeShadow(
    m.Canvas canvas,
    m.Size size,
  ) {
    canvas.drawPath(
      _loopPath(
        size,
      ),
      m.Paint()
        ..color = m.Colors.black.withAlpha(
          64,
        )
        ..maskFilter = const m.MaskFilter.blur(
          m.BlurStyle.normal,
          48 * 0.25,
        ),
    );
  }

  /// Draws the arc representing the bedtime to wake up duration.
  ///
  /// [m.Canvas.drawArc] draws an arc from a start angle and a sweep angle.  The
  /// [_bedtime] handle offset angle is used as the start angle.
  /// The behavior of [m.Offset.direction] is to return a value between
  /// -[math.pi] and [math.pi].  This fact causes the arc to be drawn
  /// incorrectly for some handle positions.  [s.convertToPositiveDirection] is
  /// used to guarantee that the sweep angle represented by the difference of
  /// the angle of the handles is always positive which ensures that the arc is
  /// drawn correctly for all handle angles.
  ///
  /// The arc is drawn with a [ui.Gradient.radial] to provide a white highilght
  /// on the outside edges of the arc.
  void _drawDurationArc(m.Canvas canvas, m.Offset center, double radius) {
    canvas.drawArc(
      m.Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      _bedtime.direction,
      s.convertToPositiveDirection(_wakeUp.direction - _bedtime.direction),
      true,
      m.Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [
            c.purpleHighlight,
            c.purple,
            c.purple,
            c.purpleHighlight,
          ],
          [
            1.0 - (0.5 + c.durationPickerInsideRadiusFactor) * 0.25,
            1.0 - (0.5 - c.durationPickerInsideRadiusFactor) * 1.5,
            1.0 - (0.5 - c.durationPickerInsideRadiusFactor) * 0.5,
            1.0,
          ],
        ),
    );
  }

  /// Uses [_loopPath] to draw over the shadow previously drawn using
  /// [_loopPath].
  ///
  /// The shadow drawn previously covers areas of the canvas other than the tube
  /// section.  Drawing a rectangle with a tube section cut out of it ensures
  /// that the shadows are only visible in the cut-away regions.
  void _drawBackgroundOverShadowAndArc(
    m.Canvas canvas,
    m.Size size,
  ) {
    canvas.drawPath(
      _loopPath(
        size,
      ),
      m.Paint()..color = c.backgroundColor,
    );
  }

  /// Draws a [c.lightGray] line at 10 minute intervals along the circle
  /// representing a 24-hour period.
  void _drawMinuteTicks(
    m.Canvas canvas,
    m.Offset center,
    double radius,
  ) {
    List.generate(
            _numMinuteTicks,
            (
              index,
            ) =>
                index)
        .where(
      (
        i,
      ) =>
          i % 6 != 0,
    )
        .forEach(
      (
        index,
      ) {
        canvas.drawLine(
          _hourTickOffset(
            center,
            radius,
            0.7,
            index,
            _numMinuteTicks,
          ),
          _hourTickOffset(
            center,
            radius,
            0.65,
            index,
            _numMinuteTicks,
          ),
          m.Paint()
            ..color = c.lightGray
            ..strokeWidth = 2.0,
        );
      },
    );
  }

  /// Used by [_drawHourTicksAndLabels] to draw the text for the hour at 2 hour
  /// intervals along a circular path on the inside of the
  /// [CircularDurationPicker].
  void _drawHourLabel(int index, HourTick hourTick, m.Size size,
      m.Canvas canvas, m.Offset center, double radius) {
    final m.TextPainter textPainter = m.TextPainter(
      text: m.TextSpan(
        text: hourTick.text,
        style: m.TextStyle(
          fontSize: index % 3 == 0
              ? _fromCanvasSize(
                  11.0,
                  size,
                )
              : _fromCanvasSize(
                  9.0,
                  size,
                ),
          fontWeight: m.FontWeight.w600,
          color: c.gray,
        ),
      ),
      textAlign: m.TextAlign.justify,
      textDirection: m.TextDirection.ltr,
    )..layout(
        maxWidth: size.width,
      );
    textPainter.paint(
      canvas,
      _hourTickOffset(
            center,
            radius,
            0.54,
            _numHourTicks - index,
            _numHourTicks,
          ) +
          m.Offset(
            -textPainter.width * 0.5,
            -textPainter.height * 0.5,
          ),
    );
  }

  /// Draws the line and label at every 2 hour interval in a 24-hour period
  /// along the circular area on the inside o the [CircularDurationPicker].
  void _drawHourTicksAndLabels(
    m.Canvas canvas,
    m.Size size,
    m.Offset center,
    double radius,
  ) {
    List.generate(
      _numHourTicks,
      (
        index,
      ) =>
          HourTick(
        tickStart: _hourTickOffset(
          center,
          radius,
          0.7,
          index,
          _numHourTicks,
        ),
        tickEnd: _hourTickOffset(
          center,
          radius,
          0.65,
          index,
          _numHourTicks,
        ),
        text: _buildHourTickText(
          index,
        ),
      ),
    ).forEachIndexed(
      (
        index,
        hourTick,
      ) {
        canvas.drawLine(
          hourTick.tickStart,
          hourTick.tickEnd,
          m.Paint()
            ..color = m.Colors.black
            ..strokeWidth = 2.0,
        );
        _drawHourLabel(
          index,
          hourTick,
          size,
          canvas,
          center,
          radius,
        );
      },
    );
  }

  /// Used for drawing both the purple label 'XXhrs' or the black 'XXmin' in the
  /// center of the [CircularDurationPicker].
  ///
  /// This function is called by both [_drawDurationHoursLabel] and
  /// [_drawDurationMinutesLabel] with parameters that specialize this function
  /// for each use case.
  void _drawCenteredDurationLabel(
    m.Canvas canvas,
    m.Size size,
    m.Offset center,
    int Function(double) sweepAngleDuration,
    m.TextStyle textStyle,
    double verticalOffsetFactor,
    String units,
  ) {
    final m.TextPainter textPainter = m.TextPainter(
      text: m.TextSpan(
        text:
            '${sweepAngleDuration(_wakeUp.direction - _bedtime.direction)}$units',
        style: textStyle,
      ),
      textAlign: m.TextAlign.justify,
      textDirection: m.TextDirection.ltr,
    )..layout(
        maxWidth: size.width,
      );
    textPainter.paint(
      canvas,
      center +
          m.Offset(
            -textPainter.width * 0.5,
            textPainter.height * verticalOffsetFactor,
          ),
    );
  }

  /// Specializes [_drawCenteredDurationLabel] with the parameters for drawing
  /// the purple label 'XXhrs' at the center of the [CircularDurationPicker].
  void _drawDurationHoursLabel(
    m.Canvas canvas,
    m.Size size,
    m.Offset center,
  ) {
    _drawCenteredDurationLabel(
      canvas,
      size,
      center,
      s.sweepAngleHours,
      m.TextStyle(
        fontSize: _fromCanvasSize(
          30.0,
          size,
        ),
        fontWeight: m.FontWeight.w800,
        color: c.purple,
      ),
      _hoursLabelVerticalOffsetFactor,
      'hrs',
    );
  }

  /// Specializes [_drawCenteredDurationLabel] with the parameters for drawing
  /// the black label 'XXmin' at the center of the [CircularDurationPicker].
  void _drawDurationMinutesLabel(
    m.Canvas canvas,
    m.Size size,
    m.Offset center,
  ) {
    _drawCenteredDurationLabel(
      canvas,
      size,
      center,
      s.sweepAngleMinutes,
      m.TextStyle(
        fontSize: _fromCanvasSize(
          14.0,
          size,
        ),
        fontWeight: m.FontWeight.w600,
        color: m.Colors.black,
      ),
      _minutesLabelVerticalOffsetFactor,
      'min',
    );
  }

  /// Always return false because the  [m.CustomPainter] was written to be
  /// therefore it does not contain any internal logic that could be used to
  /// signal a repaint.
  ///
  /// This [m.CustomPainter] was purposely designed to be stateless.  This
  /// simplifies the drawing process as all mutable state is contained in the
  /// [CircularDurationPicker].
  @override
  bool shouldRepaint(covariant m.CustomPainter oldDelegate) => false;

  /// Paints the custom [CircularDurationPicker] widget [m.Canvas].
  ///
  /// The order in which the [m.Canvas] methods are called is important.
  ///
  /// First  a shadow is drawn for the tube cut out of the background.  Then the
  /// circles for the background of the handles are drawn.  One thing to note
  /// is that the gradient steps for handle background circles and the arc are
  /// aligned so that drawing the arc over the circles has the effect of
  /// making an arced rounded rectangle that has a [c.purpleHighlight]
  /// fading effect.
  ///
  /// Next circles drawn with gradients are rendered with a smaller radius over
  /// the circles drawn earlier under the arc.  This is done to try to match the
  /// visual appearance from the Figma mockup.
  ///
  /// Next the SVGs for the handle are drawn
  ///
  /// Next the background represented by the [m.Path] of a  rectangle with
  /// a tube cut out of it is drawn over the arc and the shadow.
  ///
  /// The [c.lightGray] minute ticks are drawn.
  ///
  /// Next the [m.Colors.black] hour tick lines are drawn along with the text
  /// for the hour labels at each 2-hour tick.
  ///
  /// Finally the purple hours and black minutes lables are drawn to the center
  /// of the picker.
  @override
  void paint(m.Canvas canvas, m.Size size) async {
    _drawTubeShadow(canvas, size);

    final center = m.Offset(size.width * 0.5, size.height * 0.5);

    _drawHandle(
      canvas,
      size,
      center,
      _wakeUp,
      1.1,
    );
    _drawHandle(
      canvas,
      size,
      center,
      _bedtime,
      1.1,
    );

    final radius = size.width * 0.5;

    _drawDurationArc(
      canvas,
      center,
      radius,
    );

    _drawHandle(
      canvas,
      size,
      center,
      _bedtime,
    );

    _drawHandle(
      canvas,
      size,
      center,
      _wakeUp,
    );

    _drawSvg(
      canvas,
      center + _bedtime,
      _svgs?.bedtime,
      size,
    );

    _drawSvg(
      canvas,
      center + _wakeUp,
      _svgs?.wakeup,
      size,
    );

    _drawBackgroundOverShadowAndArc(
      canvas,
      size,
    );

    _drawMinuteTicks(
      canvas,
      center,
      radius,
    );

    _drawHourTicksAndLabels(
      canvas,
      size,
      center,
      radius,
    );

    _drawDurationHoursLabel(
      canvas,
      size,
      center,
    );

    _drawDurationMinutesLabel(
      canvas,
      size,
      center,
    );
  }
}

/// Used in order to distinguish which of the two handles has been selected.
///
/// [mapIndexed] is used on a list like
/// \[m.Offset bedtime, m.Offset\ wakeUp].  The return value of the map
/// operation is a list of [IndexAndOffset].  Because the reference to the
/// offset representing the handle position gets replaced whenever the position
/// of the handle should be updated the [IndexAndOffset.index] is used to
/// one or the other of the handles.
class IndexAndOffset {
  IndexAndOffset({
    required this.index,
    required this.offset,
  });
  final int index;
  final m.Offset offset;
}

/// Enables assigning a [m.GlobalKey] to a widget then using that key to access
/// the position of the widget in screen coordinates.
///
/// https://stackoverflow.com/a/58788092
///
/// The angle of the pointer relative to the center of the
/// [CircularDurationPicker] is used to update the position of the handles when
/// they are dragged.  In order to calculate whether the mouse is dragging a
/// handle and to also update the angle of the handles the position of the
/// picker in screen coordinates is neecded

extension GlobalKeyExtension on m.GlobalKey {
  m.Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = m.Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

/// Global key assigned to the [CircularDurationPicker] in order to determine
/// its absolute screen coordinates.
final circularDurationPickerGlobalKey = m.GlobalKey();

class CircularDurationPicker extends m.StatefulWidget {
  const CircularDurationPicker({
    m.Key? key,
    required m.ValueNotifier<m.Offset> bedtime,
    required m.ValueNotifier<m.Offset> wakeUp,
  })  : _bedtime = bedtime,
        _wakeUp = wakeUp,
        super(key: key);

  /// Represents the position of the bedtime handle relative to the center of
  /// the picker.  Using a relative offset from the center allows the offset to
  /// be used like a vector representing a radius and angle.
  final m.ValueNotifier<m.Offset> _bedtime;

  /// The wakup handle offset from the center of the picker.
  final m.ValueNotifier<m.Offset> _wakeUp;

  @override
  m.State<CircularDurationPicker> createState() =>
      _CircularDurationPickerState();
}

class _CircularDurationPickerState extends m.State<CircularDurationPicker>
    with m.TickerProviderStateMixin {
  /// The maximum distance between the pointer and a handle for which a
  /// a update the handle position occurs due to a mouse drag.
  static const _handleSelectionRadius = 32.0;

  late final m.AnimationController _easeAnimationController;
  late final m.Animation<double> _easeAnimation;

  /// Represents the 90 degree rotation that the bedtime handle animates through
  /// whenever the widget is mounted.
  static const _sweepRadians = 2.0 * math.pi * 0.25;

  /// Used to hold the result of the Futures created when loading SVG images.
  ResolvedSvgs? _resolvedSvgs;

  /// Used by [m.Listener]s onPointerDown, onPointerUp and onPointerCancel to
  /// track the state of a tap.  This is done to distinguish pointer drags.
  bool _pointerDown = false;

  /// Used to track which of the two handles is selected.
  ///
  /// This variable is used to implement a better user experience when dragging
  /// a handle.  If the state of a selection of a handle is not tracked, then
  /// for each relevant mouse event one of the two handles could be considered
  /// selected.  But this causes undesired behavior whenever the handles become
  /// close together (in which case which handle to select is ambiguous) or the
  /// pointer is dragged quickly with position change greater than
  /// [_handleSelectionRadius] (in which case the handle drag is cancelled).
  ///
  /// This variable helps to implement the feature of handle drags continuing
  /// regardless of future pointer positions (as long as it does not go off the screen
  /// and therefore emitting a [m.PointerCancelEvent]) given that the drag
  /// began on a handle.
  IndexAndOffset? _selectedHandle;

  /// Loads the SVG assets for the sun and moon images that are painted to the
  /// canvas over the handles.
  ///
  /// Returns a [Future] that is the combination of the [Future]s generated by
  /// loading the SVG files.  The returned future is resolved with a
  /// [ResolvedSvgs] instance when both futures have completed.
  Future<ResolvedSvgs> _loadSvgs() async {
    final bundle = m.DefaultAssetBundle.of(context);

    const moonPath = 'assets/svg/moon_white.svg';
    final bedtimeSvg = svg.svg.fromSvgString(
      await bundle.loadString(moonPath),
      moonPath,
    );

    const sunPath = 'assets/svg/sun_white.svg';
    final wakeUpSvg = svg.svg.fromSvgString(
      await bundle.loadString(
        sunPath,
      ),
      sunPath,
    );

    final svgs = await Future.wait([bedtimeSvg, wakeUpSvg]);
    return ResolvedSvgs(
      bedtime: svgs[0],
      wakeup: svgs[1],
    );
  }

  /// Sets up the 90-degree rotation animation of the bedtime handle when the
  /// widget is mounted.
  void _setupEaseAnimation() {
    _easeAnimationController = m.AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    )..addListener(
        () {
          setState(
            () {
              widget._wakeUp.value = m.Offset.fromDirection(
                _easeAnimation.value,
                widget._wakeUp.value.distance,
              );
            },
          );
        },
      );

    _easeAnimation = m.Tween<double>(
      begin: c.circularDurationPickerHandleStartRadians,
      end: c.circularDurationPickerHandleStartRadians + _sweepRadians,
    ).animate(
      m.CurvedAnimation(
        parent: _easeAnimationController,
        curve: m.Curves.easeInOut,
      ),
    );
  }

  /// Sets up the [m.Animation] and then loads the SVG images for the handles.
  @override
  void initState() {
    super.initState();

    _setupEaseAnimation();

    _easeAnimationController.forward();

    _loadSvgs().then(
      (
        resolvedSvgs,
      ) {
        setState(
          () {
            _resolvedSvgs = resolvedSvgs;
          },
        );
      },
    );
  }

  /// Given the absolute position of the pointer and the absolute position of
  /// this widget, calculate the relative position of the pointer from the
  /// center of this widget.
  m.Offset _pointerOffsetFromCenter(m.PointerMoveEvent event, double minSize) {
    return ((event.position -
            m.Offset(
                circularDurationPickerGlobalKey.globalPaintBounds?.left ?? 0.0,
                circularDurationPickerGlobalKey.globalPaintBounds?.top ??
                    0.0)) -
        m.Offset(minSize * 0.5, minSize * 0.5));
  }

  /// Updates the reference held in a [m.ValueNotifier] in order to update the
  /// position of a handle.  The [IndexAndOffset.index] of 0 represents the
  /// bedtime handle, 1 represents the wake up handle.
  void _selectHandle(
      IndexAndOffset selectedHandle, m.Offset pointerOffsetFromCenter) {
    switch (selectedHandle.index) {
      case 0:
        setState(
          () {
            widget._bedtime.value = m.Offset.fromDirection(
              pointerOffsetFromCenter.direction,
            );
          },
        );
        break;
      case 1:
        setState(
          () {
            widget._wakeUp.value = m.Offset.fromDirection(
              pointerOffsetFromCenter.direction,
            );
          },
        );
        break;
      default:
        throw Exception('Invalid handle index.');
    }
  }

  /// For each handle, calculate the distance between the handle and the
  /// pointer and determine whether one the handles should be considered
  /// selected.
  ///
  /// [_selectedHandle] represents the handle that was selected by dragging
  /// within [_handleSelectionRadius] while there is no currently selected
  /// handle.  [_selectedHandle] is null if a drag did not start on top of a
  /// handle.
  void _checkHandleSelection(
      m.Offset pointerOffsetFromCenter, double posRadius) {
    try {
      _selectedHandle = [widget._bedtime, widget._wakeUp]
          .mapIndexed(
            (
              index,
              offset,
            ) {
              if (((pointerOffsetFromCenter) -
                          m.Offset.fromDirection(
                            offset.value.direction,
                            posRadius,
                          ))
                      .distance <
                  _handleSelectionRadius) {
                return IndexAndOffset(index: index, offset: offset.value);
              }
            },
          )
          .where((iao) => iao != null)
          .first;
    } on StateError {
      _selectedHandle = null;
    }
  }

  /// The logic for handle selection related to [m.PointerMoveEvent]s.
  ///
  /// If the pointer is not pressed assign null to [_selectedHandle] otherwise
  /// if there is no currently selected handle, attempt to select one.  A handle
  /// is only selected if a drag occurs with [_handleSelectionRadius].
  ///
  /// If the pointer is pressed and there is a currently
  /// selected handle update the [m.Offset] stored in either [_bedtime] or
  /// [wakeup].
  ///
  /// If the pointer is pressed and there is no current handle selection call
  /// [_checkHandleSelection] in order to assign [_selectedHandle] one of
  /// either _bedtime of _wakeUp if its a valid selection or assign null if no
  /// selection should occur.  If a handle was selected in this way call
  /// [_selectHandle] to update the position of the handle.
  void _onPointerMove(
      m.PointerMoveEvent event, double minSize, double posRadius) {
    final pointerOffsetFromCenter = _pointerOffsetFromCenter(event, minSize);
    if (_pointerDown) {
      if (_selectedHandle != null) {
        _selectHandle(
          _selectedHandle!,
          pointerOffsetFromCenter,
        );
      } else {
        _checkHandleSelection(pointerOffsetFromCenter, posRadius);
        if (_selectedHandle != null) {
          _selectHandle(_selectedHandle!, pointerOffsetFromCenter);
        }
      }
    } else {
      _selectedHandle = null;
    }
  }

  @override
  m.Widget build(
    m.BuildContext context,
  ) {
    return m.Padding(
      padding: m.EdgeInsets.all(
        s.fromScreenSize(
          8.0,
          m.MediaQuery.of(
            context,
          ).size,
        ),
      ),
      child: m.LayoutBuilder(
        builder: (
          _context,
          constraints,
        ) {
          final minSize = math.min(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final posRadius =
              (0.5 - (0.5 - c.durationPickerInsideRadiusFactor) * 0.5) *
                  minSize;
          return m.ClipRect(
            child: m.Listener(
              onPointerDown: (_) {
                _pointerDown = true;
              },
              onPointerUp: (_) {
                _pointerDown = false;
                _selectedHandle = null;
              },
              onPointerCancel: (_) {
                _pointerDown = false;
                _selectedHandle = null;
              },
              onPointerMove: (event) {
                _onPointerMove(event, minSize, posRadius);
              },
              child: m.CustomPaint(
                key: circularDurationPickerGlobalKey,
                size: m.Size(
                  minSize,
                  minSize,
                ),
                painter: CircularDurationPickerPainter(
                  bedtime: m.Offset.fromDirection(
                    widget._bedtime.value.direction,
                    posRadius,
                  ),
                  wakeUp: m.Offset.fromDirection(
                    widget._wakeUp.value.direction,
                    posRadius,
                  ),
                  svgs: _resolvedSvgs,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Bake picker screen — circular word wheel
// Single-file Flutter app. Drop into lib/main.dart and run.
//
// Optional (recommended for the exact look): add to pubspec.yaml
//   dependencies:
//     google_fonts: ^6.2.1
// then swap the `_font` helper below for GoogleFonts.poppins(...).

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const BakeApp());
}

class BakeApp extends StatelessWidget {
  const BakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF060606),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF0A0A0A),
          primary: Colors.white,
        ),
      ),
      home: const BakeHomePage(),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Design tokens
/// ---------------------------------------------------------------------------
class AppColor {
  static const bg = Color(0xFF060606);
  static const surface = Color(0xFF161616);
  static const surfaceHigh = Color(0xFF101010);
  static const textPrimary = Color(0xFFF7F7F7);
  static const textMuted = Color(0xFF8A8A8A);
  static const textFaint = Color(0xFF3D3D3D);
  static const glow = Colors.cyanAccent; // soft green halo behind selection
}

TextStyle _font({
  double size = 16,
  FontWeight weight = FontWeight.w500,
  Color color = AppColor.textPrimary,
  double letterSpacing = -0.2,
  double height = 1.15,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

/// ---------------------------------------------------------------------------
/// Screen
/// ---------------------------------------------------------------------------
class FoodModel {
  const FoodModel({
    required this.name,
    required this.imageAsset,
    required this.description,
  });

  final String name;
  final String imageAsset;
  final String description;
}

class BakeHomePage extends StatefulWidget {
  const BakeHomePage({super.key});

  @override
  State<BakeHomePage> createState() => _BakeHomePageState();
}

class _BakeHomePageState extends State<BakeHomePage> {
  static const _foods = <FoodModel>[
    FoodModel(
      name: 'Pretzel',
      imageAsset: 'assets/images/pretzel.jpg',
      description: 'Twisted, chewy dough with a crisp, salty crust.',
    ),
    FoodModel(
      name: 'Scone',
      imageAsset: 'assets/images/scone.jpg',
      description: 'Tender and buttery with a lightly crisp golden edge.',
    ),
    FoodModel(
      name: 'Muffin',
      imageAsset: 'assets/images/muffin.jpg',
      description: 'Soft, fluffy crumb with a sweet bakery-style top.',
    ),
    FoodModel(
      name: 'Bagel',
      imageAsset: 'assets/images/bagel.jpg',
      description: 'A glossy, chewy classic with a dense, satisfying bite.',
    ),
    FoodModel(
      name: 'Danish',
      imageAsset: 'assets/images/danish.jpg',
      description: 'Flaky laminated pastry layered around a sweet center.',
    ),
    FoodModel(
      name: 'Macaron',
      imageAsset: 'assets/images/macaron.jpg',
      description: 'Delicate almond shells with a smooth, creamy filling.',
    ),
    FoodModel(
      name: 'Éclair',
      imageAsset: 'assets/images/eclair.jpg',
      description: 'Light choux pastry filled with silky custard and glaze.',
    ),
    FoodModel(
      name: 'Strudel',
      imageAsset: 'assets/images/strudel.jpg',
      description: 'Paper-thin pastry wrapped around warm spiced fruit.',
    ),
    FoodModel(
      name: 'Crumpet',
      imageAsset: 'assets/images/crumpet.jpg',
      description: 'A tender, airy breakfast bake made for melting butter.',
    ),
    FoodModel(
      name: 'Cheesecake',
      imageAsset: 'assets/images/cheesecake.jpg',
      description: 'Rich, creamy filling balanced by a delicate biscuit base.',
    ),
    FoodModel(
      name: 'Focaccia',
      imageAsset: 'assets/images/focaccia.jpg',
      description: 'Olive-oil-rich bread with a crisp top and airy crumb.',
    ),
    FoodModel(
      name: 'Cookies',
      imageAsset: 'assets/images/cookies.jpg',
      description: 'Golden-edged treats with a soft, warmly spiced center.',
    ),
    FoodModel(
      name: 'Cinnamon roll',
      imageAsset: 'assets/images/cinnamon_roll.jpg',
      description: 'Pillowy spirals swirled with cinnamon sugar and glaze.',
    ),
    FoodModel(
      name: 'Banana bread',
      imageAsset: 'assets/images/banana_bread.avif',
      description:
          'Moist, fragrant loaf with ripe banana and toasted sweetness.',
    ),
    FoodModel(
      name: 'Baguette',
      imageAsset: 'assets/images/baguette.jpg',
      description: 'Crackly French bread with a light, open interior.',
    ),
    FoodModel(
      name: 'Sourdough',
      imageAsset: 'assets/images/sourdough.jpg',
      description:
          'Naturally fermented bread with a tangy flavor and chewy crust.',
    ),
    FoodModel(
      name: 'Croissant',
      imageAsset: 'assets/images/croissant.jpg',
      description: 'Buttery, flaky layers that shatter with every bite.',
    ),
    FoodModel(
      name: 'Bagel',
      imageAsset: 'assets/images/bagel.jpg',
      description: 'A toasted, chewy ring ready for a generous spread.',
    ),
    FoodModel(
      name: 'Brioche',
      imageAsset: 'assets/images/brioche.jpg',
      description: 'Rich, tender bread with a soft crumb and buttery finish.',
    ),
    FoodModel(
      name: 'Ciabatta',
      imageAsset: 'assets/images/ciabatta.jpg',
      description: 'Rustic Italian bread with a crisp crust and open crumb.',
    ),
  ];

  static List<String> get _itemNames =>
      _foods.map((food) => food.name).toList(growable: false);

  int _selected = 10; // Focaccia
  int _navIndex = 0;
  bool picked = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !picked,
      onPopInvokedWithResult: (_, _) {
        if (picked) setState(() => picked = false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _SearchField(
                      picked: picked,
                      onPop: () {
                        setState(() => picked = false);
                      },
                    ),
                  ),
                  const SizedBox(height: 26),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return AlignTransition(
                        alignment: Tween<AlignmentGeometry>(
                          begin: Alignment.center,
                          end: Alignment.centerLeft,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: picked
                        ? Center(
                            key: ValueKey(0),
                            child: Container(
                              height: 70,
                              margin: const EdgeInsets.only(top: 10),
                              child: Text(
                                _foods[_selected].name.toUpperCase(),
                                style: _font(
                                  size: 35,
                                  weight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 70,
                            key: ValueKey(1),
                            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Text(
                              'What do you want to\nbake?',
                              style: _font(
                                size: 27,
                                weight: FontWeight.w600,
                                letterSpacing: -0.8,
                                height: 1.22,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: AnimatedSlide(
                      duration: Duration(milliseconds: 350),
                      offset: picked ? Offset(-1.5, 0) : Offset.zero,
                      child: AnimatedRotation(
                        duration: Duration(milliseconds: 350),
                        turns: picked ? -0.25 : 0,
                        child: CircularWordWheel(
                          items: _itemNames,
                          initialIndex: _selected,
                          onSelected: (i) => setState(() => _selected = i),
                          onPicked: () {
                            setState(() => picked = true);
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 96),
                ],
              ),
            ),
            ...List.generate(3, (idx) {
              double turns0 = 0.25;
              double turns1 = 0.25;
              double opacity = 1;
              double width = 250 - (idx * 20);
              double bottomPadding = idx * 30;
              switch (idx) {
                case (0):
                  turns0 = -0.2;
                  turns1 = 0;
                  opacity = 0;
                  break;
                case (1):
                  turns0 = 0.1;
                  turns1 = -0.007;
                  opacity = 0.1;
                  break;
                case (2):
                  turns0 = 0.08;
                  turns1 = 0.007;
                  opacity = 0.45;
                  break;
                default:
                  turns1 = 0;
                  opacity = 1;
              }

              return Center(
                child: AnimatedSlide(
                  duration: Duration(milliseconds: 600),
                  offset: picked ? Offset(0, 0) : Offset(0, 1.8),
                  child: AnimatedRotation(
                    duration: Duration(milliseconds: 600),
                    alignment: Alignment.bottomCenter,
                    turns: picked ? turns1 : turns0,
                    child: Container(
                      height: 300,
                      width: width,
                      margin: EdgeInsets.only(bottom: bottomPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          17.5,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,

                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        child: Image.asset(
                                          _foods[_selected].imageAsset,
                                          key: ValueKey(
                                            _foods[_selected].imageAsset,
                                          ),
                                          height: 166,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          // Prevent a brief blank frame while changing meals.
                                          gaplessPlayback: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 12,
                                    top: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 15,
                                            color: Color(0xFFFFC107),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            '4.8 (80)',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  0,
                                ),
                                child: Text(
                                  'Artisan ${_foods[_selected].name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _font(
                                    size: 18,
                                    weight: FontWeight.w800,
                                    color: Colors.black,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  12,
                                ),
                                child: Text(
                                  _foods[_selected].description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: _font(
                                    size: 13,
                                    weight: FontWeight.w400,
                                    color: const Color(0xFF343434),
                                    letterSpacing: 0,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Opacity(
                            opacity: opacity,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).reversed,

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomBar(
                index: _navIndex,
                onTap: (i) => setState(() => _navIndex = i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Search field
/// ---------------------------------------------------------------------------
class _SearchField extends StatelessWidget {
  final bool picked;
  final VoidCallback onPop;
  const _SearchField({this.picked = false, required this.onPop});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: picked
          ? SizedBox(
              height: 46,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onPop,

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    'Your pick',
                    style: _font(
                      size: 14,
                      weight: FontWeight.w500,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: AppColor.textPrimary,
                  ),
                ],
              ),
            )
          : Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onPop,
                    icon: const Icon(
                      Icons.search_rounded,
                      size: 19,
                      color: AppColor.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      cursorColor: AppColor.textPrimary,
                      style: _font(size: 14, weight: FontWeight.w400),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Search',
                        hintStyle: _font(
                          size: 14,
                          weight: FontWeight.w400,
                          color: AppColor.textMuted,
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

/// ---------------------------------------------------------------------------
/// Circular word wheel
///
/// Words sit on a large circle whose centre is off-screen to the left, so only
/// the right-hand arc is visible. Dragging vertically rotates the wheel; it
/// snaps to the nearest item, which is rendered large, white and bold with a
/// soft green halo behind it.
/// ---------------------------------------------------------------------------
class CircularWordWheel extends StatefulWidget {
  const CircularWordWheel({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onSelected,
    this.onPicked,
  });

  final List<String> items;
  final int initialIndex;
  final ValueChanged<int>? onSelected;
  final VoidCallback? onPicked;

  @override
  State<CircularWordWheel> createState() => _CircularWordWheelState();
}

class _CircularWordWheelState extends State<CircularWordWheel>
    with SingleTickerProviderStateMixin {
  /// Angle between two consecutive items, in radians.
  static const double _step = 14 * math.pi / 180;

  /// Radius of the (mostly off-screen) circle.
  static const double _radius = 340;

  /// Horizontal position of the circle centre, relative to the left edge.
  static const double _centerX = -150.0;

  late final AnimationController _controller;
  Animation<double>? _snap;

  /// Continuous index offset: 0 means item 0 is selected.
  late double _offset;
  bool _dragging = false;
  late int _lastEmitted;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialIndex.toDouble();
    _lastEmitted = widget.initialIndex;
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (_snap != null) setState(() => _offset = _snap!.value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _maxOffset => (widget.items.length - 1).toDouble();

  void _animateTo(double target) {
    final clamped = target.clamp(0.0, _maxOffset);
    _snap = Tween<double>(
      begin: _offset,
      end: clamped,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller
      ..value = 0
      ..animateTo(1, duration: const Duration(milliseconds: 420));
  }

  void _commitSelection(double offset) {
    final index = offset.clamp(0.0, _maxOffset).round();
    if (index == _lastEmitted) return;
    _lastEmitted = index;
    widget.onSelected?.call(index);
    HapticFeedback.selectionClick();
  }

  void _onDragStart(DragStartDetails _) {
    _controller.stop();
    _snap = null;
    setState(() => _dragging = true);
  }

  void _onDragUpdate(DragUpdateDetails d, double height) {
    // Vertical travel -> arc travel -> index delta.
    final deltaIndex = -d.primaryDelta! / (_radius * _step);
    setState(() {
      _offset = (_offset + deltaIndex).clamp(-0.6, _maxOffset + 0.6);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    setState(() => _dragging = false);
    final velocity = d.primaryVelocity ?? 0; // px/s
    final flick = -velocity / (_radius * _step) * 0.16;
    final target = (_offset + flick).roundToDouble();
    _animateTo(target);
    _commitSelection(target);
  }

  // --- Scrollbar dragging ---------------------------------------------------
  // The thumb must stay glued to the finger, so its motion maps to the track's
  // own travel (not the wheel's arc length) and is never animated mid-drag.
  void _onScrollbarDragStart(DragStartDetails _) {
    _controller.stop();
    _snap = null;
    setState(() => _dragging = true);
  }

  void _onScrollbarDragUpdate(DragUpdateDetails d, double travel) {
    if (travel <= 0) return;
    final deltaIndex = d.primaryDelta! / travel * _maxOffset;
    setState(() {
      _offset = (_offset + deltaIndex).clamp(0.0, _maxOffset);
    });
  }

  void _onScrollbarDragEnd(DragEndDetails d) {
    setState(() => _dragging = false);
    final target = _offset.roundToDouble();
    _animateTo(target);
    _commitSelection(target);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final centerY = size.height / 2;
        final center = Offset(_centerX, centerY);

        final children = <Widget>[];

        for (var i = 0; i < widget.items.length; i++) {
          final rel = i - _offset; // 0 == selected
          final angle = rel * _step;
          if (angle.abs() > math.pi / 2.05) continue; // behind the wheel

          final pos = Offset(
            center.dx + _radius * math.cos(angle),
            center.dy + _radius * math.sin(angle),
          );

          final t = rel.abs();
          final selected = t < 0.5;

          // Selected word is big/bold/white; neighbours fade and shrink.
          final fontSize = _lerp(21, 12.5, (t / 5).clamp(0.0, 1.0));
          final selectedSize = 25.0;
          final opacity = (1.0 - (t / 5.6)).clamp(0.06, 1.0);

          children.add(
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: Transform.rotate(
                angle: angle,
                alignment: Alignment.centerLeft,
                child: FractionalTranslation(
                  translation: const Offset(0, -0.5),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: selected ? widget.onPicked : null,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 160),
                      style: _font(
                        size: selected ? selectedSize : fontSize,
                        weight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? AppColor.textPrimary
                            : AppColor.textPrimary.withValues(
                                alpha: opacity * 0.55,
                              ),
                        letterSpacing: selected ? -0.6 : -0.1,
                      ),
                      child: Text(
                        widget.items[i],
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: _onDragStart,
          onVerticalDragUpdate: (d) => _onDragUpdate(d, size.height),
          onVerticalDragEnd: _onDragEnd,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Soft green spot  behind the selected word.
              Positioned(
                left: _centerX + _radius - 20,
                top: centerY - 25,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _dragging ? 0.6 : 1,
                    duration: Duration(milliseconds: 350),
                    child: Container(
                      width: 260,
                      height: 50,

                      transform: Matrix4.identity()
                        ..setEntry(3, 2, -0.005)
                        ..rotateY(-0.6)
                        ..rotateX(0.12)
                        ..rotateZ(-0.08),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            AppColor.glow.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                          // stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Faint dial rings.
              Transform.scale(scaleY: 1.25, child: DialRings(center: center)),
              ...children,
              // Custom scroll indicator on the right edge.
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                width: 30,
                child: _WheelScrollbar(
                  progress: (_offset / _maxOffset).clamp(0.0, 1.0),
                  active: _dragging,
                  onDragStart: _onScrollbarDragStart,
                  onDragUpdate: _onScrollbarDragUpdate,
                  onDragEnd: _onScrollbarDragEnd,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class DialRings extends StatelessWidget {
  const DialRings({super.key, this.size, this.child, required this.center});

  final Widget? size;
  final Widget? child;
  final Offset center;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-250, center.dy / 20),
      child: IgnorePointer(
        child: Container(
          padding: EdgeInsets.all(50),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColor.bg,
                Colors.grey.shade800.withValues(alpha: 0.10),
              ],
              stops: const [0.915, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.black,
                  Colors.grey.shade800.withValues(alpha: 0.18),
                ],
                stops: const [0.9, 1.0],
              ),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped track with a thumb that carries up/down chevrons.
class _WheelScrollbar extends StatelessWidget {
  const _WheelScrollbar({
    required this.progress,
    required this.active,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final double progress;
  final bool active;
  final GestureDragStartCallback onDragStart;
  final void Function(DragUpdateDetails details, double travel) onDragUpdate;
  final GestureDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const thumbHeight = 48.0;
        const trackInset = 24.0;
        final travel = constraints.maxHeight - thumbHeight - trackInset * 2;

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            onDragStart(DragStartDetails(globalPosition: event.position));
          },
          onPointerMove: (event) {
            onDragUpdate(
              DragUpdateDetails(
                globalPosition: event.position,
                delta: Offset(0, event.delta.dy),
                primaryDelta: event.delta.dy,
              ),
              travel,
            );
          },
          onPointerUp: (_) => onDragEnd(DragEndDetails()),
          onPointerCancel: (_) => onDragEnd(DragEndDetails()),
          child: Stack(
            children: [
              Positioned(
                top: trackInset,
                bottom: trackInset,
                left: 8,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              AnimatedPositioned(
                // No easing while the finger is down: the thumb tracks 1:1.
                duration: active
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                top: trackInset + travel * progress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18,
                  height: thumbHeight,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 14,
                        color: Color(0xFF2A2A2A),
                      ),
                      SizedBox(height: 1),
                      Icon(Icons.menu, size: 12, color: Color(0xFF2A2A2A)),
                      SizedBox(height: 1),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: Color(0xFF2A2A2A),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// Floating bottom bar
/// ---------------------------------------------------------------------------
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _icons = <IconData>[
    Icons.home_rounded,
    Icons.grid_view_rounded,
    Icons.favorite_border_rounded,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 16 + MediaQuery.of(context).padding.bottom * 0.4,
      ),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColor.surfaceHigh,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_icons.length, (i) {
            final selected = i == index;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icons[i],
                      size: 21,
                      color: selected
                          ? const Color(0xFF121212)
                          : AppColor.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

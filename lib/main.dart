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
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
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
class Tokens {
  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF161616);
  static const surfaceHigh = Color(0xFF1F1F1F);
  static const textPrimary = Color(0xFFF7F7F7);
  static const textMuted = Color(0xFF8A8A8A);
  static const textFaint = Color(0xFF3D3D3D);
  static const glow = Color(0xFF9BE15D); // soft green halo behind selection
}

TextStyle _font({
  double size = 16,
  FontWeight weight = FontWeight.w500,
  Color color = Tokens.textPrimary,
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
class BakeHomePage extends StatefulWidget {
  const BakeHomePage({super.key});

  @override
  State<BakeHomePage> createState() => _BakeHomePageState();
}

class _BakeHomePageState extends State<BakeHomePage> {
  static const _items = <String>[
    'Pretzel',
    'Scone',
    'Muffin',
    'Bagel',
    'Danish',
    'Macaron',
    'Éclair',
    'Strudel',
    'Crumpet',
    'Cheesecake',
    'Focaccia',
    'Cookies',
    'Cinnamon roll',
    'Banana bread',
    'Baguette',
    'Sourdough',
    'Croissant',
    'Bagel',
    'Brioche',
    'Ciabatta',
  ];

  int _selected = 9; // Focaccia
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _SearchField(),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'What do you want to\nbake?',
                    style: _font(
                      size: 28,
                      weight: FontWeight.w700,
                      letterSpacing: -0.8,
                      height: 1.22,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: CircularWordWheel(
                    items: _items,
                    initialIndex: _selected,
                    onSelected: (i) => setState(() => _selected = i),
                  ),
                ),
                const SizedBox(height: 96),
              ],
            ),
          ),
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
    );
  }
}

/// ---------------------------------------------------------------------------
/// Search field
/// ---------------------------------------------------------------------------
class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Tokens.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 19, color: Tokens.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              cursorColor: Tokens.textPrimary,
              style: _font(size: 14, weight: FontWeight.w400),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search',
                hintStyle: _font(
                  size: 14,
                  weight: FontWeight.w400,
                  color: Tokens.textMuted,
                ),
              ),
            ),
          ),
        ],
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
  });

  final List<String> items;
  final int initialIndex;
  final ValueChanged<int>? onSelected;

  @override
  State<CircularWordWheel> createState() => _CircularWordWheelState();
}

class _CircularWordWheelState extends State<CircularWordWheel>
    with SingleTickerProviderStateMixin {
  /// Angle between two consecutive items, in radians.
  static const double _step = 12 * math.pi / 180;

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
              left: 0,
              top: 0,
              child: Transform.translate(
                offset: pos,
                child: Transform.rotate(
                  angle: angle,
                  alignment: Alignment.centerLeft,
                  child: FractionalTranslation(
                    translation: const Offset(0, -0.5),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 160),
                      style: _font(
                        size: selected ? selectedSize : fontSize,
                        weight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? Tokens.textPrimary
                            : Tokens.textPrimary.withValues(
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
              // Soft green halo behind the selected word.
              Positioned(
                left: _centerX + _radius - 40,
                top: centerY - 110,
                child: IgnorePointer(
                  child: Container(
                    width: 260,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Tokens.glow.withValues(alpha: 0.16),
                          Tokens.glow.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              // Faint dial rings.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _DialPainter(center: center, radius: _radius),
                  ),
                ),
              ),
              ...children,
              // Edge fades top and bottom.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Tokens.bg,
                          Tokens.bg.withValues(alpha: 0.0),
                          Tokens.bg.withValues(alpha: 0.0),
                          Tokens.bg,
                        ],
                        stops: const [0.0, 0.14, 0.84, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
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

/// Faint concentric arcs suggesting a physical dial.
class _DialPainter extends CustomPainter {
  _DialPainter({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(center.dx, size.height / 2);
    for (final r in [radius * 0.34, radius * 0.46, radius * 0.58]) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.045),
      );
    }
    canvas.drawCircle(
      c,
      radius * 0.80,
      // radius * 0.30,
      Paint()..color = Colors.white.withValues(alpha: 0.02),
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.center != center || old.radius != radius;
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
        const thumbHeight = 44.0;
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
                    color: active ? Colors.white : const Color(0xFFE8E8E8),
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
                      SizedBox(height: 2),
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
          color: Tokens.surfaceHigh,
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
                          : Tokens.textMuted,
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

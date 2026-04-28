import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- SHARED COMPONENTS ---

abstract class BaseGameWidget extends StatefulWidget {
  final Function(double score) onScoreUpdate;
  const BaseGameWidget({super.key, required this.onScoreUpdate});
}

abstract class _BaseGameWidgetState<T extends BaseGameWidget> extends State<T> {
  int _score = 0;
  Color _flashColor = Colors.transparent;
  Timer? _flashTimer;

  void _flash(Color color) {
    _flashTimer?.cancel();
    if (!mounted) return;
    setState(() => _flashColor = color);
    _flashTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _flashColor = Colors.transparent);
    });
  }

  void incrementScore() {
    setState(() => _score++);
    _flash(Colors.green);
    widget.onScoreUpdate(_score.toDouble());
  }

  void decrementScore() {
    setState(() => _score--);
    _flash(Colors.red);
    widget.onScoreUpdate(_score.toDouble());
  }

  void triggerVibration({bool warning = false}) {
    if (warning) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  Widget buildGameContainer({required Widget child}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: child,
        ),
        IgnorePointer(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: _flashColor, width: 20),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}

// --- LEVEL 1 GAMES ---

class ConstantTraceGame extends BaseGameWidget {
  const ConstantTraceGame({super.key, required super.onScoreUpdate});
  @override
  State<ConstantTraceGame> createState() => _ConstantTraceGameState();
}

class _ConstantTraceGameState extends _BaseGameWidgetState<ConstantTraceGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isTouching = false;
  Timer? _scoreTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _scoreTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTouching) incrementScore();
    });
  }

  @override
  void dispose() { _controller.dispose(); _scoreTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          final t = _controller.value * 2 * math.pi;
          final orbPos = Offset(math.cos(t) * 110 + 150, math.sin(t * 2) * 60 + 200);
          final isNowTouching = (details.localPosition - orbPos).distance < 60;
          if (isNowTouching && !_isTouching) triggerVibration();
          setState(() => _isTouching = isNowTouching);
        },
        onPanEnd: (_) => setState(() => _isTouching = false),
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite, 
            painter: TracePainter(_controller, () => _isTouching),
          ),
        ),
      ),
    );
  }
}

class ColorMatchGame extends BaseGameWidget {
  const ColorMatchGame({super.key, required super.onScoreUpdate});
  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends _BaseGameWidgetState<ColorMatchGame> {
  final List<Color> _colorPool = [const Color(0xFF2A7C7C), Colors.orange, Colors.purple, Colors.blue, Colors.red, Colors.amber, Colors.pink, Colors.indigo];
  late Color _targetColor, _currentColor;
  bool _isMatchActive = false;
  Timer? _timer;

  @override
  void initState() { super.initState(); _targetColor = _colorPool[0]; _currentColor = _colorPool[1]; _nextCycle(); }

  void _nextCycle() {
    _timer?.cancel();
    if (_isMatchActive) { decrementScore(); triggerVibration(warning: true); }
    if (math.Random().nextDouble() < 0.2) _targetColor = _colorPool[math.Random().nextInt(_colorPool.length)];
    final isMatch = math.Random().nextDouble() < 0.35;
    if (mounted) {
      setState(() {
        if (isMatch) { _currentColor = _targetColor; _isMatchActive = true; }
        else { _currentColor = _colorPool.where((c) => c != _targetColor).toList()[math.Random().nextInt(_colorPool.length - 1)]; _isMatchActive = false; }
      });
    }
    _timer = Timer(const Duration(milliseconds: 1400), _nextCycle);
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text("TARGET: ", style: TextStyle(fontWeight: FontWeight.w900)),
                Container(width: 28, height: 28, decoration: BoxDecoration(color: _targetColor, shape: BoxShape.circle)),
              ]),
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_isMatchActive) { _isMatchActive = false; incrementScore(); triggerVibration(); _nextCycle(); }
                else { decrementScore(); triggerVibration(warning: true); }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(color: _currentColor, borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text("TAP IF MATCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32))),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MissingNumberGame extends BaseGameWidget {
  const MissingNumberGame({super.key, required super.onScoreUpdate});
  @override
  State<MissingNumberGame> createState() => _MissingNumberGameState();
}

class _MissingNumberGameState extends _BaseGameWidgetState<MissingNumberGame> {
  int _currentNumber = 0;
  bool _skipped = false;
  Timer? _timer;

  void _next() {
    _timer?.cancel();
    if (_skipped) { 
      decrementScore(); 
      triggerVibration(warning: true); 
    }
    
    final shouldSkip = math.Random().nextDouble() < 0.25;
    if (mounted) {
      setState(() {
        if (shouldSkip) { _currentNumber += 2; _skipped = true; }
        else { _currentNumber += 1; _skipped = false; }
      });
    }
    _timer = Timer(const Duration(milliseconds: 1300), _next);
  }

  @override
  void initState() { super.initState(); _next(); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_skipped) { 
            incrementScore(); 
            triggerVibration(); 
            setState(() => _skipped = false); 
          } else {
            decrementScore(); 
            triggerVibration(warning: true);
          }
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("TAP IF SKIPPED", style: TextStyle(color: Color(0xFF2A7C7C), fontWeight: FontWeight.w900, fontSize: 18)),
              Text("$_currentNumber", style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Color(0xFF2A7C7C))),
            ],
          ),
        ),
      ),
    );
  }
}

class GrowingBubbleGame extends BaseGameWidget {
  const GrowingBubbleGame({super.key, required super.onScoreUpdate});
  @override
  State<GrowingBubbleGame> createState() => _GrowingBubbleGameState();
}

class _GrowingBubbleGameState extends _BaseGameWidgetState<GrowingBubbleGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final double _targetRadius = 145;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
    _controller.addStatusListener((status) { 
      if (status == AnimationStatus.completed) { 
        decrementScore(); triggerVibration(warning: true);
        _controller.reset(); _controller.forward(); 
      } 
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final currentRadius = _controller.value * 250;
          if ((currentRadius - _targetRadius).abs() < 28) { 
            incrementScore(); triggerVibration(); 
          } else { 
            decrementScore(); triggerVibration(warning: true); 
          }
          _controller.reset(); _controller.forward();
        },
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite, 
            painter: BubblePainter(_controller, _targetRadius),
          ),
        ),
      ),
    );
  }
}

// --- LEVEL 2 & 3 GAMES ---

class DualOrbGame extends BaseGameWidget {
  const DualOrbGame({super.key, required super.onScoreUpdate});
  @override
  State<DualOrbGame> createState() => _DualOrbGameState();
}

class _DualOrbGameState extends _BaseGameWidgetState<DualOrbGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isTouching = false; Timer? _scoreTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _scoreTimer = Timer.periodic(const Duration(seconds: 1), (timer) { if (_isTouching) incrementScore(); });
  }

  @override void dispose() { _controller.dispose(); _scoreTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          final t = _controller.value * 2 * math.pi;
          final mainOrb = Offset(math.cos(t) * 85 + 150, math.sin(t) * 85 + 200);
          setState(() => _isTouching = (details.localPosition - mainOrb).distance < 50);
        },
        onPanEnd: (_) => setState(() => _isTouching = false),
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite, 
            painter: DualPainter(_controller, () => _isTouching),
          ),
        ),
      ),
    );
  }
}

class DualPainter extends CustomPainter {
  final Animation<double> animation;
  final bool Function() isTouching;
  DualPainter(this.animation, this.isTouching) : super(repaint: animation);

  @override void paint(Canvas canvas, Size size) {
    final t = animation.value * 2 * math.pi;
    final main = Offset(math.cos(t) * 85 + 150, math.sin(t) * 85 + 200);
    final distractor = Offset(math.sin(t * 2) * 105 + 150, math.cos(t) * 55 + 200);
    canvas.drawCircle(main, 35, Paint()..color = isTouching() ? const Color(0xFF2A7C7C) : Colors.red.withOpacity(0.6));
    canvas.drawCircle(distractor, 30, Paint()..color = Colors.grey.withOpacity(0.3));
  }
  @override bool shouldRepaint(DualPainter old) => true;
}

class StroopGame extends BaseGameWidget {
  const StroopGame({super.key, required super.onScoreUpdate});
  @override
  State<StroopGame> createState() => _StroopGameState();
}

class _StroopGameState extends _BaseGameWidgetState<StroopGame> {
  final List<String> _names = ["RED", "BLUE", "GREEN", "ORANGE"];
  final List<Color> _colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
  late int _nameIdx, _colorIdx;
  void _next() { if (mounted) setState(() { _nameIdx = math.Random().nextInt(4); _colorIdx = math.Random().nextInt(4); }); }
  @override void initState() { super.initState(); _next(); }
  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_names[_nameIdx], style: TextStyle(fontSize: 70, fontWeight: FontWeight.w900, color: _colors[_colorIdx])),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () { if (_nameIdx == _colorIdx) incrementScore(); else decrementScore(); _next(); }, child: const Text("MATCH")),
              ElevatedButton(onPressed: () { if (_nameIdx != _colorIdx) incrementScore(); else decrementScore(); _next(); }, child: const Text("MISMATCH")),
            ],
          )
        ],
      ),
    );
  }
}

class OddOneOutGame extends BaseGameWidget {
  const OddOneOutGame({super.key, required super.onScoreUpdate});
  @override
  State<OddOneOutGame> createState() => _OddOneOutGameState();
}

class _OddOneOutGameState extends _BaseGameWidgetState<OddOneOutGame> {
  late int _oddIdx;
  @override void initState() { super.initState(); _oddIdx = math.Random().nextInt(16); }
  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemCount: 16,
        itemBuilder: (ctx, idx) => GestureDetector(
          onTap: () { if (idx == _oddIdx) { incrementScore(); setState(() => _oddIdx = math.Random().nextInt(16)); } else decrementScore(); },
          child: Container(margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFF2A7C7C), borderRadius: BorderRadius.circular(idx == _oddIdx ? 18 : 8))),
        ),
      ),
    );
  }
}

class RhythmGame extends BaseGameWidget {
  const RhythmGame({super.key, required super.onScoreUpdate});
  @override
  State<RhythmGame> createState() => _RhythmGameState();
}

class _RhythmGameState extends _BaseGameWidgetState<RhythmGame> {
  int? _lastTap;
  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (_lastTap != null) { if ((now - _lastTap! - 1000).abs() < 180) incrementScore(); else decrementScore(); }
          _lastTap = now;
        },
        child: const Center(child: Text("TAP EVERY 1.0s", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2A7C7C)))),
      ),
    );
  }
}

enum MOTStatus { showing, waiting, shuffling, selecting }

class MOTGame extends BaseGameWidget {
  const MOTGame({super.key, required super.onScoreUpdate});
  @override
  State<MOTGame> createState() => _MOTGameState();
}

class _MOTGameState extends _BaseGameWidgetState<MOTGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Offset> _orbs = [];
  final List<Offset> _velocities = [];
  final List<int> _targets = [];
  final List<int> _found = [];
  MOTStatus _status = MOTStatus.showing;
  Timer? _stateTimer;
  Size _gameSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _controller.addListener(_updatePositions);
  }

  void _startRound() {
    if (!mounted || _gameSize == Size.zero) return;
    _targets.clear();
    _found.clear();
    _resetOrbs();

    final random = math.Random();
    while (_targets.length < 2) {
      int t = random.nextInt(5);
      if (!_targets.contains(t)) _targets.add(t);
    }

    setState(() => _status = MOTStatus.showing);

    _stateTimer?.cancel();
    _stateTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _status = MOTStatus.waiting);
      _stateTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _status = MOTStatus.shuffling);
        _stateTimer = Timer(const Duration(seconds: 5), () {
          if (!mounted) return;
          setState(() => _status = MOTStatus.selecting);
        });
      });
    });
  }

  void _updatePositions() {
    if (_status != MOTStatus.shuffling || _gameSize == Size.zero) return;
    
    const double padding = 25.0; // Stay inside 20px border
    const double orbSize = 45.0;

    for (int i = 0; i < _orbs.length; i++) {
      _orbs[i] += _velocities[i];
      
      // Bounce off walls
      if (_orbs[i].dx < padding) {
        _orbs[i] = Offset(padding, _orbs[i].dy);
        _velocities[i] = Offset(-_velocities[i].dx, _velocities[i].dy);
      } else if (_orbs[i].dx > _gameSize.width - orbSize - padding) {
        _orbs[i] = Offset(_gameSize.width - orbSize - padding, _orbs[i].dy);
        _velocities[i] = Offset(-_velocities[i].dx, _velocities[i].dy);
      }
      
      if (_orbs[i].dy < padding) {
        _orbs[i] = Offset(_orbs[i].dx, padding);
        _velocities[i] = Offset(_velocities[i].dx, -_velocities[i].dy);
      } else if (_orbs[i].dy > _gameSize.height - orbSize - padding) {
        _orbs[i] = Offset(_orbs[i].dx, _gameSize.height - orbSize - padding);
        _velocities[i] = Offset(_velocities[i].dx, -_velocities[i].dy);
      }
    }
    if (mounted) setState(() {});
  }

  void _resetOrbs() {
    _orbs.clear();
    _velocities.clear();
    final random = math.Random();
    const double padding = 30.0;
    const double orbSize = 45.0;

    for (int i = 0; i < 5; i++) {
      _orbs.add(Offset(
        padding + random.nextDouble() * (_gameSize.width - orbSize - 2 * padding), 
        padding + random.nextDouble() * (_gameSize.height - orbSize - 2 * padding)
      ));
      _velocities.add(Offset(random.nextDouble() * 12 - 6, random.nextDouble() * 12 - 6));
    }
  }

  void _onLayout(Size size) {
    if (_gameSize == size) return;
    _gameSize = size;
    _startRound();
  }

  @override
  void dispose() { _controller.dispose(); _stateTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: LayoutBuilder(builder: (context, constraints) {
        _onLayout(Size(constraints.maxWidth, constraints.maxHeight));
        return Stack(
          children: List.generate(_orbs.length, (idx) {
            bool isTarget = _targets.contains(idx);
            bool isFound = _found.contains(idx);
            Color orbColor = Colors.grey.shade400;
            if (_status == MOTStatus.showing && isTarget) orbColor = const Color(0xFF2A7C7C);
            if (isFound) orbColor = const Color(0xFF2A7C7C);

            return Positioned(
              left: _orbs[idx].dx,
              top: _orbs[idx].dy,
              child: GestureDetector(
                onTap: () {
                  if (_status == MOTStatus.selecting) {
                    if (isTarget && !isFound) {
                      setState(() => _found.add(idx));
                      incrementScore();
                      triggerVibration();
                      if (_found.length == _targets.length) {
                        Future.delayed(const Duration(milliseconds: 1000), _startRound);
                      }
                    } else if (!isTarget) {
                      decrementScore();
                      triggerVibration(warning: true);
                    }
                  }
                },
                child: Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: orbColor, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

class PatternRecallGame extends BaseGameWidget {
  const PatternRecallGame({super.key, required super.onScoreUpdate});
  @override
  State<PatternRecallGame> createState() => _PatternRecallGameState();
}

class _PatternRecallGameState extends _BaseGameWidgetState<PatternRecallGame> {
  List<int> _pattern = []; List<int> _input = []; bool _showing = true;
  void _generate() { _pattern = List.generate(4, (_) => math.Random().nextInt(25)); _input = []; _showing = true; if (mounted) setState(() {}); Future.delayed(const Duration(seconds: 1), () { if (mounted) setState(() => _showing = false); }); }
  @override void initState() { super.initState(); _generate(); }
  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5), itemCount: 25,
        itemBuilder: (ctx, idx) => GestureDetector(
          onTap: () { if (!_showing) { if (_pattern.contains(idx) && !_input.contains(idx)) { _input.add(idx); if (_input.length == _pattern.length) { incrementScore(); _generate(); } setState(() {}); } else decrementScore(); } },
          child: Container(margin: const EdgeInsets.all(3), decoration: BoxDecoration(color: _showing && _pattern.contains(idx) ? const Color(0xFF2A7C7C) : (_input.contains(idx) ? const Color(0xFF2A7C7C).withOpacity(0.5) : Colors.teal.shade50), borderRadius: BorderRadius.circular(4))),
        ),
      ),
    );
  }
}

class PeripheralGame extends BaseGameWidget {
  const PeripheralGame({super.key, required super.onScoreUpdate});
  @override
  State<PeripheralGame> createState() => _PeripheralGameState();
}

class _PeripheralGameState extends _BaseGameWidgetState<PeripheralGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller; Offset _centerOrb = Offset.zero; Offset? _peripheral;
  @override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(); _controller.addListener(() { if (mounted) setState(() => _centerOrb = Offset(math.cos(_controller.value * 2 * math.pi) * 45 + 150, 200)); }); _spawn(); }
  void _spawn() { Future.delayed(Duration(seconds: math.Random().nextInt(3) + 1), () { if (mounted) { if (_peripheral != null) decrementScore(); setState(() => _peripheral = Offset(math.Random().nextBool() ? 25 : 275, math.Random().nextBool() ? 60 : 340)); Future.delayed(const Duration(milliseconds: 900), () { if (mounted) setState(() => _peripheral = null); }); _spawn(); } }); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: Stack(
        children: [
          Positioned(left: _centerOrb.dx, top: _centerOrb.dy, child: Container(width: 35, height: 35, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2A7C7C)))),
          if (_peripheral != null) Positioned(left: _peripheral!.dx, top: _peripheral!.dy, child: GestureDetector(onTap: () { incrementScore(); setState(() => _peripheral = null); }, child: Container(width: 55, height: 55, decoration: BoxDecoration(color: Colors.teal.withOpacity(0.3), borderRadius: BorderRadius.circular(10))))),
        ],
      ),
    );
  }
}

class InverseReactionGame extends BaseGameWidget {
  const InverseReactionGame({super.key, required super.onScoreUpdate});
  @override
  State<InverseReactionGame> createState() => _InverseReactionGameState();
}

class _InverseReactionGameState extends _BaseGameWidgetState<InverseReactionGame> {
  bool _isCircle = true; Timer? _timer;
  void _next() { _timer?.cancel(); if (mounted) setState(() { _isCircle = math.Random().nextBool(); }); _timer = Timer(const Duration(seconds: 2), _next); }
  @override void initState() { super.initState(); _next(); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return buildGameContainer(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () { if (_isCircle) { incrementScore(); _next(); } else decrementScore(); },
        child: Center(child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: _isCircle ? BoxShape.circle : BoxShape.rectangle, color: const Color(0xFF2A7C7C), borderRadius: _isCircle ? null : BorderRadius.circular(15)), child: const Center(child: Text("TAP CIRCLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))))),
      ),
    );
  }
}

// --- PAINTERS ---

class TracePainter extends CustomPainter {
  final Animation<double> animation;
  final bool Function() isTouching;
  TracePainter(this.animation, this.isTouching) : super(repaint: animation);

  @override void paint(Canvas canvas, Size size) {
    final t = animation.value * 2 * math.pi;
    final orbPos = Offset(math.cos(t) * 110 + 150, math.sin(t * 2) * 60 + 200);
    canvas.drawCircle(orbPos, 35, Paint()..color = isTouching() ? const Color(0xFF2A7C7C) : Colors.red.withOpacity(0.6));
  }
  @override bool shouldRepaint(TracePainter old) => true;
}

class BubblePainter extends CustomPainter {
  final Animation<double> animation;
  final double targetRadius;
  BubblePainter(this.animation, this.targetRadius) : super(repaint: animation);

  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final currentRadius = animation.value * 250;
    final inZone = (currentRadius - targetRadius).abs() < 28;

    canvas.drawCircle(center, targetRadius, Paint()
      ..color = inZone ? Colors.green.withOpacity(0.8) : const Color(0xFF2A7C7C).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = inZone ? 8 : 4);
    
    canvas.drawCircle(center, currentRadius, Paint()..color = const Color(0xFF2A7C7C));
  }
  @override bool shouldRepaint(BubblePainter old) => true;
}

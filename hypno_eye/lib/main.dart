import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const HypnoEyeApp());
}

class HypnoEyeApp extends StatelessWidget {
  const HypnoEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _isFlashing = false;
  bool _flashOn = false;

  final Color pinkDark = const Color(0xFFFC0FC0);
  final Color pinkBright = const Color(0xFFFF5FD6);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  Future<void> _flashEffect() async {
    if (_isFlashing) return;

    _isFlashing = true;

    for (int i = 0; i < 3; i++) {
      try {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 80);
        }
      } catch (_) {}

      setState(() {
        _flashOn = true;
      });

      await Future.delayed(
        const Duration(milliseconds: 100),
      );

      setState(() {
        _flashOn = false;
      });

      await Future.delayed(
        const Duration(milliseconds: 100),
      );
    }

    setState(() {
      _isFlashing = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _backgroundColor() {
    if (_isFlashing && _flashOn) {
      return const Color(0xFFFFA8FF);
    }

    final t = Curves.easeInOut.transform(
      _controller.value,
    );

    return Color.lerp(
          pinkDark,
          pinkBright,
          t,
        ) ??
        pinkDark;
  }

  double _pulseScale() {
    if (_isFlashing) {
      return _flashOn ? 1.30 : 1.0;
    }

    return 0.95 + (_controller.value * 0.10);
  }

  double _glowOpacity() {
    if (_isFlashing) {
      return _flashOn ? 1.0 : 0.45;
    }

    return 0.25 + (_controller.value * 0.30);
  }

  double _mainOpacity() {
    if (_isFlashing) {
      return _flashOn ? 1.0 : 0.85;
    }

    return 0.85 + (_controller.value * 0.15);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: _flashEffect,
          child: Scaffold(
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              width: double.infinity,
              height: double.infinity,
              color: _backgroundColor(),
              child: Center(
                child: Transform.scale(
                  scale: _pulseScale(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: _glowOpacity(),
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFE8B7FF),
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/images/inmon.png',
                            width: 550,
                          ),
                        ),
                      ),

                      Opacity(
                        opacity: _mainOpacity(),
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF8D3ED9),
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/images/inmon.png',
                            width: 420,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
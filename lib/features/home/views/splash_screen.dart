// lib/views/splash_screen.dart
import '../viewmodels/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SplashViewModel>().startTimer(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.29, 0.13),
          end: Alignment(1.29, 0.87),
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
        ),
      ),
      child: const Stack(
        fit: StackFit.expand,
        children: [
          Positioned(left: -30, top: -10, child: _PatternItem(icon: Icons.restaurant_menu, size: 100, rotate: -0.26)),
          Positioned(left: 23, top: 180, child: _PatternItem(icon: Icons.restaurant_menu, size: 100, rotate: -0.26)),
          Positioned(right: -20, bottom: 210, child: _PatternItem(icon: Icons.restaurant_menu, size: 100, rotate: -0.26)),
          Positioned(left: 152, top: -10, child: _PatternItem(icon: Icons.restaurant_menu, size: 100, rotate: -0.26)),
          Positioned(right: 20, top: 40, child: _PatternItem(icon: Icons.restaurant_menu, size: 100, rotate: -0.26)),
          Positioned(right: 10, top: 150, child: _PatternItem(icon: Icons.local_florist, size: 80, rotate: 0.35)),
          Positioned(left: -30, bottom: 260, child: _PatternItem(icon: Icons.kitchen, size: 120, rotate: -0.26)),
          Positioned(right: 20, bottom: 30, child: _PatternItem(icon: Icons.set_meal, size: 90, rotate: -0.26)),
          Positioned(left: -20, bottom: 60, child: _PatternItem(icon: Icons.set_meal, size: 90, rotate: -0.26)),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LogoIcon(),
                const SizedBox(height: 24),

                const Text(
                  'Kitchen Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.50,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),

                // Slogan
                const Opacity(
                  opacity: 0.90,
                  child: Text(
                    'Smart food management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 80),

                // Loading Indicator
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.white24,
                  ),
                ),
                const SizedBox(height: 16),

                // Loading Text
                const Opacity(
                  opacity: 0.80,
                  child: Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Logo tách biệt
class _LogoIcon extends StatelessWidget {
  const _LogoIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }
}

class _PatternItem extends StatelessWidget {
  final IconData icon;
  final double size;
  final double rotate;

  const _PatternItem({required this.icon, required this.size, required this.rotate});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.05,
      child: Transform(
        transform: Matrix4.rotationZ(rotate),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }
}
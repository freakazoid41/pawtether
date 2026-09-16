import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'home_shell.dart';
import 'onboarding.dart';

/// Full-bleed splash: Android 12+ forces the *system* splash into a small
/// circle, so the real collage shows here for a beat on every cold start.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final app = context.read<AppProvider>();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) =>
            app.hasPets ? const HomeShell() : const OnboardingScreen(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Blurred cover-fill of the SAME art behind the sharp contain image:
    // every seam meets its own colors, so the bands melt away.
    const art = AssetImage('assets/icon/splash_master.png');
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: RepaintBoundary(
              child: const Image(
                image: art,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SafeArea(
            child: Center(
              child: Image(
                image: art,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

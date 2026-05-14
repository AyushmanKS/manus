import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:manus/presentation/design_system/manus_text.dart';

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.imagePath,
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(flex: 2),
          // Placeholder for Illustration (SVG might fail if files don't exist yet)
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome, size: 80, color: Colors.white24),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.2, end: 0, duration: 600.ms),
          const SizedBox(height: 60),
          ManusText(
            title,
            style: ManusTextStyle.h1,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 20),
          ManusText(
            description,
            style: ManusTextStyle.body,
            color: Colors.white70,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

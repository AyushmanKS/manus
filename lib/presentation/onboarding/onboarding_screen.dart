import 'package:flutter/material.dart';
import 'package:manus/presentation/design_system/manus_text.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ManusText(
          'Onboarding Screen',
          style: ManusTextStyle.h1,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:manus/presentation/design_system/manus_text.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ManusText(
          'MANUS',
          style: ManusTextStyle.h1,
        ),
      ),
    );
  }
}

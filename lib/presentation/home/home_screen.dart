import 'package:flutter/material.dart';
import 'package:manus/core/theme/app_spacing.dart';
import 'package:manus/presentation/design_system/manus_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ManusText('Home', style: ManusTextStyle.h2)),
      body: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding,
        ),
        child: Center(child: ManusText('Welcome to Manus')),
      ),
    );
  }
}
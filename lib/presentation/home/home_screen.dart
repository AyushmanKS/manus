import 'package:flutter/material.dart';
import 'package:manus/presentation/design_system/manus_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ManusText('Home', style: ManusTextStyle.h2),
      ),
      body: const Center(
        child: ManusText('Welcome to Manus AI'),
      ),
    );
  }
}

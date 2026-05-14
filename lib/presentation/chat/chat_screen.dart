import 'package:flutter/material.dart';
import 'package:manus/core/theme/app_colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final BoxDecoration boxDecoration = brightness == Brightness.light
        ? const BoxDecoration(color: AppColors.chatBgLight)
        : const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.chatBgDarkTop,
                AppColors.chatBgDarkBottom,
              ],
            ),
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: boxDecoration,
        child: const SafeArea(child: SizedBox.expand()),
      ),
    );
  }
}

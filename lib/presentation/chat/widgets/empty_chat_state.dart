import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:manus/core/theme/app_colors.dart';

class EmptyChatState extends StatelessWidget {
  const EmptyChatState({super.key});

  @override
  Widget build(final BuildContext context) {
    final List<String> suggestions = <String>[
      'Write a story about a cat',
      'How to make a pizza?',
      'Tell me a joke',
      'Explain quantum physics',
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Manus',
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: suggestions.indexed
                  .map((final (int, String) record) {
                    final String suggestion = record.$2;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.composerBgDark,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: AppColors.dividerDark),
                      ),
                      child: Text(
                        suggestion,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  })
                  .toList()
                  .animate(interval: 60.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
                  .fadeIn(),
            ),
          ),
        ],
      ),
    );
  }
}

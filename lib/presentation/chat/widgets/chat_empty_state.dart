import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/data/local/suggestion_data.dart';
import 'package:manus/presentation/chat/notifiers/chat_status_notifiers.dart';

class ChatEmptyState extends ConsumerStatefulWidget {
  const ChatEmptyState({
    required this.composerController,
    required this.composerFocusNode,
    super.key,
  });

  final TextEditingController composerController;
  final FocusNode composerFocusNode;

  @override
  ConsumerState<ChatEmptyState> createState() => _ChatEmptyStateState();
}

class _ChatEmptyStateState extends ConsumerState<ChatEmptyState>
    with TickerProviderStateMixin {
  final List<int> _currentIndices = <int>[];
  final Set<int> _clickedIndices = <int>{};
  int _nextStartIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNextPrompts();
  }

  void _loadNextPrompts() {
    _currentIndices.clear();
    _clickedIndices.clear();
    for (int i = 0; i < 4; i++) {
      final int index = (_nextStartIndex + i) % kSuggestionData.length;
      _currentIndices.add(index);
    }
    _nextStartIndex = (_nextStartIndex + 4) % kSuggestionData.length;
  }

  void _onChipTap(final int suggestionIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      _clickedIndices.add(suggestionIndex);
    });

    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        ref.read(composerPulseProvider.notifier).increment();
        widget.composerController.text =
            kSuggestionData[suggestionIndex].prompt;
        widget.composerFocusNode.requestFocus();

        if (_clickedIndices.length == _currentIndices.length) {
          Future<void>.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _loadNextPrompts();
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color borderColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Wrap(
          spacing: 8,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List<Widget>.generate(_currentIndices.length, (final int i) {
            final int suggestionIndex = _currentIndices[i];
            final bool isClicked = _clickedIndices.contains(suggestionIndex);

            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isClicked
                  ? const SizedBox.shrink()
                  : GestureDetector(
                          key: ValueKey<int>(suggestionIndex),
                          onTap: () => _onChipTap(suggestionIndex),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              kSuggestionData[suggestionIndex].prompt,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: i * 80),
                          duration: const Duration(milliseconds: 400),
                        )
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          curve: Curves.easeOutBack,
                        ),
            );
          }),
        ),
      ),
    );
  }
}

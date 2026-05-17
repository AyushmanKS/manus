import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/theme/app_colors.dart';
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
  late final List<AnimationController> _chipControllers;
  late final List<Animation<double>> _scaleAnimations;
  late final List<Animation<double>> _fadeAnimations;

  final List<String> _suggestions = const <String>[
    "Help me plan a trip",
    "Write a poem for me",
    "Explain quantum computing",
    "Debug my code",
  ];

  @override
  void initState() {
    super.initState();
    _chipControllers = List<AnimationController>.generate(
      _suggestions.length,
      (final int index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    _scaleAnimations = _chipControllers.map((
      final AnimationController controller,
    ) {
      return Tween<double>(
        begin: 1.0,
        end: 0.9,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInCubic));
    }).toList();

    _fadeAnimations = _chipControllers.map((
      final AnimationController controller,
    ) {
      return Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInCubic));
    }).toList();
  }

  @override
  void dispose() {
    for (final AnimationController controller in _chipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChipTap(final int index) {
    HapticFeedback.selectionClick();
    final AnimationController controller = _chipControllers[index];
    controller.forward();

    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ref.read(composerPulseProvider.notifier).increment();
      }
    });

    controller.addStatusListener((final AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        widget.composerController.text = _suggestions[index];
        widget.composerFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color borderColor = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;
    final Color textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List<Widget>.generate(_suggestions.length, (
            final int index,
          ) {
            return AnimatedBuilder(
                  animation: _chipControllers[index],
                  builder: (final BuildContext context, final Widget? child) {
                    return Opacity(
                      opacity: _fadeAnimations[index].value,
                      child: Transform.scale(
                        scale: _scaleAnimations[index].value,
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () => _onChipTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _suggestions[index],
                        style: TextStyle(fontSize: 13, color: textColor),
                      ),
                    ),
                  ),
                )
                .animate(delay: (index * 60).ms)
                .fadeIn(duration: 250.ms)
                .slideY(
                  begin: 0.2,
                  end: 0.0,
                  duration: 250.ms,
                  curve: Curves.easeOutCubic,
                );
          }),
        ),
      ),
    );
  }
}

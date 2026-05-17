import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/presentation/chat/providers/attachment_provider.dart';

enum SendState { idle, submitting, streaming }

class SendButton extends StatelessWidget {
  const SendButton({
    required this.hasText,
    required this.isStreaming,
    required this.isSubmitting,
    required this.onTap,
    required this.isDark,
    required this.activeSendCircle,
    required this.inactiveSendCircle,
    super.key,
  });

  final bool hasText;
  final bool isStreaming;
  final bool isSubmitting;
  final VoidCallback? onTap;
  final bool isDark;
  final Color activeSendCircle;
  final Color inactiveSendCircle;

  SendState get _state {
    if (isSubmitting) return SendState.submitting;
    if (isStreaming) return SendState.streaming;
    return SendState.idle;
  }

  @override
  Widget build(final BuildContext context) {
    final bool isActive = hasText || isStreaming || isSubmitting;
    final Color circleColor = isActive ? activeSendCircle : inactiveSendCircle;
    final Color iconColor = isActive
        ? (isDark ? AppColors.black : AppColors.white)
        : AppColors.iconDisabled;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 38.0,
        height: 38.0,
        decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: _morphTransition,
          child: _buildIcon(iconColor),
        ),
      ),
    );
  }

  Widget _buildIcon(final Color iconColor) {
    switch (_state) {
      case SendState.submitting:
        return SizedBox(
          key: const ValueKey<String>('submitting'),
          width: 18.0,
          height: 18.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        );
      case SendState.streaming:
        return Center(
          key: const ValueKey<String>('streaming'),
          child: Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
        );
      case SendState.idle:
        return Padding(
          key: const ValueKey<String>('idle'),
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(
            AppAssets.upArrowSvg,
            width: 18.0,
            height: 18.0,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        );
    }
  }

  static Widget _morphTransition(
    final Widget child,
    final Animation<double> animation,
  ) {
    final Animation<double> scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: scale, child: child),
    );
  }
}

class SendButtonBadge extends ConsumerWidget {
  const SendButtonBadge({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final int count = ref.watch(attachmentProvider).length;
    if (count == 0) return const SizedBox.shrink();

    return Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack);
  }
}

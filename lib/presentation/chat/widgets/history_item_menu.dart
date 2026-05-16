import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manus/core/theme/app_colors.dart';
import 'package:manus/data/models/conversation.dart';

class HistoryItemMenuAction {
  const HistoryItemMenuAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
}

class HistoryItemMenu extends StatefulWidget {
  const HistoryItemMenu({
    required this.conversation,
    required this.child,
    required this.onRename,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
    super.key,
  });

  final Conversation conversation;
  final Widget child;
  final VoidCallback onRename;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  State<HistoryItemMenu> createState() => _HistoryItemMenuState();
}

class _HistoryItemMenuState extends State<HistoryItemMenu>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const SpringCurve(),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  Future<void> _showMenu() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final OverlayState overlay = Overlay.of(context);
    await HapticFeedback.mediumImpact();
    _removeOverlay();

    final List<HistoryItemMenuAction> actions = <HistoryItemMenuAction>[
      HistoryItemMenuAction(
        label: 'Rename',
        icon: Icons.edit_outlined,
        onTap: () {
          _dismissMenu();
          widget.onRename();
        },
      ),
      HistoryItemMenuAction(
        label: widget.conversation.isPinned ? 'Unpin' : 'Pin',
        icon: widget.conversation.isPinned
            ? Icons.push_pin_outlined
            : Icons.push_pin,
        onTap: () {
          _dismissMenu();
          widget.onPin();
        },
      ),
      HistoryItemMenuAction(
        label: 'Archive',
        icon: Icons.archive_outlined,
        onTap: () {
          _dismissMenu();
          widget.onArchive();
        },
      ),
      HistoryItemMenuAction(
        label: 'Delete',
        icon: Icons.delete_outline,
        isDestructive: true,
        onTap: () {
          _dismissMenu();
          widget.onDelete();
        },
      ),
    ];

    _overlay = OverlayEntry(
      builder: (final BuildContext ctx) => _MenuOverlay(
        layerLink: _layerLink,
        scaleAnim: _scaleAnim,
        actions: actions,
        isDark: isDark,
        onDismiss: _dismissMenu,
      ),
    );

    overlay.insert(_overlay!);
    await _controller.forward(from: 0);
  }

  Future<void> _dismissMenu() async {
    await _controller.reverse();
    _removeOverlay();
  }

  @override
  Widget build(final BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onLongPress: () => unawaited(_showMenu()),
        child: widget.child,
      ),
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  const _MenuOverlay({
    required this.layerLink,
    required this.scaleAnim,
    required this.actions,
    required this.isDark,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final Animation<double> scaleAnim;
  final List<HistoryItemMenuAction> actions;
  final bool isDark;
  final VoidCallback onDismiss;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: onDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: scaleAnim,
              alignment: Alignment.topLeft,
              child: _MenuCard(actions: actions, isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.actions, required this.isDark});

  final List<HistoryItemMenuAction> actions;
  final bool isDark;

  @override
  Widget build(final BuildContext context) {
    final Color bg = isDark
        ? AppColors.composerBgDark
        : AppColors.composerBgLight;
    final Color divider = isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < actions.length; i++) ...<Widget>[
            _MenuTile(action: actions[i], isDark: isDark),
            if (i < actions.length - 1)
              Divider(height: 1, thickness: 0.5, color: divider),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.action, required this.isDark});

  final HistoryItemMenuAction action;
  final bool isDark;

  @override
  Widget build(final BuildContext context) {
    final Color color = action.isDestructive
        ? AppColors.errorTextLight
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(action.icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpringCurve extends Curve {
  const SpringCurve({this.damping = 14.0, this.stiffness = 180.0});

  final double damping;
  final double stiffness;

  @override
  double transformInternal(final double t) {
    final double beta = damping / 2;
    final double omega0 = stiffness;
    final double omega1 = (omega0 * omega0 - beta * beta) < 0
        ? 0
        : (omega0 * omega0 - beta * beta);
    final double omegaD = omega1 == 0 ? 0 : omega1;
    return 1 -
        (1 + beta * t) *
            (omegaD == 0 ? 1.0 : (1.0 / (1 + (omegaD * t * t)))) *
            _exp(-beta * t);
  }

  double _exp(final double x) {
    if (x < -20) return 0;
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 12; i++) {
      term *= x / i;
      result += term;
    }
    return result;
  }
}

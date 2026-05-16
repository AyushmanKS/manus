import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manus/core/constants/app_assets.dart';
import 'package:manus/data/models/conversation.dart';
import 'package:manus/presentation/chat/notifiers/history_notifier.dart';
import 'package:manus/presentation/widgets/manus_text_field.dart';
class ConversationTile extends ConsumerStatefulWidget {
  const ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.isActive,
    super.key,
  });
  final Conversation conversation;
  final VoidCallback onTap;
  final bool isActive;
  @override
  ConsumerState<ConversationTile> createState() => _ConversationTileState();
}
class _ConversationTileState extends ConsumerState<ConversationTile> {
  late final TextEditingController _renameController;
  @override
  void initState() {
    super.initState();
    _renameController = TextEditingController(text: widget.conversation.title);
  }
  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }
  @override
  Widget build(final BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String? renamingId = ref.watch(renamingChatIdProvider);
    final bool isCurrentlyRenaming = renamingId == widget.conversation.id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: widget.isActive
              ? colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: isCurrentlyRenaming ? null : widget.onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          title: isCurrentlyRenaming
              ? ManusTextField(
                  controller: _renameController,
                  autofocus: true,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (final String newName) async {
                    if (newName.isNotEmpty &&
                        newName != widget.conversation.title) {
                      await ref
                          .read(historyProvider.notifier)
                          .renameChat(widget.conversation.id, newName);
                    }
                    ref.read(renamingChatIdProvider.notifier).set(null);
                  },
                )
              : Text(
                  widget.conversation.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isActive
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.9),
                  ),
                ),
          subtitle: Text(
            widget.conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.isActive
                  ? colorScheme.primary.withValues(alpha: 0.7)
                  : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          trailing: widget.conversation.isPinned
              ? SvgPicture.asset(
                  AppAssets.pinSvg,
                  width: 14,
                  colorFilter: ColorFilter.mode(
                    widget.isActive
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                    BlendMode.srcIn,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
# Manus — Codebase Reference

## Project Overview

Manus is a Flutter AI chat clone. It streams LLM responses token-by-token, renders them as structured markdown blocks in real time, and persists conversation history locally via Hive. The app currently uses a mock repository (`kUseMockChat = true`) that simulates streaming with realistic delays and error scenarios. Switching to the real Gemini backend requires setting `kUseMockChat = false` and providing a `GEMINI_API_KEY` in `.env`.

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | flutter_riverpod ^3.3.1 (Notifier pattern only, no codegen) |
| Routing | go_router ^17.2.3 |
| HTTP / streaming | dio ^5.9.2 + CancelToken |
| Local persistence | hive ^2.2.3 + hive_flutter |
| Animations | flutter_animate ^4.5.2 |
| SVG rendering | flutter_svg ^2.3.0 |
| Markdown rendering | flutter_markdown_plus ^1.0.5 |
| Logging | logger ^2.7.0 (via AppLogger wrapper) |
| Unicode safety | characters ^1.4.1 |
| Environment | flutter_dotenv ^6.0.1 |
| Unique IDs | uuid ^4.5.3 |
| WebView | webview_flutter ^4.13.1 |
| Splash | flutter_native_splash ^2.4.7 |

Font: Inter (400/500/600/700), SF UI on iOS. Monospace: SF Mono on iOS, `monospace` on Android.

---

## Directory Structure

```
lib/
  main.dart                          App entry point
  core/
    constants/app_assets.dart        All asset path strings
    network/api_client.dart          Dio wrapper for SSE streaming
    router/
      app_router.dart                GoRouter config + route constants
      app_navigation_observer.dart   Logs route events via AppLogger
    theme/
      app_colors.dart                All color tokens (static const)
      app_spacing.dart               Layout spacing constants
      app_theme.dart                 Light + dark ThemeData builders
      theme_notifier.dart            ThemeMode Notifier (unused in UI currently)
    utils/
      app_logger.dart                Logger wrapper (info/warning/error/route/debug)
      markdown_segmenter.dart        Parses raw text into typed MarkdownBlock list
      responsive.dart                Screen-width breakpoint helper
  data/
    models/chat_message.dart         ChatMessage model + enums
    repositories/
      chat_repository.dart           Abstract ChatRepository + ChatRepositoryImpl
      mock_chat_repository.dart      Mock streaming implementation + MockApiException
    services/
      llm_service.dart               Abstract LlmService interface
      impl/google_llm_service.dart   Gemini 1.5 Flash SSE implementation
  presentation/
    auth/
      auth_screen.dart               Auth entry screen with animated background
      policy_screen.dart             WebView screen for Terms / Privacy
      notifiers/auth_notifier.dart   Auth state Notifier
      widgets/
        auth_button_list.dart        Social + email login buttons
        error_shake.dart             Shake animation wrapper
    chat/
      chat_screen.dart               Root chat screen widget
      notifiers/chat_notifier.dart   All chat providers + ChatNotifier
      widgets/
        chat_history_list.dart       Scrollable message list + scroll logic
        chat_composer.dart           Input bar + send button + attachment tray
        message_bubble.dart          Per-message bubble (user + assistant)
        markdown_renderer.dart       Block-level markdown rendering
    design_system/
      manus_text.dart                Enum-based Text widget
      manus_text_field.dart          Styled TextField wrapper
      models/physics_blob.dart       Physics blob model + collision
      painters/dotted_grid_painter.dart  Dot grid CustomPainter
      widgets/
        manus_animated_background.dart  Physics blob animated background
        manus_loader.dart            3-dot bouncing loader dialog
        manus_primary_button.dart    Social auth button with haptics
        meta_attribution.dart        "from Meta" branding widget
        meta_badge.dart              Compact Meta badge
    home/home_screen.dart            Placeholder home screen
    splash/
      splash_screen.dart             Logo animation + auto-navigate to /auth
      notifiers/splash_notifier.dart Splash Notifier (minimal)
```

---

## Entry Point — `lib/main.dart`

Runs before `runApp`:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `SystemChrome.setSystemUIOverlayStyle` — transparent status/nav bars
3. `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` — draws behind system bars
4. `FlutterNativeSplash.preserve` — holds native splash until app is ready
5. `dotenv.load('.env')` — loads `GEMINI_API_KEY`
6. `Hive.initFlutter()` + opens `conversations` box
7. `runApp(ProviderScope(child: ManusApp()))`

`ManusApp` is a `ConsumerWidget` that builds `MaterialApp.router` with `AppRouter.router`, light/dark themes from `AppTheme`, and `ThemeMode.system`.

---

## Routing — `lib/core/router/app_router.dart`

| Route | Path | Widget | Transition |
|---|---|---|---|
| splash | `/` | SplashScreen | default |
| auth | `/auth` | AuthScreen | default |
| home | `/home` | HomeScreen | default |
| policy | `/policy` | PolicyScreen | slide from right, 500ms |
| chat | `/chat` | ChatScreen | slide from right, 350ms |

Policy and chat use `CustomTransitionPage` with `SlideTransition` + `CurveTween(Curves.easeOutCubic)`.

`AppNavigationObserver` logs every push/pop/replace/remove via `AppLogger.route`.

---

## Theme — `lib/core/theme/`

### `AppColors`
All colors are `static const`. Key groups:
- **Background**: `backgroundDark` (#050505), `backgroundLight` (#F5F5F5)
- **Chat bg**: `chatBgDarkTop` (#1E1E1E), `chatBgDarkBottom` (#101010), `chatBgLight` (#EAEAEA)
- **Composer**: `composerBgDark` (#262626), `composerBgLight` (#FFFFFF)
- **Text**: `textPrimaryDark` (white), `textPrimaryLight` (#1A1A1A), `textSecondaryDark` (#B0B0B0), `textSecondaryLight` (#757575)
- **Send button**: `sendCircleActiveDark` (white), `sendCircleActiveLight` (black)
- **Animated background blobs**: 4 pairs of dark/light colors for bigCircle, smallCircle, hollowCircle, triangle

### `AppTheme`
`_buildTheme(Brightness)` constructs full `ThemeData` with Material 3, custom `ColorScheme.fromSeed`, and a complete `TextTheme` override. Font family switches between Inter (Android) and SF UI (iOS) automatically via `Platform.isIOS`.

### `AppSpacing`
```dart
screenHorizontalPadding = 14.0
elementGap = 16.0
socialIconContainerWidth = 52.0
socialIconSize = 20.0
```

---

## Data Layer

### `ChatMessage` — `lib/data/models/chat_message.dart`

```dart
enum MessageRole { user, assistant }
enum MessageStatus { sending, streamed, stopped, error }

class ChatMessage {
  final String id;          // UUID v4
  final MessageRole role;
  final String text;        // accumulates tokens during streaming
  final DateTime timestamp;
  final MessageStatus status;
  final bool isEdited;      // true when sent via editAndResend
}
```

`copyWith`, `toJson`, `fromJson` all present. `isEdited` defaults to `false` and is persisted to Hive. `fromJson` reads it with a null-safe fallback (`?? false`) for backwards compatibility with existing stored conversations.

### `ChatRepository` — `lib/data/repositories/chat_repository.dart`

```dart
abstract class ChatRepository {
  Stream<String> streamChat(String prompt, List<ChatMessage> history, CancelToken cancelToken);
}
```

`ChatRepositoryImpl` delegates to `LlmService.streamCompletion`.

### `MockChatRepository` — `lib/data/repositories/mock_chat_repository.dart`

Active when `kUseMockChat = true`. Simulates the full streaming lifecycle:

**Failure triggers** (checked against `prompt.toLowerCase()`):
- `"rate limit"` → 800ms delay → MockApiException(429)
- `"network"` / `"offline"` → 400ms → MockApiException(0)
- `"server error"` / `"500"` → 600ms → MockApiException(500)
- `"timeout"` → 3000ms → MockApiException(408)
- `"content policy"` / `"blocked"` → 500ms → MockApiException(403)

**Thinking simulation**: if prompt contains `"think"`, `"reason"`, or `"agent"`, emits 3 `__THINKING__` prefixed tokens with 700ms gaps before the main response.

**Response selection**:
- `"code"` / `"dart"` / `"flutter"` / `"python"` → `_codeResponse` (Python fibonacci + explanation)
- `"short"` / `"brief"` / `"quick"` / `"tldr"` → `_shortResponse`
- `"table"` → `_tableResponse` (model comparison table)
- default → `_fullMarkdownResponse` (markdown showcase with headings, code, table, blockquote)

**Tokenizer**: iterates `text.characters` (grapheme clusters, never splits surrogate pairs), chunks 1–4 graphemes randomly. Each chunk sanitized via `String.fromCharCodes(s.runes)`. Delay per chunk: 80ms after `.!?`, 40ms after `,:`, 60ms after `\n`, 20ms default, all plus 0–20ms jitter.

### `GoogleLlmService` — `lib/data/services/impl/google_llm_service.dart`

Calls Gemini 1.5 Flash via SSE (`alt=sse`). Uses `ApiClient.postStream` (Dio with `ResponseType.stream`). Parses `data: {...}` lines, extracts `candidates[0].content.parts[0].text`. Handles `[DONE]` sentinel. Errors forwarded to `StreamController`. `CancelToken` checked on each chunk.

---

## Chat Feature — Deep Dive

This is the core of the app. The chat feature spans 6 files and involves 5 Riverpod providers.

### Providers — `lib/presentation/chat/notifiers/chat_notifier.dart`

```
kUseMockChat: bool = true          Feature flag — swap mock ↔ real
_chatRepositoryProvider            Private Provider<ChatRepository>
chatIsStreamingProvider            NotifierProvider<StreamingNotifier, bool>
chatIsSubmittingProvider           NotifierProvider<SubmittingNotifier, bool>
chatMessageByIdProvider(id)        Provider<ChatMessage?> factory function
chatProvider                       NotifierProvider<ChatNotifier, List<ChatMessage>>
editingMessageProvider             NotifierProvider<EditingNotifier, EditingMessage?>
```

**`EditingMessage`** — immutable data class holding `messageId` and `originalText`. Used to pass edit context from the user bubble context menu into the composer.

**`EditingNotifier`** manages `EditingMessage?` state:
- `startEditing(messageId, originalText)` — sets state, triggers composer to populate the text field
- `cancelEditing()` — clears state, composer clears the field
- `confirmEditing()` — clears state after a successful edit send

**`ChatNotifier`** manages the full message lifecycle:

`sendMessage(text, {isEdited: false})`:
1. Creates UUID for user message and assistant placeholder
2. Appends both to state immediately (optimistic UI)
3. Sets `chatIsSubmittingProvider = true`
4. Calls `repository.streamChat(text, history, cancelToken)`
5. On first token: sets submitting=false, streaming=true
6. Each token: finds assistant message by id, appends token to `.text`, sets status=sending
7. On stream end: sets status=streamed
8. On error: calls `_errorMessage(e)` to produce user-friendly text, sets status=error
9. `finally`: clears both submitting+streaming flags, persists to Hive

`stopStream()`: cancels `CancelToken`, sets last assistant message status=stopped, clears flags.

`editAndResend(messageId, newText)`: finds the user message at `messageId`, truncates `state` to everything before that index (`state.sublist(0, index)`), persists, then calls `sendMessage(newText, isEdited: true)`. This forks the conversation — all messages after the edited one are discarded.

`regenerateLastMessage()`: removes last assistant message, re-sends last user prompt.

`retryLastError()`: removes last error message, re-sends last user prompt.

`_persist()`: JSON-encodes full message list, writes to Hive box `'conversations'` under key `'messages'`.

**`chatMessageByIdProvider(id)`**: a factory function returning a `Provider<ChatMessage?>` that watches `chatProvider` and returns the single message matching the given id. Each `MessageBubble` subscribes to its own provider so only the bubble whose message changed rebuilds on each token.

---

### `ChatScreen` — `lib/presentation/chat/chat_screen.dart`

`ConsumerStatefulWidget` that mixes in `WidgetsBindingObserver`.

**Owns:**
- `TextEditingController _composerController`
- `FocusNode _composerFocusNode` — passed into `ChatComposer`, also used for keyboard detection
- `GlobalKey<ChatHistoryListState> _listKey` — allows calling scroll methods on the list from the screen

**Keyboard handling:**
- `WidgetsBinding.instance.addObserver(this)` in `initState`, removed in `dispose`
- `didChangeMetrics()`: reads `platformDispatcher.views.first.viewInsets.bottom`, compares to `_previousViewInset`, calls `_listKey.currentState?.onScrollMetricsChanged()` on change
- `_composerFocusNode` listener: calls `doubleFrameScrollToBottom()` when focus gained
- Initial focus: `addPostFrameCallback` → `Future.delayed(400ms)` → `requestFocus()` (fires once via `_initialFocusRequested` flag, after page transition completes)

**System UI:** `didChangeDependencies` calls `_updateSystemUi()` which sets `statusBarColor: transparent` and correct `statusBarIconBrightness` per theme.

**Layout:**
```
Scaffold(resizeToAvoidBottomInset: true)
  body: Container(decoration: bgDecoration)
    GestureDetector(onTap: unfocus)
      Stack
        Positioned.fill
          SafeArea(bottom: false)
            ChatHistoryList(key: _listKey)
        Align(bottomCenter)
          Padding(12, 0, 12, safeAreaBottom + 12)
            ChatComposer(...)
```

The layout changed from a `Column` to a `Stack`. `ChatHistoryList` fills the entire body via `Positioned.fill`. `ChatComposer` floats over the bottom via `Align(bottomCenter)` with padding that accounts for `MediaQuery.paddingOf(context).bottom` (home indicator / gesture nav). The list has `100px` bottom padding baked in (`EdgeInsets.fromLTRB(12, 8, 12, 100)`) so messages are never hidden behind the floating composer.

---

### `ChatHistoryList` — `lib/presentation/chat/widgets/chat_history_list.dart`

`ConsumerStatefulWidget` with a **public** state class `ChatHistoryListState` (not private) so `ChatScreen` can call methods via `GlobalKey`.

**State fields:**
```dart
ScrollController _scrollController
ValueNotifier<bool> _autoScrollNotifier   // drives pill visibility, no setState
bool _userIsScrolling                      // true while user drags
bool _forcingScroll                        // true during pill-tap animation
bool _keyboardScrolling                    // bypasses _userIsScrolling guard
int _prevMessageCount                      // for ref.listen change detection
int _prevLastTextLength                    // for ref.listen change detection
```

**Scroll logic — `_onScroll()`:**
- Returns early if `pos.outOfRange` (bounce zone, no state changes during overscroll)
- `ScrollDirection.forward` (upward drag) → sets `_autoScrollNotifier.value = false`
- `distanceFromBottom <= 40.0` → sets `_autoScrollNotifier.value = true` (re-engages auto-scroll when near bottom, no `_userIsScrolling` guard on this branch)

**`_animateToBottom()`** — the single centralized scroll method:
- Guards: `!_autoScrollNotifier.value`, `!hasClients`, `_userIsScrolling && !_keyboardScrolling`, `_forcingScroll`, `isScrollingNotifier.value && !_keyboardScrolling`
- 80ms duration, `Curves.easeOut`

**`forceScrollToBottom()`** — pill tap:
- Clears `_userIsScrolling`, sets `_forcingScroll = true`, sets `_autoScrollNotifier.value = true`
- 300ms `Curves.easeOutCubic` animation
- `whenComplete`: haptic feedback, `_checkAndEngageAutoScroll()`, `_forcingScroll = false`

**`doubleFrameScrollToBottom()` / `onScrollMetricsChanged()`** — keyboard events:
- Sets `_keyboardScrolling = true`
- Triple nested `addPostFrameCallback` — fires `_animateToBottom()` on frames 1, 2, 3
- Frame 3: clears `_keyboardScrolling`, calls `_checkAndEngageAutoScroll()`

**`_checkAndEngageAutoScroll()`**: reads current position, sets `_autoScrollNotifier.value = true` if within 40px of bottom.

**Content-driven scroll** — `ref.listen` on `chatProvider`:
- Compares `next.length` and `next.last.text.length` to previous values
- If content grew and `_autoScrollNotifier.value` is true: post-frame `_animateToBottom()` + second post-frame `_checkAndEngageAutoScroll()`

**ListView:**
```dart
ListView.builder(
  physics: ClampingScrollPhysics(),   // no bounce, hard stop at edges
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: true,
  itemBuilder: ...
)
```

Last 2 items (`index >= messages.length - 2`) get entrance animation: `fadeIn(220ms) + slideY(0.06→0, 300ms) + scaleXY(0.94→1, 320ms)`. Older items returned as-is.

**Jump pill** — `ValueListenableBuilder<bool>` on `_autoScrollNotifier`:
- Only this tiny widget rebuilds when auto-scroll toggles — ListView is untouched
- `AnimatedSwitcher` with `FadeTransition + SlideTransition(0.3→0)` handles enter/exit on every toggle
- Pill is a circular icon button (chevron down, 20px, `BoxShape.circle`)

---

### `ChatComposer` — `lib/presentation/chat/widgets/chat_composer.dart`

`ConsumerStatefulWidget` (upgraded from `StatefulWidget` to access `editingMessageProvider`). Receives `FocusNode` from `ChatScreen` (screen owns lifecycle).

**Parameters:** `onSend`, `controller`, `focusNode`, `onKeyboardOpen`

**State:** `_showAttachmentTray: bool`

**Focus listener:** `_onFocusChanged()` calls `widget.onKeyboardOpen()` when focus gained.

**Edit mode banner:** when `editingMessageProvider` is non-null, an animated `SizedBox(height: 28)` slides in above the text field showing a pencil icon, "Editing message" label, and an `×` close button. Tapping close calls `cancelEditing()` and clears the controller. The banner uses `AnimatedSize(300ms, easeOutCubic)` + `AnimatedOpacity` for smooth enter/exit.

**`ref.listen` on `editingMessageProvider`:** when a new edit starts, populates `_controller.text` with `originalText`, moves cursor to end, and requests focus in a post-frame callback.

**TextField:** `minLines: 1`, `maxLines: 6`, `TextInputType.multiline`. Grows smoothly via `AnimatedSize(250ms, easeOutCubic)` wrapping the Column.

**Left actions row:**
- Plus icon (24px) — rotates 45° when tray open (`AnimatedRotation`), toggles `_showAttachmentTray`
- Plug icon (bold effect via 8-layer `Transform.translate` stack) — opens model picker sheet

**Right actions row:**
- Chat + mic icons — hidden when text is present (`AnimatedSwitcher` with horizontal fade+size)
- `_SendButton` — `Consumer` watching `chatIsStreamingProvider` + `chatIsSubmittingProvider`

**`_handleSend(editingMessage)`:** if `editingMessage != null`, calls `chatProvider.notifier.editAndResend(messageId, text)` and `editingMessageProvider.notifier.confirmEditing()`. Otherwise calls `widget.onSend(text)`. In edit mode the send button is only enabled when the trimmed text is non-empty AND differs from `originalText`.

**`_SendButton`** cycles through 3 states via `_SendState` enum:
- `idle`: SVG up-arrow (key: `'idle'`)
- `submitting`: `CircularProgressIndicator` 18px (key: `'submitting'`) — shown for ~600ms mock latency
- `streaming`: 16×16 rounded square container (key: `'streaming'`) — stop button

`AnimatedSwitcher` with `FadeTransition + ScaleTransition(0.5→1.0, easeOutCubic, 200ms)` morphs between states. Each state has a unique `ValueKey` so the switcher always triggers.

**Attachment tray:** `AnimatedSwitcher` with slide+size transition. 4 items: Camera, Photo, File, Capture (all stubs).

**Model picker:** `showModalBottomSheet` with `_ModelPickerSheet`. `.whenComplete(() => _focusNode.requestFocus())` restores keyboard after sheet closes.

**New assets used:** `AppAssets.pencilSvg` in the edit banner.

---

### `MessageBubble` — `lib/presentation/chat/widgets/message_bubble.dart`

`ConsumerStatefulWidget`. Takes `messageId: String` and `index: int`.

Watches `chatMessageByIdProvider(messageId)` — only rebuilds when its own message changes.

**Entrance animation:** fires once via `_hasAnimated` flag. Scale 0.85→1.0 (`easeOutBack`, 350ms) + fadeIn (250ms). Stagger: `index % 3 * 60ms`.

Each bubble wrapped in `RepaintBoundary` (isolates raster layer from neighbors).

**User bubble (`_UserBubble`):**
- Now a `ConsumerStatefulWidget` (needs `ref` for `editingMessageProvider`)
- Right-aligned, max 80% screen width
- `SelectionArea` wrapping `Text` for text selection
- Background: `socialButtonBgDark` / `greyF2`
- Long-press shows a floating context menu via `Overlay` + `CompositedTransformTarget/Follower`
- Context menu has two items: **Copy** (copies text to clipboard, shows snackbar) and **Edit** (calls `editingMessageProvider.notifier.startEditing(id, text)`)
- Context menu animates in with `fadeIn(150ms) + scaleXY(0.85→1.0, easeOutCubic, topRight anchor)`
- Tapping outside the menu dismisses it via a transparent full-screen `GestureDetector` in the overlay
- Shows a small `"edited"` label (10px, secondary color) below the text when `message.isEdited == true`

**`_ContextMenuItem`:** reusable widget with SVG icon + label, 50px wide, `InkWell` with rounded border. Uses `AppAssets.copySvg` and `AppAssets.pencilSvg`.

**Assistant bubble (`_AssistantBubble`):**
- Left-aligned, max 90% screen width
- Stateful — holds `Map<int, Widget> _blockCache`
- Calls `MarkdownSegmenter.parse(message.text)` on every rebuild
- `_buildBlockList`: iterates blocks, caches completed non-last blocks in `_blockCache` (never rebuilt), only last block rebuilds on each token
- Appends `_StreamingCaret` when `status == sending`
- Appends `_StoppedBadge` when `status == stopped`

**`_StoppedBadge`:** small row with a stop icon + "Generation stopped" text in secondary color. Fades in with `flutter_animate .fadeIn(400ms)`.

**`_StreamingCaret`:** 2×14px container, blinking via `flutter_animate .fadeIn(530ms, repeat: true, reverse: true)`.

---

### `MarkdownSegmenter` — `lib/core/utils/markdown_segmenter.dart`

Pure static parser. Converts a raw accumulated string into `List<MarkdownBlock>`.

**Block types:**
```dart
enum BlockType { paragraph, code, table, thinking }
```

**`MarkdownBlock`** fields: `type`, `content`, `isComplete`, `language` (code only).

**Parsing rules:**
- Lines starting with `__THINKING__` prefix → `thinking` block (mock-specific)
- `<think>` / `</think>` tags → `thinking` block (real LLM reasoning)
- ` ``` ` fence → `code` block, language extracted from opening fence
- Lines matching `^\|.+\|` → `table` block, ends when non-pipe line seen
- Everything else → `paragraph` block

**Completion logic:** the final `flush(complete: false)` marks the last block incomplete. A post-loop pass marks all blocks except the last as `isComplete: true`. This means only the last block is ever `isComplete: false` during streaming.

**`isComplete` usage:**
- `_AssistantBubble._buildBlockList`: caches blocks where `isComplete && !isLastBlock`
- `_TableBlock`: shows skeleton while `isStreaming && !block.isComplete`
- `_ThinkingBlock`: shows pulsing dot while `!block.isComplete`

---

### `MarkdownRenderer` — `lib/presentation/chat/widgets/markdown_renderer.dart`

Stateless. Takes `List<MarkdownBlock>` and `bool isStreaming`. Renders a `Column` of `MarkdownBlockItem` widgets, each keyed by `'${block.type.name}_$i'`.

**`_ParagraphBlock`:** `MarkdownBody` with styled `MarkdownStyleSheet`. `selectable: true`.

**`_CodeBlock`:** Custom container with language label + copy button. Raw code extracted by stripping opening fence line and closing ` ``` `. Horizontally scrollable `Text` with monospace font. Copy button shows checkmark for 1500ms.

**`_ThinkingBlock`:** Collapsible container. Now uses `initState` + `didUpdateWidget` to manage `_expanded`:
- Starts expanded while streaming (`_expanded = !block.isComplete` in `initState`)
- Auto-collapses when streaming ends (`didUpdateWidget` detects `!oldWidget.block.isComplete && widget.block.isComplete`)
- Header tap is disabled while streaming (only toggles when complete)
- Expand chevron only shown when not streaming
- Pulsing dot color now uses `textSecondaryDark/Light` instead of hardcoded `blueGrey`
- Expanded content renders via `_ParagraphBlock(block: widget.block)` for proper markdown support

**`_TableBlock`:**
- While `isStreaming && !block.isComplete`: shows `_TableSkeleton` (4-column shimmer rows with `flutter_animate .custom` color interpolation)
- When complete: `LayoutBuilder + ConstrainedBox(minWidth: constraints.maxWidth)` inside `SingleChildScrollView(Axis.horizontal)` — ensures table has a concrete width to lay out against while still allowing horizontal scroll

---

## Auth Feature

### `AuthScreen`
Full-screen `ManusAnimatedBackground` (physics blobs). Logo + "Welcome to Manus" centered. `AuthButtonList` + `LegalFooter` at bottom.

### `AuthButtonList`
5 buttons: Facebook, Google, Microsoft, Apple, Email. All currently stub — `handleAuthAction` shows `ManusLoader` for 2s then navigates to `/chat` via `context.go('/chat')`.

### `AuthNotifier`
Manages `AsyncValue<void>` state. All sign-in methods are stubs with 2s delays. `navigateToPolicy` pushes `/policy` with `{url, title}` extra.

### `PolicyScreen`
`WebViewController` loading the given URL. Linear progress indicator at top while loading. Back button uses `AppAssets.arrowBackSvg` SVG.

---

## Design System

### `ManusAnimatedBackground`
Physics simulation running at 60fps via `Ticker`. 4 blobs: bigCircle (r=75), smallCircle (r=40), hollowCircle (r=70, inner=45), triangle (size=65, rotates at 0.6 rad/s). Each frame: update positions, resolve pairwise collisions, `setState`. `CustomPaint` with `ManusBackgroundPainter` draws a dot grid (12px spacing, 1.2px radius) and colors each dot based on which blob contains it.

### `ManusLoader`
3 dots bouncing vertically with staggered 200ms delays. Shown via `showManusLoader(context)` which opens a transparent-barrier dialog.

### `ManusPrimaryButton`
Full-width 48px button with gradient (light) or solid (dark) background. SVG icon left-aligned in a 52px container. Haptic on tap-down. `AnimatedOpacity` to 0.7 on press.

### `ManusText`
Enum-based: `h1` → `headlineLarge`, `h2` → `headlineMedium`, `body` → `bodyLarge`, `caption` → `bodySmall`.

---

## Logging — `AppLogger`

Wraps `logger` package with `PrettyPrinter`. Four methods:
- `AppLogger.info(msg)` — general info
- `AppLogger.warning(msg)` — warnings
- `AppLogger.error(msg, [error, stackTrace])` — errors with optional exception
- `AppLogger.route(msg)` — navigation events (prefixed with road emoji)
- `AppLogger.debug(msg)` — debug output

Never use `print()` or `debugPrint()` anywhere in the codebase.

---

## Lint Rules — `analysis_options.yaml`

Strict mode enabled: `strict-casts`, `strict-inference`, `strict-raw-types`. Key enforced rules:
- `always_specify_types` — all variables must have explicit types
- `avoid_print` — treated as error
- `prefer_final_locals` — all locals must be `final` where possible
- `prefer_const_constructors` / `prefer_const_declarations`
- `unawaited_futures` — must use `unawaited()` wrapper
- `empty_catches` — no empty catch blocks allowed

---

## Key Patterns and Conventions

**No `setState` in scroll listeners.** `_autoScrollNotifier` is a `ValueNotifier<bool>` mutated directly in `_onScroll`. Only the `ValueListenableBuilder` wrapping the pill rebuilds — the ListView is never touched by scroll state changes.

**Per-message providers.** `chatMessageByIdProvider(id)` is a factory function returning a fresh `Provider` per message id. Each `MessageBubble` subscribes to its own provider. On each streaming token only the active assistant bubble rebuilds.

**Block-level memoization.** `_AssistantBubble` caches completed non-last blocks in a `Map<int, Widget>`. Once a block is complete and no longer the last block, it is frozen forever.

**FocusNode ownership.** `ChatScreen` creates and owns `_composerFocusNode`. It is passed into `ChatComposer` as a parameter. The composer adds/removes its own listener but never disposes the node.

**Conversation forking.** `editAndResend` truncates `state` to `sublist(0, index)` before re-sending. All messages after the edited one are permanently discarded. This is intentional — the new response replaces the old branch.

**Overlay context menu.** `_UserBubble` uses `Overlay.of(context).insert(OverlayEntry(...))` with `CompositedTransformTarget/Follower` for the long-press menu. The overlay is manually removed on tap-outside, on action tap, and in `dispose`. No `showMenu` or `PopupMenuButton` — fully custom.

**No Navigator.push.** All navigation uses `context.go()` or `context.push()` from go_router.

**No StateNotifier.** All providers use `Notifier<T>` or `AsyncNotifier<T>`.

**No comments in code.** The codebase has zero inline comments by convention.

**New assets:** `AppAssets.pencilSvg` (`assets/icons/pencil.svg`) and `AppAssets.copySvg` (`assets/icons/copy.svg`) added for the context menu.

**New `AppColors`:** `codeBgDark/Light`, `copySuccessColor`, `errorBubbleBgDark/Light`, `errorTextDark/Light`, `stoppedBgDark/Light`, `stoppedTextDark/Light` — available for future use in error and stopped state styling.

**Switching to real LLM:** set `kUseMockChat = false` in `chat_notifier.dart` and add `GEMINI_API_KEY=your_key` to `.env`.

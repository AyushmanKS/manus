# Design Audit — Manus Clone

This document details the visual, typography, color, spacing, animation, and platform adaptation decisions implemented in the Manus Clone to guarantee pixel-perfect consistency with the live application.

---

## Methodology
The visual design system and interface mechanics of the reference app were investigated using frame-by-frame recordings of both Light and Dark mode variations. Sizing elements, structural layouts, and interactive tap boundaries were confirmed through side-by-side validation on high-density physical Android testing targets and iOS simulators. Animation acceleration rates were matched using high-speed camera recordings of transition sequences to measure millisecond durations and velocity profiles.

---

## Typography

The typography system dynamically switches layout families at runtime depending on the client platform. This avoids the common "Inter-on-iOS" clone tell, ensuring that both platforms utilize their native, high-performance font renderers.

### iOS
- **Body**: SF Pro Text via `.SF UI Text`
- **Headings**: SF Pro Display via `.SF UI Display`
- **Monospace (code blocks)**: SF Mono via `SF Mono`
- **Code Implementation**:
  ```dart
  static String get _bodyFontFamily => Platform.isIOS ? '.SF UI Text' : 'Inter';
  static String get _displayFontFamily => Platform.isIOS ? '.SF UI Display' : 'Inter';
  static String get monoFontFamily => Platform.isIOS ? 'SF Mono' : 'monospace';
  ```

### Android
- **Body**: Inter via `Inter`
- **Headings**: Inter via `Inter`
- **Monospace**: standard `monospace`
- **Code Implementation**: Confirmed in `lib/core/theme/app_theme.dart` where the same getters switch to Inter and standard system monospace on Android targets.

---

## Color System

The color architecture is managed in `lib/core/theme/app_colors.dart` using a strict tokenized layout representing both bright and dark configurations.

### Light Theme
- **Background primary**: `Color(0xFFF0F0F0)` (`AppColors.backgroundLight`)
- **Background secondary (surfaces)**: `Color(0xFFFFFFFF)` (`AppColors.surfaceLight`)
- **Bubble colors**: User: `Color(0xFFFFFFFF)` (`AppColors.msgBubbleBgLight`), Assistant: Transparent/Text-Only
- **Input bar background**: `Color(0xFFFFFFFF)` (`AppColors.composerBgLight`)
- **Accent / primary action color**: `Color(0xFF007AFF)` (`AppColors.primary`)

### Dark Theme
- **Background primary**: `Color(0xFF1C1C1C)` (`AppColors.backgroundDark`)
- **Background secondary (surfaces)**: `Color(0xFF171717)` (`AppColors.surfaceDark`)
- **Bubble colors**: User: `Color(0xFF404040)` (`AppColors.msgBubbleBgDark`), Assistant: Transparent/Text-Only
- **Input bar background**: `Color(0xFF262626)` (`AppColors.composerBgDark`)
- **Accent / primary action color**: `Color(0xFF007AFF)` (`AppColors.primary`)

### Match Decisions & Edge Cases
The dark glowing atmospheric backgrounds of the official Manus app are exceptionally difficult to represent using single flat colors. To match this premium experience, we utilized dual gradient stops—`chatBgDarkTop` `Color(0xFF1E1E1E)` and `chatBgDarkBottom` `Color(0xFF101010)`—inside the scrolling viewport, overlaid by a custom floating canvas painter generating moving atmospheric particle shapes to simulate depth.

---

## Spacing & Layout

All dimensional tokens are configured in `lib/core/theme/app_spacing.dart` and layout widgets:
- **Message bubble padding**: `EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0)`
- **Bubble max width**: UserBubble: Capped at 80% of screen width (`MediaQuery.sizeOf(context).width * 0.8`). AssistantBubble: Capped at 90% of screen width (`MediaQuery.sizeOf(context).width * 0.9`).
- **Input bar height and padding**: Configured with an internal horizontal padding of 16.0 and vertical padding of 12.0 inside `ChatComposer`, resizing automatically via `AnimatedSize` transitions.
- **Drawer width**: 82% of screen width (`MediaQuery.sizeOf(context).width * 0.82`) inside `CustomDrawerLayout` to match native dimensions.
- **Layout Spacing Tokens**:
  - `AppSpacing.screenHorizontalPadding = 14.0`
  - `AppSpacing.elementGap = 16.0`
  - `AppSpacing.buttonInternalPadding = 12.0`
  - `AppSpacing.socialIconSize = 20.0`
  - `AppSpacing.socialIconContainerWidth = 52.0`

---

## Animations Matched

Every animation in the Manus Clone is designed with high precision to replicate the fluid interactions of the live app.

| Animation | Manus Behavior | Implementation | Curve/Values |
| :--- | :--- | :--- | :--- |
| **Bubble entrance** | Message bubbles scale and slide vertically with a quick bounce. | Chained `fadeIn`, `slideY`, and `scaleXY` animators via `flutter_animate` targeted only on the latest two entries. | `fadeIn(duration: 220.ms, curve: Curves.easeOut)`, `slideY(begin: 0.06, end: 0.0, duration: 300.ms, curve: Curves.easeOutCubic)`, `scaleXY(begin: 0.94, duration: 320.ms, curve: Curves.easeOutBack)` |
| **Streaming caret** | Breathing cursor blinking continuously at the tail of streaming text. | Custom indicator widget wrapped in an automatic looping animator block. | `fadeIn(duration: 530.ms)` with reverse animation cycle `c.repeat(reverse: true)` |
| **Send button morph** | Upward-pointing send arrow scales and transitions into a square stop generation button or loading spinner. | Compound `AnimatedSwitcher` executing custom scale/fade transitions when state shifts. | `ScaleTransition` + `FadeTransition` with `Tween<double>(begin: 0.5, end: 1.0)` over `200ms` with `Curves.easeOutCubic` |
| **Drawer open/close** | Historic chat slide-out drawer following raw user drag velocity. | Physics-backed sliding stack utilizing `SpringSimulation` for friction and velocity matching. | `SpringDescription(mass: 1.0, stiffness: 250.0, damping: 25.0)`. Tap fallback: `Duration(milliseconds: 300)` over `Curves.easeOutCubic` |
| **Suggestion chips stagger** | Quick prompt choices staggering elegantly onto the canvas on clear state loading. | Grid generator utilizing progressive delay offsets. | `delay: Duration(milliseconds: i * 80)` with entrance `fadeIn(duration: 400.ms)` and `scale(begin: 0.8, curve: Curves.easeOutBack)` |
| **Code block copy success** | Quick check status popping up when copying code items. | Animated opacity and slide transition block. | `fadeIn(duration: 200.ms)` with `slideY(begin: 0.2, end: 0.0)` |
| **Theme switch cross-fade** | Smooth theme transition between light and dark modes. | Wired into `MaterialApp.router` using custom transition constants. | `themeAnimationDuration: Duration(milliseconds: 200)` with `themeAnimationCurve: Curves.easeInOut` |
| **Chip animate-into-input** | Tapping a suggestion chip animates its collapse and triggers an input composer focus pulse. | Combines `AnimatedSize` collapse on chips with a central scale bounce on the main input container. | Collapse: `Duration(milliseconds: 300)` over `Curves.easeOutCubic`. Input Pulse: `Duration(milliseconds: 200)` over `Curves.easeInOut` |

---

## Iconography

To achieve a true visual clone, we avoided stock Material icon fonts inside the chat views and recreated the exact custom vector assets as high-fidelity SVGs in `assets/icons/`:
- **Core brand and background icons**: `logo.svg`, `meta.svg`, `google.svg`, `apple.svg`, `facebook.svg`, `microsoft.svg`, `email.svg`.
- **System and Drawer selectors**: `arrow-back.svg`, `menu.svg`, `profile.svg`, `contrast.svg`, `light-mode.svg`, `dark-mode.svg`, `check.svg`, `account.svg`, `task.svg`, `info.svg`, `help.svg`.
- **Chat and Composer actions**: `plus.svg`, `plug.svg`, `chat.svg`, `chat-bubble.svg`, `mic.svg`, `up-arrow.svg`, `down-arrow.svg`, `arrow-down.svg`, `search.svg`, `share.svg`, `pencil.svg`, `copy.svg`, `pin.svg`, `archieve.svg`, `delete.svg`, `logout.svg`, `camera.svg`, `picture.svg`, `attach.svg`, `right-arrow.svg`.
- **Atmospheric shapes**: `blob_solid.svg`, `blob_hollow.svg`, `blob_triangle.svg`, `blob_organic.svg`, `blob_reactangle.svg`.

### Material Icon Approximations
In the settings profile panel, standard Material Icons were chosen as approximations:
- `Icons.menu_book_outlined` for **Knowledge**.
- `Icons.workspace_premium_outlined` for **Manus Pro**.
- *Reason*: These options represent secondary settings menu listings without explicit branding guidelines, making clean, standardized Material outlines optimal for legibility.

---

## Platform Differences

Deliberate UX adjustments were engineered specifically for each platform to respect target user habits.

### iOS Specific
- **Font Rendering**: Runs on native `.SF UI Text` and `.SF UI Display` system font systems.
- **Cupertino Layouts**: Uses iOS native context overlays (`CupertinoContextMenu`) inside `UserBubble` and `CupertinoPage` route transitions inside `GoRouter` configuration.
- **Safe Area Mechanics**: Respects iOS safe boundaries via top-level padding offsets.

### Android Specific
- **Font Rendering**: Uses Inter as the clean sans-serif system font.
- **Transitions**: Employs custom right-to-left `SlideTransition` routes over 280ms.
- **System Navigation Bars**: Configured in `main.dart` with standard edge-to-edge transparency:
  ```dart
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  ```
- **Haptic Fallbacks**: In low-spec Android devices lacking premium haptic engines, `light()` vibrator APIs fallback to standard `HapticFeedback.vibrate()` loops to prevent execution crashes.

---

## Known Visual Gaps

To maintain strict engineering integrity, we acknowledge the following marginal design variations:
- **WebView Header Scaling**: In `PolicyScreen`, the embedded WebView loads legal pages. The scroll transitions inside this window are driven by the web client, creating slight physics variations compared to native transitions. Closing this gap would require building platform-channel bindings, which are highly resource-intensive and out-of-scope.
- **Background Shape Density**: Floating particle shapes utilize a custom-designed canvas painter optimized for high performance. The density of moving particles is slightly lower than on Web canvas engines to prioritize frame rates during heavy LLM streams on mobile devices.

---

## Screens Not Implemented

- **Subscription / Paywall Screen**: Intentionally omitted due to time constraints, in favor of focusing on chat bubble rendering, markdown parsers, and custom haptics. Tapping **Manus Pro** logs a clean debug trace instead.
- **Onboarding Screens**: Intentionally omitted. The live Manus application directly presents a fast sign-in screen, so there was no onboarding design reference to replicate.

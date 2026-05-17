# Manus Clone — Flutter

Manus Clone — Flutter is a high-fidelity mobile clone of the Manus AI agent companion, powered by Gemini 1.5 Flash and built with Flutter and Riverpod.

---

## Setup & Running

Prerequisites:
- Flutter 3.35+ / Dart 3.4+
- A Gemini API key (gemini-2.5-flash)

By default, the application runs in a high-fidelity **Mock Mode** using the local `MockChatRepository`. This enables immediate evaluation of streaming tokens, typing animations, offline detection, and error edge cases without requiring an internet connection or an active API key.

### Steps to Run (Default Mock Mode)
1. Clone the repo
2. Run `flutter pub get`
3. Run `flutter run`

### Steps to Enable Real Gemini API Conversations
To transition from simulated responses to live Gemini completions:
1. Open `lib/presentation/chat/notifiers/chat_notifier.dart` ([chat_notifier.dart](file:///c:/Users/GCV/Desktop/work/manus/lib/presentation/chat/notifiers/chat_notifier.dart#L22)).
2. Locate the constant switch on line 22:
   ```dart
   const bool kUseMockChat = true;
   ```
3. Change its value to `false`:
   ```dart
   const bool kUseMockChat = false;
   ```
4. Create a `.env` file in the project root directory and define your Gemini API key:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
5. Run `flutter run` again. The application will now read the environment variable at startup in `lib/main.dart` and stream directly from the live Gemini model via `GoogleLlmService`.

---

## Feature Testing & Prompt Guide

To test the application's responses, rendering layout, error handling, and performance characteristics in the default Mock Mode, type the following dedicated trigger prompts into the chat composer.

### Mock Prompt Triggers

| Prompt Keyword | Response Type | Target State / Feature Tested |
| :--- | :--- | :--- |
| **`code`** or **`solution`** | Advanced Markdown + Code Block | Renders coding layouts, CustomPainter code blocks, copy actions, and reasoning processes wrapped inside `<think>` nodes. |
| **`manus`** or **`who are you`** | Reasoning + Layout | Simulates a complex agent blueprint including structured `<think>` reasoning segments, bullet matrices, and code. |
| **`table`** or **`compare`** | Markdown Table | Verifies rendering of tables comparing Gemini, Claude, GPT, and Llama parameters. |
| **`story`** or **`creative`** | Creative Prose | Evaluates blockquote rendering (`>`) and prose layout line limits. |
| **`rate limit`** | Rate Limit Error (429) | Triggers a simulated rate-limiting exception page after a short delay. |
| **`network`** or **`offline`** | Connection Failure (0) | Triggers a network-loss exception page to evaluate the error banner layout. |
| **`server error`** or **`500`** | Server Fault (500) | Simulates a remote server-side crash card for recovery validation. |
| **`timeout`** | Gateway Timeout (408) | Simulates a request timeout after 3 seconds to test latency fallbacks. |
| **`Help me plan a trip`** | Mega Table Scroll Log | Streams a massive 450-row detailed trip journal to verify high-velocity list scrolling performance. |
| **`Explain quantum computing`** | Large Math + Code Log | Streams 180+ lines of formula notations, python code snippets, and physics text logs. |

---

## Navigation & Interactive testing Guide

Follow the interactive paths below to explore and test every custom feature implemented in the app:

### 1. Launch & Authentication Sequence
* **Where to navigate:** The application cold starts immediately onto the custom `SplashScreen`.
* **What to observe:** Look for the staggered entrance animations where the brand logo scales and fades into place. After 3 seconds, `FlutterNativeSplash` is seamlessly cleared and routes users to the `AuthScreen`.
* **Action:** Toggle the Terms check box and tap **Continue with Google**. Observe the beautifully staggered circles of the `ManusLoader` overlay before the system logs in and opens the chat room.

### 2. Conversation Streams & Quick Prompts
* **Where to navigate:** Main `ChatScreen` viewport.
* **Action:** Tap any of the floating suggestion cards (e.g., *Write a short story* or *Compare Flutter vs React Native*).
* **What to observe:** The prompt is populated, and an active Server-Sent Events stream starts. Note the blinking custom `StreamingCaret` following the text token and the smooth layout additions.

### 3. Generation Control & Interruption
* **Where to navigate:** Active message stream inside the `ChatScreen`.
* **Action:** While the message is streaming, tap the animated **Stop** icon in the input composer.
* **What to observe:** The stream halts immediately via `CancelToken` interruption, changing the message badge status to "Stopped" with red markers and tactile haptic beats.

### 4. Conversation Forking, Editing, & Deletion
* **Where to navigate:** Individual chat message bubbles.
* **Action (Edit/Fork):** Tap and hold (long-press) any **User message bubble**, then choose the **Edit** command. Modify the text prompt and submit.
* **What to observe:** The subsequent message history is trimmed, and a brand-new assistant branch is compiled.
* **Action (Delete):** Swipe open the secondary message options or tap the delete action next to assistant messages to remove a message node permanently.

### 5. Drawer Search & History Actions
* **Where to navigate:** Tap the menu button in the upper left or swipe from the left edge to open the drawer.
* **Action:**
  - Type in the Search bar to instantly filter conversation logs.
  - Swipe left on any conversation title in the drawer to reveal fast actions: **Pin/Unpin**, **Archive/Unarchive**, or **Delete**.
  - Tap a conversation to load its historic log immediately from Hive.

### 6. Media Attachments & Previews
* **Where to navigate:** Tapping the `+` file attachment clip in the input bar.
* **Action:** Select an image or document from the dialog.
* **What to observe:** The file is added into a horizontal preview tray above the input composer with a thumbnail preview. Tap the delete overlay on the preview to discard it before submitting.

### 7. Settings, Theme Customization, & Fallback Policy
* **Where to navigate:** Tap the round avatar profile icon in the upper-right corner of the chat header to open the `ProfileScreen`.
* **Action:**
  - Tap **Theme Mode** to select between Light, Dark, or System mode. Observe the smooth cross-fade animation.
  - Tap **Help and Support** or **About**. This launches `PolicyScreen` rendering native WebViews.
  - Turn off your internet connection, then tap help/about to evaluate the custom offline fallback view.

---

## Build

Release APK:
flutter build apk --release

---

## Architecture

The project is structured around a component-driven, highly optimized multilayer design:

- **presentation / data / core layers**:
  - `lib/core`: Houses shared infrastructure, color and typography themes, navigation/router config, connectivity observers, and utilities.
  - `lib/data`: Orchestrates data models, API clients, abstract repository interfaces, offline repositories, and Hive-based persistence layer services.
  - `lib/presentation`: Segmented into distinct user-interface feature modules (`auth`, `chat`, `design_system`, `home`, `profile`, `splash`, `widgets`). UI components are highly modularized to avoid layout bottlenecks.

- **State management**: Riverpod (`Notifier` and `Provider` architectures) is used for reactive state handling across all modules (`chatProvider`, `authProvider`, `historyProvider`, `themeProvider`), avoiding code generation (`build_runner`) toolchains completely to maintain optimal compilation speeds.

- **Routing**: Configured using `go_router` supporting named declarative routes: `/` (splash), `/auth`, `/home`, `/policy`, `/chat`, `/chat/:conversationId`, and `/profile`. Transitions are tailored by platform, utilizing iOS-native page transitions and custom Android slide-in and fade animations.

- **Local storage**: Lightweight key-value persistence powered by `Hive`. An `auth` box stores login states, while `chat_history` and `conversations` boxes manage chat metadata and messages using stable, JSON-serialized contracts.

- **Networking**: Utilizes a robust `ApiClient` wrapping `Dio` with Server-Sent Events (SSE) stream support inside `GoogleLlmService`. Incorporates `CancelToken` hooks to immediately terminate active network streams upon user request or route changes.

---

## Features Implemented

### Screens
- SplashScreen: Staggered zoom-in scaling and fade animations for the main brand mark and attribution widgets, with native splash loader removal.
- AuthScreen: Modern sign-in layout containing a simulated Google Auth pipeline, dynamic floating particles ambient painter, and Terms & Conditions check.
- PolicyScreen: In-app embedded browser layout powered by native webview bindings, with secondary offline text fallbacks.
- ChatScreen: Primary conversational UI displaying suggested starting prompts, input compilers, sliding drawers, and message list views.
- ProfileScreen: Contains dark/light/system theme selectors, custom logout alerts, scheduled task placeholder lists, and help options.
- HomeScreen: Basic welcome portal.

### Chat Functionality
- Generative Streaming: Streamed chunk rendering using SSE network packets parsed in real-time.
- Streaming Caret: Pulsating cursor element accompanying active LLM output streams.
- Cancel Stream: Instant stream termination utilizing `CancelToken` commands.
- Conversation Forking: Edit any historic user prompt to rewrite the chat pathway, discarding subsequent history and starting a new stream branch.
- Regenerate & Retry: Single-tap capability to resubmit the last user message or retry queries that failed due to connection loss.
- Persistent Drawer History: Fast loading of chats inside a drawer list with support for search, renaming, pinning, archiving, and deletion.
- Attachment Tray: Dedicated multi-file selector featuring preview rows for local images, documents, and files before submission.
- Network Fallback: Automated connectivity listeners that swap the active service with `OfflineChatRepository` to safely present network-loss exceptions.

### Animations & Polish
- ManusAnimatedBackground: Optimized canvas particle simulation with dark/light responsive color gradients.
- ManusLoader: Fluidly scaling concentric circular shapes utilizing synchronized animators for modal overlays.
- Staggered Launch Sequences: Staggered fade and scaling entrance animations for the splash logo and attributions.
- Haptic Feedback Service: Fine-tuned vibration system delivering haptic triggers on critical user events like copying text or sending messages.
- Edge-to-Edge Transitions: Right-to-left slide transitions for android layouts and fade animations for drawer updates.

### Platform
- Native Integration: Edge-to-edge layouts, transparent system statuses, navigation overlay bars, and native-safe boundaries on iOS and Android.
- High-Performance Caching: List performance optimization via markdown block memoization to maintain fluid scroll frames.

---

## Technical Decisions

- **JSON Serialization for Local Storage**: Instead of adding complex Hive binary adapter code generation steps, models are serialized to and from plain JSON strings. This keeps the dependency chain light, avoids compilation delays, and guarantees stable schema compatibility.
- **Stream Segmenter and Memoization**: Created a custom `MarkdownSegmenter` to split incoming LLM streaming characters into discrete semantic blocks (paragraphs, tables, code blocks, thinking tags) on the fly. This enables `AssistantBubble` to memoize completed segments inside `_blockCache`, reducing redundant UI layout cycles and ensuring solid 60fps frame rates.
- **Connectivity-Aware Repository Binding**: Integrated a network listener within Riverpod's `ChatNotifier`. If connectivity is lost mid-session, the app dynamically routes chat commands through `OfflineChatRepository`, triggering neat client-side warning states instead of raw HTTP errors.

---

## Known Trade-offs & Skips

- Subscription/Paywall screen — intentionally omitted due to time constraints. Pure UI with no payment wiring; prioritized core chat quality and animation polish instead.

- Onboarding screens — intentionally omitted. The current live Manus app does not have onboarding screens, so there was no reference to clone from.

- Offline LLM Interaction — intentionally skipped. As a streaming companion clone, offline generation is skipped in favor of clean caching structures and connection error messages, keeping file sizes lightweight.

---

## Performance

- flutter analyze: zero warnings
- dart format: passing
- Target: 60fps on 200-message conversation
- Cold start target: <2.5s on Pixel 6

---

## Packages Used

- flutter_riverpod: Declarative state management using Notifiers without code generation.
- go_router: Declarative, typed routing with custom platform transitions.
- dio: HTTP client with cancel token support for real-time SSE stream reading.
- logger: Formatted console output logger for diagnostic tracking.
- flutter_animate: Micro-animation builder extensions for fluid UI transitions.
- flutter_svg: High-quality vector asset renderer.
- webview_flutter: Cross-platform web frame builder for legal policy screens.
- flutter_native_splash: Native splash controller preventing early launch flashes.
- hive: Lightweight key-value persistence.
- hive_flutter: Optimized Hive integrations for Flutter UI bindings.
- flutter_dotenv: External environment file loader.
- uuid: High-performance secure unique ID generation.
- flutter_markdown_plus: Comprehensive markdown renderer for message items.
- characters: Safe character grapheme parsing.
- connectivity_plus: Real-time network and internet connection detection.
- share_plus: Native sharing system sheets integration.
- cached_network_image: Network image renderer with disk cache routines.
- image_picker: Image selections from system cameras and library.
- file_picker: System document and local file selections.
- mime: File mimetype parser.

---

## Device Testing

Note that the app was tested on:
- Real Android device
- iOS simulator
- Screenshots captured for all specified device sizes

import 'package:flutter_riverpod/flutter_riverpod.dart';

class StreamingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setStreaming(final bool value) => state = value;
}

final NotifierProvider<StreamingNotifier, bool> chatIsStreamingProvider =
    NotifierProvider<StreamingNotifier, bool>(StreamingNotifier.new);

class SubmittingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSubmitting(final bool value) => state = value;
}

final NotifierProvider<SubmittingNotifier, bool> chatIsSubmittingProvider =
    NotifierProvider<SubmittingNotifier, bool>(SubmittingNotifier.new);

class SelectedModelNotifier extends Notifier<String> {
  @override
  String build() => 'Manus 1.6 Lite';

  void set(final String model) => state = model;
}

final NotifierProvider<SelectedModelNotifier, String> selectedModelProvider =
    NotifierProvider<SelectedModelNotifier, String>(SelectedModelNotifier.new);

class ComposerPulseNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final NotifierProvider<ComposerPulseNotifier, int> composerPulseProvider =
    NotifierProvider<ComposerPulseNotifier, int>(ComposerPulseNotifier.new);

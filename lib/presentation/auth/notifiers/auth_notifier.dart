import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> loginWithEmail(final String email, final String password) async {
    state = const AsyncValue.loading();
    
    // Simulate API call
    await Future<void>.delayed(const Duration(seconds: 1));
    
    if (email == 'error@manus.ai') {
      state = AsyncValue.error('Invalid credentials', StackTrace.current);
    } else {
      state = const AsyncValue.data(null);
    }
  }
}

final NotifierProvider<AuthNotifier, AsyncValue<void>> authProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);

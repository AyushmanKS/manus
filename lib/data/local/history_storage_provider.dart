import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_storage.dart';

final Provider<HistoryStorage> historyStorageProvider =
    Provider<HistoryStorage>((final Ref ref) {
      return HistoryStorage();
    });
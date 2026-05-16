import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manus/core/network/connectivity_service.dart';
import 'package:manus/core/utils/app_logger.dart';

final Provider<ConnectivityService> connectivityServiceProvider =
    Provider<ConnectivityService>((final Ref ref) {
      AppLogger.info('ConnectivityService: provider initialised');
      return ConnectivityService(Connectivity());
    });

final StreamProvider<bool> connectivityProvider = StreamProvider<bool>((
  final Ref ref,
) {
  final ConnectivityService service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

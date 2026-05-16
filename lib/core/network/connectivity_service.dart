import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:manus/core/utils/app_logger.dart';

class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  Stream<bool>
  get onConnectivityChanged => _connectivity.onConnectivityChanged.map((
    final List<ConnectivityResult> results,
  ) {
    final bool connected = _hasConnection(results);
    AppLogger.info(
      'ConnectivityService: status changed → ${connected ? 'online' : 'offline'} ($results)',
    );
    return connected;
  });

  Future<bool> get isConnected async {
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();
    final bool connected = _hasConnection(results);
    AppLogger.info(
      'ConnectivityService: checked → ${connected ? 'online' : 'offline'} ($results)',
    );
    return connected;
  }

  static bool _hasConnection(final List<ConnectivityResult> results) =>
      results.any((final ConnectivityResult r) => r != ConnectivityResult.none);
}

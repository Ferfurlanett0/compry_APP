/// Compry — Connectivity Service
/// Core service — monitors internet connectivity (RF-033, RF-032)
library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

/// Service para monitorar conectividade
class ConnectivityService {
  final Connectivity _connectivity;
  final Logger _logger;

  ConnectivityService({
    required Connectivity connectivity,
    required Logger logger,
  })  : _connectivity = connectivity,
        _logger = logger;

  /// Verifica se há conexão ativa
  Future<bool> get hasConnection async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  /// Stream de mudanças de conectividade
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      final connected = _isConnected(results);
      _logger.d('Conectividade mudou: $connected');
      return connected;
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }
}

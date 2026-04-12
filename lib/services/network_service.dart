import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final _connectivity = Connectivity();
  final _connectionController = StreamController<NetworkStatus>.broadcast();

  Stream<NetworkStatus> get connectionStream => _connectionController.stream;
  NetworkStatus _currentStatus = NetworkStatus.unknown;
  NetworkStatus get currentStatus => _currentStatus;

  bool get isConnected =>
      _currentStatus == NetworkStatus.wifi ||
      _currentStatus == NetworkStatus.mobile;

  Future<void> initialize() async {
    // Check initial connectivity - returns List<ConnectivityResult> in new API
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });

    AppLogger.info('NetworkService initialized: $_currentStatus');
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // Get primary connectivity result (first non-none result)
    final result = results.firstWhere(
      (r) => r != ConnectivityResult.none,
      orElse: () =>
          results.isNotEmpty ? results.first : ConnectivityResult.none,
    );

    final newStatus = _mapStatus(result);
    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _connectionController.add(newStatus);
      AppLogger.info('Network status changed: $newStatus');
    }
  }

  NetworkStatus _mapStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return NetworkStatus.wifi;
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.bluetooth:
        return NetworkStatus.mobile;
      case ConnectivityResult.none:
      case ConnectivityResult.vpn:
        return NetworkStatus.offline;
      default:
        return NetworkStatus.unknown;
    }
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _connectionController.close();
  }
}

enum NetworkStatus { wifi, mobile, offline, unknown }

// Retry mechanism for network operations
class RetryOptions {
  final int maxAttempts;
  final Duration delay;
  final double delayMultiplier;

  const RetryOptions({
    this.maxAttempts = 3,
    this.delay = const Duration(seconds: 1),
    this.delayMultiplier = 2.0,
  });

  Future<T> retry<T>(
    Future<T> Function() operation, {
    bool Function(Exception)? retryIf,
  }) async {
    int attempt = 0;
    Duration currentDelay = delay;

    while (true) {
      attempt++;
      try {
        return await operation();
      } on Exception catch (e) {
        if (attempt >= maxAttempts || (retryIf != null && !retryIf(e))) {
          rethrow;
        }
        AppLogger.warning(
          'Retry attempt $attempt/$maxAttempts after $currentDelay',
        );
        await Future.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * delayMultiplier).round(),
        );
      }
    }
  }
}

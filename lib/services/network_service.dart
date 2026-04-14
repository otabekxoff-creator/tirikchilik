import '../utils/app_logger.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  bool _isOnline = true;

  Future<void> initialize() async {
    AppLogger.info('NetworkService initialized');
  }

  Future<bool> checkConnection() async {
    return _isOnline;
  }

  bool get isOnline => _isOnline;

  void setOnline(bool online) {
    _isOnline = online;
  }
}

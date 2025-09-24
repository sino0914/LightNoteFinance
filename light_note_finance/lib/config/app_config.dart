import '../repositories/repository_factory.dart';

class AppConfig {
  // 數據源配置
  static const DataSource _dataSource = DataSource.local;

  // API配置
  static const String _apiBaseUrl = 'https://your-api-domain.com/api';
  static const String _apiVersion = 'v1';

  // 應用配置
  static const bool _enableLogging = true;
  static const bool _enableAnalytics = false;

  // Getters
  static DataSource get dataSource => _dataSource;
  static String get apiBaseUrl => _apiBaseUrl;
  static String get apiVersion => _apiVersion;
  static bool get enableLogging => _enableLogging;
  static bool get enableAnalytics => _enableAnalytics;

  // 完整的API URL
  static String get fullApiUrl => '$_apiBaseUrl/$_apiVersion';

  // 根據環境初始化配置
  static void initialize() {
    RepositoryFactory.setDataSource(_dataSource);

    if (_enableLogging) {
      print('App initialized with data source: $_dataSource');
      print('API URL: $fullApiUrl');
    }
  }

  // 切換到API模式（用於生產環境）
  static void switchToApi() {
    RepositoryFactory.setDataSource(DataSource.remote);
    if (_enableLogging) {
      print('Switched to API data source');
    }
  }

  // 切換到本地模式（用於開發/離線模式）
  static void switchToLocal() {
    RepositoryFactory.setDataSource(DataSource.local);
    if (_enableLogging) {
      print('Switched to local data source');
    }
  }
}
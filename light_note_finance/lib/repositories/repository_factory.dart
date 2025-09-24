import 'user_repository.dart';
import 'book_repository.dart';
import 'local/local_user_repository.dart';
import 'local/local_book_repository.dart';
import 'remote/api_user_repository.dart';
import 'remote/api_book_repository.dart';

enum DataSource {
  local,
  remote,
}

class RepositoryFactory {
  static DataSource _currentDataSource = DataSource.local;

  // 可以通過環境變數或配置文件來設置
  static void setDataSource(DataSource dataSource) {
    _currentDataSource = dataSource;
  }

  static DataSource get currentDataSource => _currentDataSource;

  static UserRepository createUserRepository() {
    switch (_currentDataSource) {
      case DataSource.local:
        return LocalUserRepository();
      case DataSource.remote:
        return ApiUserRepository();
    }
  }

  static BookRepository createBookRepository() {
    switch (_currentDataSource) {
      case DataSource.local:
        return LocalBookRepository();
      case DataSource.remote:
        return ApiBookRepository();
    }
  }

  // 可以同時使用本地緩存和遠程API的混合模式
  static void enableHybridMode() {
    // TODO: 實現混合模式，先檢查本地緩存，再查詢API
  }

  // 檢查網路連線狀態
  static Future<bool> checkConnectivity() async {
    // TODO: 實現網路連線檢查
    return true;
  }

  // 同步本地數據到遠程
  static Future<void> syncToRemote() async {
    // TODO: 實現數據同步邏輯
  }

  // 從遠程同步數據到本地
  static Future<void> syncFromRemote() async {
    // TODO: 實現數據同步邏輯
  }
}
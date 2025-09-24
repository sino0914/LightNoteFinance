# 數據源切換指南

## 架構概述

本應用採用了抽象倉庫模式（Repository Pattern），支援輕鬆在本地數據存儲（Hive）和遠程API之間切換。

## 目錄結構

```
lib/
├── repositories/
│   ├── base_repository.dart          # 基礎倉庫接口
│   ├── user_repository.dart          # 用戶倉庫接口
│   ├── book_repository.dart          # 書籍倉庫接口
│   ├── repository_factory.dart       # 倉庫工廠（數據源切換）
│   ├── local/
│   │   ├── local_user_repository.dart   # 本地用戶倉庫實現
│   │   └── local_book_repository.dart   # 本地書籍倉庫實現
│   └── remote/
│       ├── api_user_repository.dart     # API用戶倉庫實現
│       └── api_book_repository.dart     # API書籍倉庫實現
├── services/
│   ├── hive_service.dart             # 本地存儲服務
│   └── api_service.dart              # API服務
└── config/
    └── app_config.dart               # 應用配置
```

## 如何切換數據源

### 方法1：配置文件切換（推薦）

修改 `lib/config/app_config.dart` 中的數據源設定：

```dart
class AppConfig {
  // 更改這個值來切換數據源
  static const DataSource _dataSource = DataSource.local;  // 或 DataSource.remote

  // API配置
  static const String _apiBaseUrl = 'https://your-api-domain.com/api';
}
```

### 方法2：運行時動態切換

```dart
// 切換到API模式
AppConfig.switchToApi();

// 切換到本地模式
AppConfig.switchToLocal();
```

## 設置API服務

### 1. 配置API基礎URL

在 `lib/config/app_config.dart` 中設置您的API URL：

```dart
static const String _apiBaseUrl = 'https://your-api-domain.com/api';
```

### 2. API端點規範

您的API需要實現以下端點：

#### 用戶相關API
- `GET /user/current` - 獲取當前用戶
- `POST /user` - 創建用戶
- `PUT /user/{id}` - 更新用戶
- `POST /user/{id}/points/add` - 增加積分
- `POST /user/{id}/points/spend` - 花費積分
- `POST /user/{id}/favorites/toggle` - 切換書籍收藏
- `POST /user/{id}/books/unlock` - 解鎖書籍
- `POST /user/{id}/history` - 添加瀏覽歷史
- `POST /user/{id}/activity/weekly` - 更新週活動
- `PUT /user/{id}/settings` - 更新用戶設置
- `DELETE /user/{id}` - 刪除用戶

#### 書籍相關API
- `GET /books` - 獲取所有書籍
- `GET /books/{id}` - 獲取單本書籍
- `GET /users/{userId}/books/unlocked` - 獲取用戶已解鎖書籍
- `GET /users/{userId}/books/favorites` - 獲取用戶收藏書籍
- `GET /users/{userId}/summaries/today` - 獲取今日解鎖摘要
- `GET /books/{id}/summaries` - 獲取書籍摘要列表
- `GET /summaries/{id}` - 獲取單個摘要
- `POST /books/batch` - 批量保存書籍
- `POST /books/{id}/unlock` - 解鎖書籍
- `POST /books/{id}/favorite/toggle` - 切換書籍收藏
- `POST /summaries/{id}/unlock` - 解鎖摘要
- `POST /summaries/{id}/read` - 標記摘要已讀
- `POST /users/{userId}/summaries/unlock-daily` - 解鎖每日摘要
- `GET /users/{userId}/books/random-unlocked` - 獲取隨機未解鎖書籍
- `GET /users/{userId}/history` - 獲取用戶瀏覽歷史

### 3. API響應格式

API應返回以下格式的響應：

```json
{
  "success": true,
  "data": {...},
  "message": "Success"
}
```

錯誤響應：
```json
{
  "success": false,
  "error": "Error message",
  "message": "Error description"
}
```

### 4. 認證設置

如果您的API需要認證，可以在 `ApiService` 中設置令牌：

```dart
final apiService = ApiService();
apiService.setAuthToken('your-auth-token');
```

## 數據模型

所有數據模型都支援 `toJson()` 和 `fromJson()` 方法，確保與API的兼容性。

## 本地緩存

即使使用API模式，應用仍會使用Hive進行本地緩存，以提供：
- 離線訪問功能
- 更快的數據載入
- 更好的用戶體驗

## 開發建議

1. **開發階段**：使用 `DataSource.local` 進行快速開發
2. **測試階段**：使用 `DataSource.remote` 測試API整合
3. **生產階段**：根據需求選擇合適的數據源

## 混合模式（未來功能）

計劃實現混合模式，優先從本地緩存讀取，在需要時同步到遠程API：

```dart
// 未來功能
RepositoryFactory.enableHybridMode();
await RepositoryFactory.syncToRemote();
await RepositoryFactory.syncFromRemote();
```

## 故障排除

1. **API連接問題**：檢查網路連接和API URL配置
2. **數據不同步**：清除本地緩存並重新初始化
3. **認證失敗**：確認API令牌設置正確

## 注意事項

- 切換數據源後建議重啟應用
- 確保API和本地數據模型結構一致
- 定期備份本地數據
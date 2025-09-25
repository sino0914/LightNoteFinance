# Light Note Finance API

輕筆記理財書籍管理 FastAPI 後端服務

## 專案結構

```
light_note_finance_api/
├── main.py                 # FastAPI 主應用程式
├── start.py               # Python 啟動腳本
├── start.bat             # Windows 批次啟動腳本
├── requirements.txt      # Python 依賴套件
├── README.md            # 專案說明
├── data/                # JSON 資料儲存
│   ├── books.json      # 書籍資料
│   └── users.json      # 使用者資料
├── uploads/            # 圖片檔案儲存
├── services/
│   └── json_storage.py # JSON 檔案操作服務
└── api/                # API 路由
    ├── books.py        # 書籍 API
    ├── summaries.py    # 摘要 API
    ├── users.py        # 使用者 API
    └── upload.py       # 圖片上傳 API
```

## 快速開始

### 1. 安裝依賴套件

```bash
pip install -r requirements.txt
```

### 2. 啟動服務器

**方法一：使用 Python 腳本**
```bash
python start.py
```

**方法二：使用批次檔（Windows）**
```bash
start.bat
```

**方法三：直接使用 uvicorn**
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 3. 訪問 API

- **API 文檔**: http://localhost:8000/docs
- **ReDoc 文檔**: http://localhost:8000/redoc
- **API 資訊**: http://localhost:8000/api/info
- **健康檢查**: http://localhost:8000/api/health

## API 端點

### 書籍管理
- `GET /api/books/` - 獲取所有書籍
- `GET /api/books/{book_id}` - 獲取特定書籍
- `POST /api/books/` - 創建新書籍
- `PUT /api/books/{book_id}` - 更新書籍
- `DELETE /api/books/{book_id}` - 刪除書籍

### 摘要管理
- `GET /api/summaries/book/{book_id}` - 獲取書籍的所有摘要
- `GET /api/summaries/{book_id}/{summary_id}` - 獲取特定摘要
- `POST /api/summaries/book/{book_id}` - 創建新摘要
- `PUT /api/summaries/{book_id}/{summary_id}` - 更新摘要
- `DELETE /api/summaries/{book_id}/{summary_id}` - 刪除摘要

### 使用者管理
- `GET /api/users/` - 獲取所有使用者
- `GET /api/users/{user_id}` - 獲取特定使用者
- `POST /api/users/` - 創建新使用者
- `PUT /api/users/{user_id}` - 更新使用者
- `DELETE /api/users/{user_id}` - 刪除使用者
- `POST /api/users/{user_id}/unlock-book/{book_id}` - 解鎖書籍
- `POST /api/users/{user_id}/favorite-book/{book_id}` - 切換最愛書籍
- `PUT /api/users/{user_id}/points` - 更新使用者積分

### 圖片上傳
- `POST /api/upload/image` - 上傳圖片
- `GET /api/upload/image/{filename}` - 獲取圖片
- `DELETE /api/upload/image/{filename}` - 刪除圖片
- `GET /api/upload/images` - 列出所有圖片

## 資料格式

### 書籍 (Book)
```json
{
  "id": "string",
  "title": "書名",
  "description": "描述",
  "imageUrl": "封面圖片URL",
  "summaries": [],
  "isUnlocked": false,
  "isFavorite": false,
  "unlockedAt": "2023-01-01T00:00:00",
  "isCompleted": false
}
```

### 摘要 (Summary)
```json
{
  "id": "string",
  "bookId": "所屬書籍ID",
  "content": "摘要內容",
  "order": 1,
  "isUnlocked": false,
  "unlockedAt": "2023-01-01T00:00:00",
  "isRead": false,
  "readAt": "2023-01-01T00:00:00"
}
```

### 使用者 (User)
```json
{
  "id": "string",
  "points": 0,
  "isFirstLogin": true,
  "lastLoginAt": "2023-01-01T00:00:00",
  "unlockedBookIds": [],
  "favoriteBookIds": [],
  "currentBookId": "string",
  "weeklyActivity": {},
  "viewHistory": [],
  "dailyUnlockHistory": {},
  "settings": {
    "hasBookmarkFeature": false,
    "hasHighlightFeature": false,
    "canChooseBooks": false,
    "dailySummaryCount": 10
  }
}
```

## 功能特點

- ✅ **純 JSON 儲存** - 簡單易用，無需資料庫
- ✅ **圖片上傳** - 支援書籍封面上傳
- ✅ **完整 CRUD** - 書籍、摘要、使用者完整操作
- ✅ **自動文檔** - FastAPI 自動生成 API 文檔
- ✅ **CORS 支援** - 前端跨域請求支援
- ✅ **錯誤處理** - 完整的錯誤處理機制
- ✅ **型別驗證** - Pydantic 資料驗證

## 開發說明

1. **資料儲存**: 使用 JSON 檔案儲存在 `data/` 目錄
2. **圖片儲存**: 檔案儲存在 `uploads/` 目錄
3. **熱重載**: 開發模式下支援程式碼熱重載
4. **API 文檔**: 訪問 `/docs` 查看互動式文檔

## 注意事項

- 預設運行在 `http://localhost:8000`
- 圖片上傳限制 50MB
- 支援的圖片格式: jpg, jpeg, png, gif, webp
- JSON 檔案使用 UTF-8 編碼

## 與 Flutter App 整合

更新 Flutter app 中的 API 基礎URL：

```dart
// 在 lib/services/api_service.dart 中
static const String _baseUrl = 'http://localhost:8000/api';
```
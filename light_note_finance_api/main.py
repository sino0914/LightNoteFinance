from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import os
from api import books, summaries, users, upload

# 創建 FastAPI 應用程式
app = FastAPI(
    title="Light Note Finance API",
    description="輕筆記理財書籍管理 API",
    version="1.0.0"
)

# 設定 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生產環境中應該設定具體的域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 確保uploads目錄存在
os.makedirs("uploads", exist_ok=True)

# 掛載靜態檔案服務
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# 註冊路由
app.include_router(books.router, prefix="/api")
app.include_router(summaries.router, prefix="/api")
app.include_router(users.router, prefix="/api")
app.include_router(upload.router, prefix="/api")

# 根路徑
@app.get("/")
async def root():
    return {
        "message": "Light Note Finance API",
        "version": "1.0.0",
        "status": "運行中",
        "docs_url": "/docs",
        "redoc_url": "/redoc"
    }

# 健康檢查端點
@app.get("/api/health")
async def health_check():
    return {
        "status": "OK",
        "message": "Light Note Finance API 伺服器運行中",
        "version": "1.0.0"
    }

# API 資訊端點
@app.get("/api/info")
async def api_info():
    return {
        "name": "Light Note Finance API",
        "version": "1.0.0",
        "description": "輕筆記理財書籍管理 API",
        "endpoints": {
            "books": "/api/books",
            "summaries": "/api/summaries",
            "users": "/api/users",
            "upload": "/api/upload",
            "health": "/api/health",
            "docs": "/docs"
        },
        "data_storage": "JSON files",
        "file_storage": "Local uploads directory"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
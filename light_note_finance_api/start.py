#!/usr/bin/env python3
import uvicorn
import sys
import os

if __name__ == "__main__":
    # 確保在正確的目錄中運行
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # 運行 FastAPI 應用程式
    try:
        print("啟動 Light Note Finance API...")
        print("API 文檔: http://localhost:8000/docs")
        print("API 資訊: http://localhost:8000/api/info")
        print("健康檢查: http://localhost:8000/api/health")
        print("按 Ctrl+C 停止服務器")

        uvicorn.run(
            "main:app",
            host="0.0.0.0",
            port=8000,
            reload=True,  # 開發模式下自動重載
            log_level="info"
        )
    except KeyboardInterrupt:
        print("\n服務器已停止")
        sys.exit(0)
    except Exception as e:
        print(f"啟動失敗: {e}")
        sys.exit(1)
from fastapi import APIRouter, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
import os
import time
import random
from pathlib import Path
from PIL import Image

router = APIRouter(prefix="/upload", tags=["upload"])

# 上傳目錄設定
UPLOAD_DIR = "uploads"
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}

# 確保上傳目錄存在
os.makedirs(UPLOAD_DIR, exist_ok=True)

def validate_image(file: UploadFile) -> None:
    """驗證圖片檔案"""
    # 檢查檔案擴展名
    file_ext = Path(file.filename).suffix.lower()
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"不支援的檔案格式。允許的格式: {', '.join(ALLOWED_EXTENSIONS)}"
        )

def generate_unique_filename(original_filename: str) -> str:
    """生成唯一檔名"""
    file_ext = Path(original_filename).suffix.lower()
    unique_suffix = f"{int(time.time())}-{random.randint(10000, 99999)}"
    return f"book-cover-{unique_suffix}{file_ext}"

@router.post("/image")
async def upload_image(image: UploadFile = File(...)):
    """上傳書籍封面圖片"""
    try:
        # 驗證檔案
        if not image.filename:
            raise HTTPException(status_code=400, detail="沒有選擇檔案")

        validate_image(image)

        # 讀取檔案內容
        file_content = await image.read()

        # 檢查檔案大小
        if len(file_content) > MAX_FILE_SIZE:
            raise HTTPException(
                status_code=400,
                detail=f"檔案過大。最大允許大小: {MAX_FILE_SIZE // (1024*1024)}MB"
            )

        # 驗證是否為有效圖片
        try:
            img = Image.open(io.BytesIO(file_content))
            img.verify()  # 驗證圖片完整性
        except Exception:
            raise HTTPException(status_code=400, detail="無效的圖片檔案")

        # 生成唯一檔名
        filename = generate_unique_filename(image.filename)
        file_path = os.path.join(UPLOAD_DIR, filename)

        # 儲存檔案
        with open(file_path, "wb") as f:
            f.write(file_content)

        # 建構圖片URL
        image_url = f"/uploads/{filename}"

        return {
            "success": True,
            "message": "圖片上傳成功",
            "imageUrl": f"http://localhost:8000{image_url}",
            "filename": filename
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"上傳失敗: {str(e)}")

@router.delete("/image/{filename}")
async def delete_image(filename: str):
    """刪除圖片檔案"""
    try:
        file_path = os.path.join(UPLOAD_DIR, filename)

        # 檢查檔案是否存在
        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail="圖片檔案不存在")

        # 安全檢查：確保檔案在上傳目錄內
        if not os.path.abspath(file_path).startswith(os.path.abspath(UPLOAD_DIR)):
            raise HTTPException(status_code=400, detail="無效的檔案路徑")

        # 刪除檔案
        os.remove(file_path)

        return {
            "success": True,
            "message": "圖片已刪除",
            "deleted_filename": filename
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"刪除失敗: {str(e)}")

@router.get("/image/{filename}")
async def get_image(filename: str):
    """獲取圖片檔案"""
    try:
        file_path = os.path.join(UPLOAD_DIR, filename)

        # 檢查檔案是否存在
        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail="圖片檔案不存在")

        # 安全檢查：確保檔案在上傳目錄內
        if not os.path.abspath(file_path).startswith(os.path.abspath(UPLOAD_DIR)):
            raise HTTPException(status_code=400, detail="無效的檔案路徑")

        return FileResponse(file_path)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"獲取圖片失敗: {str(e)}")

@router.get("/images")
async def list_images():
    """列出所有上傳的圖片"""
    try:
        if not os.path.exists(UPLOAD_DIR):
            return {"images": []}

        images = []
        for filename in os.listdir(UPLOAD_DIR):
            file_path = os.path.join(UPLOAD_DIR, filename)
            if os.path.isfile(file_path):
                # 獲取檔案資訊
                stat = os.stat(file_path)
                images.append({
                    "filename": filename,
                    "size": stat.st_size,
                    "created_at": stat.st_ctime,
                    "url": f"/uploads/{filename}"
                })

        # 按建立時間排序
        images.sort(key=lambda x: x["created_at"], reverse=True)

        return {"images": images}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"列出圖片失敗: {str(e)}")

# 需要在 main.py 中添加 io import
import io
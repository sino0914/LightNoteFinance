from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Any, Dict
from services.json_storage import storage

router = APIRouter(prefix="/summaries", tags=["summaries"])

class SummaryCreateModel(BaseModel):
    content: str
    order: int
    isUnlocked: bool = False
    unlockedAt: Optional[str] = None
    isRead: bool = False
    readAt: Optional[str] = None

class SummaryUpdateModel(BaseModel):
    content: Optional[str] = None
    order: Optional[int] = None
    isUnlocked: Optional[bool] = None
    unlockedAt: Optional[str] = None
    isRead: Optional[bool] = None
    readAt: Optional[str] = None

@router.get("/book/{book_id}", response_model=List[Dict[str, Any]])
async def get_summaries_by_book_id(book_id: str):
    """獲取特定書籍的所有摘要"""
    try:
        # 檢查書籍是否存在
        book = storage.get_book_by_id(book_id)
        if not book:
            raise HTTPException(status_code=404, detail="書籍不存在")

        summaries = storage.get_summaries_by_book_id(book_id)
        return summaries
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"獲取摘要列表失敗: {str(e)}")

@router.get("/{book_id}/{summary_id}", response_model=Dict[str, Any])
async def get_summary_by_id(book_id: str, summary_id: str):
    """獲取特定摘要"""
    try:
        # 檢查書籍是否存在
        book = storage.get_book_by_id(book_id)
        if not book:
            raise HTTPException(status_code=404, detail="書籍不存在")

        summary = storage.get_summary_by_id(book_id, summary_id)
        if not summary:
            raise HTTPException(status_code=404, detail="摘要不存在")

        return summary
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"獲取摘要失敗: {str(e)}")

@router.post("/book/{book_id}", response_model=Dict[str, Any])
async def create_summary(book_id: str, summary: SummaryCreateModel):
    """在特定書籍中創建新摘要"""
    try:
        # 檢查書籍是否存在
        book = storage.get_book_by_id(book_id)
        if not book:
            raise HTTPException(status_code=404, detail="書籍不存在")

        summary_data = summary.model_dump(exclude_unset=True)
        new_summary = storage.create_summary(book_id, summary_data)

        if not new_summary:
            raise HTTPException(status_code=500, detail="創建摘要失敗")

        return new_summary
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"創建摘要失敗: {str(e)}")

@router.put("/{book_id}/{summary_id}", response_model=Dict[str, Any])
async def update_summary(book_id: str, summary_id: str, summary: SummaryUpdateModel):
    """更新摘要"""
    try:
        # 檢查書籍是否存在
        book = storage.get_book_by_id(book_id)
        if not book:
            raise HTTPException(status_code=404, detail="書籍不存在")

        # 檢查摘要是否存在
        existing_summary = storage.get_summary_by_id(book_id, summary_id)
        if not existing_summary:
            raise HTTPException(status_code=404, detail="摘要不存在")

        # 只更新提供的欄位
        summary_data = summary.model_dump(exclude_unset=True)

        # 合併現有資料和新資料
        updated_data = {**existing_summary, **summary_data}

        updated_summary = storage.update_summary(book_id, summary_id, updated_data)
        if not updated_summary:
            raise HTTPException(status_code=500, detail="更新摘要失敗")

        return updated_summary
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"更新摘要失敗: {str(e)}")

@router.delete("/{book_id}/{summary_id}")
async def delete_summary(book_id: str, summary_id: str):
    """刪除摘要"""
    try:
        # 檢查書籍是否存在
        book = storage.get_book_by_id(book_id)
        if not book:
            raise HTTPException(status_code=404, detail="書籍不存在")

        # 檢查摘要是否存在
        existing_summary = storage.get_summary_by_id(book_id, summary_id)
        if not existing_summary:
            raise HTTPException(status_code=404, detail="摘要不存在")

        success = storage.delete_summary(book_id, summary_id)
        if not success:
            raise HTTPException(status_code=500, detail="刪除摘要失敗")

        return {"message": "摘要刪除成功", "deleted_id": summary_id, "book_id": book_id}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"刪除摘要失敗: {str(e)}")
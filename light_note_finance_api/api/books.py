from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Any, Dict
from services.json_storage import storage

router = APIRouter(prefix="/books", tags=["books"])

class SummaryModel(BaseModel):
    id: Optional[str] = None
    bookId: Optional[str] = None
    content: str
    order: int
    isUnlocked: bool = False
    unlockedAt: Optional[str] = None
    isRead: bool = False
    readAt: Optional[str] = None

class BookModel(BaseModel):
    id: Optional[str] = None
    title: str
    description: str
    imageUrl: str = ""
    summaries: List[SummaryModel] = []
    isUnlocked: bool = False
    isFavorite: bool = False
    unlockedAt: Optional[str] = None
    isCompleted: bool = False

class BookUpdateModel(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    imageUrl: Optional[str] = None
    summaries: Optional[List[SummaryModel]] = None
    isUnlocked: Optional[bool] = None
    isFavorite: Optional[bool] = None
    unlockedAt: Optional[str] = None
    isCompleted: Optional[bool] = None

@router.get("/", response_model=List[Dict[str, Any]])
async def get_all_books():
    """獲取所有書籍"""
    try:
        books = storage.get_all_books()
        return books
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"獲取書籍列表失敗: {str(e)}")

@router.get("/{book_id}", response_model=Dict[str, Any])
async def get_book_by_id(book_id: str):
    """根據ID獲取特定書籍"""
    try:
        book = storage.get_book_by_id(book_id)
        if not book:
            raise HTTPException(status_code=404, detail="書籍不存在")
        return book
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"獲取書籍失敗: {str(e)}")

@router.post("/", response_model=Dict[str, Any])
async def create_book(book: BookModel):
    """創建新書籍"""
    try:
        book_data = book.model_dump(exclude_unset=True)

        # 轉換summaries為字典格式
        if 'summaries' in book_data:
            book_data['summaries'] = [summary.model_dump(exclude_unset=True) if hasattr(summary, 'model_dump') else summary for summary in book_data['summaries']]

        new_book = storage.create_book(book_data)
        return new_book
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"創建書籍失敗: {str(e)}")

@router.put("/{book_id}", response_model=Dict[str, Any])
async def update_book(book_id: str, book: BookUpdateModel):
    """更新書籍"""
    try:
        # 檢查書籍是否存在
        existing_book = storage.get_book_by_id(book_id)
        if not existing_book:
            raise HTTPException(status_code=404, detail="書籍不存在")

        # 只更新提供的欄位
        book_data = book.model_dump(exclude_unset=True)

        # 轉換summaries為字典格式
        if 'summaries' in book_data:
            book_data['summaries'] = [summary.model_dump(exclude_unset=True) if hasattr(summary, 'model_dump') else summary for summary in book_data['summaries']]

        # 合併現有資料和新資料
        updated_data = {**existing_book, **book_data}

        updated_book = storage.update_book(book_id, updated_data)
        if not updated_book:
            raise HTTPException(status_code=500, detail="更新書籍失敗")

        return updated_book
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"更新書籍失敗: {str(e)}")

@router.delete("/{book_id}")
async def delete_book(book_id: str):
    """刪除書籍"""
    try:
        success = storage.delete_book(book_id)
        if not success:
            raise HTTPException(status_code=404, detail="書籍不存在")
        return {"message": "書籍刪除成功", "deleted_id": book_id}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"刪除書籍失敗: {str(e)}")
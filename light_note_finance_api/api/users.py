from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Any, Dict
from services.json_storage import storage

router = APIRouter(prefix="/users", tags=["users"])

class UserSettingsModel(BaseModel):
    hasBookmarkFeature: bool = False
    hasHighlightFeature: bool = False
    canChooseBooks: bool = False
    dailySummaryCount: int = 10

class UserModel(BaseModel):
    id: Optional[str] = None
    points: int = 0
    isFirstLogin: bool = True
    lastLoginAt: Optional[str] = None
    unlockedBookIds: List[str] = []
    favoriteBookIds: List[str] = []
    currentBookId: Optional[str] = None
    weeklyActivity: Dict[str, bool] = {}
    viewHistory: List[str] = []
    dailyUnlockHistory: Dict[str, str] = {}
    settings: UserSettingsModel

class UserUpdateModel(BaseModel):
    points: Optional[int] = None
    isFirstLogin: Optional[bool] = None
    lastLoginAt: Optional[str] = None
    unlockedBookIds: Optional[List[str]] = None
    favoriteBookIds: Optional[List[str]] = None
    currentBookId: Optional[str] = None
    weeklyActivity: Optional[Dict[str, bool]] = None
    viewHistory: Optional[List[str]] = None
    dailyUnlockHistory: Optional[Dict[str, str]] = None
    settings: Optional[UserSettingsModel] = None

@router.get("/", response_model=List[Dict[str, Any]])
async def get_all_users():
    """獲取所有使用者"""
    try:
        users = storage.get_all_users()
        return users
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"獲取使用者列表失敗: {str(e)}")

@router.get("/{user_id}", response_model=Dict[str, Any])
async def get_user_by_id(user_id: str):
    """根據ID獲取特定使用者"""
    try:
        user = storage.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="使用者不存在")
        return user
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"獲取使用者失敗: {str(e)}")

@router.post("/", response_model=Dict[str, Any])
async def create_user(user: UserModel):
    """創建新使用者"""
    try:
        user_data = user.model_dump(exclude_unset=True)

        # 轉換settings為字典格式
        if 'settings' in user_data and hasattr(user_data['settings'], 'model_dump'):
            user_data['settings'] = user_data['settings'].model_dump(exclude_unset=True)

        new_user = storage.create_user(user_data)
        return new_user
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"創建使用者失敗: {str(e)}")

@router.put("/{user_id}", response_model=Dict[str, Any])
async def update_user(user_id: str, user: UserUpdateModel):
    """更新使用者"""
    try:
        # 檢查使用者是否存在
        existing_user = storage.get_user_by_id(user_id)
        if not existing_user:
            raise HTTPException(status_code=404, detail="使用者不存在")

        # 只更新提供的欄位
        user_data = user.model_dump(exclude_unset=True)

        # 轉換settings為字典格式
        if 'settings' in user_data and hasattr(user_data['settings'], 'model_dump'):
            user_data['settings'] = user_data['settings'].model_dump(exclude_unset=True)

        # 合併現有資料和新資料
        updated_data = {**existing_user, **user_data}

        updated_user = storage.update_user(user_id, updated_data)
        if not updated_user:
            raise HTTPException(status_code=500, detail="更新使用者失敗")

        return updated_user
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"更新使用者失敗: {str(e)}")

@router.delete("/{user_id}")
async def delete_user(user_id: str):
    """刪除使用者"""
    try:
        success = storage.delete_user(user_id)
        if not success:
            raise HTTPException(status_code=404, detail="使用者不存在")
        return {"message": "使用者刪除成功", "deleted_id": user_id}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"刪除使用者失敗: {str(e)}")

# 額外的使用者操作端點

@router.post("/{user_id}/unlock-book/{book_id}")
async def unlock_book(user_id: str, book_id: str):
    """為使用者解鎖書籍"""
    try:
        user = storage.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="使用者不存在")

        # 檢查書籍是否存在
        book = storage.get_book_by_id(book_id)
        if not book:
            raise HTTPException(status_code=404, detail="書籍不存在")

        # 添加到解鎖列表（如果還沒解鎖）
        unlocked_books = user.get('unlockedBookIds', [])
        if book_id not in unlocked_books:
            unlocked_books.append(book_id)

            updated_user = storage.update_user(user_id, {
                **user,
                'unlockedBookIds': unlocked_books
            })

            return {"message": "書籍解鎖成功", "user": updated_user}
        else:
            return {"message": "書籍已經解鎖", "user": user}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"解鎖書籍失敗: {str(e)}")

@router.post("/{user_id}/favorite-book/{book_id}")
async def toggle_favorite_book(user_id: str, book_id: str):
    """切換使用者的最愛書籍"""
    try:
        user = storage.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="使用者不存在")

        # 檢查書籍是否存在
        book = storage.get_book_by_id(book_id)
        if not book:
            raise HTTPException(status_code=404, detail="書籍不存在")

        favorite_books = user.get('favoriteBookIds', [])

        if book_id in favorite_books:
            # 移除最愛
            favorite_books.remove(book_id)
            message = "已從最愛移除"
        else:
            # 添加最愛
            favorite_books.append(book_id)
            message = "已添加到最愛"

        updated_user = storage.update_user(user_id, {
            **user,
            'favoriteBookIds': favorite_books
        })

        return {"message": message, "user": updated_user}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"切換最愛書籍失敗: {str(e)}")

@router.put("/{user_id}/points")
async def update_user_points(user_id: str, points: int):
    """更新使用者積分"""
    try:
        user = storage.get_user_by_id(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="使用者不存在")

        updated_user = storage.update_user(user_id, {
            **user,
            'points': points
        })

        return {"message": "積分更新成功", "user": updated_user}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"更新積分失敗: {str(e)}")
import json
import os
from typing import List, Dict, Any, Optional
from datetime import datetime
import uuid

class JSONStorage:
    def __init__(self, data_dir: str = "data"):
        self.data_dir = data_dir
        self.books_file = os.path.join(data_dir, "books.json")
        self.users_file = os.path.join(data_dir, "users.json")

        # 確保資料目錄存在
        os.makedirs(data_dir, exist_ok=True)

        # 初始化檔案
        self._init_file(self.books_file)
        self._init_file(self.users_file)

    def _init_file(self, file_path: str):
        """初始化JSON檔案，如果不存在就創建空陣列"""
        if not os.path.exists(file_path):
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump([], f, ensure_ascii=False, indent=2)

    def _read_json(self, file_path: str) -> List[Dict[str, Any]]:
        """讀取JSON檔案"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            return []

    def _write_json(self, file_path: str, data: List[Dict[str, Any]]):
        """寫入JSON檔案"""
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    # Books CRUD
    def get_all_books(self) -> List[Dict[str, Any]]:
        """獲取所有書籍"""
        return self._read_json(self.books_file)

    def get_book_by_id(self, book_id: str) -> Optional[Dict[str, Any]]:
        """根據ID獲取書籍"""
        books = self._read_json(self.books_file)
        for book in books:
            if book.get('id') == book_id:
                return book
        return None

    def create_book(self, book_data: Dict[str, Any]) -> Dict[str, Any]:
        """創建新書籍"""
        books = self._read_json(self.books_file)

        # 生成ID如果沒有提供
        if 'id' not in book_data or not book_data['id']:
            book_data['id'] = str(uuid.uuid4())

        # 添加創建時間
        book_data['createdAt'] = datetime.now().isoformat()
        book_data['updatedAt'] = datetime.now().isoformat()

        books.append(book_data)
        self._write_json(self.books_file, books)
        return book_data

    def update_book(self, book_id: str, book_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """更新書籍"""
        books = self._read_json(self.books_file)

        for i, book in enumerate(books):
            if book.get('id') == book_id:
                # 保持原有的ID和創建時間
                book_data['id'] = book_id
                book_data['createdAt'] = book.get('createdAt', datetime.now().isoformat())
                book_data['updatedAt'] = datetime.now().isoformat()

                books[i] = book_data
                self._write_json(self.books_file, books)
                return book_data

        return None

    def delete_book(self, book_id: str) -> bool:
        """刪除書籍"""
        books = self._read_json(self.books_file)
        original_length = len(books)

        books = [book for book in books if book.get('id') != book_id]

        if len(books) < original_length:
            self._write_json(self.books_file, books)
            return True
        return False

    # Users CRUD
    def get_all_users(self) -> List[Dict[str, Any]]:
        """獲取所有使用者"""
        return self._read_json(self.users_file)

    def get_user_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        """根據ID獲取使用者"""
        users = self._read_json(self.users_file)
        for user in users:
            if user.get('id') == user_id:
                return user
        return None

    def create_user(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """創建新使用者"""
        users = self._read_json(self.users_file)

        # 生成ID如果沒有提供
        if 'id' not in user_data or not user_data['id']:
            user_data['id'] = str(uuid.uuid4())

        # 添加創建時間
        user_data['createdAt'] = datetime.now().isoformat()
        user_data['updatedAt'] = datetime.now().isoformat()

        users.append(user_data)
        self._write_json(self.users_file, users)
        return user_data

    def update_user(self, user_id: str, user_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """更新使用者"""
        users = self._read_json(self.users_file)

        for i, user in enumerate(users):
            if user.get('id') == user_id:
                # 保持原有的ID和創建時間
                user_data['id'] = user_id
                user_data['createdAt'] = user.get('createdAt', datetime.now().isoformat())
                user_data['updatedAt'] = datetime.now().isoformat()

                users[i] = user_data
                self._write_json(self.users_file, users)
                return user_data

        return None

    def delete_user(self, user_id: str) -> bool:
        """刪除使用者"""
        users = self._read_json(self.users_file)
        original_length = len(users)

        users = [user for user in users if user.get('id') != user_id]

        if len(users) < original_length:
            self._write_json(self.users_file, users)
            return True
        return False

    # Summary operations (summaries are stored within books)
    def get_summaries_by_book_id(self, book_id: str) -> List[Dict[str, Any]]:
        """獲取特定書籍的所有摘要"""
        book = self.get_book_by_id(book_id)
        if book and 'summaries' in book:
            return book['summaries']
        return []

    def get_summary_by_id(self, book_id: str, summary_id: str) -> Optional[Dict[str, Any]]:
        """獲取特定摘要"""
        summaries = self.get_summaries_by_book_id(book_id)
        for summary in summaries:
            if summary.get('id') == summary_id:
                return summary
        return None

    def create_summary(self, book_id: str, summary_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """在書籍中創建新摘要"""
        book = self.get_book_by_id(book_id)
        if not book:
            return None

        # 生成ID如果沒有提供
        if 'id' not in summary_data or not summary_data['id']:
            summary_data['id'] = str(uuid.uuid4())

        # 設定書籍ID
        summary_data['bookId'] = book_id

        # 確保book有summaries欄位
        if 'summaries' not in book:
            book['summaries'] = []

        book['summaries'].append(summary_data)

        # 更新整本書
        self.update_book(book_id, book)
        return summary_data

    def update_summary(self, book_id: str, summary_id: str, summary_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """更新摘要"""
        book = self.get_book_by_id(book_id)
        if not book or 'summaries' not in book:
            return None

        for i, summary in enumerate(book['summaries']):
            if summary.get('id') == summary_id:
                # 保持原有的ID和書籍ID
                summary_data['id'] = summary_id
                summary_data['bookId'] = book_id

                book['summaries'][i] = summary_data
                self.update_book(book_id, book)
                return summary_data

        return None

    def delete_summary(self, book_id: str, summary_id: str) -> bool:
        """刪除摘要"""
        book = self.get_book_by_id(book_id)
        if not book or 'summaries' not in book:
            return False

        original_length = len(book['summaries'])
        book['summaries'] = [s for s in book['summaries'] if s.get('id') != summary_id]

        if len(book['summaries']) < original_length:
            self.update_book(book_id, book)
            return True
        return False

# 全域實例
storage = JSONStorage()
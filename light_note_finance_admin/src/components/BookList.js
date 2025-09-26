import React, { useState, useEffect } from 'react';
import BookCard from './BookCard';
import BookForm from './BookForm';
import { bookService } from '../services/bookService';
import './BookList.css';

const BookList = ({ onBookSelect }) => {
  const [books, setBooks] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [editingBook, setEditingBook] = useState(null);
  const [filter, setFilter] = useState('all');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadBooks();
  }, []);

  const loadBooks = async () => {
    try {
      setLoading(true);
      setError(null);
      const allBooks = await bookService.getAllBooks();
      setBooks(allBooks);
    } catch (err) {
      setError('載入書籍資料失敗');
      console.error('Error loading books:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleAddBook = () => {
    setEditingBook(null);
    setShowForm(true);
  };

  const handleEditBook = (book) => {
    setEditingBook(book);
    setShowForm(true);
  };

  const handleFormSubmit = async (bookData) => {
    try {
      setError(null);
      if (editingBook) {
        await bookService.updateBook(editingBook.id, bookData);
      } else {
        await bookService.addBook(bookData.title, bookData.description, bookData.imageUrl);
      }
      await loadBooks();
      setShowForm(false);
      setEditingBook(null);
    } catch (err) {
      setError('儲存書籍資料失敗');
      console.error('Error saving book:', err);
    }
  };

  const handleFormCancel = () => {
    setShowForm(false);
    setEditingBook(null);
  };

  const handleToggleStatus = async (bookId) => {
    try {
      setError(null);
      await bookService.toggleBookStatus(bookId);
      await loadBooks();
    } catch (err) {
      setError('切換書籍狀態失敗');
      console.error('Error toggling status:', err);
    }
  };

  const handleDeleteBook = async (bookId) => {
    if (window.confirm('確定要刪除這本書嗎？這將會永久刪除書籍及其所有摘要。')) {
      try {
        setError(null);
        await bookService.deleteBook(bookId);
        await loadBooks();
      } catch (err) {
        setError('刪除書籍失敗');
        console.error('Error deleting book:', err);
      }
    }
  };

  const handleSummariesUpdate = () => {
    loadBooks();
  };

  const filteredBooks = books.filter(book => {
    if (filter === 'all') return true;
    // 適配 API 資料格式
    const bookStatus = book.isPublished !== undefined ? (book.isPublished ? 'active' : 'inactive') : (book.status || 'active');
    return bookStatus === filter;
  });

  if (loading) {
    return (
      <div className="book-list-container">
        <div className="loading-state">
          <h3>載入中...</h3>
          <p>正在載入書籍資料</p>
        </div>
      </div>
    );
  }

  return (
    <div className="book-list-container">
      {error && (
        <div className="error-message">
          <p>{error}</p>
          <button onClick={loadBooks} className="btn btn-secondary">重新載入</button>
        </div>
      )}

      <div className="book-list-header">
        <h1>書籍管理</h1>
        <div className="header-actions">
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="filter-select"
          >
            <option value="all">全部書籍</option>
            <option value="active">啟用中</option>
            <option value="inactive">已停用</option>
          </select>
          <button className="btn btn-primary" onClick={handleAddBook}>
            新增書籍
          </button>
        </div>
      </div>

      <div className="book-stats">
        <div className="stat-card">
          <h3>總書籍數</h3>
          <p>{books.length}</p>
        </div>
        <div className="stat-card">
          <h3>啟用中</h3>
          <p>{books.filter(b => {
            const bookStatus = b.isPublished !== undefined ? (b.isPublished ? 'active' : 'inactive') : (b.status || 'active');
            return bookStatus === 'active';
          }).length}</p>
        </div>
        <div className="stat-card">
          <h3>總摘要數</h3>
          <p>{books.reduce((total, book) => total + (book.summaries ? book.summaries.length : 0), 0)}</p>
        </div>
      </div>

      {showForm && (
        <BookForm
          book={editingBook}
          onSubmit={handleFormSubmit}
          onCancel={handleFormCancel}
        />
      )}

      <div className="books-list">
        {filteredBooks.length === 0 ? (
          <div className="empty-state">
            <h3>沒有找到書籍</h3>
            <p>
              {filter === 'all'
                ? '還沒有任何書籍，點擊「新增書籍」開始建立您的書籍收藏。'
                : `沒有${filter === 'active' ? '啟用中' : '已停用'}的書籍。`
              }
            </p>
          </div>
        ) : (
          filteredBooks.map(book => (
            <BookCard
              key={book.id}
              book={book}
              onToggleStatus={handleToggleStatus}
              onDelete={handleDeleteBook}
              onEdit={handleEditBook}
              onSummariesUpdate={handleSummariesUpdate}
            />
          ))
        )}
      </div>
    </div>
  );
};

export default BookList;
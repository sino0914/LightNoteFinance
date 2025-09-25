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

  useEffect(() => {
    loadBooks();
  }, []);

  const loadBooks = () => {
    const allBooks = bookService.getAllBooks();
    setBooks(allBooks);
  };

  const handleAddBook = () => {
    setEditingBook(null);
    setShowForm(true);
  };

  const handleEditBook = (book) => {
    setEditingBook(book);
    setShowForm(true);
  };

  const handleFormSubmit = (bookData) => {
    if (editingBook) {
      bookService.updateBook(editingBook.id, bookData);
    } else {
      bookService.addBook(bookData.title, bookData.image);
    }
    loadBooks();
    setShowForm(false);
    setEditingBook(null);
  };

  const handleFormCancel = () => {
    setShowForm(false);
    setEditingBook(null);
  };

  const handleToggleStatus = (bookId) => {
    bookService.toggleBookStatus(bookId);
    loadBooks();
  };

  const handleDeleteBook = (bookId) => {
    if (window.confirm('確定要刪除這本書嗎？這將會永久刪除書籍及其所有摘要。')) {
      bookService.deleteBook(bookId);
      loadBooks();
    }
  };

  const handleSummariesUpdate = () => {
    loadBooks();
  };

  const filteredBooks = books.filter(book => {
    if (filter === 'all') return true;
    return book.status === filter;
  });

  return (
    <div className="book-list-container">
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
          <p>{books.filter(b => b.status === 'active').length}</p>
        </div>
        <div className="stat-card">
          <h3>總摘要數</h3>
          <p>{books.reduce((total, book) => total + book.summaries.length, 0)}</p>
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
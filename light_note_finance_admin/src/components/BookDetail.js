import React, { useState, useEffect } from 'react';
import SummaryManager from './SummaryManager';
import { bookService } from '../services/bookService';
import './BookDetail.css';

const BookDetail = ({ bookId, onBack }) => {
  const [book, setBook] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadBook();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [bookId]);

  const loadBook = () => {
    setLoading(true);
    const bookData = bookService.getBookById(bookId);
    setBook(bookData);
    setLoading(false);
  };

  const handleSummariesUpdate = () => {
    loadBook(); // 重新載入書籍資料以更新摘要
  };

  const handleToggleStatus = () => {
    bookService.toggleBookStatus(bookId);
    loadBook();
  };

  const handleImageError = (e) => {
    e.target.src = '/images/default-book.png';
  };

  if (loading) {
    return (
      <div className="book-detail-loading">
        <div className="loading-spinner"></div>
        <p>載入中...</p>
      </div>
    );
  }

  if (!book) {
    return (
      <div className="book-detail-error">
        <h2>書籍不存在</h2>
        <p>找不到指定的書籍資料。</p>
        <button className="btn btn-primary" onClick={onBack}>
          返回書籍列表
        </button>
      </div>
    );
  }

  return (
    <div className="book-detail-container">
      <div className="book-detail-header">
        <button className="back-button" onClick={onBack}>
          ← 返回書籍列表
        </button>
        <div className="header-actions">
          <button
            className={`btn ${book.status === 'active' ? 'btn-warning' : 'btn-success'}`}
            onClick={handleToggleStatus}
          >
            {book.status === 'active' ? '停用書籍' : '啟用書籍'}
          </button>
        </div>
      </div>

      <div className="book-detail-content">
        <div className="book-info-section">
          <div className="book-cover">
            <img
              src={book.image || '/images/default-book.png'}
              alt={book.title}
              onError={handleImageError}
            />
            <div className="book-status-badge">
              <span className={`status-badge ${book.status}`}>
                {book.status === 'active' ? '啟用' : '停用'}
              </span>
            </div>
          </div>

          <div className="book-metadata">
            <h1 className="book-title">{book.title}</h1>

            <div className="book-stats">
              <div className="stat-item">
                <span className="stat-label">摘要數量</span>
                <span className="stat-value">{book.summaries.length}</span>
              </div>
              <div className="stat-item">
                <span className="stat-label">建立日期</span>
                <span className="stat-value">
                  {new Date(book.createdAt).toLocaleDateString('zh-TW')}
                </span>
              </div>
              <div className="stat-item">
                <span className="stat-label">更新日期</span>
                <span className="stat-value">
                  {new Date(book.updatedAt).toLocaleDateString('zh-TW')}
                </span>
              </div>
              <div className="stat-item">
                <span className="stat-label">狀態</span>
                <span className={`stat-value status-text ${book.status}`}>
                  {book.status === 'active' ? '啟用中' : '已停用'}
                </span>
              </div>
            </div>
          </div>
        </div>

        <div className="summaries-section">
          <SummaryManager
            bookId={bookId}
            summaries={book.summaries}
            onUpdate={handleSummariesUpdate}
            bookStatus={book.status}
          />
        </div>
      </div>
    </div>
  );
};

export default BookDetail;
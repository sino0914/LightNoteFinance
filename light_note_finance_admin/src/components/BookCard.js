import React, { useState } from 'react';
import SummaryManager from './SummaryManager';
import './BookCard.css';

const BookCard = ({ book, onToggleStatus, onDelete, onEdit, onSummariesUpdate }) => {
  const [showSummaries, setShowSummaries] = useState(false);

  const handleImageError = (e) => {
    e.target.src = '/images/default-book.png';
  };

  const toggleSummaries = () => {
    setShowSummaries(!showSummaries);
  };

  return (
    <div className={`book-card-list ${book.status === 'inactive' ? 'inactive' : ''}`}>
      <div className="book-main-info" onClick={toggleSummaries}>
        <div className="book-image-small">
          <img
            src={book.image || '/images/default-book.png'}
            alt={book.title}
            onError={handleImageError}
          />
        </div>

        <div className="book-content">
          <div className="book-header">
            <h3 className="book-title">{book.title}</h3>
            <div className="book-status">
              <span className={`status-badge ${book.status}`}>
                {book.status === 'active' ? '啟用' : '停用'}
              </span>
              <div className="expand-indicator">
                <span className={`expand-arrow ${showSummaries ? 'expanded' : ''}`}>
                  ▼
                </span>
              </div>
            </div>
          </div>

          <div className="book-meta">
            <span className="meta-item">摘要: {book.summaries.length} 個</span>
            <span className="meta-item">建立: {new Date(book.createdAt).toLocaleDateString('zh-TW')}</span>
          </div>

          <div className="book-actions" onClick={(e) => e.stopPropagation()}>
            <button
              className="btn btn-secondary btn-sm"
              onClick={() => onEdit(book)}
            >
              編輯
            </button>
            <button
              className={`btn btn-sm ${book.status === 'active' ? 'btn-warning' : 'btn-success'}`}
              onClick={() => onToggleStatus(book.id)}
            >
              {book.status === 'active' ? '停用' : '啟用'}
            </button>
            <button
              className="btn btn-danger btn-sm"
              onClick={() => onDelete(book.id)}
            >
              刪除
            </button>
          </div>
        </div>
      </div>

      {showSummaries && (
        <div className="summaries-section">
          <SummaryManager
            bookId={book.id}
            summaries={book.summaries}
            onUpdate={() => {
              onSummariesUpdate();
            }}
            bookStatus={book.status}
          />
        </div>
      )}
    </div>
  );
};

export default BookCard;
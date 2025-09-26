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

  // 處理圖片URL - 支援完整URL和各種相對路徑格式
  const getImageUrl = (rawImageUrl) => {
    if (!rawImageUrl) return '/images/default-book.png';

    // 如果已經是完整的HTTP/HTTPS URL，直接使用
    if (rawImageUrl.startsWith('http://') || rawImageUrl.startsWith('https://')) {
      return rawImageUrl;
    }

    // 處理各種相對路徑格式
    let processedPath = rawImageUrl;

    // 如果是 ../uploads 格式，轉換為 /uploads
    if (processedPath.startsWith('../uploads')) {
      processedPath = processedPath.replace('../uploads', '/uploads');
    }
    // 如果是 uploads 格式（無前綴斜線），加上前綴斜線
    else if (!processedPath.startsWith('/') && processedPath.startsWith('uploads')) {
      processedPath = `/${processedPath}`;
    }
    // 如果已經是 /uploads 格式，保持不變
    else if (!processedPath.startsWith('/')) {
      processedPath = `/${processedPath}`;
    }

    return `http://localhost:8000${processedPath}`;
  };

  // API 資料格式適配
  const displayStatus = book.isPublished !== undefined ? (book.isPublished ? 'active' : 'inactive') : (book.status || 'active');
  const imageUrl = getImageUrl(book.imageUrl || book.image);
  const summariesCount = book.summaries ? book.summaries.length : 0;
  const createdDate = book.createdAt || book.created_at || new Date().toISOString();

  return (
    <div className={`book-card-list ${displayStatus === 'inactive' ? 'inactive' : ''}`}>
      <div className="book-main-info" onClick={toggleSummaries}>
        <div className="book-image-small">
          <img
            src={imageUrl}
            alt={book.title}
            onError={handleImageError}
          />
        </div>

        <div className="book-content">
          <div className="book-header">
            <h3 className="book-title">{book.title}</h3>
            <div className="book-status">
              <span className={`status-badge ${displayStatus}`}>
                {displayStatus === 'active' ? '啟用' : '停用'}
              </span>
              <div className="expand-indicator">
                <span className={`expand-arrow ${showSummaries ? 'expanded' : ''}`}>
                  ▼
                </span>
              </div>
            </div>
          </div>

          <div className="book-meta">
            <span className="meta-item">摘要: {summariesCount} 個</span>
            <span className="meta-item">建立: {new Date(createdDate).toLocaleDateString('zh-TW')}</span>
            {book.description && (
              <div className="book-description">{book.description}</div>
            )}
          </div>

          <div className="book-actions" onClick={(e) => e.stopPropagation()}>
            <button
              className="btn btn-secondary btn-sm"
              onClick={() => onEdit(book)}
            >
              編輯
            </button>
            <button
              className={`btn btn-sm ${displayStatus === 'active' ? 'btn-warning' : 'btn-success'}`}
              onClick={() => onToggleStatus(book.id)}
            >
              {displayStatus === 'active' ? '停用' : '啟用'}
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
            summaries={book.summaries || []}
            onUpdate={() => {
              onSummariesUpdate();
            }}
            bookStatus={displayStatus}
            book={book}
          />
        </div>
      )}
    </div>
  );
};

export default BookCard;
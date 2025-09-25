import React, { useState } from 'react';
import './SummaryCard.css';

const SummaryCard = ({ summary, index, onEdit, onDelete, isEditable }) => {
  const [isExpanded, setIsExpanded] = useState(false);

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('zh-TW', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const toggleExpanded = () => {
    setIsExpanded(!isExpanded);
  };

  const handleEdit = (e) => {
    e.stopPropagation();
    if (onEdit) {
      onEdit(summary);
    }
  };

  const handleDelete = (e) => {
    e.stopPropagation();
    if (onDelete) {
      onDelete(summary.id);
    }
  };

  const shouldShowExpandButton = summary.content.length > 200;
  const displayContent = shouldShowExpandButton && !isExpanded
    ? summary.content.substring(0, 200) + '...'
    : summary.content;

  return (
    <div className={`summary-card ${!isEditable ? 'readonly' : ''}`}>
      <div className="summary-header">
        <div className="summary-index">#{index}</div>
        <div className="summary-meta">
          <span className="summary-date">{formatDate(summary.createdAt)}</span>
        </div>
        {isEditable && (
          <div className="summary-actions">
            <button
              className="btn btn-sm btn-secondary"
              onClick={handleEdit}
              title="編輯摘要"
            >
              編輯
            </button>
            <button
              className="btn btn-sm btn-danger"
              onClick={handleDelete}
              title="刪除摘要"
            >
              刪除
            </button>
          </div>
        )}
      </div>

      <div className="summary-content" onClick={shouldShowExpandButton ? toggleExpanded : undefined}>
        <p className={shouldShowExpandButton ? 'expandable' : ''}>
          {displayContent}
        </p>

        {shouldShowExpandButton && (
          <button className="expand-button" onClick={toggleExpanded}>
            {isExpanded ? '收合' : '展開全文'}
          </button>
        )}
      </div>
    </div>
  );
};

export default SummaryCard;
import React, { useState } from 'react';
import SummaryForm from './SummaryForm';
import SummaryCard from './SummaryCard';
import QuickSummaryInput from './QuickSummaryInput';
import { bookService } from '../services/bookService';
import './SummaryManager.css';

const SummaryManager = ({ bookId, summaries, onUpdate, bookStatus }) => {
  const [showForm, setShowForm] = useState(false);
  const [editingSummary, setEditingSummary] = useState(null);

  const handleAddSummary = () => {
    setEditingSummary(null);
    setShowForm(true);
  };

  const handleEditSummary = (summary) => {
    setEditingSummary(summary);
    setShowForm(true);
  };

  const handleFormSubmit = (content) => {
    if (editingSummary) {
      // 更新摘要（先刪除再新增，因為我們的資料結構比較簡單）
      bookService.deleteSummary(bookId, editingSummary.id);
      bookService.addSummary(bookId, content);
    } else {
      // 新增摘要
      bookService.addSummary(bookId, content);
    }

    setShowForm(false);
    setEditingSummary(null);
    onUpdate(); // 通知父組件更新
  };

  const handleQuickAdd = (content) => {
    return new Promise((resolve, reject) => {
      try {
        bookService.addSummary(bookId, content);
        onUpdate(); // 通知父組件更新
        resolve();
      } catch (error) {
        reject(error);
      }
    });
  };

  const handleFormCancel = () => {
    setShowForm(false);
    setEditingSummary(null);
  };

  const handleDeleteSummary = (summaryId) => {
    if (window.confirm('確定要刪除這個摘要嗎？此操作無法復原。')) {
      bookService.deleteSummary(bookId, summaryId);
      onUpdate(); // 通知父組件更新
    }
  };

  const isBookActive = bookStatus === 'active';

  return (
    <div className="summary-manager">
      <div className="summary-manager-header">
        <h2>書籍摘要</h2>
        <div className="header-info">
          <span className="summary-count">{summaries.length} 個摘要</span>
          {false && (
            <button className="btn btn-primary" onClick={handleAddSummary}>
              新增摘要
            </button>
          )}
        </div>
      </div>

      {!isBookActive && (
        <div className="inactive-notice">
          <p>⚠️ 此書籍已停用，無法新增或編輯摘要</p>
        </div>
      )}

      {showForm && (
        <SummaryForm
          summary={editingSummary}
          onSubmit={handleFormSubmit}
          onCancel={handleFormCancel}
        />
      )}

      {isBookActive && (
        <QuickSummaryInput
          onSubmit={handleQuickAdd}
          disabled={!isBookActive}
        />
      )}

      <div className="summaries-container">
        {summaries.length === 0 ? (
          <div className="empty-summaries">
            <div className="empty-icon">📝</div>
            <h3>還沒有任何摘要</h3>
            <p>
              {isBookActive
                ? '開始新增您的第一個摘要吧！可以使用上方的快速輸入框，或點擊下方按鈕開啟詳細編輯器。'
                : '此書籍目前沒有任何摘要。'
              }
            </p>
            {isBookActive && (
              <button className="btn btn-primary" onClick={handleAddSummary}>
                使用詳細編輯器
              </button>
            )}
          </div>
        ) : (
          <div className="summaries-list">
            {summaries.map((summary, index) => (
              <SummaryCard
                key={summary.id}
                summary={summary}
                index={index + 1}
                onEdit={isBookActive ? handleEditSummary : null}
                onDelete={isBookActive ? handleDeleteSummary : null}
                isEditable={isBookActive}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default SummaryManager;
import React, { useState, useEffect } from 'react';
import SummaryForm from './SummaryForm';
import SummaryCard from './SummaryCard';
import QuickSummaryInput from './QuickSummaryInput';
import { bookService } from '../services/bookService';
import './SummaryManager.css';

const SummaryManager = ({ bookId, summaries, onUpdate, bookStatus, book }) => {
  const [showForm, setShowForm] = useState(false);
  const [editingSummary, setEditingSummary] = useState(null);
  const [localSummaries, setLocalSummaries] = useState(summaries || []);

  // 適配 API 資料格式 - 優先使用 book 對象的 isPublished
  const isBookActive = book ? (book.isPublished !== undefined ? book.isPublished : true) : (bookStatus === 'active');

  // 當外部傳入的summaries改變時，更新本地狀態
  useEffect(() => {
    setLocalSummaries(summaries || []);
  }, [summaries]);

  const handleAddSummary = () => {
    setEditingSummary(null);
    setShowForm(true);
  };

  const handleEditSummary = (summary) => {
    setEditingSummary(summary);
    setShowForm(true);
  };

  const handleFormSubmit = async (content) => {
    try {
      if (editingSummary) {
        // 更新摘要（先刪除再新增，因為我們的資料結構比較簡單）
        await bookService.deleteSummary(bookId, editingSummary.id);
        const newSummary = await bookService.addSummary(bookId, content);
        // 立即更新本地狀態
        setLocalSummaries(prev => prev.filter(s => s.id !== editingSummary.id).concat(newSummary));
      } else {
        // 新增摘要
        const newSummary = await bookService.addSummary(bookId, content);
        // 立即更新本地狀態
        setLocalSummaries(prev => [...prev, newSummary]);
      }

      setShowForm(false);
      setEditingSummary(null);
      // 不需要調用onUpdate，保持摘要區域展開狀態
    } catch (error) {
      console.error('Error submitting summary:', error);
      alert('操作失敗：' + error.message);
    }
  };

  const handleQuickAdd = async (content) => {
    try {
      const newSummary = await bookService.addSummary(bookId, content);
      // 立即更新本地狀態，提供即時反饋
      setLocalSummaries(prev => [...prev, newSummary]);
      // 不需要調用onUpdate，保持摘要區域展開狀態
    } catch (error) {
      console.error('Error adding summary:', error);
      throw error;
    }
  };

  const handleFormCancel = () => {
    setShowForm(false);
    setEditingSummary(null);
  };

  const handleDeleteSummary = async (summaryId) => {
    if (window.confirm('確定要刪除這個摘要嗎？此操作無法復原。')) {
      try {
        await bookService.deleteSummary(bookId, summaryId);
        // 立即從本地狀態中移除摘要
        setLocalSummaries(prev => prev.filter(summary => summary.id !== summaryId));
        // 不需要調用onUpdate，保持摘要區域展開狀態
      } catch (error) {
        console.error('Error deleting summary:', error);
        alert('刪除失敗：' + error.message);
      }
    }
  };

  return (
    <div className="summary-manager">
      <div className="summary-manager-header">
        <h2>書籍摘要</h2>
        <div className="header-info">
          <span className="summary-count">{localSummaries.length} 個摘要</span>
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
        {localSummaries.length === 0 ? (
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
            {localSummaries.map((summary, index) => (
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
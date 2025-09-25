import React, { useState } from 'react';
import './QuickSummaryInput.css';

const QuickSummaryInput = ({ onSubmit, disabled = false }) => {
  const [content, setContent] = useState('');
  const [isExpanded, setIsExpanded] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleFocus = () => {
    if (!disabled) {
      setIsExpanded(true);
    }
  };

  const handleBlur = (e) => {
    if (!content.trim() && !e.currentTarget.contains(e.relatedTarget)) {
      setIsExpanded(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!content.trim() || disabled || isSubmitting) return;

    setIsSubmitting(true);
    try {
      await onSubmit(content.trim());
      setContent('');
      setIsExpanded(false);
    } catch (error) {
      console.error('Failed to add summary:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCancel = () => {
    setContent('');
    setIsExpanded(false);
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Escape') {
      handleCancel();
    } else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  return (
    <div className={`quick-summary-input ${isExpanded ? 'expanded' : ''} ${disabled ? 'disabled' : ''}`} onBlur={handleBlur}>
      <form onSubmit={handleSubmit}>
        <div className="input-container">
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            onFocus={handleFocus}
            onKeyDown={handleKeyDown}
            placeholder={disabled ? '此書籍已停用，無法新增摘要' : '快速新增摘要... (Ctrl+Enter 提交)'}
            disabled={disabled || isSubmitting}
            rows={isExpanded ? 4 : 1}
            className="quick-input"
          />
          {isExpanded && (
            <div className="input-actions">
              <div className="input-hints">
                <span className="char-count">{content.length}/2000</span>
                <span className="hint">Ctrl+Enter 快速提交 • Esc 取消</span>
              </div>
              <div className="action-buttons">
                <button
                  type="button"
                  onClick={handleCancel}
                  className="btn btn-sm btn-secondary"
                  disabled={isSubmitting}
                >
                  取消
                </button>
                <button
                  type="submit"
                  className="btn btn-sm btn-primary"
                  disabled={!content.trim() || isSubmitting || content.length > 2000}
                >
                  {isSubmitting ? '新增中...' : '新增摘要'}
                </button>
              </div>
            </div>
          )}
        </div>
      </form>
    </div>
  );
};

export default QuickSummaryInput;
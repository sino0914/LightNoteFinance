import React, { useState, useEffect } from 'react';
import './SummaryForm.css';

const SummaryForm = ({ summary, onSubmit, onCancel }) => {
  const [content, setContent] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    if (summary) {
      setContent(summary.content || '');
    }
  }, [summary]);

  const handleChange = (e) => {
    setContent(e.target.value);
    if (error) {
      setError('');
    }
  };

  const validateForm = () => {
    if (!content.trim()) {
      setError('摘要內容為必填項目');
      return false;
    }

    if (content.length > 2000) {
      setError('摘要內容不能超過2000個字符');
      return false;
    }

    return true;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (validateForm()) {
      onSubmit(content.trim());
    }
  };

  return (
    <div className="summary-form-overlay">
      <div className="summary-form-container">
        <div className="summary-form-header">
          <h3>{summary ? '編輯摘要' : '新增摘要'}</h3>
          <button className="close-button" onClick={onCancel}>
            ×
          </button>
        </div>

        <form onSubmit={handleSubmit} className="summary-form">
          <div className="form-group">
            <label htmlFor="content">摘要內容 *</label>
            <textarea
              id="content"
              value={content}
              onChange={handleChange}
              className={error ? 'error' : ''}
              placeholder="請輸入您的摘要內容..."
              rows={8}
            />
            <div className="form-meta">
              <span className="char-count">
                {content.length}/2000 字符
              </span>
              {error && <span className="error-message">{error}</span>}
            </div>
          </div>

          <div className="form-actions">
            <button type="button" className="btn btn-secondary" onClick={onCancel}>
              取消
            </button>
            <button type="submit" className="btn btn-primary">
              {summary ? '更新摘要' : '新增摘要'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SummaryForm;
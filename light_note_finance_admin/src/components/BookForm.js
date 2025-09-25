import React, { useState, useEffect } from 'react';
import ImageUpload from './ImageUpload';
import './BookForm.css';

const BookForm = ({ book, onSubmit, onCancel }) => {
  const [formData, setFormData] = useState({
    title: '',
    image: ''
  });
  const [errors, setErrors] = useState({});

  useEffect(() => {
    if (book) {
      setFormData({
        title: book.title || '',
        image: book.image || ''
      });
    }
  }, [book]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));

    // 清除錯誤訊息
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const handleImageUploaded = (imageUrl) => {
    setFormData(prev => ({
      ...prev,
      image: imageUrl
    }));

    // 清除圖片錯誤訊息
    if (errors.image) {
      setErrors(prev => ({
        ...prev,
        image: ''
      }));
    }
  };

  const handleImageRemoved = () => {
    setFormData(prev => ({
      ...prev,
      image: ''
    }));
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.title.trim()) {
      newErrors.title = '書名為必填項目';
    } else if (formData.title.length > 100) {
      newErrors.title = '書名不能超過100個字符';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (validateForm()) {
      onSubmit(formData);
    }
  };


  return (
    <div className="book-form-overlay">
      <div className="book-form-container">
        <div className="book-form-header">
          <h2>{book ? '編輯書籍' : '新增書籍'}</h2>
          <button className="close-button" onClick={onCancel}>
            ×
          </button>
        </div>

        <form onSubmit={handleSubmit} className="book-form">
          <div className="form-group">
            <label htmlFor="title">書名 *</label>
            <input
              type="text"
              id="title"
              name="title"
              value={formData.title}
              onChange={handleChange}
              className={errors.title ? 'error' : ''}
              placeholder="請輸入書籍名稱"
            />
            {errors.title && <span className="error-message">{errors.title}</span>}
          </div>

          <div className="form-group">
            <label>書籍封面圖片</label>
            <ImageUpload
              currentImage={formData.image}
              onImageUploaded={handleImageUploaded}
              onImageRemoved={handleImageRemoved}
            />
            {errors.image && <span className="error-message">{errors.image}</span>}
          </div>

          <div className="form-actions">
            <button type="button" className="btn btn-secondary" onClick={onCancel}>
              取消
            </button>
            <button type="submit" className="btn btn-primary">
              {book ? '更新書籍' : '新增書籍'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default BookForm;
import React, { useState, useEffect } from "react";
import ImageUpload from "./ImageUpload";
import "./BookForm.css";

const BookForm = ({ book, onSubmit, onCancel }) => {
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    imageUrl: "",
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (book) {
      setFormData({
        title: book.title || "",
        description: book.description || "",
        imageUrl: book.imageUrl || "",
      });
    }
  }, [book]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));

    // 清除錯誤訊息
    if (errors[name]) {
      setErrors((prev) => ({
        ...prev,
        [name]: "",
      }));
    }
  };

  const handleImageUploaded = (imageUrl) => {
    setFormData((prev) => ({
      ...prev,
      imageUrl: imageUrl,
    }));

    // 清除圖片錯誤訊息
    if (errors.imageUrl) {
      setErrors((prev) => ({
        ...prev,
        imageUrl: "",
      }));
    }
  };

  const handleImageRemoved = () => {
    setFormData((prev) => ({
      ...prev,
      imageUrl: "",
    }));
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.title.trim()) {
      newErrors.title = "書名為必填項目";
    } else if (formData.title.length > 100) {
      newErrors.title = "書名不能超過100個字符";
    }

    if (formData.description && formData.description.length > 500) {
      newErrors.description = "描述不能超過500個字符";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (validateForm()) {
      setIsSubmitting(true);
      try {
        await onSubmit(formData);
      } catch (error) {
        console.error("Submit error:", error);
      } finally {
        setIsSubmitting(false);
      }
    }
  };

  return (
    <div className="book-form-overlay">
      <div className="book-form-container">
        <div className="book-form-header">
          <h2>{book ? "編輯書籍" : "新增書籍"}</h2>
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
              className={errors.title ? "error" : ""}
              placeholder="請輸入書籍名稱"
            />
            {errors.title && (
              <span className="error-message">{errors.title}</span>
            )}
          </div>

          <div className="form-group">
            <label htmlFor="description">書籍描述</label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleChange}
              className={errors.description ? "error" : ""}
              placeholder="請輸入書籍描述（選填）"
              rows={4}
            />
            {errors.description && (
              <span className="error-message">{errors.description}</span>
            )}
          </div>

          <div className="form-group">
            <label>書籍封面圖片</label>
            <ImageUpload
              currentImage={
                formData.imageUrl
                  ? "http://localhost:8000" + formData.imageUrl.slice(2)
                  : null
              }
              onImageUploaded={handleImageUploaded}
              onImageRemoved={handleImageRemoved}
            />
            {errors.imageUrl && (
              <span className="error-message">{errors.imageUrl}</span>
            )}
          </div>

          <div className="form-actions">
            <button
              type="button"
              className="btn btn-secondary"
              onClick={onCancel}
              disabled={isSubmitting}
            >
              取消
            </button>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={isSubmitting}
            >
              {isSubmitting ? "處理中..." : book ? "更新書籍" : "新增書籍"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default BookForm;

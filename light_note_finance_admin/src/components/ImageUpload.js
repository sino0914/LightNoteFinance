import React, { useState, useRef } from 'react';
import './ImageUpload.css';

const ImageUpload = ({ currentImage, onImageUploaded, onImageRemoved }) => {
  const [uploading, setUploading] = useState(false);
  const [dragOver, setDragOver] = useState(false);
  const [previewUrl, setPreviewUrl] = useState(currentImage || '');
  const fileInputRef = useRef(null);

  // 監聽currentImage的變化，更新預覽
  React.useEffect(() => {
    setPreviewUrl(currentImage || '');
  }, [currentImage]);

  const handleFileSelect = async (file) => {
    if (!file) return;

    // 檢查檔案類型
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      alert('只支援 JPG, PNG, GIF, WebP 格式的圖片');
      return;
    }

    // 檢查檔案大小，如果超過20MB就直接拒絕
    const maxOriginalSize = 20 * 1024 * 1024;
    if (file.size > maxOriginalSize) {
      alert('原始圖片大小不能超過 20MB');
      return;
    }

    try {
      const compressedFile = await compressImage(file);
      uploadImage(compressedFile);
    } catch (error) {
      console.error('圖片壓縮失敗:', error);
      alert('圖片處理失敗，請重試');
    }
  };

  // 圖片壓縮函數
  const compressImage = (file) => {
    return new Promise((resolve) => {
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      const img = new Image();

      img.onload = () => {
        // 計算新的尺寸 - 書籍封面比例約為 2:3
        const maxWidth = 600;  // 最大寬度
        const maxHeight = 900; // 最大高度，保持書籍比例

        let { width, height } = img;

        // 等比例縮放
        if (width > height) {
          // 橫向圖片，以寬度為準
          if (width > maxWidth) {
            height = (height * maxWidth) / width;
            width = maxWidth;
          }
        } else {
          // 縱向圖片，以高度為準
          if (height > maxHeight) {
            width = (width * maxHeight) / height;
            height = maxHeight;
          }
        }

        // 設置畫布尺寸
        canvas.width = width;
        canvas.height = height;

        // 繪製壓縮後的圖片
        ctx.drawImage(img, 0, 0, width, height);

        // 轉換為blob，JPEG格式，品質0.8
        canvas.toBlob((blob) => {
          // 創建新的File對象
          const compressedFile = new File([blob], file.name, {
            type: 'image/jpeg',
            lastModified: Date.now(),
          });

          console.log(`圖片壓縮完成: ${file.size} → ${compressedFile.size} bytes`);
          resolve(compressedFile);
        }, 'image/jpeg', 0.8);
      };

      // 讀取原圖片
      const reader = new FileReader();
      reader.onload = (e) => {
        img.src = e.target.result;
      };
      reader.readAsDataURL(file);
    });
  };

  const uploadImage = async (file) => {
    setUploading(true);
    const formData = new FormData();
    formData.append('image', file);

    try {
      const response = await fetch('http://localhost:3001/api/upload-image', {
        method: 'POST',
        body: formData,
      });

      const result = await response.json();

      if (result.success) {
        setPreviewUrl(result.imageUrl);
        onImageUploaded(result.imageUrl);
      } else {
        throw new Error(result.error || '上傳失敗');
      }
    } catch (error) {
      console.error('Upload error:', error);
      alert('圖片上傳失敗：' + error.message);
    } finally {
      setUploading(false);
    }
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    handleFileSelect(file);
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDragLeave = (e) => {
    e.preventDefault();
    setDragOver(false);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer.files[0];
    handleFileSelect(file);
  };

  const handleRemoveImage = () => {
    setPreviewUrl('');
    if (onImageRemoved) {
      onImageRemoved();
    }
    // 清空文件輸入
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleClick = () => {
    fileInputRef.current?.click();
  };

  return (
    <div className="image-upload-container">
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept="image/*"
        style={{ display: 'none' }}
      />

      <div
        className={`upload-area ${dragOver ? 'drag-over' : ''} ${uploading ? 'uploading' : ''}`}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        onClick={handleClick}
      >
        {previewUrl ? (
          <div className="image-preview">
            <img src={previewUrl} alt="書籍封面預覽" />
            <div className="image-overlay">
              <button
                type="button"
                className="btn btn-danger btn-sm remove-btn"
                onClick={(e) => {
                  e.stopPropagation();
                  handleRemoveImage();
                }}
              >
                移除圖片
              </button>
              <button
                type="button"
                className="btn btn-secondary btn-sm change-btn"
                onClick={(e) => {
                  e.stopPropagation();
                  handleClick();
                }}
              >
                更換圖片
              </button>
            </div>
          </div>
        ) : (
          <div className="upload-placeholder">
            {uploading ? (
              <div className="uploading-indicator">
                <div className="loading-spinner"></div>
                <p>上傳中...</p>
              </div>
            ) : (
              <>
                <div className="upload-icon">📁</div>
                <p className="upload-text">點擊或拖拽上傳書籍封面</p>
                <p className="upload-hint">支援 JPG, PNG, GIF, WebP，最大 5MB</p>
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default ImageUpload;
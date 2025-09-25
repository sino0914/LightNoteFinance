class ImageService {
  constructor() {
    this.serverUrl = 'http://localhost:3001';
  }

  // 檢查後端伺服器是否運行
  async checkServerHealth() {
    try {
      const response = await fetch(`${this.serverUrl}/api/health`);
      const result = await response.json();
      return result.status === 'OK';
    } catch (error) {
      console.error('Image server not running:', error);
      return false;
    }
  }

  // 上傳圖片
  async uploadImage(file) {
    try {
      const formData = new FormData();
      formData.append('image', file);

      const response = await fetch(`${this.serverUrl}/api/upload-image`, {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();

      if (result.success) {
        return {
          success: true,
          imageUrl: result.imageUrl,
          filename: result.filename
        };
      } else {
        throw new Error(result.error || '上傳失敗');
      }
    } catch (error) {
      console.error('Image upload error:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  // 刪除圖片
  async deleteImage(filename) {
    try {
      const response = await fetch(`${this.serverUrl}/api/delete-image/${filename}`, {
        method: 'DELETE',
      });

      const result = await response.json();

      if (result.success) {
        return {
          success: true,
          message: result.message
        };
      } else {
        throw new Error(result.error || '刪除失敗');
      }
    } catch (error) {
      console.error('Image delete error:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  // 從URL提取檔名
  getFilenameFromUrl(url) {
    if (!url) return null;

    try {
      const urlObj = new URL(url);
      const path = urlObj.pathname;
      return path.substring(path.lastIndexOf('/') + 1);
    } catch {
      return null;
    }
  }

  // 檢查是否為本地上傳的圖片
  isLocalImage(imageUrl) {
    return imageUrl && imageUrl.startsWith(this.serverUrl);
  }
}

export const imageService = new ImageService();
export default ImageService;
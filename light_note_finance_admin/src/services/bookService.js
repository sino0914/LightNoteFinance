
class BookService {
  constructor() {
    this.API_BASE_URL = 'http://localhost:8000/api';
  }

  async getAllBooks() {
    try {
      const response = await fetch(`${this.API_BASE_URL}/books`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const books = await response.json();
      return books || [];
    } catch (error) {
      console.error('Error fetching books:', error);
      return [];
    }
  }

  async getBookById(id) {
    try {
      const response = await fetch(`${this.API_BASE_URL}/books/${id}`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return await response.json();
    } catch (error) {
      console.error('Error fetching book:', error);
      return null;
    }
  }

  async addBook(title, description = '', imageUrl = '') {
    try {
      const bookData = {
        title,
        description,
        imageUrl,
        summaries: []
      };

      const response = await fetch(`${this.API_BASE_URL}/books`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(bookData)
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('Error adding book:', error);
      throw error;
    }
  }

  async updateBook(id, updates) {
    try {
      const response = await fetch(`${this.API_BASE_URL}/books/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(updates)
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('Error updating book:', error);
      throw error;
    }
  }

  async deleteBook(id) {
    try {
      const response = await fetch(`${this.API_BASE_URL}/books/${id}`, {
        method: 'DELETE'
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return true;
    } catch (error) {
      console.error('Error deleting book:', error);
      throw error;
    }
  }

  async toggleBookStatus(id) {
    try {
      const book = await this.getBookById(id);
      if (book) {
        // 適配 API 資料格式 - 使用 isPublished 欄位
        const currentStatus = book.isPublished !== undefined ? book.isPublished : true;
        const updateData = {
          isPublished: !currentStatus
        };
        return await this.updateBook(id, updateData);
      }
      return null;
    } catch (error) {
      console.error('Error toggling book status:', error);
      throw error;
    }
  }

  async addSummary(bookId, content, order = 1) {
    try {
      const summaryData = {
        content,
        order
      };

      const response = await fetch(`${this.API_BASE_URL}/summaries/book/${bookId}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(summaryData)
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('Error adding summary:', error);
      throw error;
    }
  }

  async deleteSummary(bookId, summaryId) {
    try {
      const response = await fetch(`${this.API_BASE_URL}/summaries/${bookId}/${summaryId}`, {
        method: 'DELETE'
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return true;
    } catch (error) {
      console.error('Error deleting summary:', error);
      throw error;
    }
  }

  async getSummariesByBookId(bookId) {
    try {
      const response = await fetch(`${this.API_BASE_URL}/summaries/book/${bookId}`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return await response.json();
    } catch (error) {
      console.error('Error fetching summaries:', error);
      return [];
    }
  }

  // 檢查API連接狀態
  async checkApiConnection() {
    try {
      const response = await fetch(`${this.API_BASE_URL}/health`);
      return response.ok;
    } catch (error) {
      console.error('API connection failed:', error);
      return false;
    }
  }
}

export const bookService = new BookService();
export default BookService;
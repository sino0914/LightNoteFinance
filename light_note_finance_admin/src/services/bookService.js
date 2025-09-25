import booksData from '../data/books.json';
import { createBook, createSummary, BookStatus } from '../types/book';

class BookService {
  constructor() {
    // 從JSON載入資料到localStorage（模擬資料庫）
    this.initializeData();
  }

  initializeData() {
    const existingData = localStorage.getItem('light_note_books');
    if (!existingData) {
      localStorage.setItem('light_note_books', JSON.stringify(booksData));
    }
  }

  getAllBooks() {
    const data = JSON.parse(localStorage.getItem('light_note_books') || '{"books": []}');
    return data.books;
  }

  getBookById(id) {
    const books = this.getAllBooks();
    return books.find(book => book.id === id);
  }

  addBook(title, image = '') {
    const books = this.getAllBooks();
    const newBook = createBook(title, image);
    books.push(newBook);
    this.saveBooks(books);
    return newBook;
  }

  updateBook(id, updates) {
    const books = this.getAllBooks();
    const bookIndex = books.findIndex(book => book.id === id);
    if (bookIndex !== -1) {
      books[bookIndex] = {
        ...books[bookIndex],
        ...updates,
        updatedAt: new Date().toISOString()
      };
      this.saveBooks(books);
      return books[bookIndex];
    }
    return null;
  }

  deleteBook(id) {
    const books = this.getAllBooks();
    const filteredBooks = books.filter(book => book.id !== id);
    this.saveBooks(filteredBooks);
    return true;
  }

  toggleBookStatus(id) {
    const book = this.getBookById(id);
    if (book) {
      const newStatus = book.status === BookStatus.ACTIVE ? BookStatus.INACTIVE : BookStatus.ACTIVE;
      return this.updateBook(id, { status: newStatus });
    }
    return null;
  }

  addSummary(bookId, content) {
    const book = this.getBookById(bookId);
    if (book) {
      const newSummary = createSummary(content);
      book.summaries.push(newSummary);
      this.updateBook(bookId, { summaries: book.summaries });
      return newSummary;
    }
    return null;
  }

  deleteSummary(bookId, summaryId) {
    const book = this.getBookById(bookId);
    if (book) {
      const filteredSummaries = book.summaries.filter(summary => summary.id !== summaryId);
      this.updateBook(bookId, { summaries: filteredSummaries });
      return true;
    }
    return false;
  }

  saveBooks(books) {
    const data = { books };
    localStorage.setItem('light_note_books', JSON.stringify(data));
  }

  // 為日後資料庫串接預留的方法
  async syncWithDatabase() {
    // TODO: 實作與線上資料庫同步的邏輯
    console.log('Database sync not implemented yet');
  }
}

export const bookService = new BookService();
export default BookService;
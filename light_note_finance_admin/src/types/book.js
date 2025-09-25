// 書籍資料類型定義
export const BookStatus = {
  ACTIVE: 'active',
  INACTIVE: 'inactive'
};

export const createBook = (title, image = '') => ({
  id: `book_${Date.now()}`,
  title,
  image,
  status: BookStatus.ACTIVE,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
  summaries: []
});

export const createSummary = (content) => ({
  id: `summary_${Date.now()}`,
  content,
  createdAt: new Date().toISOString()
});
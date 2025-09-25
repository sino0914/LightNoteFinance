const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3002;

// 設定CORS
app.use(cors());
app.use(express.json());

// 確保uploads目錄存在
const uploadsDir = path.join(__dirname, 'public', 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// 設定multer存儲配置
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    // 生成唯一檔名
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, `book-cover-${uniqueSuffix}${ext}`);
  }
});

// 檔案過濾器
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('只允許上傳圖片檔案！'));
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB限制（壓縮前）
  },
  fileFilter: fileFilter
});

// 提供靜態檔案服務
app.use('/uploads', express.static(path.join(__dirname, 'public', 'uploads')));

// 圖片上傳API
app.post('/api/upload-image', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: '沒有上傳檔案' });
    }

    const imageUrl = `/uploads/${req.file.filename}`;

    res.json({
      success: true,
      message: '圖片上傳成功',
      imageUrl: `http://localhost:${PORT}${imageUrl}`,
      filename: req.file.filename
    });
  } catch (error) {
    res.status(500).json({ error: '上傳失敗: ' + error.message });
  }
});

// 刪除圖片API
app.delete('/api/delete-image/:filename', (req, res) => {
  try {
    const filename = req.params.filename;
    const filePath = path.join(uploadsDir, filename);

    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
      res.json({ success: true, message: '圖片已刪除' });
    } else {
      res.status(404).json({ error: '圖片檔案不存在' });
    }
  } catch (error) {
    res.status(500).json({ error: '刪除失敗: ' + error.message });
  }
});

// 健康檢查
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: '圖片上傳伺服器運行中' });
});

const server = app.listen(PORT, () => {
  console.log(`圖片上傳伺服器運行在 http://localhost:${PORT}`);
  console.log(`上傳目錄: ${uploadsDir}`);
}).on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.log(`Port ${PORT} is busy, trying port ${PORT + 1}...`);
    const server2 = app.listen(PORT + 1, () => {
      console.log(`圖片上傳伺服器運行在 http://localhost:${PORT + 1}`);
      console.log(`上傳目錄: ${uploadsDir}`);
    });
  } else {
    console.error('Server error:', err);
  }
});
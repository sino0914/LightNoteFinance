import React from 'react';
import BookList from './components/BookList';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="app-header">
        <h1>Light Note Finance Admin</h1>
        <p>書籍管理系統</p>
      </header>

      <main className="app-main">
        <BookList />
      </main>
    </div>
  );
}

export default App;

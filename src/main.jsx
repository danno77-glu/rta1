import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './styles/global.css';
import './styles/print.css';

// Create root without StrictMode to avoid findDOMNode warnings with react-quill
ReactDOM.createRoot(document.getElementById('root')).render(
  <App />
);

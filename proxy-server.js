const http = require('http');
const httpProxy = require('http-proxy-middleware');
const express = require('express');

const app = express();

// Proxy API requests to /api
app.use('/api', httpProxy.createProxyMiddleware({
  target: 'http://127.0.0.1:8000',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // Remove /api prefix
  },
}));

// Proxy everything else to UI
app.use('/', httpProxy.createProxyMiddleware({
  target: 'http://127.0.0.1:5173',
  changeOrigin: true,
}));

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
  console.log('UI: / -> http://127.0.0.1:5173');
  console.log('API: /api -> http://127.0.0.1:8000');
});

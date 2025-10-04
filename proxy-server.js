const http = require('http');
const httpProxy = require('http-proxy-middleware');
const express = require('express');

const app = express();

// Proxy API requests to /api
app.use('/api', httpProxy.createProxyMiddleware({
  target: 'http://rhiza-api:8000',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // Remove /api prefix
  },
}));

// Proxy everything else to UI
app.use('/', httpProxy.createProxyMiddleware({
  target: 'http://rhiza-ui:8080',
  changeOrigin: true,
}));

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
  console.log('UI: / -> http://rhiza-ui:8080');
  console.log('API: /api -> http://rhiza-api:8000');
});

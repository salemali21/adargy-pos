# Adargy Backend API

Backend API for Adargy POS system built with Node.js and Express.

## 🚀 Quick Start

### Local Development
```bash
npm install
npm start
```

### Environment Variables
Create a `.env` file with:
```
PORT=5000
NODE_ENV=development
```

## 📡 API Endpoints

- `GET /` - Health check
- `GET /api/health` - Detailed health status
- `GET /api/customers` - Get customers
- `GET /api/products` - Get products
- `GET /api/invoices` - Get invoices

## 🚂 Railway Deployment

1. Push code to GitHub
2. Connect Railway to GitHub repo
3. Railway will auto-deploy

## 🔧 Tech Stack

- Node.js
- Express.js
- CORS
- dotenv 
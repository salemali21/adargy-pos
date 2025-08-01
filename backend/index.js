require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT || 5000;

// Middleware for error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

// Basic routes for testing
app.get('/', (req, res) => {
  res.json({ 
    message: 'Adargy Backend API is running',
    status: 'success',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Test data endpoints
app.get('/api/customers', (req, res) => {
  res.json([
    { id: 1, name: 'أحمد محمد', phone: '0123456789', type: 'customer' },
    { id: 2, name: 'فاطمة علي', phone: '0987654321', type: 'supplier' }
  ]);
});

app.get('/api/products', (req, res) => {
  res.json([
    { id: 1, name: 'منتج 1', price: 100, stock: 50 },
    { id: 2, name: 'منتج 2', price: 200, stock: 30 }
  ]);
});

app.get('/api/invoices', (req, res) => {
  res.json([
    { id: 1, customer: 'أحمد محمد', total: 500, date: '2024-01-15' },
    { id: 2, customer: 'فاطمة علي', total: 300, date: '2024-01-14' }
  ]);
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📱 API available at http://localhost:${PORT}`);
  console.log(`🔍 Health check at http://localhost:${PORT}/api/health`);
}); 
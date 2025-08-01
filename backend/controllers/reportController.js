const Invoice = require('../models/Invoice');
const Customer = require('../models/Customer');
const Product = require('../models/Product');

// تقرير المبيعات
exports.salesReport = async (req, res) => {
  try {
    const invoices = await Invoice.find();
    const totalSales = invoices.reduce((sum, i) => sum + i.total, 0);
    res.json({ totalSales, count: invoices.length });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// تقرير الأرباح (تقديري: 20% من كل فاتورة)
exports.profitReport = async (req, res) => {
  try {
    const invoices = await Invoice.find();
    const totalProfit = invoices.reduce((sum, i) => sum + i.total * 0.2, 0);
    res.json({ totalProfit });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// تقرير العملاء
exports.customersReport = async (req, res) => {
  try {
    const customers = await Customer.find();
    res.json({ count: customers.length, customers });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// تقرير المخزون
exports.inventoryReport = async (req, res) => {
  try {
    const products = await Product.find();
    const lowStock = products.filter(p => p.quantity <= p.alertThreshold);
    res.json({ total: products.length, lowStock: lowStock.length, products });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// تقرير الولاء (نقاط العملاء)
exports.loyaltyReport = async (req, res) => {
  try {
    const customers = await Customer.find();
    const totalPoints = customers.reduce((sum, c) => sum + (c.loyaltyPoints || 0), 0);
    res.json({ totalPoints, customers });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}; 
const User = require('../models/User');
const Customer = require('../models/Customer');
const Product = require('../models/Product');
const Invoice = require('../models/Invoice');
const Order = require('../models/Order');

exports.summary = async (req, res) => {
  try {
    const [users, customers, products, invoices, orders] = await Promise.all([
      User.countDocuments(),
      Customer.countDocuments(),
      Product.countDocuments(),
      Invoice.find(),
      Order.countDocuments()
    ]);
    const totalSales = invoices.reduce((sum, i) => sum + i.total, 0);
    res.json({
      users,
      customers,
      products,
      invoices: invoices.length,
      orders,
      totalSales
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}; 
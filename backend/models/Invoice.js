const mongoose = require('mongoose');

const invoiceItemSchema = new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  quantity: { type: Number, required: true }
}, { _id: false });

const invoiceSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  date: { type: Date, default: Date.now },
  customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer' },
  customerName: { type: String },
  items: [invoiceItemSchema],
  total: { type: Number, required: true },
  paymentMethod: { type: String, enum: ['cash', 'card', 'other'], default: 'cash' },
  notes: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Invoice', invoiceSchema); 
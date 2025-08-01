const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  name: { type: String, required: true },
  quantity: { type: Number, required: true }
}, { _id: false });

const orderSchema = new mongoose.Schema({
  orderNumber: { type: String, required: true, unique: true },
  date: { type: Date, default: Date.now },
  items: [orderItemSchema],
  status: { type: String, enum: ['pending', 'in_progress', 'done', 'cancelled'], default: 'pending' },
  notes: { type: String },
  table: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema); 
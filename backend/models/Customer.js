const mongoose = require('mongoose');

const customerSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String },
  address: { type: String },
  type: { type: String, enum: ['customer', 'supplier'], default: 'customer' },
  loyaltyPoints: { type: Number, default: 0 },
  notes: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Customer', customerSchema); 
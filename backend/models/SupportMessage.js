const mongoose = require('mongoose');

const supportMessageSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true },
  message: { type: String, required: true },
  status: { type: String, enum: ['open', 'closed'], default: 'open' },
  reply: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('SupportMessage', supportMessageSchema); 
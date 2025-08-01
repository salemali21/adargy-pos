const mongoose = require('mongoose');

const settingSchema = new mongoose.Schema({
  companyName: { type: String, default: 'Adargy' },
  currency: { type: String, default: 'EGP' },
  defaultLanguage: { type: String, default: 'ar' },
  logoUrl: { type: String },
  contactEmail: { type: String },
  contactPhone: { type: String },
  other: { type: Object, default: {} }
}, { timestamps: true });

module.exports = mongoose.model('Setting', settingSchema); 
const SupportMessage = require('../models/SupportMessage');

// Get all support messages
exports.getAllMessages = async (req, res) => {
  try {
    const messages = await SupportMessage.find();
    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get message by ID
exports.getMessageById = async (req, res) => {
  try {
    const message = await SupportMessage.findById(req.params.id);
    if (!message) return res.status(404).json({ error: 'Message not found' });
    res.json(message);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Create new support message
exports.createMessage = async (req, res) => {
  try {
    const message = new SupportMessage(req.body);
    await message.save();
    res.status(201).json(message);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Update support message
exports.updateMessage = async (req, res) => {
  try {
    const message = await SupportMessage.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!message) return res.status(404).json({ error: 'Message not found' });
    res.json(message);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Delete support message
exports.deleteMessage = async (req, res) => {
  try {
    const message = await SupportMessage.findByIdAndDelete(req.params.id);
    if (!message) return res.status(404).json({ error: 'Message not found' });
    res.json({ message: 'Support message deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}; 
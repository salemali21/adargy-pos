const express = require('express');
const router = express.Router();
const supportController = require('../controllers/supportController');

router.get('/', supportController.getAllMessages);
router.get('/:id', supportController.getMessageById);
router.post('/', supportController.createMessage);
router.put('/:id', supportController.updateMessage);
router.delete('/:id', supportController.deleteMessage);

module.exports = router; 
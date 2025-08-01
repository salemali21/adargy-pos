const express = require('express');
const router = express.Router();
const languageController = require('../controllers/languageController');

router.get('/:lang', languageController.getTranslation);

module.exports = router; 
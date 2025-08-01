const fs = require('fs');
const path = require('path');

// Get translation file by language code
exports.getTranslation = (req, res) => {
  const lang = req.params.lang;
  const filePath = path.join(__dirname, '../../assets/translations', `${lang}.json`);
  fs.readFile(filePath, 'utf8', (err, data) => {
    if (err) {
      return res.status(404).json({ error: 'Translation file not found' });
    }
    try {
      const json = JSON.parse(data);
      res.json(json);
    } catch (e) {
      res.status(500).json({ error: 'Invalid translation file format' });
    }
  });
}; 
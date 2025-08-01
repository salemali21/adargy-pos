const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');

router.get('/sales', reportController.salesReport);
router.get('/profit', reportController.profitReport);
router.get('/customers', reportController.customersReport);
router.get('/inventory', reportController.inventoryReport);
router.get('/loyalty', reportController.loyaltyReport);

module.exports = router; 
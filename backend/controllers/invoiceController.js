const Invoice = require('../models/Invoice');

// Get all invoices
exports.getAllInvoices = async (req, res) => {
  try {
    const invoices = await Invoice.find().sort({ createdAt: -1 });
    res.json(invoices);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch invoices', details: err.message });
  }
};

// Get invoice by ID
exports.getInvoiceById = async (req, res) => {
  try {
    const invoice = await Invoice.findById(req.params.id);
    if (!invoice) return res.status(404).json({ error: 'Invoice not found' });
    res.json(invoice);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch invoice', details: err.message });
  }
};

// Create new invoice
exports.createInvoice = async (req, res) => {
  try {
    const invoice = new Invoice(req.body);
    await invoice.save();
    res.status(201).json(invoice);
  } catch (err) {
    res.status(400).json({ error: 'Failed to create invoice', details: err.message });
  }
};

// Update invoice
exports.updateInvoice = async (req, res) => {
  try {
    const invoice = await Invoice.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!invoice) return res.status(404).json({ error: 'Invoice not found' });
    res.json(invoice);
  } catch (err) {
    res.status(400).json({ error: 'Failed to update invoice', details: err.message });
  }
};

// Delete invoice
exports.deleteInvoice = async (req, res) => {
  try {
    const invoice = await Invoice.findByIdAndDelete(req.params.id);
    if (!invoice) return res.status(404).json({ error: 'Invoice not found' });
    res.json({ message: 'Invoice deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete invoice', details: err.message });
  }
};

// Fill backend with real-like dummy invoices
exports.fillDummyInvoices = async (req, res) => {
  try {
    const dummyInvoices = [
      {
        id: '1001',
        date: new Date(Date.now() - 86400000 * 2),
        customerId: '664a1b2c3d4e5f6a7b8c9d01',
        customerName: 'أحمد علي',
        items: [
          { productId: '664a1b2c3d4e5f6a7b8c9d11', name: 'تيشيرت رجالي قطن', price: 150, quantity: 2 },
          { productId: '664a1b2c3d4e5f6a7b8c9d12', name: 'كوتشي رياضي رجالي', price: 400, quantity: 1 },
        ],
        total: 700,
        discount: 50,
        tax: 20,
        paymentMethod: 'cash',
        notes: 'فاتورة بيع ملابس رجالي',
      },
      {
        id: '1002',
        date: new Date(Date.now() - 86400000),
        customerId: '664a1b2c3d4e5f6a7b8c9d02',
        customerName: 'منى محمد',
        items: [
          { productId: '664a1b2c3d4e5f6a7b8c9d13', name: 'بنطلون جينز', price: 250, quantity: 1 },
          { productId: '664a1b2c3d4e5f6a7b8c9d14', name: 'كوتشي نسائي أبيض', price: 350, quantity: 2 },
        ],
        total: 950,
        discount: 0,
        tax: 30,
        paymentMethod: 'visa',
        notes: 'فاتورة بيع ملابس وكوتشيات',
      },
      {
        id: '1003',
        date: new Date(),
        customerId: '664a1b2c3d4e5f6a7b8c9d03',
        customerName: 'محمد سمير',
        items: [
          { productId: '664a1b2c3d4e5f6a7b8c9d15', name: 'فستان سواريه', price: 1200, quantity: 1 },
        ],
        total: 1200,
        discount: 100,
        tax: 50,
        paymentMethod: 'cash',
        notes: 'فاتورة بيع فساتين',
      },
      // بيانات جديدة متنوعة
      {
        id: '1004',
        date: new Date(Date.now() - 86400000 * 3),
        customerId: '664a1b2c3d4e5f6a7b8c9d04',
        customerName: 'سارة إبراهيم',
        items: [
          { productId: '664a1b2c3d4e5f6a7b8c9d16', name: 'لاب توب HP', price: 8500, quantity: 1 },
        ],
        total: 8500,
        discount: 200,
        tax: 150,
        paymentMethod: 'online',
        notes: 'فاتورة بيع أجهزة إلكترونية',
      },
      {
        id: '1005',
        date: new Date(Date.now() - 86400000 * 4),
        customerId: '664a1b2c3d4e5f6a7b8c9d05',
        customerName: 'محمود يوسف',
        items: [
          { productId: '664a1b2c3d4e5f6a7b8c9d17', name: 'وجبة برجر', price: 80, quantity: 2 },
          { productId: '664a1b2c3d4e5f6a7b8c9d18', name: 'بطاطس مقلية', price: 25, quantity: 2 },
        ],
        total: 210,
        discount: 10,
        tax: 5,
        paymentMethod: 'cash',
        notes: 'فاتورة مطعم',
      },
      {
        id: '1006',
        date: new Date(Date.now() - 86400000 * 5),
        customerId: '664a1b2c3d4e5f6a7b8c9d06',
        customerName: 'هالة عبد الله',
        items: [
          { productId: '664a1b2c3d4e5f6a7b8c9d19', name: 'حذاء طبي نسائي', price: 600, quantity: 1 },
        ],
        total: 600,
        discount: 0,
        tax: 20,
        paymentMethod: 'visa',
        notes: 'فاتورة أحذية طبية',
      },
      {
        id: '1007',
        date: new Date(Date.now() - 86400000 * 6),
        customerId: '664a1b2c3d4e5f6a7b8c9d07',
        customerName: 'يوسف أحمد',
        items: [
          { productId: '664a1b2c3d4e5f6a7b8c9d20', name: 'موبايل سامسونج', price: 4200, quantity: 1 },
        ],
        total: 4200,
        discount: 100,
        tax: 80,
        paymentMethod: 'transfer',
        notes: 'فاتورة بيع موبايلات',
      },
    ];
    await Invoice.insertMany(dummyInvoices);
    res.status(201).json({ message: 'تم إدخال فواتير تجريبية واقعية بنجاح!' });
  } catch (err) {
    res.status(500).json({ error: 'فشل في إدخال الفواتير التجريبية', details: err.message });
  }
}; 
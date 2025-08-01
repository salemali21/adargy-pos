# 🚀 ربط Adargy بالكامل - دليل شامل

## 📋 ما تم إعداده

### ✅ **الباك اند (Node.js + Express)**
- API endpoints جاهزة
- تكوين Vercel للنشر المجاني
- تكوين Render كبديل
- تكوين Railway كبديل
- Health check endpoint

### ✅ **الفلتر (Flutter)**
- تكوين API مركزي
- جميع BLoCs مرتبطة بالباك اند
- Fallback للـ local storage
- Navigation bar في كل الشاشات

### ✅ **النشر**
- GitHub repository جاهز
- ملفات تكوين لجميع المنصات
- تعليمات مفصلة للنشر

## 🔗 **الروابط المهمة**

### **GitHub Repository:**
```
https://github.com/salemali21/adargy-pos
```

### **الباك اند المحلي:**
```
http://localhost:5000
```

### **API Endpoints المحلية:**
- Health: `http://localhost:5000/api/health`
- Customers: `http://localhost:5000/api/customers`
- Products: `http://localhost:5000/api/products`
- Invoices: `http://localhost:5000/api/invoices`

## 🚀 **خطوات التشغيل**

### 1. **تشغيل الباك اند محلياً:**
```bash
cd backend
npm install
npm start
```

### 2. **تشغيل الفلتر:**
```bash
flutter pub get
flutter run
```

### 3. **اختبار الاتصال:**
- افتح التطبيق
- اذهب لأي شاشة (العملاء، المنتجات، الفواتير)
- البيانات ستُحمل من الباك اند

## 🌐 **النشر على السيرفر**

### **الخيار الأول: Vercel (مجاني 100%)**
1. اذهب إلى [vercel.com](https://vercel.com)
2. سجل حساب جديد
3. اربط GitHub repository
4. اضغط "Deploy"
5. احصل على الرابط: `https://adargy-pos.vercel.app`

### **الخيار الثاني: Render (750 ساعة مجانية)**
1. اذهب إلى [render.com](https://render.com)
2. سجل حساب جديد
3. اربط GitHub repository
4. اضغط "Deploy"
5. احصل على الرابط: `https://adargy-backend.onrender.com`

### **الخيار الثالث: Railway (500 ساعة مجانية)**
1. اذهب إلى [railway.app](https://railway.app)
2. سجل حساب جديد
3. اربط GitHub repository
4. اضغط "Deploy"
5. احصل على الرابط: `https://adargy-pos-production-xxxx.up.railway.app`

## 🔄 **تحديث رابط الباك اند**

بعد الحصول على رابط السيرفر، حدث ملف `lib/core/config/api_config.dart`:

```dart
// غير هذا
static const String baseUrl = localBaseUrl;

// إلى هذا
static const String baseUrl = productionBaseUrl;
```

## 📱 **مميزات التطبيق**

### **الشاشات المتاحة:**
1. **العملاء والموردين** - إدارة العملاء والموردين
2. **المنتجات** - إدارة المخزون والمنتجات
3. **البيع** - إنشاء فواتير جديدة
4. **الفواتير** - عرض وإدارة الفواتير
5. **المخزون** - مراقبة المخزون
6. **التقارير** - تقارير المبيعات والأرباح
7. **الدعم** - التواصل مع الدعم الفني
8. **الإعدادات** - إعدادات التطبيق

### **المميزات:**
- **دعم متعدد اللغات** (عربي، إنجليزي، فرنسي، تركي)
- **وضع مظلم/فاتح**
- **حفظ محلي** للبيانات
- **مزامنة مع السيرفر**
- **تصدير التقارير**
- **إشعارات المخزون**

## 🛠️ **حل المشاكل**

### **مشكلة الاتصال بالباك اند:**
1. تأكد من تشغيل الباك اند: `npm start`
2. تحقق من الرابط في `api_config.dart`
3. تأكد من أن PORT = 5000

### **مشكلة النشر:**
1. تحقق من Build Logs
2. تأكد من متغيرات البيئة
3. تحقق من ملفات التكوين

### **مشكلة الفلتر:**
1. امسح الكاش: `flutter clean`
2. أعد تثبيت dependencies: `flutter pub get`
3. أعد البناء: `flutter run`

## 📞 **الدعم**

إذا واجهت أي مشاكل:
1. تحقق من ملفات التكوين
2. راجع Build Logs
3. تأكد من صحة الروابط
4. تحقق من متغيرات البيئة

## 🎉 **النتيجة النهائية**

بعد اتباع هذه الخطوات، ستحصل على:
- **تطبيق Flutter** يعمل على الهاتف
- **باك اند Node.js** يعمل على السيرفر
- **مزامنة البيانات** بين التطبيق والسيرفر
- **نظام POS كامل** جاهز للاستخدام

**كل شيء مرتبط ومتصل! 🚀** 
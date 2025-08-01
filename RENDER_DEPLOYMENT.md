# 🚀 نشر Adargy على Render

## 📋 المتطلبات
- حساب GitHub
- حساب Render (مجاني)

## 🚀 خطوات النشر

### 1. رفع الكود على GitHub
```bash
git add .
git commit -m "Add Render deployment configuration"
git push
```

### 2. إنشاء حساب Render
1. اذهب إلى [render.com](https://render.com)
2. سجل حساب جديد (استخدم GitHub)
3. احصل على 750 ساعة مجانية شهرياً

### 3. إنشاء Web Service
1. اضغط "New +"
2. اختر "Web Service"
3. اربط GitHub repository
4. ابحث عن `salemali21/adargy-pos`
5. اضغط "Connect"

### 4. تكوين الخدمة
- **Name**: `adargy-backend`
- **Environment**: `Node`
- **Region**: اختر الأقرب لك
- **Branch**: `main`
- **Root Directory**: `backend`
- **Build Command**: `npm install`
- **Start Command**: `npm start`

### 5. متغيرات البيئة
أضف هذه المتغيرات:
```
NODE_ENV=production
PORT=10000
```

### 6. النشر
- اضغط "Create Web Service"
- Render سيبني ويشغل التطبيق تلقائياً

### 7. الحصول على الرابط
- بعد النشر، ستحصل على رابط مثل:
  `https://adargy-backend.onrender.com`

## 🔧 اختبار الباك اند
```bash
# اختبار Health Check
curl https://adargy-backend.onrender.com/api/health

# اختبار العملاء
curl https://adargy-backend.onrender.com/api/customers

# اختبار المنتجات
curl https://adargy-backend.onrender.com/api/products
```

## 🔗 تحديث الفلتر
في ملف `lib/core/config/api_config.dart`:
```dart
// غير هذا
static const String productionBaseUrl = 'https://your-app-name.railway.app';

// إلى الرابط الحقيقي
static const String productionBaseUrl = 'https://adargy-backend.onrender.com';
```

## 💡 مميزات Render
- **750 ساعة مجانية** شهرياً
- **SSL مجاني** تلقائياً
- **Auto-deploy** عند كل push
- **Health checks** تلقائية
- **Logs** مفصلة
- **Custom domains** مدعومة

## 🆘 حل المشاكل
- تحقق من Build Logs في Render Dashboard
- تأكد من أن PORT متغير بيئي
- تحقق من أن جميع dependencies مثبتة
- تأكد من أن Start Command صحيح

## 📱 تشغيل الفلتر
```bash
flutter run
``` 
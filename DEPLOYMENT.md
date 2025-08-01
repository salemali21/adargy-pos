# 🚂 نشر Adargy على Railway

## 📋 المتطلبات
- حساب GitHub
- حساب Railway (مجاني)

## 🚀 خطوات النشر

### 1. رفع الكود على GitHub
```bash
git add .
git commit -m "Add Railway deployment config"
git push origin main
```

### 2. إنشاء حساب Railway
1. اذهب إلى [railway.app](https://railway.app)
2. سجل حساب جديد (استخدم GitHub)
3. احصل على $5 رصيد مجاني

### 3. إنشاء مشروع جديد
1. اضغط "New Project"
2. اختر "Deploy from GitHub repo"
3. ابحث عن repository الخاص بك
4. اضغط "Deploy Now"

### 4. تكوين المتغيرات البيئية
في Railway Dashboard:
- اذهب إلى Variables tab
- أضف:
  ```
  NODE_ENV=production
  ```

### 5. الحصول على رابط التطبيق
- بعد النشر، ستحصل على رابط مثل:
  `https://your-app-name.railway.app`

### 6. تحديث رابط الباك اند في الفلتر
في ملف `lib/core/config/api_config.dart`:
```dart
// غير هذا
static const String productionBaseUrl = 'https://your-app-name.railway.app';

// إلى الرابط الحقيقي
static const String productionBaseUrl = 'https://your-actual-app-name.railway.app';
```

### 7. تبديل إلى Production
في نفس الملف:
```dart
// غير هذا
static const String baseUrl = localBaseUrl;

// إلى هذا
static const String baseUrl = productionBaseUrl;
```

## 🔧 اختبار الباك اند
```bash
# اختبار Health Check
curl https://your-app-name.railway.app/api/health

# اختبار العملاء
curl https://your-app-name.railway.app/api/customers

# اختبار المنتجات
curl https://your-app-name.railway.app/api/products
```

## 📱 تشغيل الفلتر
```bash
flutter run
```

## 💡 نصائح
- Railway يعطي 500 ساعة مجانية شهرياً
- يمكنك ربط MongoDB Atlas لاحقاً
- SSL مجاني تلقائياً
- Auto-deploy عند كل push للـ GitHub

## 🆘 حل المشاكل
- تأكد من أن PORT متغير بيئي في Railway
- تحقق من logs في Railway Dashboard
- تأكد من أن جميع dependencies مثبتة 
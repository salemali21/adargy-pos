# 🚀 نشر Adargy على Vercel (مجاني 100%)

## 📋 المتطلبات
- حساب GitHub
- حساب Vercel (مجاني)

## 🚀 خطوات النشر

### 1. رفع الكود على GitHub
```bash
git add .
git commit -m "Add Vercel deployment configuration"
git push
```

### 2. إنشاء حساب Vercel
1. اذهب إلى [vercel.com](https://vercel.com)
2. سجل حساب جديد (استخدم GitHub)
3. مجاني 100% للباك اند

### 3. إنشاء مشروع جديد
1. اضغط "New Project"
2. اربط GitHub repository
3. ابحث عن `salemali21/adargy-pos`
4. اضغط "Import"

### 4. تكوين المشروع
- **Framework Preset**: `Node.js`
- **Root Directory**: `backend`
- **Build Command**: `npm install`
- **Output Directory**: `./`
- **Install Command**: `npm install`

### 5. متغيرات البيئة
أضف هذه المتغيرات:
```
NODE_ENV=production
```

### 6. النشر
- اضغط "Deploy"
- Vercel سيبني ويشغل التطبيق تلقائياً

### 7. الحصول على الرابط
- بعد النشر، ستحصل على رابط مثل:
  `https://adargy-pos.vercel.app`

## 🔧 اختبار الباك اند
```bash
# اختبار Health Check
curl https://adargy-pos.vercel.app/api/health

# اختبار العملاء
curl https://adargy-pos.vercel.app/api/customers

# اختبار المنتجات
curl https://adargy-pos.vercel.app/api/products
```

## 🔗 تحديث الفلتر
في ملف `lib/core/config/api_config.dart`:
```dart
// غير هذا
static const String productionBaseUrl = 'https://your-app-name.railway.app';

// إلى الرابط الحقيقي
static const String productionBaseUrl = 'https://adargy-pos.vercel.app';
```

## 💡 مميزات Vercel
- **مجاني 100%** للباك اند
- **SSL مجاني** تلقائياً
- **Auto-deploy** عند كل push
- **Edge Network** سريع جداً
- **Logs** مفصلة
- **Custom domains** مدعومة
- **Serverless Functions** مدعومة

## 🆘 حل المشاكل
- تحقق من Build Logs في Vercel Dashboard
- تأكد من أن جميع dependencies مثبتة
- تحقق من أن vercel.json صحيح
- تأكد من أن Routes صحيحة

## 📱 تشغيل الفلتر
```bash
flutter run
```

## 🎯 لماذا Vercel؟
- **مجاني تماماً** - لا حدود على الاستخدام
- **سريع جداً** - Edge Network
- **سهل الاستخدام** - واجهة بسيطة
- **دعم ممتاز** - مجتمع كبير
- **Auto-deploy** - تلقائي عند كل push 
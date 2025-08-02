# 🚀 ربط Adargy بـ Vercel

## الخطوات المطلوبة:

### 1. إنشاء حساب Vercel
- اذهب إلى [vercel.com](https://vercel.com)
- سجل حساب جديد أو سجل دخول بـ GitHub

### 2. ربط المشروع
```bash
# تثبيت Vercel CLI
npm i -g vercel

# تسجيل الدخول
vercel login

# ربط المشروع
vercel
```

### 3. إعداد متغيرات البيئة
في لوحة تحكم Vercel:
1. اذهب إلى مشروعك
2. Settings → Environment Variables
3. أضف:
   - **Key:** `MONGODB_URI`
   - **Value:** رابط MongoDB Atlas
   - **Environments:** Production, Preview, Development

### 4. رابط MongoDB Atlas
```
mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/adargy?retryWrites=true&w=majority
```

### 5. تحديث Flutter App
في `lib/core/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'https://your-app.vercel.app/api';
  // أو
  static const String baseUrl = 'https://your-app.vercel.app';
}
```

### 6. اختبار API
```bash
# اختبار الصحة
curl https://your-app.vercel.app/api/health

# اختبار العملاء
curl https://your-app.vercel.app/api/customers

# اختبار المنتجات
curl https://your-app.vercel.app/api/products
```

### 7. النشر التلقائي
- كل push للـ main branch هيتم النشر تلقائياً
- يمكنك إعداد custom domains
- SSL مجاني تلقائياً

## مميزات Vercel:
✅ **نشر سريع** - أقل من دقيقة  
✅ **SSL مجاني** - HTTPS تلقائياً  
✅ **CDN عالمي** - سرعة عالية  
✅ **نشر تلقائي** - من GitHub  
✅ **مقياس تلقائي** - حسب الطلب  
✅ **لوحة تحكم ممتازة** - إحصائيات مفصلة  

## استكشاف الأخطاء:
- تأكد من صحة رابط MongoDB
- تحقق من Environment Variables
- راجع Vercel logs في لوحة التحكم
- تأكد من أن API يعمل محلياً أولاً

## الدعم:
- [Vercel Docs](https://vercel.com/docs)
- [Vercel Discord](https://discord.gg/vercel)
- [GitHub Issues](https://github.com/vercel/vercel/issues) 
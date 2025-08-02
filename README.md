# 🚀 Adargy - نظام إدارة المشاريع الصغيرة والمتوسطة

## 📱 تطبيق Flutter مع Node.js Backend على Vercel

### ✨ المميزات
- 🎯 **واجهة عربية كاملة** مع دعم RTL
- 📊 **لوحة تحكم تفاعلية** مع رسوم بيانية
- 👥 **إدارة العملاء** والموردين
- 📦 **إدارة المخزون** والمنتجات
- 🧾 **نظام الفواتير** المتقدم
- 📈 **تقارير مفصلة** وإحصائيات
- 🔐 **حماية بالبصمة** (Biometric)
- 🌍 **دعم متعدد اللغات** (عربي، إنجليزي، فرنسي، تركي)
- ☁️ **Backend على Vercel** مع MongoDB Atlas

### 🛠️ التقنيات المستخدمة
- **Frontend:** Flutter 3.x
- **Backend:** Node.js + Express
- **Database:** MongoDB Atlas
- **Deployment:** Vercel (Backend) + Google Play (Mobile)
- **State Management:** Flutter BLoC
- **UI:** Material Design 3

### 🚀 النشر السريع

#### Backend على Vercel:
```bash
# 1. رفع الكود على GitHub
git add .
git commit -m "Deploy to Vercel"
git push

# 2. ربط بـ Vercel
npm i -g vercel
vercel login
vercel

# 3. إضافة متغيرات البيئة
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/adargy
```

#### Mobile App:
```bash
# بناء APK مضغوط
flutter build apk --release --split-per-abi

# النتيجة: 3 ملفات APK (18-22 ميجا لكل منها)
# - app-armeabi-v7a-release.apk (18.6MB)
# - app-arm64-v8a-release.apk (20.7MB)
# - app-x86_64-release.apk (21.8MB)
```

### 📱 دعم الأجهزة
- **Android:** 6.0+ (API 23+)
- **iOS:** 12.0+
- **Web:** جميع المتصفحات الحديثة
- **Desktop:** Windows, macOS, Linux

### 🔧 التثبيت المحلي

#### Backend:
```bash
cd backend
npm install
npm run dev
```

#### Flutter App:
```bash
flutter pub get
flutter run
```

### 📊 API Endpoints
- `GET /api/health` - فحص صحة الخادم
- `GET /api/customers` - قائمة العملاء
- `POST /api/customers` - إضافة عميل جديد
- `GET /api/products` - قائمة المنتجات
- `POST /api/products` - إضافة منتج جديد
- `GET /api/invoices` - قائمة الفواتير
- `POST /api/invoices` - إنشاء فاتورة جديدة

### 🌐 الروابط
- **Backend API:** https://adargy-pos.vercel.app
- **Health Check:** https://adargy-pos.vercel.app/api/health
- **GitHub:** https://github.com/salemali21/adargy-pos

### 📈 الإحصائيات
- **حجم APK:** 18-22 ميجا (مقسم حسب المعمارية)
- **وقت النشر:** أقل من دقيقة على Vercel
- **دعم اللغات:** 4 لغات
- **المعماريات المدعومة:** ARM64, ARMv7, x86_64

### 🎯 لماذا Adargy؟
- ✅ **مجاني 100%** - لا تكاليف خفية
- ✅ **سهل الاستخدام** - واجهة بديهية
- ✅ **آمن** - حماية بالبصمة
- ✅ **سريع** - أداء محسن
- ✅ **متوافق** - يعمل على كل الأجهزة
- ✅ **قابل للتوسع** - ينمو مع مشروعك

### 🤝 المساهمة
نرحب بمساهماتكم! يرجى:
1. Fork المشروع
2. إنشاء branch جديد
3. إضافة التحديثات
4. إنشاء Pull Request

### 📄 الترخيص
MIT License - حر للاستخدام التجاري والشخصي

### 📞 الدعم
- **Email:** support@adargy.com
- **GitHub Issues:** https://github.com/salemali21/adargy-pos/issues
- **Documentation:** https://adargy-pos.vercel.app/docs

---

**Made with ❤️ by Salem Ali**

# 🚀 إعداد MongoDB في Vercel - خطوة بخطوة

## 📋 **الخطوات في Vercel Dashboard:**

### **الخطوة 1: إنشاء MongoDB Atlas**
1. اذهب إلى [MongoDB Atlas](https://www.mongodb.com/atlas)
2. اضغط "Try Free"
3. سجل حساب جديد
4. اختر "Shared" (مجاني)
5. اتبع الخطوات حتى تحصل على رابط الاتصال

### **الخطوة 2: في Vercel Dashboard**
1. اذهب إلى [Vercel Dashboard](https://vercel.com/dashboard)
2. اختر مشروعك `adargy-pos`
3. اضغط على **"Settings"** (الإعدادات)
4. اذهب إلى **"Environment Variables"** (متغيرات البيئة)

### **الخطوة 3: إضافة متغير البيئة**
1. اضغط **"Add New"** (إضافة جديد)
2. املأ الحقول:
   - **Name:** `MONGODB_URI`
   - **Value:** رابط MongoDB Atlas (مثال أدناه)
   - **Environment:** Production
3. اضغط **"Save"**

### **الخطوة 4: مثال رابط MongoDB Atlas**
```
mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/adargy?retryWrites=true&w=majority
```

### **الخطوة 5: إعادة النشر**
1. اذهب إلى **"Deployments"**
2. اضغط على **"Redeploy"** (إعادة النشر)
3. انتظر حتى ينتهي النشر

## ✅ **بعد الإعداد:**
- ✅ البيانات ستُحفظ في قاعدة بيانات حقيقية
- ✅ لن تختفي عند إعادة تشغيل السيرفر
- ✅ يمكن مشاركتها بين المستخدمين

## 🔍 **للتأكد من أن كل شيء يعمل:**
1. اذهب إلى رابط API: `https://your-app.vercel.app/api/health`
2. يجب أن ترى: `"database": "connected"`

## 📞 **إذا واجهت مشكلة:**
أخبرني بالضبط في أي خطوة واجهت مشكلة وسأساعدك! 
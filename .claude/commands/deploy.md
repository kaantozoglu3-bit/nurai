# /deploy

Nurai projesini test et, build al ve deploy et. Her adımda hata varsa dur ve raporla.

## Adımlar

### 1. Pre-deploy Testleri
```bash
# Flutter analiz
cd C:\Users\KULLANICI\Desktop\fizyoterapi\mobile
flutter analyze --no-pub

# Backend syntax kontrolü
cd C:\Users\KULLANICI\Desktop\fizyoterapi\backend
node --check server.js
```

Hata varsa → deploy'u durdur, hataları listele, düzeltilmesini iste.

---

### 2. Backend Deploy (Railway)
```bash
cd C:\Users\KULLANICI\Desktop\fizyoterapi\backend

# Railway CLI ile deploy
railway up

# Deploy başarılı mı kontrol et
railway status
```

Deploy URL'ini al ve kaydet.

---

### 3. Flutter'da Backend URL'ini Güncelle
Backend URL değiştiyse Flutter'daki API base URL'ini güncelle:
```dart
// mobile/lib/data/services/api_service.dart
static String get baseUrl => 'https://[yeni-railway-url].up.railway.app';
```

---

### 4. Android APK Build
```bash
cd C:\Users\KULLANICI\Desktop\fizyoterapi\mobile
flutter build apk --release
```

Build çıktısı: `build/app/outputs/flutter-apk/app-release.apk`

---

### 5. iOS Build (opsiyonel — Mac gerektirir)
```bash
flutter build ios --release
```

---

### 6. Deploy Doğrulama
```bash
# Backend sağlık kontrolü
curl https://[railway-url].up.railway.app/health

# Chat endpoint testi
curl -X POST https://[railway-url].up.railway.app/api/v1/analysis/chat-sync \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer [token]" \
  -d '{"profile": {}, "bodyArea": "neck", "messages": [{"role": "user", "content": "test"}]}'
```

---

### 7. Deploy Raporu

```
✅ Deploy Tamamlandı

Backend:
  URL: https://[url].up.railway.app
  Status: ✓ Çalışıyor
  Health: ✓ OK
  AI Chat: ✓ Yanıt veriyor

Flutter:
  APK: ✓ Build alındı
  Boyut: XX MB
  Konum: mobile/build/app/outputs/flutter-apk/app-release.apk

⚠️ Yapılacaklar:
  - APK'yı telefona yükle: flutter install -d [device-id]
  - Play Store için: flutter build appbundle --release
```

## Hata Durumları

| Hata | Çözüm |
|------|-------|
| Flutter analyze hatası | Önce hataları düzelt, sonra tekrar /deploy |
| Railway bağlantı hatası | `railway login` ile giriş yap |
| APK build hatası | `flutter clean && flutter pub get` çalıştır |
| Backend health check başarısız | Railway loglarını kontrol et |

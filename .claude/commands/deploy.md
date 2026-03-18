# /deploy

Nurai projesini production'a deploy et. Flutter web build alır, backend'i kontrol eder.

## Adımlar

1. **Ön kontroller:**
```bash
# Backend sağlık kontrolü
curl -s http://localhost:3000/health

# Flutter analiz
cd C:\Users\KULLANICI\Desktop\fizyoterapi\mobile
flutter analyze --no-pub
```
Hata varsa deploy'u durdur, önce düzelt.

2. **Flutter web build:**
```bash
cd C:\Users\KULLANICI\Desktop\fizyoterapi\mobile
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=false
```
Build çıktısı: `mobile/build/web/`

3. **APK build (opsiyonel — kullanıcı isterse):**
```bash
flutter build apk --release
```
APK çıktısı: `mobile/build/app/outputs/flutter-apk/app-release.apk`

4. **Backend bağımlılıkları kontrol et:**
```bash
cd C:\Users\KULLANICI\Desktop\fizyoterapi\backend
npm audit --audit-level=high
```

5. **Deploy özeti yaz:**
- Build süresi
- Çıktı dosya boyutu
- Kritik uyarılar varsa listele
- Sonraki adım: web hosting veya APK dağıtımı

## Önemli notlar
- `backend/.env` dosyasının production değerlerini içerdiğinden emin ol
- `mobile/lib/data/services/api_service.dart` içindeki `baseUrl`'in production sunucusuna işaret ettiğini kontrol et
- Firebase web config (`firebase_options.dart`) doğru proje ID'sini kullandığını doğrula

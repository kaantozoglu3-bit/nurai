# /review

Nurai projesini 5 açıdan kapsamlı kod incelemesi yap ve puanlı rapor üret.

## İnceleme Kapsamı

Şu dosyaları ve klasörleri incele:
- `mobile/lib/` — tüm Flutter kodu
- `backend/src/` — tüm Node.js kodu
- `mobile/pubspec.yaml` ve `backend/package.json`
- `.env` dosyaları (key'ler gizli tutularak)

---

## 5 İnceleme Boyutu

### 1. 🔒 Güvenlik (Security) — /10

Kontrol edilecekler:
- API key'ler `.env`'de mi, kodda hardcoded var mı?
- Firebase token doğrulama her endpoint'te var mı?
- Client-side quota kontrolü var mı? (güvensiz)
- `flutter_secure_storage` şifre için kullanılıyor mu?
- HTTPS kullanılıyor mu?
- SQL injection riski var mı?
- Rate limiting var mı?
- `.gitignore`'da hassas dosyalar var mı?

---

### 2. ⚡ Performans (Performance) — /10

Kontrol edilecekler:
- YouTube API gereksiz yere her seferinde çağrılıyor mu? (cache var mı?)
- AI prompt her mesajda tam geçmişi gönderiyor mu? (token optimizasyonu)
- Flutter'da `const` widget'lar kullanılıyor mu?
- Gereksiz `setState` çağrıları var mı?
- Görsel önbellekleme (`cached_network_image`) kullanılıyor mu?
- Backend'de veritabanı sorguları optimize mi?
- `flutter analyze` temiz mi?

---

### 3. 🏗️ Kod Kalitesi (Code Quality) — /10

Kontrol edilecekler:
- DRY prensibi (kod tekrarı var mı?)
- Fonksiyonlar tek sorumluluk taşıyor mu?
- Magic number/string var mı? (sabitler kullanılıyor mu?)
- Hata yönetimi (try/catch) her kritik noktada var mı?
- Dart null safety doğru kullanılıyor mu?
- Widget'lar makul boyutta mı? (500+ satır tek widget kötü)
- Backend route'lar mantıklı yapılanmış mı?

---

### 4. 🎨 Kullanıcı Deneyimi (UX) — /10

Kontrol edilecekler:
- Loading state her async işlemde gösteriliyor mu?
- Hata mesajları kullanıcı dostu mu? ("Error 500" değil, anlaşılır Türkçe)
- Boş durum (empty state) ekranları var mı?
- Navigation geri tuşu doğru çalışıyor mu?
- Keyboard açıldığında UI bozuluyor mu?
- Analiz sonucu doğru vücut bölgesini gösteriyor mu?
- AI chat akıcı mı? (streaming çalışıyor mu?)
- Disclaimer (tıbbi uyarı) her analiz sonucunda var mı?

---

### 5. 🏛️ Mimari (Architecture) — /10

Kontrol edilecekler:
- Riverpod provider'lar doğru kullanılıyor mu?
- GoRouter redirect mantığı sağlam mı?
- Business logic UI'dan ayrılmış mı?
- Mock data kaldırılmış mı, gerçek API kullanılıyor mu?
- Backend servis katmanı (service/controller/route) ayrımı var mı?
- Veri modelleri (UserModel, AnalysisModel) tutarlı mı?
- Freemium quota sunucu tarafında kontrol ediliyor mu?

---

## Rapor Formatı

```
# Nurai Kod İnceleme Raporu
Tarih: [tarih]
İncelenen: [kaç dosya, kaç satır kod]

## Genel Puan: XX/50

| Boyut | Puan | Durum |
|-------|------|-------|
| 🔒 Güvenlik | X/10 | 🔴/🟡/🟢 |
| ⚡ Performans | X/10 | 🔴/🟡/🟢 |
| 🏗️ Kod Kalitesi | X/10 | 🔴/🟡/🟢 |
| 🎨 UX | X/10 | 🔴/🟡/🟢 |
| 🏛️ Mimari | X/10 | 🔴/🟡/🟢 |

## 🔴 Kritik Sorunlar (Hemen Düzeltilmeli)
1. [sorun] → [dosya:satır] → [çözüm]
2. ...

## 🟡 Orta Sorunlar (Yakında Düzeltilmeli)
1. [sorun] → [dosya:satır] → [çözüm]
2. ...

## 🟢 İyi Yapılanlar
1. ...

## Sonraki Adımlar (Öncelik Sırasıyla)
1. ...
2. ...
3. ...
```

## Puan Skalası
- 🟢 8-10: İyi
- 🟡 5-7: Orta, iyileştirme gerekli
- 🔴 0-4: Kritik, hemen düzeltilmeli

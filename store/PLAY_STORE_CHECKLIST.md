# Play Store Yükleme Rehberi — Nurai

## Hazır Olanlar
- [x] AAB dosyası: store/nurai-v1.0.0.aab
- [x] Gizlilik politikası: https://kaantozoglu3-bit.github.io/nurai
- [x] Kısa açıklama: store/listing.md
- [x] Uzun açıklama: store/listing.md
- [x] Feature graphic HTML: assets/store/feature.html
- [x] Crashlytics entegre
- [x] Analytics entegre
- [x] AdMob test ID'leri hazır

## Play Console Adımları
1. play.google.com/console → Yeni uygulama
2. Uygulama adı: Nurai — Fizyoterapi Asistanı
3. Dil: Türkçe (tr-TR)
4. Uygulama tipi: Uygulama
5. Ücretsiz/Ücretli: Ücretsiz
6. AAB yükle: store/nurai-v1.0.0.aab
7. Gizlilik politikası URL: https://kaantozoglu3-bit.github.io/nurai
8. İçerik derecelendirmesi anketi doldur (Sağlık & Fitness)
9. Fiyatlandırma: Ücretsiz (premium uygulama içi)
10. İncelemeye gönder

## Ekran Görüntüleri Gereksinimleri
- Telefon: Min 2, max 8 görüntü (1080x1920 veya 9:16)
- 7" tablet: opsiyonel
- 10" tablet: opsiyonel

## AdMob Sonrası (Play Store onayı sonrası)
1. admob.google.com → Android uygulaması kaydet
2. Gerçek reklam birimlerini oluştur (Rewarded + Banner)
3. `AdConstants.useTestAds = false` yap
4. `AdConstants.rewardedAdUnitId` → gerçek ID
5. `AdConstants.bannerAdUnitId` → gerçek ID
6. Yeni AAB build al ve Play Store'a güncelleme gönder

## App Check (Play Store onayı sonrası)
1. Google Cloud Console → Play Integrity API etkinleştir
2. Firebase Console → App Check → Android → Play Integrity
3. SHA-1 fingerprint ekle (keytool -list komutuyla al)
4. Backend'de app check hard enforcement'e geç

## Kalan Teknik Görevler
- [ ] iOS build (Mac gerekiyor)
- [ ] Gerçek AdMob ID'leri (Play Store onayı sonrası)
- [ ] App Check Play Integrity aktifleştirme
- [ ] SSL native pinning (opsiyonel, dart:io SPKI zaten aktif)
- [ ] Push notification (FCM) — opsiyonel gelecek özellik

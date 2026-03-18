# nurai-debug

Nurai projesinde hata bul, kök nedenini tespit et ve düzelt.

## Kullanım
Kullanıcı "neden çalışmıyor", "hata var", "şu ekran açılmıyor" dediğinde uygula.

## Adım 1 — Log Topla
cd C:\Users\KULLANICI\Desktop\fizyoterapi\backend
node server.js 2>&1
flutter analyze --no-pub
flutter logs -d R9AMC1PLZZJ

## Adım 2 — Hata Tablosu

Flutter:
- null check operator → null safety ihlali → ?. veya ?? ekle
- setState after dispose → if (mounted) setState ekle
- Connection refused → backend başlat
- Firebase no app → main.dart Firebase.initializeApp kontrol et
- GoRouter redirect loop → app_router.dart redirect mantığı kontrol et

Backend:
- 401 Unauthorized → Firebase token geçersiz → auth middleware kontrol et
- 429 Too Many Requests → quota aşıldı → quota middleware kontrol et
- 500 Internal Server Error → server loguna bak
- Groq API error → .env key kontrol et

## Adım 3 — Sık Karşılaşılan Nurai Hataları

"Bağlantı hatası" chat ekranında:
1. curl http://localhost:3000/health → backend çalışıyor mu?
2. api_service.dart baseUrl doğru mu?
3. AndroidManifest usesCleartextTraffic var mı?

Analiz sonucu hep "Alt Sırt/Bel":
1. body_selector → chat_screen'e bodyArea geçiyor mu?
2. chat_screen → backend'e bodyArea gönderiliyor mu?
3. Backend → sistem promptuna inject ediliyor mu?
4. MockData.analyses.first kaldırıldı mı?

AI alakasız cevap:
1. nurai-prompt skill'ini çalıştır
2. conversationHistory boş değil mi?
3. userProfile inject ediliyor mu?

YouTube gelmiyor:
1. .env YouTube key var mı?
2. Google Cloud Console quota dolmadı mı?

## Adım 4 — Rapor
Hata: [mesaj]
Konum: [dosya:satır]
Kök Neden: [açıklama]
Düzeltme: [ne değiştirildi]
Doğrulama: flutter analyze ✅/❌ — manuel test ✅/❌
Önlem: [tekrar oluşmaması için]

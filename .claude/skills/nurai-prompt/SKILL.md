# nurai-prompt

Nurai'nin AI sistem promptunu analiz et, zayıf noktaları bul ve optimize et.

## Kullanım
Kullanıcı "AI alakasız cevap veriyor", "prompt geliştir", "daha iyi sorular sorsun" dediğinde uygula.

## Adım 1 — Mevcut Promptu Oku
cat C:\Users\KULLANICI\Desktop\fizyoterapi\backend\src\services\groq.service.js
Kontrol et:
- Kullanıcı profili inject ediliyor mu?
- Vücut bölgesi inject ediliyor mu?
- Konuşma geçmişi gönderiliyor mu?
- Red flag kontrolleri var mı?
- Dil talimatı var mı?

## Adım 2 — 5 Senaryo Testi

Senaryo 1 — Akut boyun:
{"message":"bugün sabah boynum tutuldu","bodyArea":"neck","userProfile":{"age":35,"fitnessLevel":"sedentary"}}
Beklenen: Akut ağrıya uygun soru

Senaryo 2 — Kronik bel:
{"message":"6 aydır belim ağrıyor","bodyArea":"lower_back","userProfile":{"age":45,"pastInjuries":["bel fıtığı"]}}
Beklenen: Kronik sorular, fıtık geçmişi dikkate alınmalı

Senaryo 3 — Red flag:
{"message":"bacaklarımda uyuşma var ve tuvalete gidemiyorum","bodyArea":"lower_back"}
Beklenen: Hemen doktora git uyarısı

Senaryo 4 — Sporcu diz:
{"message":"koşu sonrası dizim ağrıyor","bodyArea":"left_knee","userProfile":{"age":22,"fitnessLevel":"active"}}
Beklenen: Şişlik var mı, tık sesi var mı soruları

Senaryo 5 — Yanlış konu:
{"message":"bugün hava nasıl","bodyArea":"neck"}
Beklenen: Nazikçe konuya yönlendirme

## Adım 3 — Puanlama
Her senaryo 0-2 puan. Toplam 10 üzerinden:
- 8-10: İyi
- 5-7: Optimizasyon gerekli
- 0-4: Yeniden yaz

## Adım 4 — Rapor
Mevcut Puan: X/10
Senaryo Sonuçları: [liste]
Tespit Edilen Sorunlar: [liste]
Yapılan İyileştirmeler: [liste]
Yeni Puan: X/10

# nurai-test

Nurai uygulamasını otomatik test et. Her kritik akışı sırayla dene, hataları raporla.

## Kullanım
Kullanıcı "test et", "hataları bul", "çalışıyor mu" dediğinde bu skill'i uygula.

## Test Adımları

### 1. Backend Sağlık
curl -s http://localhost:3000/health
✅ 200 dönüyorsa devam, ❌ yoksa backend başlat.

### 2. Flutter Analiz
cd C:\Users\KULLANICI\Desktop\fizyoterapi\mobile
flutter analyze --no-pub
✅ "No issues" → devam, ❌ hata varsa düzelt.

### 3. AI Chat Testi
curl -X POST http://localhost:3000/api/v1/analysis/chat-sync -H "Content-Type: application/json" -d '{"message":"bel ağrım var","bodyArea":"lower_back","conversationHistory":[]}'
Yanıt Türkçe mi? Vücut bölgesine uygun mu?

### 4. YouTube Testi
curl "http://localhost:3000/api/v1/youtube/search?q=bel+agrisi&area=lower_back"
En az 3 video dönüyor mu?

### 5. Quota Testi
4. istekte 429 dönmeli.

### 6. Vücut Bölgesi Testi
neck, lower_back, left_knee, right_shoulder için farklı yanıtlar dönüyor mu?

## Rapor Formatı
| Test | Durum | Not |
|------|-------|-----|
| Backend | ✅/❌ | — |
| Flutter analyze | ✅/❌ | — |
| AI chat | ✅/❌ | — |
| YouTube | ✅/❌ | — |
| Quota | ✅/❌ | — |
| Vücut bölgesi | ✅/❌ | — |

Genel: X/6 test geçti
Bulunan hatalar: [liste]

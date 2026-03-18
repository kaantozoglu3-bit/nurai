# /commit

Nurai projesindeki tüm değişiklikleri analiz et, anlamlı bir commit mesajı oluştur ve commit at.

## Adımlar

1. **Değişiklikleri analiz et:**
```bash
cd C:\Users\KULLANICI\Desktop\fizyoterapi
git diff --staged
git diff
git status
```

2. **Değişiklikleri kategorize et:**
- `feat:` → Yeni özellik (yeni ekran, yeni endpoint, yeni fonksiyon)
- `fix:` → Hata düzeltme
- `refactor:` → Kod iyileştirme (davranış değişmeden)
- `style:` → UI/UX değişikliği
- `perf:` → Performans iyileştirme
- `test:` → Test ekleme/düzenleme
- `chore:` → Bağımlılık güncelleme, config değişikliği
- `docs:` → Dokümantasyon

3. **Semantic commit mesajı oluştur:**

Format:
```
<type>(<scope>): <kısa açıklama>

<detaylı açıklama — ne değişti ve neden>

Değişen dosyalar:
- dosya1.dart: ne değişti
- dosya2.js: ne değişti
```

Scope örnekleri: `auth`, `chat`, `ai`, `youtube`, `backend`, `ui`, `router`, `profile`

4. **Git işlemlerini yap:**
```bash
git add .
git commit -m "<oluşturulan mesaj>"
```

5. **Commit özeti yaz:**
- Commit hash
- Kaç dosya değişti
- Ne eklendi / ne silindi
- Sonraki adım önerisi

## Örnek çıktı

```
✅ Commit başarılı

Hash: a3f9c2d
Type: fix(chat)
Mesaj: "fix(chat): vücut bölgesi seçimi analiz sonucuna yansımıyor"

Detay:
- body_selector_screen.dart: seçilen bölge artık chat'e parametre olarak geçiliyor
- chat_screen.dart: bodyArea parametresi sistem promptuna inject ediliyor
- analysis_result_screen.dart: mock data.first yerine gerçek analiz verisi kullanılıyor

3 dosya değişti | +47 satır eklendi | -12 satır silindi
```

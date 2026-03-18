# /review

Son değişiklikleri veya belirtilen dosyaları kod kalitesi, güvenlik ve Flutter/Node.js best practice açısından incele.

## Adımlar

1. **Neyin review edileceğini belirle:**
   - Argüman verilmişse (`/review chat_screen.dart`) → sadece o dosya
   - Argüman yoksa → `git diff HEAD~1` veya `git diff --staged` ile son değişiklikler

2. **Flutter/Dart dosyaları için kontrol listesi:**
   - [ ] `setState` gereksiz yerde kullanılıyor mu? (Riverpod tercih et)
   - [ ] Widget'lar `const` constructor kullanıyor mu?
   - [ ] `BuildContext` async gap'ten sonra kullanılıyor mu? (`mounted` kontrolü var mı?)
   - [ ] Büyük widget'lar küçük parçalara bölünmüş mü?
   - [ ] `dispose()` içinde stream/controller kapatılıyor mu?
   - [ ] Hardcoded string var mı? (Turkish UI text, magic numbers)
   - [ ] `try/catch` blokları spesifik exception yakalıyor mu?

3. **Backend/Node.js dosyaları için kontrol listesi:**
   - [ ] Input validation (Joi veya manuel) yapılıyor mu?
   - [ ] Auth middleware korumalı mı?
   - [ ] SQL/NoSQL injection riski var mı?
   - [ ] `async/await` hataları `try/catch` ile sarılı mı?
   - [ ] Console.log'lar production'da kalmamalı (winston kullan)
   - [ ] API key veya secret hardcoded var mı?
   - [ ] Rate limiting uygulanıyor mu?

4. **Genel kontroller:**
   - [ ] TODO/FIXME yorumları kalmış mı?
   - [ ] Dead code (kullanılmayan import, fonksiyon, değişken) var mı?
   - [ ] Fonksiyon çok uzun mu? (50+ satır → bölmeyi düşün)

5. **Review raporu yaz:**

Format:
```
## Review Raporu

### ✅ İyi
- ...

### ⚠️ Uyarı (düzeltilmeli)
- dosya:satır — sorun açıklaması → öneri

### 🔴 Kritik (mutlaka düzelt)
- dosya:satır — sorun açıklaması → öneri

### 💡 Öneri (opsiyonel iyileştirme)
- ...
```

6. **Kritik sorun varsa otomatik düzelt**, uyarı/öneri için kullanıcıya sor.

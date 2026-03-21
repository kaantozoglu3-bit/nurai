# Consultant Kararları

## 2026-03-21: Bildirim Sistemi Seçimi

### Değerlendirilen Alternatifler
1. Sosyal paylaşım (share_plus) — viral etki, share_plus zaten var, 1 saat
2. Bildirim sistemi (flutter_local_notifications) — retention, zaten var, 2-3 saat
3. Ağrı haritası — görsellik, custom painter gerekir, 4+ saat

### Seçilen: Bildirim Sistemi
**Neden:** En yüksek retention etkisi. DAU artışı = gelir artışı. Bağımlılıklar zaten pubspec'te.

### Uygulama Planı
1. NotificationService — izin alma, bildirim zamanlama (zaten mevcut, genişletildi)
2. NotificationSettingsScreen — kullanıcı tercihlerini kaydet
3. Settings ekranına entegrasyon
4. Android manifest güncelleme

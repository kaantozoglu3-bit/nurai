class ShoulderRehabilitationProtocol {
  static const String injuryName =
      'Omuz Yaralanmaları (Rotator Cuff / Bankart / SLAP)';
  static const String injuryDescription =
      'Rotator cuff yırtığı, Bankart lezyonu ve SLAP yaralanması rehabilitasyonu.';

  static const List<Map<String, dynamic>> rotatorCuffProgram = [
    {
      'phase': 'Faz 1 (0-4. Hafta)',
      'name': 'Ağrı Kontrolü ve Erken Mobilite',
      'exercises': [
        'Sarkık Sarkaç Egzersizi (Codman): 3x20 küçük daireler',
        'AAROM Supra/Elevation: kademeli ROM artışı',
        'Kürek Kası Retraksiyon: 3x15',
        'Rotator Cuff İzometrik: Dışa/içe rotasyon 5 sn tutma, 3x10',
      ],
    },
    {
      'phase': 'Faz 2 (4-8. Hafta)',
      'name': 'Aktif ROM ve Başlangıç Güçlendirme',
      'exercises': [
        'Direnç Bandı Dış Rotasyon: 3x15',
        'Direnç Bandı İç Rotasyon: 3x15',
        'Lateral Raise (30°): 3x15 hafif dambıl',
        'Prone Y-T-W: 3x12 (skapular stabilite)',
        'Serratus Anterior Push-Up Plus: 3x15',
      ],
    },
    {
      'phase': 'Faz 3 (8-12. Hafta)',
      'name': 'Güç ve Fonksiyon',
      'exercises': [
        'Overhead Press (ağrısız ROM): 3x12',
        'Cable Face Pull: 3x15',
        'Single Arm Row: 3x12',
        'Plyometric Ball Throw: 3x10',
        'Sport-specific shoulder patterns',
      ],
    },
  ];

  static const Map<String, List<String>> bankartProtocol = {
    'Cerrahi Sonrası 0-6. Hafta': [
      'Askı (immobilizasyon) kullanımı',
      'Sarkaç egzersizleri: Günde 3x',
      'El-Bilek ROM hareketleri',
      'Kürek kası izometrik',
    ],
    '6-12. Hafta': [
      'AAROM→AROM geçiş',
      'Direnç bandı eksternal rotasyon (90° kısıtlamasıyla)',
      'Skapular güçlendirme',
      'Aqua therapy',
    ],
    '12-24. Hafta': [
      'Tam ROM hedefi',
      'Spor spesifik güçlendirme',
      'Kontakt spor dönüşü: 6. ayda değerlendirme',
    ],
  };
}

class MeniscusRehabilitation {
  static const String injuryName = 'Menisküs Hasarı';
  static const String injuryDescription =
      'Medial veya lateral menisküs yırtığı rehabilitasyonu. '
      'Konservatif ve cerrahi sonrası protokol.';

  static const List<Map<String, dynamic>> conservativeProtocol = [
    {
      'week': '1-3. Hafta',
      'focus': 'Ağrı-Ödem Kontrolü',
      'exercises': [
        'Quad Set: 3x15, 5 sn izometrik kasılma',
        'SLR (Düz Bacak Kaldırma): 3x15',
        'Topuk Kaydırma ROM: 3x10',
        'Buz: Her 2 saatte 15 dk',
      ],
    },
    {
      'week': '3-8. Hafta',
      'focus': 'Güç ve Mobilite',
      'exercises': [
        'Mini Squat (0-60°): 3x15',
        'Step Up: 3x12',
        'Hamstring Curl: 3x12',
        'Sabit Bisiklet: 20 dk',
      ],
    },
    {
      'week': '8-12. Hafta',
      'focus': 'Fonksiyonel Aktiviteler',
      'exercises': [
        'Tam Squat (ağrısız): 3x12',
        'Tek Bacak Denge: 3x30 sn',
        'Jogging (düz zemin): 20 dk',
        'Yüzme/Su içi yürüyüş: 30 dk',
      ],
    },
  ];

  static const List<Map<String, dynamic>> postSurgicalProtocol = [
    {
      'week': '0-2. Hafta (Parsiyel Menisektomi)',
      'focus': 'Erken Mobilizasyon',
      'notes': 'Tam yük vermeye 1. haftada başlanabilir',
      'exercises': [
        'Quad Set ve SLR: İlk gün başla',
        'ROM egzersizleri: Tam fleksiyona 2. haftada',
        'Yürüme: Koltuk değneğiyle 1. haftada',
      ],
    },
    {
      'week': '0-6. Hafta (Menisküs Tamiri)',
      'focus': 'Koruyucu Faz',
      'notes': 'Ağırlık yasağı, 90° fleksiyon kısıtlaması',
      'exercises': [
        'Quad Set: 3x15 (ağrısız)',
        'SLR: Yavaş progresyon',
        'ROM: Sadece 0-60° arası',
        'CPM cihazı kullanımı (hekim kararına göre)',
      ],
    },
  ];
}

class ElbowRehabilitationProtocol {
  static const String injuryName = 'Dirsek Tendinopati (Tenis / Golfer Dirseği)';
  static const String injuryDescription =
      'Lateral epikondilalji (tenis dirseği) ve medial epikondilalji (golfçü dirseği) '
      'için Tyler Twist protokolü dahil kanıta dayalı rehabilitasyon.';

  static const Map<String, dynamic> tylerTwistProtocol = {
    'name': 'Tyler Twist (FlexBar Egzersizi)',
    'targetCondition': 'Lateral Epikondilalji (Tenis Dirseği)',
    'equipment': 'Theraband FlexBar (kırmızı veya yeşil)',
    'sets': '3x15',
    'frequency': 'Günde 3x, 6 hafta',
    'steps': [
      '1. Sağlıklı elle FlexBar\'ı bükerek tut (supinasyon)',
      '2. Yaralı elle diğer ucu kavra (nötral pozisyon)',
      '3. Sağlıklı eli sabit tutarken yaralı eli bük (pronasyon)',
      '4. FlexBar\'ın açılmasına direnç göster — 3 sn kontrollü',
      '5. Başa dön — 15 tekrar',
    ],
    'note':
        'Tolere edilebilir ağrı 5/10\'a kadar kabul — aktivite sonrası azalmalı',
  };

  static const List<Map<String, String>> additionalExercises = [
    {
      'name': 'Bilek Ekstansör Eksantrik',
      'description':
          'Masaya destek, ağırlıkla bilek ekstansiyonu — yavaş indirme',
      'sets': '3x15',
    },
    {
      'name': 'Bilek Fleksör Güçlendirme (Medial)',
      'description': 'Hafif ağırlıkla bilek fleksiyonu',
      'sets': '3x15',
    },
    {
      'name': 'Direnç Bandı Önkol Rotasyonu',
      'description': 'Pronasyon-Supinasyon direnç egzersizi',
      'sets': '3x15',
    },
    {
      'name': 'Kavrama Güçlendirme',
      'description': 'Stres topu veya kavrama aleti',
      'sets': '3x20',
    },
    {
      'name': 'Isı — Masaj — Buz Protokolü',
      'description': 'Egzersiz öncesi ısıtma, sonrası buz 10 dk',
      'sets': 'Her seans',
    },
  ];
}

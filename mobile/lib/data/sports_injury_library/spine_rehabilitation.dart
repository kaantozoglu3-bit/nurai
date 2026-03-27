class SpineRehabilitationProtocol {
  static const String injuryName = 'Bel-Sırt Yaralanmaları (Disk / Spor Streni)';
  static const String injuryDescription =
      'Sporcuya özgü bel-sırt rehabilitasyonu: disk patolojisi ve kas streni için '
      '4 fazlı McGill Big 3 + fonksiyonel güç programı.';

  static const List<Map<String, dynamic>> phases = [
    {
      'phase': 1,
      'name': 'Akut Faz — Ağrı Kontrolü',
      'duration': '0-2. Hafta',
      'exercises': [
        {
          'name': 'McGill Curl-Up',
          'description':
              'Sırtüstü, bir diz bükük. Başı hafifçe kaldır, boynu nötral tut. '
              '10 sn izometrik.',
          'sets': '3x10 sn',
        },
        {
          'name': 'McGill Side Bridge (Kısa)',
          'description': 'Yan plank, dizler bükük. 10 sn tutma.',
          'sets': '3x10 sn',
        },
        {
          'name': 'McGill Bird Dog',
          'description':
              'Dört ayak pozisyonu. Karşı kol-bacak uzatma, 10 sn tut.',
          'sets': '3x10 sn',
        },
      ],
    },
    {
      'phase': 2,
      'name': 'Stabilizasyon Fazı',
      'duration': '2-6. Hafta',
      'exercises': [
        {
          'name': 'Dead Bug',
          'description':
              'Sırtüstü, diz 90° havada. Karşı kol-bacak uzat, beli yerden ayırma.',
          'sets': '3x10',
        },
        {
          'name': 'Plank Progresyonu',
          'description': 'Ön plank: 30 sn → 60 sn → 90 sn',
          'sets': '3x max süre',
        },
        {
          'name': 'Pallof Press',
          'description': 'Kablo veya bant ile core anti-rotasyon.',
          'sets': '3x15',
        },
        {
          'name': 'Glute Bridge',
          'description': 'İki ayak → tek ayak progresyonu',
          'sets': '3x15',
        },
      ],
    },
    {
      'phase': 3,
      'name': 'Güç ve Fonksiyon Fazı',
      'duration': '6-12. Hafta',
      'exercises': [
        {
          'name': 'Romanian Deadlift',
          'description': 'Hafif yükle bel nötral, yavaş eksentrik',
          'sets': '4x12',
        },
        {
          'name': 'Goblet Squat',
          'description': 'Kettlebell ile derin squat, core aktif',
          'sets': '4x12',
        },
        {
          'name': 'Cable Pull-Through',
          'description': 'Gluteal aktivasyon ve bel ekstansörü',
          'sets': '3x15',
        },
        {
          'name': 'Farmer Carry',
          'description': 'Ağırlık taşıyarak yürüyüş, core stability',
          'sets': '4x20 m',
        },
      ],
    },
    {
      'phase': 4,
      'name': 'Spora Dönüş Fazı',
      'duration': '3-6. Ay',
      'exercises': [
        {
          'name': 'Olimpik Kaldırışlar (Mod.)',
          'description': 'Güç sporcuları için temiz teknikle',
          'sets': 'Koça göre',
        },
        {
          'name': 'Rotasyonel Power',
          'description': 'Med ball rotational throw',
          'sets': '4x8',
        },
        {
          'name': 'Spor-Spesifik Yüklenme',
          'description': 'Branşa özgü antrenman yükleri',
          'sets': 'Antrenman planına göre',
        },
      ],
    },
  ];

  static const List<Map<String, String>> muscleStrainProtocol = [
    {
      'grade': 'Grade 1 (Hafif)',
      'duration': '1-2 Hafta',
      'treatment': 'RICE, hafif germe, kısa sürede aktiviteye dönüş',
    },
    {
      'grade': 'Grade 2 (Orta)',
      'duration': '3-6 Hafta',
      'treatment': 'RICE + Faz 1-2 egzersizleri, kademeli yüklenme',
    },
    {
      'grade': 'Grade 3 (Ciddi)',
      'duration': '6-12 Hafta',
      'treatment':
          'Ortopedi konsültasyonu, cerrahi değerlendirme, uzun dönem rehab',
    },
  ];
}

class AchillesRehabilitationProtocol {
  static const String injuryName = 'Aşil Tendinopati';
  static const String injuryDescription =
      'Aşil tendonu aşırı kullanım hasarı. '
      'Alfredson HSR (Ağır Yük-Yavaş Hız) protokolü ile kanıta dayalı tedavi.';

  static const Map<String, dynamic> alfredsonProtocol = {
    'name': 'Alfredson HSR Protokolü',
    'frequency': 'Günde 2 kez, 7 gün/hafta, 12 hafta',
    'principle': '3x15 eksantrik kasılma — ağrıya rağmen devam edilir (en fazla 5/10)',
    'exercises': [
      {
        'name': 'Diz Düz Calf Raise — Eksantrik',
        'description':
            'İki ayakla kalk, tek ayakla yavaşça in (3 sn). '
            'İniş fazı eksantrik — kaldırma fazı iki ayakla yapılır.',
        'sets': '3x15',
        'tempo': '3 sn iniş',
        'pain': 'Ağrı 5/10\'a kadar kabul',
      },
      {
        'name': 'Diz Bükük Calf Raise — Eksantrik',
        'description':
            'Diz hafif bükük pozisyonda aynı hareket. '
            'Soleus kasını hedefler.',
        'sets': '3x15',
        'tempo': '3 sn iniş',
        'pain': 'Ağrı 5/10\'a kadar kabul',
      },
    ],
    'progression': [
      'Hafta 1-4: Kendi vücut ağırlığı',
      'Hafta 5-8: +5-10 kg backpack ekle',
      'Hafta 9-12: Yük progresyonu devam',
    ],
    'warningSign':
        'Sabah ciddi sertlik ve ağrı artıyorsa yükü azalt',
  };

  static const List<Map<String, dynamic>> additionalExercises = [
    {
      'name': 'Fasya Bandajı / Taping',
      'description': 'Antrenman süresince aşil tendon yükünü azaltır',
    },
    {
      'name': 'Topuk Yükseltici (Heel Raise)',
      'description': '1-1.5 cm topuk yükseltici ile yürüyüş yükünü azalt',
    },
    {
      'name': 'Bisiklet (Aerobik Kondisyon)',
      'description': 'Kardiyovasküler kondisyonu koru, aşil yükü düşük',
      'sets': '30 dk',
    },
  ];
}

class AnkleRehabilitationProtocol {
  static const String injuryName = 'Ayak Bileği Burkulmasi (Lateral Sprain)';
  static const String injuryDescription =
      'Lateral ayak bileği burkulması (ATF, CF ligament) rehabilitasyonu. '
      'Evre 1-2-3 için kapsamlı program.';

  static const List<Map<String, dynamic>> phases = [
    {
      'phase': 1,
      'name': 'Mobilite Fazı',
      'duration': '0-1. Hafta',
      'goals': 'Ödemi azalt, ROM\'u koru, ağrıyı yönet',
      'exercises': [
        'RICE protokolü (Dinlenme, Buz, Kompresyon, Elevasyon)',
        'Ayak bileği alphabet: Havada harf çizme — 3 set',
        'Topuk-Parmak Ucu Yürüyüşü: 3x10 adım',
        'Bisiklet (Sabit): Ağrısız 10 dk',
      ],
    },
    {
      'phase': 2,
      'name': 'Güç Fazı',
      'duration': '1-3. Hafta',
      'goals': 'Peroneal güç kazan, eklem stabilitesi',
      'exercises': [
        'Direnç Bandı Eversiyon: 3x15 (peroneal kas)',
        'Direnç Bandı Dorsifleksiyon: 3x15',
        'Calf Raise (İki Ayak→Tek Ayak): 3x20',
        'Mini Squat: 3x15 (ağrısız)',
      ],
    },
    {
      'phase': 3,
      'name': 'Denge Fazı',
      'duration': '2-4. Hafta',
      'goals': 'Propriosepsiyon ve nöromüsküler kontrol',
      'exercises': [
        'Tek Bacak Denge (Düz Zemin): 3x30 sn',
        'Wobble Board/Denge Tahtası: 3x45 sn',
        'BOSU Top Denge: 3x30 sn',
        'Mini Trampolin: 3x30 sn',
      ],
    },
    {
      'phase': 4,
      'name': 'Fonksiyonel Faz',
      'duration': '3-6. Hafta',
      'goals': 'Koşu, zıplama, spor hareketleri',
      'exercises': [
        'Jogging (Düz Zemin): 10-20 dk',
        'Figure-8 Koşusu: 5x',
        'Lateral Hop: 3x10 (tek ayak yanlara zıplama)',
        'Hekim onayıyla spora dönüş',
      ],
    },
  ];
}

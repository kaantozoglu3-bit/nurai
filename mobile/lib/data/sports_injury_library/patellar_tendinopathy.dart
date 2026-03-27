class PatellarTendinopathyRehabilitation {
  static const String injuryName = 'Patellar Tendinopati (Jumper\'s Knee)';
  static const String injuryDescription =
      'Patellar tendon aşırı kullanım hasarı. '
      'Zıplama sporlarında sık görülür. Ağır eksantrik protokol ile tedavi.';

  static const List<Map<String, dynamic>> vikrProgram = [
    {
      'phase': 1,
      'name': 'Ağrı Azaltma',
      'duration': '1-2. Hafta',
      'exercises': [
        {
          'name': 'İzometrik Leg Extension',
          'description':
              '60° açıda 45 sn tutma, 5 tekrar, 2 dk dinlenme arası',
          'sets': '5x45 sn',
          'note':
              'Anlık ağrı kesici etki — maç/antrenman öncesi de kullanılabilir',
        },
      ],
    },
    {
      'phase': 2,
      'name': 'İzotonik Yüklenme',
      'duration': '3-8. Hafta',
      'exercises': [
        {
          'name': 'Düşük Hızlı Leg Extension',
          'description': '3 sn yukarı — 4 sn aşağı, tam ROM',
          'sets': '4x15',
          'note': 'Ağrı 0-4/10 arası kabul edilebilir',
        },
        {
          'name': 'Squat (Ağrısız ROM)',
          'description': 'Kendi ağırlığıyla tam squat',
          'sets': '3x15',
          'note': '',
        },
      ],
    },
    {
      'phase': 3,
      'name': 'Enerji Depolama Egzersizleri',
      'duration': '8-12. Hafta',
      'exercises': [
        {
          'name': 'Drop Squat',
          'description': 'Kutudan inip çömelme hareketi',
          'sets': '4x8',
          'note': 'Ağrı 4/10\'u geçmemeli',
        },
        {
          'name': 'Tek Bacak Squat Progresyonu',
          'description': 'Düz zemin → eğimli zemin',
          'sets': '3x8',
          'note': '',
        },
      ],
    },
    {
      'phase': 4,
      'name': 'Spora Dönüş',
      'duration': '12+ Hafta',
      'exercises': [
        {
          'name': 'Pliometrik Progresyon',
          'description': 'Bilateral → unilateral zıplama',
          'sets': '4x10',
          'note': 'Tam ağrısızlık şartıyla',
        },
        {
          'name': 'Spor-Spesifik Yüklenme',
          'description': 'Branşa özgü antrenman yükü',
          'sets': 'Antrenman programına göre',
          'note': '',
        },
      ],
    },
  ];
}

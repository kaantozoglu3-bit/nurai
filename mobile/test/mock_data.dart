import 'package:painrelief_ai/data/models/analysis_model.dart';

/// Development / demo mock data.
/// Do NOT use in production flows — only for UI previews and tests.
class MockData {
  static final List<AnalysisModel> analyses = [
    AnalysisModel(
      id: '1',
      bodyArea: 'lower_back',
      bodyAreaLabel: 'Alt Sırt / Bel',
      painScore: 6,
      userComplaint: 'Bel ağrısı, özellikle sabahları kötü',
      aiSummary:
          'Bel bölgesinde kas gerilmesi ve postür bozukluğu nedeniyle ağrı yaşıyorsunuz. '
          'Uzun süre oturma ve hareketsizlik bu durumu tetiklemiş olabilir.',
      possibleCauses: [
        'Uzun süreli oturma pozisyonu',
        'Zayıf core kasları',
        'Postür bozukluğu',
      ],
      exercises: [
        const ExerciseModel(
          name: 'Kedi-İnek Hareketi',
          description: 'Bel kaslarını gevşetmek için',
          difficulty: 'Kolay',
          duration: '2 set x 10 tekrar',
          videoId: 'kgHpCMqG6E8',
        ),
        const ExerciseModel(
          name: 'Çocuk Pozu',
          description: 'Alt sırt gerilmesi',
          difficulty: 'Kolay',
          duration: '3 x 30 saniye',
          videoId: 'eqVMAPM00T8',
        ),
        const ExerciseModel(
          name: 'Pelvik Tilt',
          description: 'Core aktivasyonu ve bel desteği',
          difficulty: 'Orta',
          duration: '3 set x 15 tekrar',
          videoId: 'lbo2YIW5MvA',
        ),
      ],
      videos: [
        const VideoModel(
          videoId: 'kgHpCMqG6E8',
          title: 'Bel Ağrısı İçin En Etkili 5 Egzersiz',
          channelTitle: 'Fizyoterapi Türkiye',
          thumbnailUrl: 'https://img.youtube.com/vi/kgHpCMqG6E8/mqdefault.jpg',
          duration: '8:32',
        ),
        const VideoModel(
          videoId: 'eqVMAPM00T8',
          title: 'Bel Fıtığı ve Bel Ağrısı Egzersizleri',
          channelTitle: 'Sağlıklı Hareket',
          thumbnailUrl: 'https://img.youtube.com/vi/eqVMAPM00T8/mqdefault.jpg',
          duration: '12:15',
        ),
        const VideoModel(
          videoId: 'lbo2YIW5MvA',
          title: 'Sabah Bel Ağrısı için Esneme Rutini',
          channelTitle: 'FizioTerapi',
          thumbnailUrl: 'https://img.youtube.com/vi/lbo2YIW5MvA/mqdefault.jpg',
          duration: '6:45',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AnalysisModel(
      id: '2',
      bodyArea: 'neck',
      bodyAreaLabel: 'Boyun',
      painScore: 4,
      userComplaint: 'Boyun tutulması, bilgisayar başında çalışıyorum',
      aiSummary:
          'Boyun kaslarında gerilme ve tetik noktası ağrısı görülmektedir. '
          'Masa başı çalışma ve ekran duruşu bu durumun ana nedenidir.',
      possibleCauses: [
        'Masa başı çalışma pozisyonu',
        'Ekrana bakış açısı',
        'Boyun kaslarında gerilme',
      ],
      exercises: [
        const ExerciseModel(
          name: 'Boyun Rotasyonu',
          description: 'Boyun hareketliliğini artırır',
          difficulty: 'Kolay',
          duration: '2 x 10 her yön',
          videoId: 'abc123',
        ),
      ],
      videos: [
        const VideoModel(
          videoId: 'abc123',
          title: 'Boyun Ağrısı için Ofis Egzersizleri',
          channelTitle: 'Sağlıklı Ofis',
          thumbnailUrl: 'https://img.youtube.com/vi/abc123/mqdefault.jpg',
          duration: '5:20',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static const Map<String, String> bodyAreaLabels = {
    'neck': 'Boyun',
    'left_shoulder': 'Sol Omuz',
    'right_shoulder': 'Sağ Omuz',
    'upper_back': 'Üst Sırt',
    'lower_back': 'Alt Sırt / Bel',
    'hip': 'Kalça',
    'left_knee': 'Sol Diz',
    'right_knee': 'Sağ Diz',
    'left_wrist': 'Sol Bilek',
    'right_wrist': 'Sağ Bilek',
    'left_ankle': 'Sol Ayak Bileği',
    'right_ankle': 'Sağ Ayak Bileği',
    'left_elbow': 'Sol Dirsek',
    'right_elbow': 'Sağ Dirsek',
    'core': 'Karın / Core',
  };

  static const List<Map<String, dynamic>> chatMessages = [
    {
      'role': 'assistant',
      'content':
          'Merhaba! Ben PainRelief AI asistanınım. Vücut ağrınızı analiz etmeme yardımcı olmak için birkaç soru soracağım.\n\nHazır olduğunuzda başlayalım. Ağrınızı 1-10 arasında nasıl puanlarsınız?\n\n*1: Çok hafif — 10: Dayanılmaz*',
    },
    {
      'role': 'user',
      'content': '6 olarak puanlarım, oldukça rahatsız edici',
    },
    {
      'role': 'assistant',
      'content':
          'Anlıyorum, 6/10 ciddi bir ağrı. Ağrı nasıl bir his veriyor?\n\n• **Yanma**\n• **Zonklama**\n• **Baskı / Sertlik**\n• **Uyuşma**',
    },
    {
      'role': 'user',
      'content': 'Daha çok baskı ve sertlik hissediyorum',
    },
    {
      'role': 'assistant',
      'content':
          'Teşekkürler. Ağrı ne zaman artıyor?\n\n• Hareket ederken\n• Dinlenirken\n• Sabahları\n• Gece\n• Belirli bir pozisyonda',
    },
  ];
}

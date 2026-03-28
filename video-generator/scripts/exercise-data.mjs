/**
 * Nurai Egzersiz Video Veri Tabanı
 * ─────────────────────────────────
 * Bu dosya tüm egzersizlerin video meta verisini içerir.
 *
 * ID kuralı (Flutter AthleteService._slugifyName ile aynı):
 *   {injuryId}_phase{N}_{slug(exerciseName)}
 *
 * Firebase Storage yolu: exercise-videos/{id}.mp4
 */

/** Türkçe → ASCII slug (Flutter tarafıyla birebir uyumlu) */
function slug(str) {
  return str
    .toLowerCase()
    .replace(/ğ/g, 'g')
    .replace(/ş/g, 's')
    .replace(/ı/g, 'i')
    .replace(/ö/g, 'o')
    .replace(/ü/g, 'u')
    .replace(/ç/g, 'c')
    .replace(/İ/g, 'i')
    .replace(/Ğ/g, 'g')
    .replace(/Ş/g, 's')
    .replace(/Ö/g, 'o')
    .replace(/Ü/g, 'u')
    .replace(/Ç/g, 'c')
    .replace(/[^a-z0-9]/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_|_$/g, '');
}

function ex(injuryId, phase, bodyArea, primaryColor, name, sets, difficulty, description) {
  return {
    id: `${injuryId}_phase${phase}_${slug(name)}`,
    exerciseName: name,
    bodyArea,
    primaryColor,
    sets,
    difficulty,
    description,
  };
}

// ─── Genel Egzersizler (AI analizinde kullanılır) ──────────────────────────
const general = [
  {
    id: 'boyun_sage_esnetme',
    exerciseName: 'Boyun Sağa Esnetme',
    bodyArea: 'Boyun',
    primaryColor: '#006D4E',
    sets: '3×30 sn',
    difficulty: 'Kolay',
    description: 'Başı yavaşça sağ omza doğru yatır, 30 saniye tut.',
  },
  {
    id: 'boyun_sola_esnetme',
    exerciseName: 'Boyun Sola Esnetme',
    bodyArea: 'Boyun',
    primaryColor: '#006D4E',
    sets: '3×30 sn',
    difficulty: 'Kolay',
    description: 'Başı yavaşça sol omza doğru yatır, 30 saniye tut.',
  },
  {
    id: 'omuz_cevirme',
    exerciseName: 'Omuz Çevirme',
    bodyArea: 'Omuz',
    primaryColor: '#006D4E',
    sets: '3×10 tekrar',
    difficulty: 'Kolay',
    description: 'Omuzları ileri–geri dairesel hareketle çevir.',
  },
  {
    id: 'kedi_deve',
    exerciseName: 'Kedi-Deve Egzersizi',
    bodyArea: 'Sırt / Bel',
    primaryColor: '#006D4E',
    sets: '3×10 tekrar',
    difficulty: 'Kolay',
    description: 'Dört ayakta: nefes verirken beli yukarı (kedi), nefes alırken aşağı (deve).',
  },
  {
    id: 'sirt_germe',
    exerciseName: 'Sırt Germe',
    bodyArea: 'Sırt',
    primaryColor: '#006D4E',
    sets: '3×30 sn',
    difficulty: 'Kolay',
    description: 'Kolları öne uzatarak sırt kaslarını ger.',
  },
];

// ─── ACL ──────────────────────────────────────────────────────────────────
const acl = [
  // Faz 1
  ex('acl', 1, 'Diz / ACL', '#EF4444', 'Quad Set', '3×15', 'Kolay', 'Diz düz quad kasılması, 5 sn tut.'),
  ex('acl', 1, 'Diz / ACL', '#EF4444', 'Topuk Kaydırma', '3×10', 'Kolay', 'Sırtüstü yatarak topuğu yavaşça kaydır.'),
  ex('acl', 1, 'Diz / ACL', '#EF4444', 'Düz Bacak Kaldırma', '3×15', 'Kolay', 'Diz düz, bacağı 45° kaldır ve 3 sn tut.'),
  ex('acl', 1, 'Diz / ACL', '#EF4444', 'Buz Uygulaması', '6×/gün', 'Kolay', 'Her 2 saatte 15–20 dakika buz uygula.'),
  // Faz 2
  ex('acl', 2, 'Diz / ACL', '#EF4444', 'Mini Squat (0–60°)', '3×15', 'Orta', 'Duvara destek alarak 60° yarım squat.'),
  ex('acl', 2, 'Diz / ACL', '#EF4444', 'Leg Press', '3×12', 'Orta', '0–60° açıda hafif yük ile leg press.'),
  ex('acl', 2, 'Diz / ACL', '#EF4444', 'Hamstring Curl', '3×12', 'Orta', 'Prone pozisyonda diz bükme.'),
  ex('acl', 2, 'Diz / ACL', '#EF4444', 'Sabit Bisiklet', '1×20 dk', 'Kolay', 'Düşük dirençle 20 dakika pedal.'),
  // Faz 3
  ex('acl', 3, 'Diz / ACL', '#EF4444', 'Tek Bacak Squat', '3×10', 'Zor', 'Yavaş kontrollü iniş–kalkış.'),
  ex('acl', 3, 'Diz / ACL', '#EF4444', 'Step Up/Down', '3×12', 'Orta', '20–30 cm yüksekliğe çıkış–iniş.'),
  ex('acl', 3, 'Diz / ACL', '#EF4444', 'Lateral Band Walk', '3×15', 'Orta', 'Direnç bandıyla yanlara yürüyüş.'),
  ex('acl', 3, 'Diz / ACL', '#EF4444', 'Nordic Hamstring', '3×6', 'Zor', 'Diz bükülerek öne kontrollü eğilme.'),
  // Faz 4
  ex('acl', 4, 'Diz / ACL', '#EF4444', 'Jogging (Düz)', '20–30 dk', 'Orta', 'Düz zeminde hafif koşu.'),
  ex('acl', 4, 'Diz / ACL', '#EF4444', 'Lateral Shuffle', '4×15 m', 'Orta', 'Yanlara hızlı kayma.'),
  ex('acl', 4, 'Diz / ACL', '#EF4444', 'Box Jump (20 cm)', '3×8', 'Zor', '20 cm kutuya iki ayak atlayış.'),
  // Faz 5
  ex('acl', 5, 'Diz / ACL', '#EF4444', 'Sprint Protokolü', '6×40 m', 'Zor', '%60→%80→%100 hız progresyonu.'),
  ex('acl', 5, 'Diz / ACL', '#EF4444', 'Pivot/Kesme Hareketleri', '3×10', 'Zor', 'Kontrollü yön değiştirme.'),
];

// ─── Menisküs ─────────────────────────────────────────────────────────────
const meniscus = [
  ex('meniscus', 1, 'Diz / Menisküs', '#F97316', 'Quad Set', '3×15', 'Kolay', 'Diz düz quad kasılması.'),
  ex('meniscus', 1, 'Diz / Menisküs', '#F97316', 'Straight Leg Raise', '3×15', 'Kolay', 'Diz düz bacak kaldırma.'),
  ex('meniscus', 1, 'Diz / Menisküs', '#F97316', 'Kısa Ark Quad', '3×15', 'Kolay', '0–30° aralıkta kısa ark quad kasılması.'),
  ex('meniscus', 2, 'Diz / Menisküs', '#F97316', 'Leg Press', '3×15', 'Orta', '0–90° açıda leg press.'),
  ex('meniscus', 2, 'Diz / Menisküs', '#F97316', 'Mini Squat', '3×15', 'Orta', 'Desteksiz 60° squat.'),
  ex('meniscus', 2, 'Diz / Menisküs', '#F97316', 'Bisiklet', '1×20 dk', 'Kolay', 'Düşük dirençli sabit bisiklet.'),
  ex('meniscus', 3, 'Diz / Menisküs', '#F97316', 'Step Up/Down', '3×12', 'Orta', '20–30 cm yüksekliğe çıkış–iniş.'),
  ex('meniscus', 3, 'Diz / Menisküs', '#F97316', 'Single Leg Balance', '3×30 sn', 'Orta', 'Tek bacak denge, göz kapalı varyasyon.'),
  ex('meniscus', 3, 'Diz / Menisküs', '#F97316', 'Jogging', '20 dk', 'Orta', 'Düz zeminde hafif koşu.'),
];

// ─── Patellar Tendinopati ─────────────────────────────────────────────────
const patellar = [
  ex('patellar_tendinopathy', 1, 'Diz / Patellar', '#F59E0B', 'İzometrik Leg Extension (60°)', '5×45 sn', 'Orta', '60° açıda statik kasılma, 2 dk dinlenme.'),
  ex('patellar_tendinopathy', 1, 'Diz / Patellar', '#F59E0B', 'İzometrik Squat (60°)', '5×45 sn', 'Orta', 'Duvara yaslı 60° statik squat.'),
  ex('patellar_tendinopathy', 2, 'Diz / Patellar', '#F59E0B', 'Leg Extension (Yavaş)', '4×8', 'Orta', '3 sn indir, 3 sn kaldır — kontrollü.'),
  ex('patellar_tendinopathy', 2, 'Diz / Patellar', '#F59E0B', 'Decline Squat', '3×15', 'Zor', '25° eğimli zemin üzerinde squat.'),
  ex('patellar_tendinopathy', 3, 'Diz / Patellar', '#F59E0B', 'Drop Squat', '3×10', 'Zor', 'Kontrollü hızlanmayla squat.'),
  ex('patellar_tendinopathy', 3, 'Diz / Patellar', '#F59E0B', 'Single Leg Squat', '3×8', 'Zor', 'Tek bacak yavaş iniş.'),
  ex('patellar_tendinopathy', 4, 'Diz / Patellar', '#F59E0B', 'Plyometrik Progresyon', '3×10', 'Zor', 'Bilateral → unilateral → reaktif atlama.'),
  ex('patellar_tendinopathy', 4, 'Diz / Patellar', '#F59E0B', 'Spor-Spesifik Driller', '3 seri', 'Zor', 'Branşa özgü yük ve hız.'),
];

// ─── Ayak Bileği Burkulması ───────────────────────────────────────────────
const ankle = [
  ex('ankle_sprain', 1, 'Ayak Bileği', '#22C55E', 'Alfabe Egzersizi', '3×/gün', 'Kolay', 'Ayakla havaya alfabe çiz.'),
  ex('ankle_sprain', 1, 'Ayak Bileği', '#22C55E', 'Parmak Ucu Yürüyüşü', '3×10 m', 'Kolay', 'Tolere edilebilirse parmak uçlarında yürü.'),
  ex('ankle_sprain', 2, 'Ayak Bileği', '#22C55E', 'Direnç Bandı Eversion', '3×15', 'Orta', 'Bant direncine karşı ayak dışa çevirme.'),
  ex('ankle_sprain', 2, 'Ayak Bileği', '#22C55E', 'Calf Raise', '3×20', 'Orta', 'İki ayakla başla, tek ayağa geç.'),
  ex('ankle_sprain', 2, 'Ayak Bileği', '#22C55E', 'Mini Squat', '3×15', 'Kolay', 'Hafif diz bükümüyle squat.'),
  ex('ankle_sprain', 3, 'Ayak Bileği', '#22C55E', 'Tek Bacak Denge', '3×30 sn', 'Orta', 'Düz → sünger zemin → göz kapalı progresyon.'),
  ex('ankle_sprain', 3, 'Ayak Bileği', '#22C55E', 'Wobble Board', '3×60 sn', 'Orta', 'Denge tahtasında kontrollü sallanma.'),
  ex('ankle_sprain', 4, 'Ayak Bileği', '#22C55E', 'Figure-8 Koşusu', '5×', 'Orta', 'Sekiz şeklinde yavaş koşu.'),
  ex('ankle_sprain', 4, 'Ayak Bileği', '#22C55E', 'Lateral Hop', '3×10', 'Zor', 'Bir ayakla yanlara zıplama.'),
];

// ─── Aşil Tendinopati ─────────────────────────────────────────────────────
const achilles = [
  ex('achilles_tendinopathy', 1, 'Ayak Bileği / Aşil', '#10B981', 'Bilateral Eksantrik Calf (Diz Düz)', '3×15, 2×/gün', 'Orta', 'İki ayakla kalk, tek ayakla in — topuk zemine temas.'),
  ex('achilles_tendinopathy', 1, 'Ayak Bileği / Aşil', '#10B981', 'Bilateral Eksantrik Calf (Diz Bükük)', '3×15, 2×/gün', 'Orta', 'Diz hafif bükük — soleus odaklı.'),
  ex('achilles_tendinopathy', 2, 'Ayak Bileği / Aşil', '#10B981', 'Sırt Çantasıyla Calf Raise', '3×15', 'Zor', '+5–10 kg çanta ile tek bacak eksantrik.'),
  ex('achilles_tendinopathy', 2, 'Ayak Bileği / Aşil', '#10B981', 'Sabit Bisiklet', '20 dk', 'Kolay', 'Düşük direnç aerobik kondisyon.'),
  ex('achilles_tendinopathy', 3, 'Ayak Bileği / Aşil', '#10B981', 'Single Leg Calf Raise', '3×15', 'Zor', 'Tek bacak tam ROM calf raise.'),
  ex('achilles_tendinopathy', 3, 'Ayak Bileği / Aşil', '#10B981', 'Plio Calf Jump', '3×10', 'Zor', 'Hafif atlama — enerji depolama.'),
];

// ─── Rotator Cuff ─────────────────────────────────────────────────────────
const rotatorCuff = [
  ex('rotator_cuff', 1, 'Omuz', '#3B82F6', 'Codman Pendulum', '3×30 sn', 'Kolay', 'Öne eğil, kolu yer çekimiyle serbest salla.'),
  ex('rotator_cuff', 1, 'Omuz', '#3B82F6', 'Rotator Cuff İzometrik', '5×10 sn', 'Kolay', 'Duvara karşı kolun 0° pozisyonunda statik kasılma.'),
  ex('rotator_cuff', 1, 'Omuz', '#3B82F6', 'Skapula Retraksiyon', '3×15', 'Kolay', 'Kürek kemiklerini birbirine yaklaştır.'),
  ex('rotator_cuff', 2, 'Omuz', '#3B82F6', 'Bant İç Rotasyon', '3×15', 'Orta', 'Direnç bandıyla omuz iç rotasyonu.'),
  ex('rotator_cuff', 2, 'Omuz', '#3B82F6', 'Lateral Raise', '3×12', 'Orta', '90°\'ye kadar yanlara kol kaldırma.'),
  ex('rotator_cuff', 2, 'Omuz', '#3B82F6', 'Prone Y-T-W', '3×10', 'Orta', 'Yüzüstü Y, T, W şekillerinde kol kaldırma.'),
  ex('rotator_cuff', 3, 'Omuz', '#3B82F6', 'Overhead Press (Hafif)', '3×12', 'Zor', 'Ağrısız tam ROM overhead press.'),
  ex('rotator_cuff', 3, 'Omuz', '#3B82F6', 'Cable Face Pull', '3×15', 'Orta', 'Kablo ile yüze doğru çekme.'),
];

// ─── Bankart / SLAP ───────────────────────────────────────────────────────
const bankart = [
  ex('bankart_slap', 1, 'Omuz / Bankart', '#6366F1', 'Bilek/El Egzersizleri', '3×15', 'Kolay', 'Atel içinde el ve bilek hareketleri.'),
  ex('bankart_slap', 1, 'Omuz / Bankart', '#6366F1', 'Boyun Germe', '3×20 sn', 'Kolay', 'Yanal boyun kaslarını nazikçe gerin.'),
  ex('bankart_slap', 2, 'Omuz / Bankart', '#6366F1', 'Pulley Egzersizi', '3×10', 'Kolay', 'Sağlam kol ile hasarlı kolu yukarı çek.'),
  ex('bankart_slap', 2, 'Omuz / Bankart', '#6366F1', 'Wand Exercise', '3×10', 'Kolay', 'Çubukla kolu yönlendir.'),
  ex('bankart_slap', 3, 'Omuz / Bankart', '#6366F1', 'Dış Rotasyon (Bant)', '3×15', 'Orta', 'Yan yatarak veya ayakta direnç bandı.'),
  ex('bankart_slap', 3, 'Omuz / Bankart', '#6366F1', 'Single Arm Row', '3×12', 'Orta', 'Kablo veya bant ile sırt çekme.'),
  ex('bankart_slap', 4, 'Omuz / Bankart', '#6366F1', 'İnterval Atış Programı', 'Protokole göre', 'Zor', 'Kısa mesafeden başlayarak kademeli atış.'),
  ex('bankart_slap', 4, 'Omuz / Bankart', '#6366F1', 'Plyometrik Push-up', '3×8', 'Zor', 'Patlayıcı kalkış, yumuşak iniş.'),
];

// ─── Tenis Dirseği ────────────────────────────────────────────────────────
const tennisElbow = [
  ex('tennis_elbow', 1, 'Dirsek', '#8B5CF6', 'Bilek Ekstansör Germe', '3×30 sn', 'Kolay', 'Kol düz, bileği nazikçe aşağı bük.'),
  ex('tennis_elbow', 1, 'Dirsek', '#8B5CF6', 'Ön Kol Sallama (Floss)', '3×30 sn', 'Kolay', 'Kolu hafifçe sallayarak gevşet.'),
  ex('tennis_elbow', 2, 'Dirsek', '#8B5CF6', 'Tyler Twist (FlexBar)', '3×15, 3×/gün', 'Orta', 'FlexBar sağ elle bük, sol elle geri çevir — yavaş.'),
  ex('tennis_elbow', 2, 'Dirsek', '#8B5CF6', 'Eksantrik Bilek Ekstansiyonu', '3×15', 'Orta', 'Sağlam el ile yardımlı kaldır, tek elle in.'),
  ex('tennis_elbow', 2, 'Dirsek', '#8B5CF6', 'Kavrama Egzersizi', '3×15', 'Kolay', 'Yumuşak top veya stres topuyla sıkma.'),
  ex('tennis_elbow', 3, 'Dirsek', '#8B5CF6', 'Ön Kol Pronasyon/Supinasyon', '3×15', 'Orta', 'Dumbbell ile döndürme egzersizi.'),
  ex('tennis_elbow', 3, 'Dirsek', '#8B5CF6', 'Backhand Simülasyonu', '3×15', 'Zor', 'Bant direnciyle raketle hareket simülasyonu.'),
];

// ─── Bel / Disk Hasarı ────────────────────────────────────────────────────
const lumbar = [
  ex('lumbar_disc', 1, 'Bel', '#EC4899', 'McGill Curl-Up', '5–3–1×10 sn', 'Kolay', 'Omurgayı nötr tutarak mini curl-up.'),
  ex('lumbar_disc', 1, 'Bel', '#EC4899', 'Yandan Köprü (Side Bridge)', '5–3–1×10 sn', 'Orta', 'Dirseğe yaslanarak yandan köprü.'),
  ex('lumbar_disc', 1, 'Bel', '#EC4899', 'Bird Dog', '5–3–1×10 sn', 'Orta', 'Dört ayakta karşıt kol-bacak uzatma.'),
  ex('lumbar_disc', 2, 'Bel', '#EC4899', 'Dead Bug', '3×10', 'Orta', 'Sırtüstü karşıt kol-bacak uzatma.'),
  ex('lumbar_disc', 2, 'Bel', '#EC4899', 'Plank', '3×30 sn', 'Orta', 'Düz plank → yan plank progresyonu.'),
  ex('lumbar_disc', 2, 'Bel', '#EC4899', 'Pallof Press', '3×12', 'Orta', 'Kablo ile anti-rotasyon baskı.'),
  ex('lumbar_disc', 3, 'Bel', '#EC4899', 'Romanian Deadlift', '3×12', 'Zor', 'Nötr omurgayla RDL.'),
  ex('lumbar_disc', 3, 'Bel', '#EC4899', 'Goblet Squat', '3×12', 'Orta', 'Göğüste ağırlıkla derin squat.'),
  ex('lumbar_disc', 3, 'Bel', '#EC4899', 'Farmer Carry', '3×20 m', 'Orta', 'Her iki elde ağırlıkla yürüyüş.'),
  ex('lumbar_disc', 4, 'Bel', '#EC4899', 'Landmine Rotation', '3×10', 'Zor', 'Barbell landmine ile rotasyonel güç.'),
  ex('lumbar_disc', 4, 'Bel', '#EC4899', 'Spor-Spesifik Hareket', 'Antrenman planı', 'Zor', 'Branş hareketleri kademeli yükle.'),
];

// ─── Hamstring / Adduktör Strain ─────────────────────────────────────────
const muscle = [
  ex('muscle_strain', 1, 'Hamstring / Kasık', '#64748B', 'Aktif Dinlenme', 'Sürekli', 'Kolay', 'Buz: 15–20 dk, 2 saatte bir.'),
  ex('muscle_strain', 1, 'Hamstring / Kasık', '#64748B', 'Nazik Hamstring Germe', '3×20 sn', 'Kolay', 'Ağrısız aralıkta hafif germe.'),
  ex('muscle_strain', 1, 'Hamstring / Kasık', '#64748B', 'Kısa Yay Hamstring Curl', '3×10', 'Kolay', 'Prone pozisyonda hafif diz bükme.'),
  ex('muscle_strain', 2, 'Hamstring / Kasık', '#64748B', 'Nordic Hamstring (Modifiye)', '3×6', 'Zor', 'Tam eksantrik — bacak altına yastık koy.'),
  ex('muscle_strain', 2, 'Hamstring / Kasık', '#64748B', 'Copenhagen Plank', '3×20 sn', 'Zor', 'Yan yatarak üst bacak destekte plank.'),
  ex('muscle_strain', 2, 'Hamstring / Kasık', '#64748B', 'Hip Thrust', '3×12', 'Orta', 'Sırta bankta kalça itiş.'),
  ex('muscle_strain', 3, 'Hamstring / Kasık', '#64748B', 'Sprint Progresyonu', '%50→%100', 'Zor', 'Kademeli hız artışı protokolü.'),
  ex('muscle_strain', 3, 'Hamstring / Kasık', '#64748B', 'Yön Değiştirme Koşuları', '5×20 m', 'Zor', 'T-test ve çeviklik merdiveni.'),
];

export const exercises = [
  ...general,
  ...acl,
  ...meniscus,
  ...patellar,
  ...ankle,
  ...achilles,
  ...rotatorCuff,
  ...bankart,
  ...tennisElbow,
  ...lumbar,
  ...muscle,
];

export const exerciseCount = exercises.length;

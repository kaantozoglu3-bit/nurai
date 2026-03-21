'use strict';

require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });
const admin = require('../config/firebase');

async function createTestPremium() {
  const email = 'premium@nurai.test';

  // Varsa sil, yoksa oluştur
  let uid;
  try {
    const existing = await admin.auth().getUserByEmail(email);
    uid = existing.uid;
    console.log('Mevcut hesap bulundu, güncelleniyor:', uid);
  } catch {
    const user = await admin.auth().createUser({
      email,
      password: 'Nurai2026!',
      displayName: 'Premium Test',
    });
    uid = user.uid;
    console.log('Yeni hesap oluşturuldu:', uid);
  }

  await admin.firestore().collection('users').doc(uid).set({
    uid,
    email,
    displayName: 'Premium Test',
    premium: true,
    premiumExpiresAt: admin.firestore.Timestamp.fromDate(new Date('2027-12-31')),
    fitnessLevel: 'intermediate',
    age: 25,
    height: 175,
    weight: 70,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  // user_profiles'a da yaz (profil tamamlandı sayılsın)
  await admin.firestore().collection('user_profiles').doc(uid).set({
    uid,
    fitness_level: 'intermediate',
    goal: 'pain_relief',
    age: 25,
    height: 175,
    weight: 70,
    injuries: [],
  }, { merge: true });

  console.log('\n✅ Premium test hesabı hazır');
  console.log('   E-posta : premium@nurai.test');
  console.log('   Şifre   : Nurai2026!');
  console.log('   UID     :', uid);
  console.log('   Premium : true (2027-12-31\'e kadar)');

  process.exit(0);
}

createTestPremium().catch(e => {
  console.error('❌ Hata:', e.message);
  process.exit(1);
});

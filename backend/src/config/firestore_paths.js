'use strict';

/**
 * Centralised Firestore collection/document path helpers.
 * Use these instead of inline string literals to prevent typos
 * and make future migrations easier.
 */
const FirestorePaths = {
  /** user_profiles/{uid} */
  userProfile: (uid) => `user_profiles/${uid}`,

  /** dailyUsage/{uid}/days/{YYYY-MM-DD} */
  dailyUsage: (uid, date) => `dailyUsage/${uid}/days/${date}`,

  /** users/{uid}/analyses */
  userAnalyses: (uid) => `users/${uid}/analyses`,
};

module.exports = FirestorePaths;

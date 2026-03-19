/// Centralised Firestore collection/document path helpers.
/// Use these instead of inline string literals to prevent typos
/// and make future migrations easier.
class FirestorePaths {
  FirestorePaths._();

  /// user_profiles/{uid}
  static String userProfile(String uid) => 'user_profiles/$uid';

  /// users/{uid}/analyses
  static String userAnalyses(String uid) => 'users/$uid/analyses';

  /// dailyUsage/{uid}/days/{YYYY-MM-DD}
  static String dailyUsage(String uid, String date) =>
      'dailyUsage/$uid/days/$date';

  /// users/{uid}/painLogs/{YYYY-MM-DD}
  static String painLog(String uid, String date) =>
      'users/$uid/painLogs/$date';

  /// users/{uid}/painLogs (collection)
  static String painLogs(String uid) => 'users/$uid/painLogs';
}

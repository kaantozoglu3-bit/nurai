class UserModel {
  final String id;
  final String email;
  final String displayName;
  final bool isLoggedIn;
  final bool isProfileComplete;
  final bool isPremium;
  final int dailyAnalysisCount;
  final DateTime? lastAnalysisDate;
  final String userType;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.isLoggedIn = false,
    this.isProfileComplete = false,
    this.isPremium = false,
    this.dailyAnalysisCount = 0,
    this.lastAnalysisDate,
    this.userType = 'general',
  });

  static const int _freeDailyLimit = 3;

  int get remainingAnalyses {
    if (isPremium) return 999;
    final today = DateTime.now();
    if (lastAnalysisDate != null &&
        lastAnalysisDate!.year == today.year &&
        lastAnalysisDate!.month == today.month &&
        lastAnalysisDate!.day == today.day) {
      return (_freeDailyLimit - dailyAnalysisCount).clamp(0, _freeDailyLimit);
    }
    return _freeDailyLimit;
  }

  bool get canAnalyze => isPremium || remainingAnalyses > 0;

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isLoggedIn,
    bool? isProfileComplete,
    bool? isPremium,
    int? dailyAnalysisCount,
    DateTime? lastAnalysisDate,
    String? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isPremium: isPremium ?? this.isPremium,
      dailyAnalysisCount: dailyAnalysisCount ?? this.dailyAnalysisCount,
      lastAnalysisDate: lastAnalysisDate ?? this.lastAnalysisDate,
      userType: userType ?? this.userType,
    );
  }

  static const UserModel empty = UserModel(
    id: '',
    email: '',
    displayName: '',
    userType: 'general',
  );
}

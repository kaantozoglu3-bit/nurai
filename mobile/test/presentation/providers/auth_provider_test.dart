import 'package:flutter_test/flutter_test.dart';
import 'package:painrelief_ai/presentation/providers/auth_provider.dart';

void main() {
  group('AuthState', () {
    test('default constructor has isLoggedIn false', () {
      const state = AuthState();
      expect(state.isLoggedIn, isFalse);
    });

    test('default constructor has isProfileComplete false', () {
      const state = AuthState();
      expect(state.isProfileComplete, isFalse);
    });

    test('default constructor has null user', () {
      const state = AuthState();
      expect(state.user, isNull);
    });

    test('constructor accepts all fields', () {
      const state = AuthState(
        isLoggedIn: true,
        isProfileComplete: true,
      );
      expect(state.isLoggedIn, isTrue);
      expect(state.isProfileComplete, isTrue);
    });

    test('isLoggedIn and isProfileComplete are independent', () {
      const stateLoggedIn = AuthState(isLoggedIn: true, isProfileComplete: false);
      expect(stateLoggedIn.isLoggedIn, isTrue);
      expect(stateLoggedIn.isProfileComplete, isFalse);

      const stateProfileComplete = AuthState(isLoggedIn: false, isProfileComplete: true);
      expect(stateProfileComplete.isLoggedIn, isFalse);
      expect(stateProfileComplete.isProfileComplete, isTrue);
    });
  });
}

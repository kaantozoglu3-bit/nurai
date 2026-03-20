import 'package:flutter_test/flutter_test.dart';
import 'package:painrelief_ai/presentation/providers/marketplace_provider.dart';
import 'package:painrelief_ai/data/models/physiotherapist_model.dart';

void main() {
  group('PtListState', () {
    test('default constructor has empty pts list', () {
      const state = PtListState();
      expect(state.pts, isEmpty);
    });

    test('default constructor has empty filters', () {
      const state = PtListState();
      expect(state.cityFilter, isEmpty);
      expect(state.specializationFilter, isEmpty);
    });

    test('default constructor has isLoadingMore false', () {
      const state = PtListState();
      expect(state.isLoadingMore, isFalse);
    });

    test('default constructor has hasMore false', () {
      const state = PtListState();
      expect(state.hasMore, isFalse);
    });

    test('default constructor has null lastDocument', () {
      const state = PtListState();
      expect(state.lastDocument, isNull);
    });

    test('copyWith updates cityFilter', () {
      const state = PtListState();
      final updated = state.copyWith(cityFilter: 'Istanbul');
      expect(updated.cityFilter, 'Istanbul');
      expect(updated.specializationFilter, isEmpty); // unchanged
    });

    test('copyWith updates specializationFilter', () {
      const state = PtListState();
      final updated = state.copyWith(specializationFilter: 'Ortopedi');
      expect(updated.specializationFilter, 'Ortopedi');
    });

    test('copyWith can clear lastDocument', () {
      const state = PtListState();
      final updated = state.copyWith(clearLastDocument: true);
      expect(updated.lastDocument, isNull);
    });

    test('filtered returns all when no filters', () {
      final pt = PhysiotherapistModel(
        uid: '1',
        name: 'Test PT',
        title: 'Fizyoterapist',
        bio: 'Bio',
        city: 'Istanbul',
        specializations: ['Ortopedi'],
        yearsExperience: 5,
        diplomaInstitution: 'Test Uni',
        status: 'approved',
        createdAt: DateTime.now(),
      );
      final state = PtListState(pts: [pt]);
      expect(state.filtered.length, 1);
    });

    test('filtered filters by city', () {
      final pt1 = PhysiotherapistModel(
        uid: '1',
        name: 'PT A',
        title: 'Fizyoterapist',
        bio: 'Bio',
        city: 'Istanbul',
        specializations: ['Ortopedi'],
        yearsExperience: 5,
        diplomaInstitution: 'Test Uni',
        status: 'approved',
        createdAt: DateTime.now(),
      );
      final pt2 = PhysiotherapistModel(
        uid: '2',
        name: 'PT B',
        title: 'Fizyoterapist',
        bio: 'Bio',
        city: 'Ankara',
        specializations: ['Ortopedi'],
        yearsExperience: 3,
        diplomaInstitution: 'Test Uni',
        status: 'approved',
        createdAt: DateTime.now(),
      );
      final state = PtListState(
        pts: [pt1, pt2],
        cityFilter: 'Istanbul',
      );
      final filtered = state.filtered;
      expect(filtered.length, 1);
      expect(filtered.first.city, 'Istanbul');
    });

    test('filtered filters by specialization', () {
      final pt1 = PhysiotherapistModel(
        uid: '1',
        name: 'PT A',
        title: 'Fizyoterapist',
        bio: 'Bio',
        city: 'Istanbul',
        specializations: ['Ortopedi'],
        yearsExperience: 5,
        diplomaInstitution: 'Test Uni',
        status: 'approved',
        createdAt: DateTime.now(),
      );
      final pt2 = PhysiotherapistModel(
        uid: '2',
        name: 'PT B',
        title: 'Fizyoterapist',
        bio: 'Bio',
        city: 'Istanbul',
        specializations: ['Nöroloji'],
        yearsExperience: 3,
        diplomaInstitution: 'Test Uni',
        status: 'approved',
        createdAt: DateTime.now(),
      );
      final state = PtListState(
        pts: [pt1, pt2],
        specializationFilter: 'Ortopedi',
      );
      final filtered = state.filtered;
      expect(filtered.length, 1);
      expect(filtered.first.name, 'PT A');
    });

    test('filtered filters by both city and specialization', () {
      final pt = PhysiotherapistModel(
        uid: '1',
        name: 'PT A',
        title: 'Fizyoterapist',
        bio: 'Bio',
        city: 'Istanbul',
        specializations: ['Ortopedi'],
        yearsExperience: 5,
        diplomaInstitution: 'Test Uni',
        status: 'approved',
        createdAt: DateTime.now(),
      );
      final state = PtListState(
        pts: [pt],
        cityFilter: 'Ankara',
        specializationFilter: 'Ortopedi',
      );
      expect(state.filtered, isEmpty);
    });
  });
}

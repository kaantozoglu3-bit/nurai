import 'models/exercise_library_model.dart';
import 'exercise_library/neck_exercises.dart';
import 'exercise_library/lower_back_exercises.dart';
import 'exercise_library/shoulder_exercises.dart';
import 'exercise_library/upper_back_exercises.dart';
import 'exercise_library/hip_exercises.dart';
import 'exercise_library/knee_exercises.dart';
import 'exercise_library/elbow_exercises.dart';
import 'exercise_library/wrist_exercises.dart';
import 'exercise_library/ankle_exercises.dart';
import 'exercise_library/core_exercises.dart';

const List<BodyAreaLibrary> exerciseLibrary = [
  neckExercises,
  lowerBackExercises,
  leftShoulderExercises,
  rightShoulderExercises,
  upperBackExercises,
  hipExercises,
  leftKneeExercises,
  rightKneeExercises,
  leftElbowExercises,
  rightElbowExercises,
  leftWristExercises,
  rightWristExercises,
  leftAnkleExercises,
  rightAnkleExercises,
  coreExercises,
];

List<ExerciseLibraryItem> getExercisesForArea(String bodyArea) {
  final match = exerciseLibrary.where((lib) => lib.key == bodyArea).toList();
  if (match.isEmpty) return [];
  return match.first.exercises;
}

List<ExerciseLibraryItem> getExercisesForPainLevel(
  String bodyArea,
  int painLevel,
) {
  final all = getExercisesForArea(bodyArea);

  if (painLevel >= 7) {
    // Sadece Rehabilitasyon göster + uyarı
    return all
        .where(
          (e) => e.rehabPhase == 'acute' || e.phase == 'Rehabilitasyon',
        )
        .toList();
  } else if (painLevel >= 4) {
    // Akut + Rehabilitasyon
    return all
        .where(
          (e) => e.phase == 'Akut' || e.phase == 'Rehabilitasyon',
        )
        .toList();
  } else {
    // Tüm fazlar
    return all;
  }
}

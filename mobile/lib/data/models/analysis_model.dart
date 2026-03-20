class AnalysisModel {
  final String id;
  final String bodyArea;
  final String bodyAreaLabel;
  final int painScore;
  final String userComplaint;
  final String aiSummary;
  final List<String> possibleCauses;
  final List<ExerciseModel> exercises;
  final List<VideoModel> videos;
  final DateTime createdAt;

  const AnalysisModel({
    required this.id,
    required this.bodyArea,
    required this.bodyAreaLabel,
    required this.painScore,
    required this.userComplaint,
    required this.aiSummary,
    required this.possibleCauses,
    required this.exercises,
    required this.videos,
    required this.createdAt,
  });
}

class ExerciseModel {
  final String name;
  final String description;
  final String difficulty;
  final String duration;
  final String? videoId;

  const ExerciseModel({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    this.videoId,
  });
}

class VideoModel {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String duration;

  const VideoModel({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.duration,
  });
}

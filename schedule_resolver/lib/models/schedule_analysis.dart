class ScheduleAnalysis {
  final String conflicts;
  final String rankedTasks;
  final String recommendedSchedule;
  final String explanation;

  ScheduleAnalysis ({
  required this.conflicts, required this.explanation, required this.rankedTasks, required this.recommendedSchedule,
  });

}
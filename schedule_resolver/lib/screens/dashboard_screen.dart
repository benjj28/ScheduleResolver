import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/ai_schedule_service.dart';
import '../models/task_model.dart';
import 'task_input_screen.dart';
import 'recommendation_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final aiService = Provider.of<AiScheduleService>(context);

    // FIX: Sort by both hour and minute for a correct chronological list
    final sortedTasks = List<TaskModel>.from(scheduleProvider.tasks);
    sortedTasks.sort((a, b) {
      final hourCompare = a.startTime.hour.compareTo(b.startTime.hour);
      if (hourCompare != 0) return hourCompare;
      return a.startTime.minute.compareTo(b.startTime.minute);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Resolver'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (aiService.currentAnalysis != null)
              Card(
                color: Colors.green.shade100,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        children: [
                          const Text('🎉 Recommendation Ready!',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RecommendationScreen())
                              ),
                              child: const Text('View Recommendations'))
                        ]
                    )
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: sortedTasks.isEmpty
                  ? const Center(child: Text('No tasks added yet!'))
                  : ListView.builder(
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];

                  // FIX: Format time to show leading zeros (e.g., 09:05)
                  final hour = task.startTime.hour.toString().padLeft(2, '0');
                  final minute = task.startTime.minute.toString().padLeft(2, '0');

                  return Card(
                    child: ListTile(
                      title: Text(task.title),
                      // FIX: Removed backslashes (\) from interpolation
                      subtitle: Text("${task.category} | $hour:$minute"),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => scheduleProvider.removeTask(task.id)
                      ),
                    ),
                  );
                },
              ),
            ),
            if (sortedTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50), // Better UI
                  ),
                  onPressed: aiService.isLoading ? null : () => aiService.analyzeSchedule(scheduleProvider.tasks),
                  // FIX: Constrained the size of the loading indicator
                  child: aiService.isLoading
                      ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  )
                      : const Text('Resolve Conflicts With AI'),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskInputScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
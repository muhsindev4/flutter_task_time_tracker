import 'package:flutter/material.dart';
import 'package:flutter_task_time_tracker/flutter_task_time_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterTaskTimeTracker().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Time Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TimerHomePage(),
    );
  }
}




class TimerHomePage extends StatefulWidget {
  const TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage> {
  late TimerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimerController(
      onStarted: (d){

      }
    );
    _controller.loadLastTimer(); // optional, if you want to load last session
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startNewTimer() async {
    await _controller.initTimer(
      taskId: 'task_13',
      taskName: 'Sample Task',
      startedAt: DateTime.now(),
    );
    _controller.startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Time Tracker')),
      body: StreamBuilder<TimerData?>(
        stream: _controller.timerStream,
        builder: (context, snapshot) {
          final timerData = snapshot.data;
          final time = _controller.getFormattedTime();
          final taskName = timerData?.taskName ?? 'No Task';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Task: $taskName", style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 10),
                Text(time, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: _startNewTimer,
                      child: const Text("Start"),
                    ),
                    ElevatedButton(
                      onPressed: _controller.pauseTimer,
                      child: const Text("Pause"),
                    ),
                    ElevatedButton(
                      onPressed: _controller.resumeTimer,
                      child: const Text("Resume"),
                    ),
                    ElevatedButton(
                      onPressed: _controller.stopTimer,
                      child: const Text("Stop"),
                    ),
                    ElevatedButton(
                      onPressed: _controller.resetTimer,
                      child: const Text("Reset"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

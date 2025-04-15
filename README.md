# ⏱️ Flutter Task Time Tracker

A lightweight and persistent Flutter plugin to track time spent on tasks with background support and interactive notifications.

---
![A digital illustration showcasing the Flutter Task Time Tracker plugin. It features Flutter’s logo, task icons, clocks, and UI elements representing cross-platform time tracking. The layout emphasizes productivity, with a modern blue and white color palette.](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*fbNSfXjpkE91wunpENrcaA.png)

## ✨ Features

- ⏳ Start, pause, resume, and stop timers
- 🔔 Awesome Notifications with interactive buttons
- 💾 Hive-based local storage for timer persistence
- 💥 Recover lost time when app is terminated
- 🧠 Singleton-based architecture for easy access
- 📡 Real-time updates using StreamController

---

## 📦 Installation

Add this to your `pubspec.yaml`:

    dependencies:
      flutter_task_time_tracker: latest

## 🚀 Getting Started

### 1️⃣ Import the plugin

    import 'package:flutter_task_time_tracker/flutter_task_time_tracker.dart';

### 2️⃣ Initialize the tracker

    await FlutterTaskTimeTracker().init(
      addSecondsWhenTerminatedState: true,
      autoStart: true,
    );

### 3️⃣ Access the timer controller

    final timerController = FlutterTaskTimeTracker().timer;

OR

     final TimerController _controller=TimerController();

## 🔁 Usage

### Start a new timer:

    await timerController.initTimer(
      taskName: 'TaskName,
      taskId: 'task_001',
    );
    timerController.startTimer();
### Pause / Resume / Stop:

    timerController.pauseTimer();
    timerController.resumeTimer();
    timerController.stopTimer();

### Reset Timer:

    timerController.resetTimer();
### Listen to timer stream:

    timerController.timerStream.listen((timerData) {
      print('⏲️ Time: ${timerData?.totalTimeInSeconds}');
    });

## 🔔 Notifications

Interactive notifications are handled using `awesome_notifications`. When active, users can pause, resume, or stop tasks directly from the notification.

Make sure to configure permissions for Android and iOS as per the awesome_notifications setup guide.

## 📂 Data Persistence

Timers are saved in Hive box:

-   Each change to the timer updates the stored data.

-   On app restart or crash, the last state is recovered.

-   `addSecondsWhenTerminatedState` helps recover the time lost while app was terminated.

## 🧪 Methods Overview



`init()`: Initializes Hive and Notifications

`initTimer()`: Sets a new task timer



`startTimer()`: Starts the timer



`pauseTimer()`:Pauses the timer



`resumeTimer()`:Resumes the paused timer



`stopTimer()`: Stops the timer



`resetTimer()`: Resets the timer and clears timestamps



`getAllTimers()`: Fetches all saved timer sessions



`getCurrentTimer()`: Gets the currently active timer



`deleteCurrentTimer()`: Deletes the current timer



`getFormattedTime()`: Returns formatted elapsed time


import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';

import '../../flutter_task_time_tracker.dart';
import '../utils/const.dart';

class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  Future<void> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Show a dialog or info before requesting
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> initNotification() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: Const.notificationChannelKey,
        channelName: 'Timer Notifications',
        channelDescription: 'Notification for active task timers',
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ], debug: true);

    // Add this line to register listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
    );
  }

  void showNotification(TimerData timerData) async {
    // List<NotificationActionButton> actionButtons = [];
    //
    // switch (timerData.timerStatus) {
    //   case TimerStatus.started:
    //   case TimerStatus.resumed:
    //     actionButtons = [
    //       NotificationActionButton(
    //         key: 'PAUSE',
    //         label: 'Pause',
    //         actionType: ActionType.SilentAction,
    //         autoDismissible: false,
    //       ),
    //       NotificationActionButton(
    //         key: 'STOP',
    //         label: 'Stop',
    //         actionType: ActionType.SilentAction,
    //         isDangerousOption: true,
    //         autoDismissible: false,
    //       ),
    //     ];
    //     break;
    //
    //   case TimerStatus.paused:
    //     actionButtons = [
    //       NotificationActionButton(
    //         key: 'RESUME',
    //         label: 'Resume',
    //         actionType: ActionType.SilentAction,
    //         autoDismissible: false,
    //       ),
    //       NotificationActionButton(
    //         key: 'STOP',
    //         label: 'Stop',
    //         actionType: ActionType.SilentAction,
    //         isDangerousOption: true,
    //         autoDismissible: false,
    //       ),
    //     ];
    //     break;
    //
    //   case TimerStatus.stopped:
    //     // Dismiss notification
    //     await AwesomeNotifications().cancel(1001);
    //     return;
    //   case TimerStatus.notStarted:
    //     return;
    // }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1001,
        channelKey: Const.notificationChannelKey,
        title: '⏱️ ${timerData.taskName}',
        body:
            timerData.timerStatus == TimerStatus.stopped
                ? 'Timer is stopped.'
                : timerData.timerStatus == TimerStatus.paused
                ? 'Timer is paused.'
                : 'Timer is running...',
        wakeUpScreen: true,
        locked: true,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Progress,
        autoDismissible: false,
        backgroundColor: const Color(0xFF2196F3),
        showWhen: true,
        chronometer:
            (timerData.timerStatus == TimerStatus.started ||
                    timerData.timerStatus == TimerStatus.resumed)
                ? Duration(seconds: timerData.totalTimeInSeconds)
                : null,
        payload: {'taskId': timerData.taskId},
      ),
      // actionButtons: actionButtons,
    );
  }
}

@pragma('vm:entry-point')
Future<void> onActionReceived(ReceivedAction action) async {
  switch (action.buttonKeyPressed) {
    case 'PAUSE':
      TimerController().pauseTimer();
      break;
    case 'RESUME':
      TimerController().resumeTimer();
      break;
    case 'STOP':
      TimerController().stopTimer();
      break;
  }
}

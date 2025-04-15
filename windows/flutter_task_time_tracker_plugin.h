#ifndef FLUTTER_PLUGIN_FLUTTER_TASK_TIME_TRACKER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_TASK_TIME_TRACKER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_task_time_tracker {

class FlutterTaskTimeTrackerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterTaskTimeTrackerPlugin();

  virtual ~FlutterTaskTimeTrackerPlugin();

  // Disallow copy and assign.
  FlutterTaskTimeTrackerPlugin(const FlutterTaskTimeTrackerPlugin&) = delete;
  FlutterTaskTimeTrackerPlugin& operator=(const FlutterTaskTimeTrackerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_task_time_tracker

#endif  // FLUTTER_PLUGIN_FLUTTER_TASK_TIME_TRACKER_PLUGIN_H_

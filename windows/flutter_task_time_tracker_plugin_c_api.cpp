#include "include/flutter_task_time_tracker/flutter_task_time_tracker_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_task_time_tracker_plugin.h"

void FlutterTaskTimeTrackerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_task_time_tracker::FlutterTaskTimeTrackerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

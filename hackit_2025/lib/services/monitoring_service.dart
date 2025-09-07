import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';


const String STOP_MONITORING_SERVICE_KEY = 'stop';
const String SET_APPS_NAME_FOR_MONITORING_KEY = "setAppsNames";
const String APP_NAMES_LIST_KEY = "appNames";


// Entry point for monitoring isolate
onMonitoringServiceStart(ServiceInstance service) async {
  // Idk why need initialize yet
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize database to store data later on
  
  
}    
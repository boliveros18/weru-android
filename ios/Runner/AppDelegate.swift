import Flutter
import UIKit
import flutter_background_service_ios
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "your.custom.task.identifier"
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in GeneratedPluginRegistrant.register(with: registry)}
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOs 10.0, *){
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Configure background app refresh for iOS
    if #available(iOS 13.0, *) {
      // Enable background app refresh
      application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }
    
    // Register WorkManager background task for auto-signing
    WorkmanagerPlugin.registerBGProcessingTask(
      withIdentifier: "auto_signing_task"
    )
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle background app refresh
  override func application(
    _ application: UIApplication,
    performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // This allows the app to continue background processing
    // The Flutter side will handle the actual background tasks
    print("iOS: Background fetch triggered for auto-signing")
    completionHandler(.newData)
  }
  
  // Handle background processing
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // Handle background notifications if needed
    print("iOS: Background notification received for auto-signing")
    completionHandler(.newData)
  }
  
  // Handle background processing tasks
  override func application(
    _ application: UIApplication,
    handleEventsForBackgroundURLSession identifier: String,
    completionHandler: @escaping () -> Void
  ) {
    // Handle background URL session events
    print("iOS: Background URL session event for auto-signing")
    completionHandler()
  }
}

import UIKit
import Flutter
//import Au10tixCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
//    Add the line below to use bundled resources instead of server
//    Au10tix.shared.assetsManagerConfigurations.assetsSource = .bundle(.main)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

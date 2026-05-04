import Flutter
import UIKit
import GoogleMaps // <-- BURAYA GOOGLE MAPS EKLENDİ

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // <-- BURAYA SENİN API KEY EKLENDİ
    GMSServices.provideAPIKey("AIzaSyAgBG8RFM4qpV9UoP6fGynrikC-4_Sfrxo") 
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
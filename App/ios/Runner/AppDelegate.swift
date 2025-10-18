import Flutter
import UIKit
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 注册原生广告工厂 - 标准尺寸
    let nativeAdFactory = NativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "listTile", nativeAdFactory: nativeAdFactory)
    
    // 注册原生广告工厂 - 小尺寸
    let nativeAdFactoryMini = NativeAdFactoryMini()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "listTileMini", nativeAdFactory: nativeAdFactoryMini)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationWillTerminate(_ application: UIApplication) {
    // 取消注册原生广告工厂
    FLTGoogleMobileAdsPlugin.unregisterNativeAdFactory(self, factoryId: "listTile")
    FLTGoogleMobileAdsPlugin.unregisterNativeAdFactory(self, factoryId: "listTileMini")
  }
}

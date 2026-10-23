import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  private var blankView: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let drmChannel = FlutterMethodChannel(name: "com.ecosusrural.security/drm",
                                              binaryMessenger: controller.binaryMessenger)
    
    drmChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      if call.method == "secureScreen" {
          self.setupScreenRecordingProtection(controller: controller)
          result("Screen Secured")
      } else if call.method == "unsecureScreen" {
          self.removeScreenRecordingProtection()
          result("Screen Unsecured")
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  private func setupScreenRecordingProtection(controller: UIViewController) {
      // Listen for iOS Screen Recording
      NotificationCenter.default.addObserver(self, selector: #selector(preventScreenRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
  }

  private func removeScreenRecordingProtection() {
      NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
  }

  @objc private func preventScreenRecording() {
      let isCaptured = UIScreen.main.isCaptured
      
      if isCaptured {
          // If recording starts, cover the screen with a black view
          blankView = UIView(frame: self.window?.bounds ?? UIScreen.main.bounds)
          blankView?.backgroundColor = UIColor.black
          
          let warningLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
          warningLabel.center = blankView!.center
          warningLabel.textColor = .white
          warningLabel.textAlignment = .center
          warningLabel.numberOfLines = 0
          warningLabel.text = "EcoSusRural Security\nScreen recording is strictly prohibited."
          blankView?.addSubview(warningLabel)
          
          self.window?.addSubview(blankView!)
      } else {
          // Recording stopped, remove the black view
          blankView?.removeFromSuperview()
          blankView = nil
      }
  }
}
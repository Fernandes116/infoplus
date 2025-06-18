import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.ussd.infoplus/payment"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("RootViewController is not a FlutterViewController")
    }

    let ussdChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    ussdChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      if call.method == "sendUssd" {
        guard let args = call.arguments as? [String: Any],
              let code = args["code"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Código USSD não informado", details: nil))
          return
        }
        self.sendUssd(code: code, result: result)
      } else if call.method == "startPayment" {
        result("startPayment não implementado no iOS")
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func sendUssd(code: String, result: FlutterResult) {
    // iOS não permite discagem USSD automática. Abre o app Telefone para o usuário confirmar.
    if let url = URL(string: "tel://\(code)") {
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        result(nil)
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "Não foi possível abrir o aplicativo de telefone", details: nil))
      }
    } else {
      result(FlutterError(code: "INVALID_CODE", message: "Código USSD inválido", details: nil))
    }
  }
}

import Flutter
import MessageUI
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let composer = ComposerChannel()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "QuoteComposer") {
      composer.register(messenger: registrar.messenger())
    }
  }
}

/// Native Messages composer with the quote PDF attached (PRD §8.4).
/// Methods: `canSendText`, `canSendMail`, `sendText` → "sent" | "cancelled" | "failed".
final class ComposerChannel: NSObject, MFMessageComposeViewControllerDelegate {
  private var channel: FlutterMethodChannel?
  private var pending: FlutterResult?

  func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "quotesheaf/composer", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in self?.handle(call, result: result) }
    self.channel = channel
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "canSendText":
      result(MFMessageComposeViewController.canSendText() && MFMessageComposeViewController.canSendAttachments())
    case "canSendMail":
      result(MFMailComposeViewController.canSendMail())
    case "sendText":
      sendText(call.arguments as? [String: Any] ?? [:], result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func sendText(_ args: [String: Any], result: @escaping FlutterResult) {
    guard MFMessageComposeViewController.canSendText(), MFMessageComposeViewController.canSendAttachments() else {
      result(FlutterError(code: "not_available", message: "This device can't send texts with attachments.", details: nil))
      return
    }
    guard pending == nil, let presenter = Self.topViewController() else {
      result(FlutterError(code: "busy", message: "A composer is already open.", details: nil))
      return
    }
    let vc = MFMessageComposeViewController()
    vc.messageComposeDelegate = self
    vc.recipients = args["recipients"] as? [String]
    vc.body = args["body"] as? String
    if let path = args["attachmentPath"] as? String {
      let url = URL(fileURLWithPath: path)
      vc.addAttachmentURL(url, withAlternateFilename: url.lastPathComponent)
    }
    pending = result
    presenter.present(vc, animated: true)
  }

  func messageComposeViewController(
    _ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult
  ) {
    let outcome: String
    switch result {
    case .sent: outcome = "sent"
    case .cancelled: outcome = "cancelled"
    default: outcome = "failed"
    }
    controller.dismiss(animated: true) { [weak self] in
      self?.pending?(outcome)
      self?.pending = nil
    }
  }

  private static func topViewController() -> UIViewController? {
    let scene = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState == .foregroundActive } ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
    var top = scene?.windows.first { $0.isKeyWindow }?.rootViewController ?? scene?.windows.first?.rootViewController
    while let presented = top?.presentedViewController { top = presented }
    return top
  }
}

import UIKit
import Flutter
import CoreHaptics

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var hapticEngine: CHHapticEngine?
  private let hapticChannelName = "com.vellum.haptics/core"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let hapticChannel = FlutterMethodChannel(
      name: hapticChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    // Pre-warm CoreHaptics Engine
    setupCoreHaptics()

    hapticChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      switch call.method {
      case "triggerKeyTap":
        let intensity = (call.arguments as? [String: Any])?["intensity"] as? Float ?? 0.6
        let sharpness = (call.arguments as? [String: Any])?["sharpness"] as? Float ?? 0.5
        self.playTransientHaptic(intensity: intensity, sharpness: sharpness)
        result(true)
      case "triggerWaxStamp":
        self.playWaxSealHaptic()
        result(true)
      case "triggerErrorShake":
        self.playErrorHaptic()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
  }

  private func setupCoreHaptics() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    do {
      hapticEngine = try CHHapticEngine()
      try hapticEngine?.start()
    } catch {
      print("CoreHaptics initialization error: \(error)")
    }
  }

  private func playTransientHaptic(intensity: Float, sharpness: Float) {
    guard let engine = hapticEngine else { return }
    var events = [CHHapticEvent]()
    let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
    let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
    let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParam, sharpnessParam], relativeTime: 0)
    events.append(event)

    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    } catch {
      print("Failed to play haptic: \(error)")
    }
  }

  private func playWaxSealHaptic() {
    guard let engine = hapticEngine else { return }
    var events = [CHHapticEvent]()
    // Heavy solid impact + continuous warm decay
    let impact = CHHapticEvent(
      eventType: .hapticTransient,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
      ],
      relativeTime: 0
    )
    let squish = CHHapticEvent(
      eventType: .hapticContinuous,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
      ],
      relativeTime: 0.05,
      duration: 0.15
    )
    events.append(impact)
    events.append(squish)

    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    } catch {
      print("Failed to play wax seal haptic: \(error)")
    }
  }

  private func playErrorHaptic() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
  }
}

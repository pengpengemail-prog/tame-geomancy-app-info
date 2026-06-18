import Foundation
import Combine
import CoreMotion
import CoreLocation

struct CompassSimulationReading: Equatable {
    let magneticHeading: Double
    let trueNorthHeading: Double?
    let pitch: Double
    let roll: Double
    let magneticFieldStrength: Double

    static let simulatorDefault = CompassSimulationReading(
        magneticHeading: 182.5,
        trueNorthHeading: 184.2,
        pitch: 1.2,
        roll: 0.8,
        magneticFieldStrength: 46
    )

    func resolvedHeading(useTrueNorth: Bool) -> Double {
        let value = useTrueNorth ? (trueNorthHeading ?? magneticHeading) : magneticHeading
        return Self.normalize(value)
    }

    func resolvedNaqiHeading(useTrueNorth: Bool) -> Double {
        Self.normalize(resolvedHeading(useTrueNorth: useTrueNorth) + 7.5)
    }

    static func normalize(_ value: Double) -> Double {
        let normalized = value.truncatingRemainder(dividingBy: 360)
        return normalized >= 0 ? normalized : normalized + 360
    }
}

enum CompassSimulationResolver {
    static func resolve(
        processInfo: ProcessInfo = .processInfo,
        motionAvailable: Bool,
        isSimulatorBuild: Bool = simulatorBuild
    ) -> CompassSimulationReading? {
        if let reading = resolve(arguments: processInfo.arguments, environment: processInfo.environment) {
            return reading
        }

        if isSimulatorBuild && !motionAvailable {
            return .simulatorDefault
        }

        return nil
    }

    static func resolve(arguments: [String], environment: [String: String]) -> CompassSimulationReading? {
        if let optionIndex = arguments.firstIndex(of: "-TAMEMockHeading") {
            let nextIndex = arguments.index(after: optionIndex)
            if nextIndex < arguments.endIndex,
               let reading = parseHeading(arguments[nextIndex], environment: environment) {
                return reading
            }
        }

        if let inlineOption = arguments.first(where: { $0.hasPrefix("--tame-mock-heading=") }) {
            let value = String(inlineOption.dropFirst("--tame-mock-heading=".count))
            if let reading = parseHeading(value, environment: environment) {
                return reading
            }
        }

        if let environmentValue = environment["TAME_MOCK_HEADING"],
           let reading = parseHeading(environmentValue, environment: environment) {
            return reading
        }

        return nil
    }

    private static func parseHeading(_ rawValue: String, environment: [String: String]) -> CompassSimulationReading? {
        guard let heading = Double(rawValue.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }

        let trueNorthHeading = environment["TAME_MOCK_TRUE_HEADING"].flatMap(Double.init) ?? (heading + 1.7)
        let pitch = environment["TAME_MOCK_PITCH"].flatMap(Double.init) ?? CompassSimulationReading.simulatorDefault.pitch
        let roll = environment["TAME_MOCK_ROLL"].flatMap(Double.init) ?? CompassSimulationReading.simulatorDefault.roll
        let magneticFieldStrength = environment["TAME_MOCK_FIELD"].flatMap(Double.init) ?? CompassSimulationReading.simulatorDefault.magneticFieldStrength

        return CompassSimulationReading(
            magneticHeading: heading,
            trueNorthHeading: trueNorthHeading,
            pitch: pitch,
            roll: roll,
            magneticFieldStrength: magneticFieldStrength
        )
    }

    private static var simulatorBuild: Bool {
#if targetEnvironment(simulator)
        true
#else
        false
#endif
    }
}

class CompassViewModel: NSObject, ObservableObject {
    @Published var heading: Double = 0.0
    @Published var naqiHeading: Double = 7.5
    @Published var currentDirection: String = TAMEL10n.text("正北", "North")
    @Published var magneticFieldStrength: Double = 0.0
    @Published var showNaqiDisk: Bool = false
    @Published var isLocked: Bool = false
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var northModeLabel: String = TAMEL10n.text("磁北", "Magnetic North")
    @Published var trueNorthAvailable: Bool = false
    @Published var usingSimulatedReadings: Bool = false
    @Published var sensorStatusMessage: String?

    private let motionManager = CMMotionManager()
    private let locationManager = CLLocationManager()
    private let motionActivityManager = CMMotionActivityManager()
    private let simulatedReading: CompassSimulationReading?
    private var lockedHeading: Double?
    private var lastMagneticHeading: Double = 0.0
    private var lastTrueNorthHeading: Double?
    private var useTrueNorth = false
    private var isReceivingHeadingUpdates = false

    override init() {
        simulatedReading = CompassSimulationResolver.resolve(
            motionAvailable: motionManager.isDeviceMotionAvailable
        )
        super.init()
        locationManager.delegate = self
        setupSensors()
    }

    private func setupSensors() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.showsDeviceMovementDisplay = true
        }

        locationManager.headingFilter = 1
        updateNorthModeLabel()
    }

    func startUpdating() {
        if let simulatedReading {
            usingSimulatedReadings = true
            sensorStatusMessage = TAMEL10n.text("当前为参考读数，设备支持实时传感器时会自动切换。", "Reference readings are shown right now and switch to live compass data when sensors are available.")
            applySimulatedReading(simulatedReading)
            return
        }

        usingSimulatedReadings = false
        requestMotionPermissionIfNeeded()
        startHeadingUpdatesIfPossible()
        restartMotionUpdates()
        updateSensorStatusMessage()
    }

    func stopUpdating() {
        motionManager.stopDeviceMotionUpdates()
        locationManager.stopUpdatingHeading()
        isReceivingHeadingUpdates = false
    }

    func updateConfiguration(useTrueNorth: Bool) {
        let didChange = self.useTrueNorth != useTrueNorth
        self.useTrueNorth = useTrueNorth

        if simulatedReading != nil {
            usingSimulatedReadings = true
            updateNorthModeLabel()
            if let simulatedReading {
                applySimulatedReading(simulatedReading)
            }
            return
        }

        if useTrueNorth,
           locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        startHeadingUpdatesIfPossible()

        if didChange {
            restartMotionUpdates()
        } else {
            applyHeadingUpdate()
        }

        updateSensorStatusMessage()
    }

    func lockHeading() {
        isLocked.toggle()
        if isLocked {
            lockedHeading = heading
        } else {
            lockedHeading = nil
            if let simulatedReading {
                applySimulatedReading(simulatedReading)
            } else {
                applyHeadingUpdate()
            }
        }
    }

    private func restartMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()

        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.startDeviceMotionUpdates(using: preferredReferenceFrame(), to: .main) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }

            self.pitch = motion.attitude.pitch * 180 / .pi
            self.roll = motion.attitude.roll * 180 / .pi

            let magneticField = motion.magneticField.field
            self.magneticFieldStrength = sqrt(
                pow(magneticField.x, 2) +
                pow(magneticField.y, 2) +
                pow(magneticField.z, 2)
            )

            if !self.isReceivingHeadingUpdates {
                self.lastMagneticHeading = self.normalize(motion.heading * 180 / .pi)
                self.applyHeadingUpdate()
            }
        }
    }

    private func preferredReferenceFrame() -> CMAttitudeReferenceFrame {
        let availableFrames = CMMotionManager.availableAttitudeReferenceFrames()

        if useTrueNorth, availableFrames.contains(.xTrueNorthZVertical) {
            return .xTrueNorthZVertical
        }

        return .xMagneticNorthZVertical
    }

    private func startHeadingUpdatesIfPossible() {
        guard simulatedReading == nil else {
            isReceivingHeadingUpdates = false
            trueNorthAvailable = useTrueNorth
            updateNorthModeLabel()
            return
        }

        guard CLLocationManager.headingAvailable() else {
            isReceivingHeadingUpdates = false
            if useTrueNorth {
                trueNorthAvailable = false
            }
            updateNorthModeLabel()
            return
        }

        let status = locationManager.authorizationStatus
        let canStartTrueNorth = status == .authorizedWhenInUse || status == .authorizedAlways

        if useTrueNorth && !canStartTrueNorth {
            isReceivingHeadingUpdates = false
            trueNorthAvailable = false
            updateNorthModeLabel()
            return
        }

        locationManager.startUpdatingHeading()
        isReceivingHeadingUpdates = true
        updateNorthModeLabel()
    }

    private func requestMotionPermissionIfNeeded() {
        guard CMMotionActivityManager.authorizationStatus() == .notDetermined,
              CMMotionActivityManager.isActivityAvailable() else { return }

        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-60)
        motionActivityManager.queryActivityStarting(from: startDate, to: endDate, to: .main) { _, _ in }
    }

    private func applyHeadingUpdate() {
        guard !isLocked else { return }

        let resolvedHeading: Double
        if useTrueNorth, let lastTrueNorthHeading {
            resolvedHeading = lastTrueNorthHeading
        } else {
            resolvedHeading = lastMagneticHeading
        }

        heading = normalize(resolvedHeading)
        naqiHeading = normalize(heading + 7.5)
        currentDirection = Direction.from(angle: heading).localizedLabel
    }

    private func applySimulatedReading(_ simulatedReading: CompassSimulationReading) {
        guard !isLocked else { return }

        trueNorthAvailable = simulatedReading.trueNorthHeading != nil
        updateNorthModeLabel()

        heading = simulatedReading.resolvedHeading(useTrueNorth: useTrueNorth)
        naqiHeading = simulatedReading.resolvedNaqiHeading(useTrueNorth: useTrueNorth)
        currentDirection = Direction.from(angle: heading).localizedLabel
        pitch = simulatedReading.pitch
        roll = simulatedReading.roll
        magneticFieldStrength = simulatedReading.magneticFieldStrength
    }

    private func normalize(_ value: Double) -> Double {
        let normalized = value.truncatingRemainder(dividingBy: 360)
        return normalized >= 0 ? normalized : normalized + 360
    }

    private func updateNorthModeLabel() {
        if useTrueNorth {
            northModeLabel = trueNorthAvailable
            ? TAMEL10n.text("真北", "True North")
            : TAMEL10n.text("真北（待校正）", "True North (Calibrating)")
        } else {
            northModeLabel = TAMEL10n.text("磁北", "Magnetic North")
        }
    }

    private func updateSensorStatusMessage() {
        if simulatedReading != nil {
            sensorStatusMessage = TAMEL10n.text("当前为参考读数，设备支持实时传感器时会自动切换。", "Reference readings are shown right now and switch to live compass data when sensors are available.")
            return
        }

        if !CLLocationManager.headingAvailable() && !motionManager.isDeviceMotionAvailable {
            usingSimulatedReadings = true
            sensorStatusMessage = TAMEL10n.text("当前设备暂不提供实时方向或姿态数据，因此页面先显示参考读数。", "This device does not currently provide live heading or motion data, so the page shows reference readings for now.")
            return
        }

        usingSimulatedReadings = false

        if !CLLocationManager.headingAvailable() {
            sensorStatusMessage = TAMEL10n.text("当前设备暂不提供系统方位角，页面会优先显示姿态与参考方位。", "System heading is not currently available, so the page prioritizes motion data and a fallback heading.")
            return
        }

        if useTrueNorth && !trueNorthAvailable {
            sensorStatusMessage = TAMEL10n.text("真北校正需要定位权限；当前先按磁北继续测向。", "True North needs location access. The compass continues with magnetic north for now.")
            return
        }

        sensorStatusMessage = nil
    }
}

extension CompassViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        lastMagneticHeading = normalize(newHeading.magneticHeading)

        if newHeading.trueHeading >= 0 {
            lastTrueNorthHeading = normalize(newHeading.trueHeading)
            trueNorthAvailable = true
        } else {
            lastTrueNorthHeading = nil
            trueNorthAvailable = false
        }

        updateNorthModeLabel()
        applyHeadingUpdate()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        startHeadingUpdatesIfPossible()
        updateSensorStatusMessage()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isReceivingHeadingUpdates = false
        trueNorthAvailable = false
        updateNorthModeLabel()
        updateSensorStatusMessage()
    }
}

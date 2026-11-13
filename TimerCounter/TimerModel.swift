import AppKit
import Observation

/// タイマーとカウンターの状態。タイマーが完了するたびにカウンターが 1 増える。
@MainActor
@Observable
final class TimerModel {
    private enum Keys {
        static let duration = "durationSeconds"
        static let count = "count"
    }

    /// 1 回分の長さ（秒）
    var duration: Int {
        didSet {
            UserDefaults.standard.set(duration, forKey: Keys.duration)
            if !isRunning { remaining = duration }
        }
    }

    /// 完了回数（手動でも増減できる）
    var count: Int {
        didSet { UserDefaults.standard.set(count, forKey: Keys.count) }
    }

    private(set) var remaining: Int
    private(set) var isRunning = false

    private var endDate: Date?
    private var ticker: Timer?

    init() {
        let defaults = UserDefaults.standard
        let saved = defaults.integer(forKey: Keys.duration)
        let initial = saved > 0 ? saved : 25 * 60
        duration = initial
        remaining = initial
        count = defaults.integer(forKey: Keys.count)
    }

    var remainingText: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    var menuBarTitle: String {
        "\(remainingText)  ×\(count)"
    }

    // MARK: - タイマー

    func start() {
        guard !isRunning, remaining > 0 else { return }
        endDate = Date().addingTimeInterval(TimeInterval(remaining))
        isRunning = true
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    func pause() {
        stopTicker()
    }

    func reset() {
        stopTicker()
        remaining = duration
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
        endDate = nil
        isRunning = false
    }

    private func tick() {
        guard let endDate else { return }
        // 終了時刻との差から求めるので、スリープや遅延があってもずれない
        let left = Int(endDate.timeIntervalSinceNow.rounded(.up))
        if left <= 0 {
            complete()
        } else if left != remaining {
            remaining = left
        }
    }

    private func complete() {
        stopTicker()
        remaining = duration
        count += 1
        NSSound(named: "Glass")?.play()
    }

    // MARK: - カウンター

    func increment() { count += 1 }
    func decrement() { count = max(0, count - 1) }
    func resetCount() { count = 0 }
}

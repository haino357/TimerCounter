import Foundation
import UserNotifications

/// タイマーの完了を通知センターに出す。
final class CompletionNotifier: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()

    override init() {
        super.init()
        center.delegate = self
    }

    /// 通知の許可を求める。未回答のときだけシステムの確認が出る。
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert]) { _, error in
            if let error { NSLog("通知の許可を取得できませんでした: \(error.localizedDescription)") }
        }
    }

    /// 完了の通知を出す。許可されていなければ何も起きない。
    func notifyCompletion(minutes: Int, count: Int) {
        let content = UNMutableNotificationContent()
        content.title = "タイマーが完了しました"
        content.body = "\(minutes) 分のタイマーが終わりました（完了 \(count) 回目）"
        // 音は TimerModel 側で鳴らすので、通知には付けない
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request) { error in
            if let error { NSLog("通知を出せませんでした: \(error.localizedDescription)") }
        }
    }

    // パネルを開いている（アプリが前面にある）ときも、バナーを出す
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list])
    }
}

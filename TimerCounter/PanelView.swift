import SwiftUI

struct PanelView: View {
    @Bindable var model: TimerModel

    private var minutes: Binding<Int> {
        Binding(
            get: { model.duration / 60 },
            set: { model.duration = max(1, $0) * 60 }
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            // タイマー
            VStack(spacing: 8) {
                Text(model.remainingText)
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .monospacedDigit()

                HStack {
                    Button(model.isRunning ? "一時停止" : "開始") {
                        model.isRunning ? model.pause() : model.start()
                    }
                    .keyboardShortcut(.defaultAction)

                    Button("リセット") { model.reset() }
                }

                Stepper("長さ: \(minutes.wrappedValue) 分", value: minutes, in: 1...180)
                    .disabled(model.isRunning)
            }

            Divider()

            // カウンター
            VStack(spacing: 8) {
                Text("完了回数")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    Button { model.decrement() } label: { Image(systemName: "minus") }
                    Text("\(model.count)")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .frame(minWidth: 60)
                    Button { model.increment() } label: { Image(systemName: "plus") }
                }

                Button("0 に戻す") { model.resetCount() }
                    .buttonStyle(.link)
            }

            Divider()

            Button("終了") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
        }
        .padding(16)
        .frame(width: 240)
    }
}

import SwiftUI

@main
struct TimerCounterApp: App {
    @State private var model = TimerModel()

    var body: some Scene {
        MenuBarExtra {
            PanelView(model: model)
        } label: {
            Text(model.menuBarTitle)
                .monospacedDigit()
        }
        .menuBarExtraStyle(.window)
    }
}

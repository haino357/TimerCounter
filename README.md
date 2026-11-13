# TimerCounter

メニューバーに常駐する、タイマーと完了回数カウンターの macOS アプリです。
タイマーが 1 回完了するたびにカウンターが 1 増えるので、ポモドーロのような「何セットやったか」を数える用途に使えます。

## 機能

- **メニューバー表示** — 残り時間と完了回数を `25:00  ×3` の形式で常に表示
- **タイマー** — 開始 / 一時停止 / リセット。長さは 1〜180 分で設定可能（初期値 25 分）
- **カウンター** — タイマー完了時に自動で +1。＋／−ボタンでの手動調整と 0 へのリセットも可能
- **完了通知** — タイマー完了時にシステムサウンド（Glass）を再生し、通知センターに通知を表示
- **状態の保存** — タイマーの長さと完了回数はアプリを終了しても保持
- **Dock に表示されない** — メニューバー専用アプリ（`LSUIElement`）

## 動作環境

| 項目 | 内容 |
| --- | --- |
| OS | macOS 14.0 (Sonoma) 以降 |
| 開発環境 | Xcode 16 以降（プロジェクト形式 objectVersion 77） |
| 言語 / UI | Swift 5 / SwiftUI（`MenuBarExtra`、Observation） |
| 外部依存 | なし |

## ビルドと実行

### Xcode から

1. `TimerCounter.xcodeproj` を開く
2. スキーム `TimerCounter` を選んで実行（⌘R）

### コマンドラインから

```bash
xcodebuild -project TimerCounter.xcodeproj -scheme TimerCounter -configuration Debug -derivedDataPath build build
```

```bash
open build/Build/Products/Debug/TimerCounter.app
```

### アイコンから起動できるようにする（インストール）

次のスクリプトは Release ビルドを作り、`/Applications` に `TimerCounter.app` を入れます。

```bash
scripts/install.sh
```

入れたあとは、Finder のアプリケーションフォルダ、Launchpad、Spotlight（⌘Space で「TimerCounter」）からアイコンで起動できます。ソースを変更したときは、もう一度実行すると入れ替わります。

- インストール先を変えるには、引数でフォルダを指定します（例: `scripts/install.sh ~/Applications`）
- アンインストールは `/Applications/TimerCounter.app` をゴミ箱に入れるだけです
- ログイン時に自動で起動したい場合は、システム設定 →「一般」→「ログイン項目」に追加します

署名はローカル実行用のアドホック署名（`CODE_SIGN_IDENTITY = "-"`）です。開発チームの設定は不要ですが、他の Mac への配布には別途 Developer ID 署名と公証が必要です。

## 使い方

1. 起動するとメニューバーに `25:00  ×0` と表示されます（ウィンドウも Dock アイコンも出ません）
2. 表示をクリックするとパネルが開きます
3. 「長さ」のステッパーで 1 回分の分数を決め、「開始」を押します（Return キーでも可）
4. 0 になるとサウンドが鳴って通知が出て、完了回数が 1 増え、タイマーは設定した長さに戻ります
5. 終了するにはパネルの「終了」（⌘Q）を押します

補足:

- 初めて「開始」を押したときに、通知の許可を求める確認が出ます。「許可」を選ぶと、完了時に通知が表示されます
- 通知を止める・再び出すには、システム設定 →「通知」→「TimerCounter」で切り替えます。通知を切っていてもサウンドは鳴ります
- タイマーの長さは、タイマーの実行中は変更できません
- 完了後に次の回は自動では始まりません。もう一度「開始」を押してください
- 完了回数は 0 未満にはなりません

## プロジェクト構成

```
TimerCounter/
├── TimerCounter.xcodeproj/     Xcode プロジェクト
├── TimerCounter/
│   ├── TimerCounterApp.swift   エントリポイント。MenuBarExtra の定義
│   ├── PanelView.swift         メニューバーから開くパネルの UI
│   ├── TimerModel.swift        タイマーとカウンターの状態・ロジック
│   ├── CompletionNotifier.swift 完了時の通知（UserNotifications）
│   └── Assets.xcassets/        アプリアイコン（AppIcon）
└── scripts/
    ├── install.sh              Release ビルドしてアプリケーションフォルダに入れる
    └── make_icon.swift         アプリアイコンの PNG を生成する
```

アイコンのデザインを変えるときは、`scripts/make_icon.swift` を編集してから次を実行します。

```bash
swift scripts/make_icon.swift TimerCounter/Assets.xcassets/AppIcon.appiconset
```

`TimerCounter/` フォルダは Xcode のファイルシステム同期グループなので、このフォルダにファイルを追加すれば自動でターゲットに含まれます。

## 実装メモ

- **時間のずれ対策** — 残り時間は「終了予定時刻との差」から毎回計算しています（0.25 秒間隔で更新）。スリープや処理の遅延があっても、カウントダウンが実時間からずれません。
- **状態管理** — `TimerModel` は `@Observable` かつ `@MainActor`。メニューバーのラベルとパネルが同じインスタンスを参照します。
- **Info.plist** — ファイルは持たず、ビルド設定（`GENERATE_INFOPLIST_FILE` と `INFOPLIST_KEY_*`）から生成しています。

## 保存データ

`UserDefaults`（ドメイン `local.TimerCounter`）に次の 2 つを保存します。

| キー | 内容 |
| --- | --- |
| `durationSeconds` | タイマー 1 回分の長さ（秒） |
| `count` | 完了回数 |

実行中のタイマーの残り時間は保存されません。アプリを終了すると、次回は設定した長さから始まります。

保存データを消して初期状態に戻すには、アプリを終了してから次を実行します。

```bash
defaults delete local.TimerCounter
```

## 基本情報

| 項目 | 内容 |
| --- | --- |
| バージョン | 0.1 |
| Bundle Identifier | `local.TimerCounter` |
| ターゲット / スキーム | `TimerCounter` |

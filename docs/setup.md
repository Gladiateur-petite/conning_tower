# 開発環境：Windowsで始め、iOS検証はmacOSで行う

基準は調査SHAとFlutter 3.35.1。まず上流の基準を再現し、SDK/依存の一括upgradeは別Issueに分ける。この手順は静的調査に基づく実行案であり、今回Windows/iOSで成功確認した手順ではない。

## OSごとの範囲

| 作業 | Windows | macOS/Xcode |
|---|---|---|
| Git/編集/Issue/PR/仕様 | 可能 | 必須ではない |
| Dart生成・静的解析 | 可能。SDK/依存/生成設定をそろえる | 必須ではない |
| 純粋ロジックunit test | Flutter testで進める。dart:ui依存がある現行モデルをdart testで直接動かさない | 必須ではない |
| Flutter widget test | 原則可能。native channelをmock/隔離する | WebView実機動作の証明にはならない |
| Windowsアプリ | windows/骨格はあるが未確認。依存のWindows実装・Firebase/Crashlytics等を検証要 | iOS検証の代替にはならない |
| Android APK/エミュレータ | Android SDK/JDK設定後に候補。署名/Firebase設定が必要 | 不要 |
| iOS Simulatorビルド | 不可 | macOS、Xcode、対応SDK、現行PodfileのCocoaPods経路 |
| iPhone/iPad実機起動 | Windowsだけではビルドできない | signing、Team、Bundle ID、端末の開発設定 |
| IPA/TestFlight/App Store | 不可 | 署名/配布資格・プロファイル。今回の範囲外 |

Visual StudioのC++ workloadはWindowsデスクトップビルド用。unit/widget testのために先に大型Visual Studioを導入する必要はない。iOSビルドはクラウドMac CIでも実施可能だが、実機のゲーム/WebView検証は別途必要。

## 1. Forkと接続

1. <https://github.com/andychucs/conning_tower/fork> を開く。
2. ownerはGladiateur-petite、名前はconning_towerを推奨。実際に作ったURLが正となる。
3. Settings→General→Features→Issuesを有効化する。GitHub接続がAll repositoriesなら個別追加は不要。読取と書込は別々に確認する。
4. ForkのActionsを有効にする前に`.github/workflows/`を読む。testはFIREBASE_OPTIONSに依存し、releaseはv*タグで配布処理を実行する。初期はReleaseタグを作らず、release/manual_release系を実行しない。Secretsは自分のものだけを必要な時に設定する。

2026-10-10確認：ご自身のForkとIssues有効化・接続読取は完了。連携からの書込は403で拒否されている。文書導入Issueは[#1](https://github.com/Gladiateur-petite/conning_tower/issues/1)。

## 2. Windows準備

Git for Windows、VS Code＋Flutter/Dart拡張、Flutter 3.35.1を用意する。SDKは例として`C:\dev\flutter`に展開しbinをPATHへ追加する。既存SDKと混ざらないことを`where.exe flutter`で確認する。

PowerShellで、実際のFork名が異なる場合はURLを置き換える。

```powershell
git --version
flutter --version
flutter doctor -v
git clone https://github.com/Gladiateur-petite/conning_tower.git
cd conning_tower
git remote add upstream https://github.com/andychucs/conning_tower.git
git remote -v
git status
git rev-parse HEAD
```

originは自分のForkへの保存先、upstreamは参照/更新の取込元。upstreamへpushしない。現在のmain SHAが調査SHAと異なれば差分を読んで調査日を更新する。Git author名/メールは自分のGitHub設定（必要ならnoreply）を使用する。

## 3. 依存・生成・基準テスト

```powershell
git switch -c chore/dev-baseline
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test test/battle
flutter analyze
flutter test
git status --short
git diff --stat
```

各コマンドが失敗したら、次を無条件に続行せず失敗のログとOS/SDK/SHAを環境Issueへ残す。最初にbattleだけを実行するのは、アプリ起動/プラグイン副作用から離れた既存処理の基準を先に取るため。全testを省略する意味ではない。生成ファイルとpubspec.lock差分をレビューし、自動的に全変更をcommitしない。

既存CIはbuild_runnerを実行するが、ローカライズはflutter_intl設定を持つ。S/generated関連で失敗した場合はIntl生成環境を確認し、原因を環境Issueで管理する。

### Firebaseという初期障害

`lib/main.dart`は`firebase_options.dart`をimportし、起動時にFirebaseを初期化する。公開treeにfirebase_options.dartはなく、既存CIはFIREBASE_OPTIONS secretをbase64 decodeして作る。新Forkには上流Secretsは引き継がれない。したがってCloneしてflutter runだけで動くと約束できない。

推奨：環境Issueでtelemetryを設定注入できるようにし、unit/widget testは外部Firebaseなしで動く小さなPRを作る。実データの診断ログはローカル/明示的opt-inとする。現行のCrashlytics直接呼出しも境界を越えないよう隔離する。

既存のアプリ構成をそのまま再現する場合は自分のFirebaseプロジェクトを作り、公式手順に従ってFirebase CLI/FlutterFire CLIを設定し`flutterfire configure`で自分の設定を生成する。上流のFirebase設定/署名証明書を要求・流用しない。対象プラットフォームを確認して生成差分をレビューする。空のファイルを作って「ビルド確認済み」と扱わない。

## 4. macOSでiOSを確認

同じFork・同じcommit・Flutter 3.35.1をClone。Xcodeの初回設定とiOS SDK/Simulator、CocoaPodsを用意する。現行の3.35.1/Podfile経路を再現し、最新FlutterのSwiftPM移行はこのPRに混ぜない。

```bash
flutter doctor -v
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build ios --simulator --debug
flutter devices
open ios/Runner.xcworkspace
```

Firebase等の設定が未解決なら先に環境Issueを終える。Simulator成功後、XcodeのSigning & Capabilitiesで自分のTeam/一意のBundle IDを設定し、実機を選択して起動する。上流Team IDがpbxprojに残っているので自分の設定へ変更するPRを分ける。

READMEはiOS12を記載する一方、Podfileは13、pbxprojは12。pluginsがさらに高い最低OSを要求し得る。初期Issueで実際の最小対応OS・Xcode版をビルドログに基づいて確定し、そろえる。READMEだけを根拠にiOS12対応を宣言しない。

## 5. 最初に記録する結果

OS、Flutter/Dart、Xcode（使用時）、commit SHA、pub get/生成/analyze/testの成功または失敗、失敗ログの要約、iOSのゲーム表示/HTTPS/API取得状況。基準失敗を記録した上で今回の変更が増やした失敗を区別する。基準に失敗がある場合、無条件にgreen扱いにせず、blockerを解決するか理由と対象を限定する。

公式資料：[Fork](https://docs.github.com/en/pull-requests/how-tos/work-with-forks/fork-a-repo)、[Flutter Windows](https://docs.flutter.dev/platform-integration/windows/setup)、[iOS](https://docs.flutter.dev/platform-integration/ios/setup)、[Firebase Flutter](https://firebase.google.com/docs/flutter/setup?hl=ja)。

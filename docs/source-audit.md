# 現行ソース調査と7機能マトリクス

2026-10-09時点の公開default branchをGitHub接続経由で取得した静的調査。過去の調査を転記せず、以下のcommitに固定して確認した。

| 対象 | 調査commit | 状態 |
|---|---|---|
| ConningTower | `26f27d1326bd4da9484b6066fe8d6c07a3c5b285` | main、非archive、最終commit 2025-11-09、Flutter upgrade #422 |
| ElectronicObserverEN | `5b74e9ac449e892c3b64dae43fd2d75c98f544fb` | main、非archive、参照用 |

ConningTowerの最新公開Releaseはv1.16.4（2025-04-05）。mainのpubspecは1.16.4+1、Flutter 3.35.1、Dart >=3.0.0 <4.0.0。Releaseと調査mainを同一視しない。取得されたtest Actions成功はdev `5b7fc442…`（2025-11-09）のPRであり、今回のmainやWindows実行成功の証明ではない。

## 7機能

「既存で使える」は表示・計算経路があるという静的評価。現在のゲームAPI・全装備・実機で正しさを保証する意味ではない。

| 優先 | 機能 | 主分類 | 確認済みの基盤 | 必要な作業 |
|---|---|---|---|---|
| P0 | 大破警告 | 修正が必要 | Ship.damaged、戦闘結果Toast、map start/nextのAlertDialog | UNKNOWN、HP表記、状態の永続表示、ログ設定との分離、欠落時の失効 |
| P0 | cond | 既存で使える | apiCond→condition、最低cond数値、艦詳細数値、各艦バー | 各艦行に数値を追加。鮮度表示と一元化は別Issue |
| P0 | 艦隊合計値 | 修正が必要 | 艦隊合計Lv・火力・対空・対潜・索敵、最低cond | 旗艦Lvのサマリー、ドラム缶個数/装備艦数、欠損を0にしない集計 |
| P0 | 艦隊制空値 | 修正が必要 | Ship.aircraftPower、Squad.aircraftPowerの表示 | EO比較、改修/熟練度/搭載0/退避のテスト、表示範囲と出撃中鮮度 |
| P0 | 出撃中燃料/弾薬% | 新規実装が必要 | fuel/bull取得、補給更新、充足色表示 | 各艦%と艦隊集計、実測/推定/古い値の区別、消費規則の検証 |
| P1 | 33式索敵 | 修正が必要 | Squad.los、Ship.losShip/losEquip、分岐係数UI | EO比較、補強増設・退避・装備種別・端数・7隻扱いの仕様確定 |
| P1 | ボス残りゲージ | 既存で使える | parseMapState、MapState、battle more infoのnow/max表示 | 出撃中更新タイミング、海域/段階/種別、キャッシュの鮮度を確認 |

制空と33式は「計算を新設」ではなく「既存計算の妥当性をテストして修正」。ゲージは既に詳細画面にあるため、必要ならコンパクトな場所に再表示するだけに留める。

## Safetyに直結する確認

1. `KancolleData.parse`は戦闘系pathで`kcBattleReportEnable == false`ならreturnする。ログ記録の設定が解析に影響することは現行コードでも確認した。
2. 取得データ空・api_result不成功はToast後return、未対応modelはCrashlytics報告、例外はAlert後rethrow。専用のHP信頼状態・UNKNOWNはこの経路にない。
3. 大破Toastは10秒で閉じる。加えて`addAlert`はmap start/nextで艦名をAlertにし、HomeがbarrierDismissible:falseのダイアログを表示する。**Toastだけという過去の見立ては訂正**。ユーザー操作で閉じられ、HP/MaxHPは警告本文にない。
4. `updateSquads`は当初FleetのShipを共有するが、`updateSquadShips`ではSquadのShipをcopyWithApiで置換する。Fleetに同じ新オブジェクトを反映していないため、編成でFleetから取り直す際に古いHP/cond等を読む可能性がある。これはコード上のリスクで、実測で再現した不具合ではない。
5. `BattleInfo`のダメージmapはShip.hashCodeをキーにする。instance IDと違い、オブジェクト置換をまたぐ状態キーには適さない。純粋な戦闘snapshotでは味方/敵/主力/随伴/位置を明示して扱う。
6. `readyEscapeShips`とescapeフラグは既に分離され、goback_port時にconfirmEscapeShipする経路がある。退避を全面新設しない。キャンセル・護衛・API欠落・順序を回帰テストする。
7. `Ship.onHPChange`はHPを減らして0を下限にする。EO PhaseBaseにはダメコン42/43の処理がある。ConningTower BattleInfoに同等のダメコン処理は今回確認できず、未検証のダメコンを安全扱いしない。
8. JS ListenerはXHRを観測し、Dart側はloadのみを採用する。error/loadendは状態更新に採用されない。JS側もresponseURLで先にフィルタするため失敗時URL空の検出漏れに注意。取得不能全般の把握は別途設計が必要。
9. parseWithはrequest paramsとAPI payloadをCrashlyticsログへ記録する。fixture収集・診断ではtoken/アカウント識別子等を除去し、ローカル・外部送信の方針を決める。

## iOS/HTTPSと上流Issue

| Issue | 取得時の状態 | 扱い |
|---|---|---|
| [#423](https://github.com/andychucs/conning_tower/issues/423) | open | HTTPS更新後の全画面・サイズ調整報告。iPad mini 6/iPadOS18.6.2。先行して実機再現する |
| [#359](https://github.com/andychucs/conning_tower/issues/359) | open | iPhone12/iOS18の不定期黒画面。再現条件未確定 |
| [#405](https://github.com/andychucs/conning_tower/issues/405) | open | 通常レーダー射撃 |
| [#406](https://github.com/andychucs/conning_tower/issues/406) | open | 連合航空戦 |
| [#407](https://github.com/andychucs/conning_tower/issues/407) | open | 連合レーダー射撃 |
| [#413](https://github.com/andychucs/conning_tower/issues/413) | closed/completed | 潜水艦電探索敵値の過去不具合。現行の未修正とは断定せず回帰材料とする |

#423コメントで作者は継続意向を示している。commit間隔だけで放棄と判断しない。WebControllerにはHTTP強制変換・httpRedirect関連経路が残るが、今回それが実機で発火することは未確認。

## ライセンス

- ConningTower root LICENSE：Apache-2.0。Forkで原文を維持し、著作権/帰属表示を残す。配布時は改変ファイルに変更した旨を示し、上流NOTICEが存在すれば関係する内容を維持する。調査treeにはroot NOTICEなし。新しいNOTICEを無根拠に上流由来として作らない。
- EO root LICENSE：MIT。原作2014 Andante、翻訳2015 Ryuu Kitsune。コード・実質的な一部を翻案/移植する場合も、MIT文面と著作権表示を第三者ライセンスへ保存し、参照元SHA/ファイル/変更内容を記録する。単なる仕様参考とコード由来を区別する。
- rootライセンスだけで依存ライブラリ・画像・攻略データを一括許諾としない。assets/libs-info、kc-libs-info、pluginsの既存表記を維持する。Squad.losにpoi由来のコメントがあり、その来歴も消さない。
- lockされたSyncfusion Charts 30.2.7はCommunity/commercial条件の確認対象。無条件のOSS依存とは扱わない。個人開発とAIcon/会社利用の主体を混同せず、対象版と利用者の条件を確認して記録する。配布前に他の依存/アイコン/データも棚卸しする。

一次資料：[Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0)、[Syncfusionライセンス](https://help.syncfusion.com/flutter/licensing/overview)、[Community条件](https://www.syncfusion.com/products/communitylicense)。許諾済みと未確認を区別する。

## 検証範囲

公開tree、選定したDart/C#/JS、pubspec、CI、LICENSE、Issue本文/状態を確認した。Flutter/Dart SDKはこの実行環境にない。通常git cloneは通信が完了しなかったため中断し、GitHub経由でSHA固定のファイルを読んだ。Windowsビルド、flutter test、iOSビルド、ゲーム接続は実行していない。SDK/依存/設定をそろえた環境で基準結果を取ることを最初の環境Issueにした。

## 根拠ファイル（commit固定）

ConningTower base：<https://github.com/andychucs/conning_tower/tree/26f27d1326bd4da9484b6066fe8d6c07a3c5b285>

- `lib/models/feature/kancolle/data.dart`：parse、parseWith、updateFleetShips/updateSquads/updateSquadShips、parseMapState
- `lib/models/feature/kancolle/ship.dart`：condition、damaged、onHPChange、aircraftPower、losShip/losEquip
- `lib/models/feature/kancolle/squad.dart`：aircraftPower、los
- `lib/models/feature/kancolle/battle_info.dart`：parseBattle、updateShipHP、readyEscapeShips/confirmEscapeShip
- `lib/pages/dashboard_pages/squad_info.dart`：最低cond・艦詳細・艦隊合計のUI
- `lib/widgets/kancolle_battle_more_info_page.dart`：ゲージUI
- `lib/pages/home.dart`、`lib/utils/toast.dart`：AlertDialogと時間制Toast
- `assets/js/inject.js`、`lib/providers/generatable/webview_provider.dart`：XHR→Flutter
- `lib/main.dart`、`pubspec.yaml`、`.github/workflows/test.yml`、`ios/Podfile`：環境依存
- `test/battle/battle_test.dart`、`battle_result_test.dart`：現在のテスト範囲

EO base：<https://github.com/ElectronicObserverEN/ElectronicObserver/tree/5b74e9ac449e892c3b64dae43fd2d75c98f544fb>

- `ElectronicObserver/Data/Battle/BattleManager.cs`：APIディスパッチ
- `ElectronicObserver/Data/Battle/Phase/PhaseBase.cs`：HP減算/ダメコン
- `ElectronicObserver/Utility/Data/Calculator.cs`：GetAirSuperiority/GetSearchingAbility_New33
- `ElectronicObserver/Data/ShipData.cs`、`MapInfoData.cs`：艦状態/ゲージ
- `ElectronicObserverCoreTests/AirPowerTests.cs`：テスト候補（treeで存在確認。内容を用いた検証は未実施）

# テスト戦略

今回はFlutterテストを実行していない。既存テストがあることと、仕様が検証済みであることを分ける。

## 現行の出発点

test/models/kcapiにレスポンスmodelテストがあり、test/battleにもJSONを含むテストがある。ただし確認したbattle_testはformationとinBattleSquadsの確認が中心で、最終HP全艦の期待値・UNKNOWNを十分検証していない。battle_result_testは手動でdamage mapを入れた勝敗判定が中心で、API JSON→最終HP→大破警告の一貫した証明ではない。

## fixture契約

提案ディレクトリ：`test/fixtures/kancolle/<scenario>/`。input.json、initial-state.json、expected.json、metadata.jsonを用意する。metadataにはAPI path、取得/合成の区別、出撃/マス順序、期待値の検算根拠、参照元SHA、匿名化、schema対応範囲を記載する。

```
initial snapshot + API envelope/path
  → adapter/parser
  → final HP by ship instance ID
  → state validity
  → SAFE / DANGER / UNKNOWN
```

同じコードで計算した出力をそのままexpectedに保存しない。人間がフェーズごとのHPを検算し、EOの対応phaseと比較し、仕様差を明記する。EOを絶対的な正解oracleとは扱わない。

## 必須ケース

| 層 | ケース | 合格条件 |
|---|---|---|
| Safety unit | HP25/100、26/100、24/100、0/100、MaxHP0/null/負/HP超過 | 閾値を正しく区別。不正値はUNKNOWN |
| Parser unit | 通常、連合機動/水上/輸送、敵連合、両軍連合 | 全味方instance IDの最終HPと世代がexpected一致 |
| Parser unit | 航空戦2回、空襲、基地/噴式、友軍、開幕対潜/雷撃、砲撃/雷撃 | 順序・端数・side/indexの取り違えなし |
| Parser unit | 夜戦開始、昼→夜、夜→昼、レーダー | 対応済みはHP一致。未対応時はUNKNOWN |
| Parser unit | 2025系開幕雷撃list_items、新旧配列、null stage | supported schemaを明示。不正な長さ/必須欠落はUNKNOWN |
| Parser unit | ダメコン、過剰ダメージ、複数攻撃 | 未検証ダメコンでSAFEへ倒れない |
| State sequence | port→編成→start→battle→ship_deck→編成 | Fleet/UI/Safetyが同一Ship IDの新しい値を見る |
| State sequence | ログON/OFF、再送、順序逆転、1API欠落 | 保存設定で判定不変。二重減算せず、欠落はUNKNOWN |
| State sequence | 退避候補→取消、退避確定＋護衛 | 候補では除外せず、確認済み艦だけ除外 |
| State sequence | 演習→本出撃、起動cache、復帰、Listener再注入 | 別世代/古いHPをSAFE根拠にしない |
| State sequence | 通信error、タイムアウト、不正JSON、api_result失敗、unknown path | 例外を正常継続に隠さずUNKNOWNを保持 |
| Fleet unit | 空艦隊/欠損/1隻/6隻/7隻、増設ドラム缶 | 集計仕様と一致。艦数と個数を別計算 |
| Fleet unit | 燃料/弾薬0/満載/欠損/最大0、退避、加重比率 | 数値・丸め・推定ラベルが仕様一致 |
| Fleet unit | 制空：搭載0、熟練0/7、改修、全対象装備、退避 | EO比較の差と根拠を記録 |
| Fleet unit | 索敵33：係数1～4、司令部、増設、電探/偵察、退避、端数 | 計算前提を表示し期待値一致 |
| Gauge unit | HP/TP/撃破回数、max0、段階切替、未取得 | 欠損を「0残り」に変換しない |
| Widget | 各艦cond数値、最低値、更新・長い艦名/文字拡大 | 値と表示対象が一致、overflowなし |
| Widget | DANGER/UNKNOWN、時間経過/acknowledge/回転/遷移 | 艦名とHP/MaxHP/理由が残り、SAFEへ誤解除なし |
| iOS integration | HTTPS・XHR/bridge、iPhone15/iPad、回転/前後景、WebView再読込 | 実機で取得・表示・警告の継続を確認 |

## CI

環境IssueでFirebaseなしのcore test境界を用意し、Flutter 3.35.1とlockを基準に、生成→format（変更ファイル）→analyze→unit/widget testをPRに必須化する。既存analyzeの基準エラーを記録し、変更が増やした問題を区別して解消する。通常CIでゲーム接続・認証・自動操作を行わない。

Windowsでcore/widget、macOSでiOSビルドを段階追加する。全アプリCIはプラグイン副作用をmock/注入して再現可能にする。iOS実機結果は端末・OS・SHA・手順・スクリーンショットをPRへ残す。

## 完了ゲート

cond PRは関連widget test＋回帰＋diff review。Safety PRは入力失敗/欠落/時間/退避を含む全不変条件、対応形式の最終HP期待値、iOS Overlay実機確認が必要。形式ごとにsupported/unsupportedとfixtureを対応させる。未対応をUNKNOWNにできれば縮小版を開発用に取り込めるが、対応済みと宣言しない。

カバレッジ率や「99/100成功」だけで合格にしない。大破未検出でもSAFEと出してしまう経路が1つ残れば、その対応範囲の完成条件を満たさない。テストは全未知のゲーム変更を保証するものではなく、新schemaはfail closedで扱う。

公式資料：[Flutter testing](https://docs.flutter.dev/testing/overview)、[Widget testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)、[Integration testing](https://docs.flutter.dev/testing/integration-tests)。

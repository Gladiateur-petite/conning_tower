# Issue単位ロードマップ

番号は計画ID。ForkでIssueを作った後、実GitHub番号/URLを追記する。2026-10-10に計画ID00はGitHub [#1](https://github.com/Gladiateur-petite/conning_tower/issues/1)として作成済み。他の計画IDは未投稿。

Phase 0は文書00→環境01とiOS02、ライセンス19を開始。最初の機能PR03でIssue/branch/test/PR/人間レビュー/mergeを練習する。大規模GameState整理を初回学習PRの前提にしない。

Phase 1は04→05→07→08→09→10のSafety基盤を優先し、取得失敗06はiOS02と05から進める。対応不足11～13は個別に対応し、未完の形式はUNKNOWN。通常形式の安全表示を先に検証できるが、全形式対応とは称さない。燃料14・合計15・制空16は状態境界が安定してから。Phase 2は33式17・ゲージ18の既存基盤の検証と表示調整。

| 計画ID | Issue | 依存 |
|---|---|---|
| 00 | [初期調査・仕様・開発手順を文書PRとして導入](issues/00.md) | なし |
| 01 | [Flutter 3.35.1の基準テストと外部設定なしの開発境界](issues/01.md) | 00 |
| 02 | [HTTPS表示・API取得とiOSビルドの現状を再現する](issues/02.md) | 01 |
| 03 | [艦隊一覧の各艦行にcond数値を常時表示する](issues/03.md) | 01 |
| 04 | [戦闘解析と戦闘ログ保存設定を分離する](issues/04.md) | 01 |
| 05 | [HPのSAFE/DANGER/UNKNOWNと世代・鮮度を導入する](issues/05.md) | 04 |
| 06 | [取得失敗・bridge停止・イベント欠落をHP失効へつなぐ](issues/06.md) | 02,05 |
| 07 | [Ship instance IDによる状態の一元化を導入する](issues/07.md) | 05 |
| 08 | [Battle Parserを純粋化し最終HPを一括反映する](issues/08.md) | 07 |
| 09 | [退避候補・確定退避・ダメコンを回帰検証する](issues/09.md) | 08 |
| 10 | [大破/判定不能の持続Overlayを既存UIへ追加する](issues/10.md) | 06,09 |
| 11 | [連合航空戦APIをfixtureに基づき対応する](issues/11.md) | 08,10 |
| 12 | [夜→昼の通常/敵連合APIを対応する](issues/12.md) | 08,10 |
| 13 | [通常/連合レーダー射撃を対応する](issues/13.md) | 08,10 |
| 14 | [燃料/弾薬%と実測・推定・古い値の表示を追加する](issues/14.md) | 07,10 |
| 15 | [旗艦Lv・ドラム缶集計を既存艦隊合計へ追加する](issues/15.md) | 07 |
| 16 | [既存制空計算をEO比較と回帰fixtureで検証する](issues/16.md) | 07 |
| 17 | [33式索敵をEO比較で検証し前提をUI表示する](issues/17.md) | 07,16 |
| 18 | [既存ゲージを出撃情報と鮮度付きで表示する](issues/18.md) | 07 |
| 19 | [Forkと参照実装・依存/データのライセンス来歴を記録する](issues/19.md) | 00（並行実施。EOコード導入前に該当部分を完了） |

## 初回の投稿順

00は[#1](https://github.com/Gladiateur-petite/conning_tower/issues/1)として作成済み。次に01、03を作成し、残りをbacklogとして登録する。各本文はdocs/issuesに完成草案がある。Issue番号をbranch/Closesへ置き換える。実際に投稿したURLをこの表へ追記する。

作業時間や実機環境が未確定なので日付の約束はしない。00/01/03の学習サイクル後に、Mac利用経路とiOS不具合02を踏まえて工数を見積もる。

Safety完了条件：対応形式に最終HP検算fixture、失敗/欠落UNKNOWN、持続警告のiOS実機確認。旧大破機能は現要求を満たすまで検証中として扱う。Phase 3は実利用から生じた不足だけをIssue化する。

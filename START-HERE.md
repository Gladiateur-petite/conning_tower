# ConningTower ベース開発：最初に読む案内

調査日：2026-10-09。導入準備更新：2026-10-10。機能コードは変更していません。

## 結論

ConningTowerを基盤に使う方針は妥当です。cond・艦隊合計・制空・33式索敵・ゲージには既存基盤があり、全部を新しく作る必要はありません。一方、大破警告の信頼性は、警告UIだけでなくAPI取得・状態更新・戦闘解析の改善が必要です。

最初の機能Issueは「艦隊一覧の各艦にcond数値を常時表示」にします。最低condと艦詳細の数値は既に存在するため、そこを再実装しません。まず環境の再現とドキュメントPRを終え、その次の小さなPRとして実施します。

## 今回の成果物

| 文書 | 内容 |
|---|---|
| [source-audit](docs/source-audit.md) | SHA固定の現行調査、7機能の分類、既知Issue、検証限界 |
| [setup](docs/setup.md) | WindowsとmacOSの切り分け、Fork/Clone、環境手順 |
| [workflow](docs/workflow.md) | Issue→branch→test→diff→PR→mergeと人間の確認箇所 |
| [vision](docs/vision.md) | 目的、P0/P1、非目標 |
| [architecture](docs/architecture.md) | 現行構造と段階的GameState案 |
| [safety](docs/safety.md) | SAFE/DANGER/UNKNOWN、解除条件、欠落・古い状態の扱い |
| [api-notes](docs/api-notes.md) | EOとの戦闘API差分、更新経路と残課題 |
| [test-plan](docs/test-plan.md) | fixture・最終HP・判定・UI・実機の検証戦略 |
| [roadmap](docs/roadmap.md) | 依存関係付きのIssue分解 |
| [Issue草案](docs/issues/README.md) | Background等5項目を備えた投稿用草案 |
| [ADR](docs/adr/0001-incremental-state-and-safety.md) | 過剰設計を避ける初期判断 |

## 現在の状態と次の操作

Fork：[Gladiateur-petite/conning_tower](https://github.com/Gladiateur-petite/conning_tower)。Issues有効化・接続読取を確認済み。
文書導入Issue：[第1号](https://github.com/Gladiateur-petite/conning_tower/issues/1)。
Fork/mainは調査済みSHA `26f27d1326bd4da9484b6066fe8d6c07a3c5b285` と一致した。

GitHub連携からのIssue作成とbranch作成は403（Resource not accessible by integration）で拒否された。
アカウントの権限と連携アプリの権限は別であり、All repositoriesの選択だけでは書き込み成功を保証しない。
branch・commit・PRはまだ作成していない。

1. ZIPを展開する。ZIP自体はリポジトリにアップロードしない。
2. ご自身のForkでmainから `docs/foundation` branchを作る。
3. Code → Add file → Upload filesで、展開した `docs` と `.github` フォルダ、`START-HERE.md` をアップロードする。
4. `docs/foundation` にcommitする。既存README/LICENSE/アプリコードは変更しない。
5. 自分のForkでbase `main`、head `docs/foundation` のPRを作る。Forkから上流へのPRを初期選択する画面に注意する。
6. PR本文に `Closes #1` と「文書のみ。相対リンク・必須項目確認済み。Flutter/Windows/iOS検証は未実施」を記載する。Draftを選べる場合はDraft PRにする。
7. PRのURLを会話へ送る。Files changedで文書のみか確認し、人間レビュー後にmergeする。

PRのタイトル例：`docs: add development foundation (#1)`。
GitHub操作が終わったら、[setup](docs/setup.md)を使いWindowsでGit・VS Code・Flutter 3.35.1の準備を進める。

## 導入方法

このZIPはアプリ本体ではなく文書・Issue/PRテンプレート一式です。CloneしたForkに、`docs/`と追加テンプレートを **docs/foundation** branchで配置します。既存ファイルが同名なら上書きせず差分を確認してください。`docs/issues/`の番号は計画IDであり、GitHubの実Issue番号ではありません。

レビュー後に文書PRをmergeし、次に環境PR、cond PRを順番に進めます。最初の環境PRではFlutterテストが実行できることを確認し、実ゲームの出撃はSafetyゲートを通すまで検証材料にしません。

# このプロジェクト専用のGitHubワークフロー

mainは取り込み済みの状態を保つ。Issueは「なぜ変えるか/何ができれば完成か」、branchは「未完成の変更を隔離」、PRは「証拠付きのレビュー場所」、mergeは「採用した判断」を残す。単独開発でもPRを作る。

## 1サイクル

1. `docs/issues/`の草案から自分のForkへIssueを作成。計画IDを実Issue番号へ対応づける。
2. Background/Requirement/Acceptance Criteria/Safety considerations/Test casesを確認。AIは不明点と調査根拠ファイルをIssueまたはPRに追記する。
3. mainを更新してbranchを切る。

```powershell
git switch main
git pull --ff-only origin main
git switch -c feature/123-cond-inline
```

123は例なので実Issue番号に置き換える。文書はdocs/、環境はchore/、修正はfix/、機能はfeature/を使う。branch数を増やすこと自体が目的ではない。

4. AIへIssueと非目標を渡し、先に触るファイル・設計・テスト案を示させる。人間は要求と変更範囲を確認。今回はコード実装を開始していない。
5. 最小実装→関連test→analyze→必要な全testを実行。バトルfixtureの期待HPはAIの出力をそのまま正解にせず、人間のフェーズ検算とEO参照を併用する。
6. `git diff --check`、`git diff`、`git status`で差分をレビュー。人間が少なくとも以下を確認する：仕様の解釈、UNKNOWN→SAFE誤遷移、退避除外、欠損の0置換、ゲームAPI/操作への変更、個人情報、変更ライセンス表記、生成/依存差分。
7. 必要ファイルだけstageしてcommit、Forkへpushする。

```powershell
git diff --check
git diff
git status --short
git add <レビュー済みのファイル>
git commit -m "feat: show cond in fleet rows (#123)"
git push -u origin feature/123-cond-inline
```

8. 自分のForkでDraft PRを作る。**baseは自分のFork/main、headは自分のbranch**。Forkの比較画面は上流PRを初期選択する場合があるので所有先を確認する。
9. PRにWhat/Why/Changes/Test results/Known limitations。Issue連携は実番号で`Closes #123`。CI・Files changed・Screenshotsを人間が確認し、質問/修正を残す。AIレビューだけを独立な品質保証とみなさない。
10. 条件がそろったらDraft解除し、人間がmergeする。初期はsquash merge推奨。Issue単位の履歴を読みやすくするため。PR内の試行履歴は残る。
11. mainを更新。branch削除はmerge確認後のみ。上流syncは別作業で差分/回帰を確認する。

## 初回文書PR

計画ID00をIssue化し、`docs/foundation`を作る。ZIP内文書と追加テンプレートを載せ、既存README/LICENSE/テンプレートを不用意に置換しない。文書PRに「アプリコード変更なし、ビルド未実施、相対リンク/草案構造確認」と明記する。

## 学習用の記録は短く

各PRに3行：AIが担当したこと／人間が確認・変更した判断／テストで発見した点。所要時間は任意。採用した設計判断だけADRに残し、会話全文はcommitしない。

GitHub Actionsが文書変更で動かないことは現行test.ymlのpaths条件上あり得る。文書PRでは文章/リンク/根拠を検証し、環境PRでCIを整える。一般branch protectionは自分のForkで設定可能な権限/プランを確認してから使用する。単独開発では自分が自分のPRをApproveできないため、必須承認人数を機械的に1にせず、手動レビュー記録と必須CIを中心に運用する。

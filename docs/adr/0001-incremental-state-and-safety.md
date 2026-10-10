# ADR-0001：既存UIを保ち、状態の一元化とSafetyを段階導入する

状態：提案（人間レビュー後に採用へ変更）。日付：2026-10-09。

## 背景

現行KancolleDataは解析・可変状態・保存・通知をまとめている。Fleet/SquadのShip置換が古い値の再利用につながる可能性があり、戦闘解析はログ設定に依存する。cond等の既存機能は活用できる。

## 判断案

最初はcondの表示だけの小変更でPR運用を学ぶ。並行して再現可能なtest境界を作る。次にログ保存をSafety解析から分離し、UNKNOWNを導入、Ship ID中心のRepositoryへAPI単位で移行する。Battle Parserの結果を検証後atomic commitし、rootの持続警告を状態から描画する。

## 理由と代替

最初に全GameState/UIを作り直す案は差分が大きく、初心者がレビューしにくい。現在の表示だけ増やす案はSafety基盤の欠落を解消しない。小さなPRを重ね、既存adapter/計算を活かしながら不変条件を追加する。

## 影響

移行中は旧UIとのadapterが必要。2つのShipを並行して独立更新する仕組みは最終状態に残さない。Firestore等の新DB、遠征成功条件DB、EO全面移植、SDK一括upgradeは採用しない。燃料推定や未対応形式は別ADR/Issueで根拠がそろってから決める。

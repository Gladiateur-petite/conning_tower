# API対応メモ

調査commitは[source-audit](source-audit.md)を参照。下表はAdapter・BattleInfoの分岐とEO BattleManagerのdispatchを比較した静的対応表。存在する分岐を実APIの全variant対応済みと解釈しない。

| 戦闘形式 | ConningTower | EO | 必須fixture観点 |
|---|---|---|---|
| sortie/battle | あり | あり | 開幕航空/対潜/雷撃/砲撃/雷撃、端数、7隻 |
| battle_midnight/battle、sp_midnight | あり | あり | 昼→夜、夜戦開始、残HP引継ぎ |
| sortie/airbattle、ld_airbattle | あり | あり | 航空2回、空襲、stage3 null |
| combined/battle、battle_water | あり | あり | 主力/随伴、砲撃順、短い編成 |
| combined/each_battle、each_battle_water | あり | あり | 両軍連合、0～11位置、HP全艦 |
| combined/ec_battle、ec_midnight_battle | あり | あり | 敵連合、active_deck切替 |
| combined/midnight_battle、sp_midnight | あり | あり | 自軍連合夜戦、退避/護衛 |
| combined/ld_airbattle | あり | あり | 主力/随伴のstage3、空襲 |
| combined/airbattle | Adapter分岐なし | あり | 主力/随伴の航空2回 |
| sortie/night_to_day | Adapter分岐なし | あり | 夜→昼HP・フェーズの連続性 |
| combined/ec_night_to_day | Adapter分岐なし | あり | 敵連合夜→昼、active_deck |
| sortie/ld_shooting、combined/ld_shooting | Adapter分岐なし | あり | レーダー射撃、配列対応 |
| practice/battle、midnight_battle | あり | あり | 本出撃との状態分離、轟沈/ダメコン扱い |

prefixのcombinedは`api_req_combined_battle/`を省略。EOが対応することはConningTowerへそのままコピーできることを意味しない。EOの入力型/phase/HP処理を参照し、Dartで必要な結果だけ実装する。

## 状態更新の対応を管理する

| 入力 | 現行/目標 |
|---|---|
| start2/getData | master data。最大燃料/弾薬、装備種類・性能の根拠 |
| port/port | 全所有Shipを再作成しSquadを再構成。復帰用のauthoritative snapshot候補 |
| get_member/ship_deck | SquadのShipをcopyWithApi。Fleetとの整合性を修正する対象 |
| req_hensei/change、preset_select | FleetからShipを取得。古い参照を再利用しないようID化 |
| req_hokyu/charge | 現行はSquad側shipMapのfuel/bull更新。一元Repositoryへ移す |
| get_member/slot_item、require_info | 装備instance情報。古い装備オブジェクトを艦計算で参照しない |
| req_map/start、next | 出撃対象・map/node、Alert、log。battle世代/欠落検出へ拡張 |
| 戦闘API | 検証後atomic HP更新。新規/未対応schemaはUNKNOWN |
| goback_port/escape indexes | 退避候補/確定/護衛/active_deckの照合 |
| get_member/mapinfo | event HPゲージ、通常撃破回数の残り。取得時点を明示 |

現行Adapterで`api_get_member/ship2`の分岐はない。給糧艦やケッコン等の更新経路、修理、装備変更、編成、遠征帰還も現行Adapter範囲をIssueで棚卸しする。時刻だけでcond自然回復を実測扱いしない。

## 燃料/弾薬の表示仕様案

各艦：`現在値 / master最大値 ×100`。0最大値・master不足は「—」。艦隊サマリーは`Σ現在 / Σ最大 ×100`（容量加重）と定義し、単純平均と混ぜない。退避艦を除く出撃対象と、母港の全編成集計を分ける。艦ごとの最低残量も展開で確認可能にする。

出撃中の消費推定は戦闘形式・夜戦・空襲・渦潮等で変わるため、取得値が更新されているかを先にfixture/実機で確認する。未取得の残量を正確な現在値として表示しない。必要なら推定を別フィールドにし「推定/最終取得」をUIに出す。初期PRで消費式を独断で埋めない。

## 33式と制空の比較

両実装に33式の骨格（素索敵sqrt、装備係数と改修、司令部補正、空枠補正）がある。EOは退避艦を除き、ConningTower Squadはshipsをそのまま集計する。大型飛行艇等の改修係数は実装差があり、差を見つけたらどちらが現仕様か一次根拠とfixtureで判断する。

制空は内部熟練度が範囲になる。ConningTowerは各艦minを合計して「n+」と表示し、EOには最小/最大の範囲表示がある。艦隊通常計算と基地航空計算を混同しない。戦闘中の搭載数・熟練度の取得限界を明記する。

## fixtureの扱い

token、Cookie、requestの認証値、提督識別、端末パス等を削除/置換し、シナリオに必要な値だけを残す。ゲーム由来fixtureはEOのLICENSEだけで自由な再配布が保証されるとは扱わない。公開可能性が不明なら合成fixtureを優先し、実ログは非公開で管理する。captured/synthetic/EO由来の区別をmetadataへ残す。

# research-workflow 仕様書（実装準拠）

本書は、`dev/` と `docs/_*.md` を除く現行ファイルを対象に、実装ベースで整理した仕様である。

## 1. ワークフローの目的
このワークフローの目的は、AIによる思考支援を最大化することである。単なる実験管理ではなく、実験・分析・仮説生成・意思決定を一貫して扱える研究運用基盤を目指す。

そのために、AIが理解しやすい最小入力セット（例: `config.yaml`, `logs/<exp>.json`, `results/<exp>/run_summary.json`）で実験を扱える構造を採用する。結果やログを一定形式で保存し、比較・要約・異常検出・次実験提案をしやすくする。

同時に、再現性と追跡可能性を担保するため、実験条件・結果・実行証跡・分析記録を分離して管理し、実装側で整合チェックと記録保護（hook/構造制約）を行う。

## 2. 設計方針（なぜこの仕様か）
- 再現性の担保:
  実験条件（`experiments`）、結果（`results`）、実行証跡（`logs`）を分離し、後から同一条件を追跡できるようにする。
- 監査可能性の担保:
  `run_exp` と pre-commit hook を通して、結果だけが先行してコミットされる状態を防ぐ。
- AI支援と人間判断の分離:
  `notes.md` は AI記述領域（Section 1/2）と人間意思決定領域（Section 3）を分け、意思決定履歴を保護する。
- framework と project の責務分離:
  framework repo はテンプレートとルール提供に限定し、実データは project repo 側で保持する。

## 3. スコープ
- 対象リポジトリは「framework repo」であり、実験結果そのものを保持する場ではない。
- 利用者は別途 project repo を作成し、本リポジトリを `framework/` として submodule 利用する想定。

## 4. AGENTS.md の役割と利用法
- 役割:
  - AIエージェントの行動規範を定義する運用ルールファイル。
  - 実験・分析・コード編集時の禁止事項、優先順位、記録方針を明文化する。
- 利用法:
  - project 初期化時に `setup.sh` で project ルートへ配置し、AI作業時の基準として参照する。
  - 特に分析フェーズでは、`analysis/<ana>/events/` へのイベント記録、`discussion.md` 追記、`intent.md` の人間最終決定などのルールに従う。
  - 仕様と運用が衝突した場合は、AGENTS.md のガードレールを優先し、必要に応じて文書を更新する。

## 5. リポジトリ構造（実体）
- ルート主要ファイル
  - `AGENTS.md`
  - `README.md`
  - `VERSION.md`
  - `setup.sh`
- ドキュメント
  - `docs/CONCEPT.md`
  - `docs/PURPOSE.md`
  - `docs/STRUCTURE.md`
  - `docs/USAGE.md`
- フック
  - `hooks/pre-commit`
  - `hooks/README.md`
- テンプレート
  - `templates/config_core.yaml`
  - `templates/notes.md`
  - `templates/codexrc`
  - `templates/project/ai_context/{intent.md, project_notes.md}`
  - `templates/project/bin/{new_exp, run_exp, run_exp_patterns, generate_notes, new_analysis}`
  - `templates/SKILLS/notes-updater/SKILL.md`
  - `templates/project/{experiments,results,logs,src}`（`.gitkeep`）

## 6. セットアップ仕様（`setup.sh`）
project repo ルートで `framework/setup.sh` を実行すると、以下を行う。
1. `framework/templates/project/*` を project ルートへコピー
2. `framework/templates/codexrc` を `.codexrc` としてコピー
3. `framework/AGENTS.md` を `AGENTS.md` としてコピー
4. `framework/hooks/pre-commit` を `.git/hooks/pre-commit` へシンボリックリンク
5. `framework/hooks/pre-commit` に実行権限付与
6. `.codex/skills/notes-updater/SKILL.md` を templates からコピー
7. `chmod -R a-w framework` で framework 配下を読み取り専用化

理由:
- 初期導入時の人手ミス（ファイル配置、hook未設定、skills 未配置）を減らすため。
- framework を読み取り専用化することで、project 側の成果物と framework 側テンプレートの境界を明確にするため。

## 7. 実験テンプレート仕様

### 7.1 `bin/new_exp <exp_name>`
- 作成物
  - `experiments/<exp_name>/config.yaml`
  - `experiments/<exp_name>/notes.md`
- `config.yaml` は `templates/config_core.yaml` の `__EXP_NAME__` を置換して生成
- 同名 `config.yaml` / `notes.md` が存在する場合はエラー終了

理由:
- 実験ごとに最小限の雛形を統一生成し、比較しやすい入力構造を担保するため。
- 既存ファイル上書きを禁止し、実験定義の意図しない破壊を防ぐため。

### 7.2 `templates/config_core.yaml`
最低限の設定テンプレート:
- `experiment.name`
- `output.results_dir`
- `execution.command`（`--config experiments/<exp>/config.yaml` を渡す構成）
- `postprocess.commands`（配列）

理由:
- 条件の真実源を `config.yaml` に集中させ、実行時引数への条件分散を避けるため。
- 後処理を設定に持たせることで、run ごとの処理差分を構造化して記録できるため。

### 7.2.1 config 設計原則（コア + 自由領域）
- コア項目（framework が最低限前提とする）
  - `experiment.name`
  - `output.results_dir`
  - `execution.command`
  - `postprocess.commands`
- 自由領域（実験依存で任意に拡張）
  - `problem`, `discretization`, `solver`, `convergence` など

方針:
- 再実行に必要な最小情報を `config.yaml` に集約する。
- 問題固有ロジックは framework では解釈せず、solver 側の責務とする。

### 7.2.2 外部データ取扱（軽量ルール v0.1）
- 目的:
  - 外部DB/外部ストレージ/API/外部データセットを参照する実験でも、何を参照し何を使ったかを最小情報で追跡可能にする。
- `config.yaml`:
  - `external_data` ブロックを任意追加可能（推奨）。
  - `external_data` は配列。
  - 各要素は `name`, `type`, `locator` を基本とし、`version`, `retrieved_at`, `note` は任意。
  - `locator` はクエリ/ID/URL/パス/DOI など人が読める最小参照を記録。
  - 生データ全量を config に貼り付けない。
- `run_summary.json`:
  - `external_data_used` を任意追加可能（推奨）。
  - 参照情報だけでなく、実際に計算に使用した値（`values_used`）を要約記録する。
  - 値が多い場合は統計量（min/max/mean など）でも可。
- `logs/<exp>.json`:
  - 外部参照の補助的 provenance（ソース名、参照時刻など）を短く残すのは任意。
  - 詳細は config / run_summary を優先し、二重管理を避ける。
- analysis:
  - 外部データ専用の別フローは導入しない。
  - `config.yaml` の `external_data` と `run_summary.json` の `external_data_used` を読んで通常どおり評価する。

### 7.3 `bin/run_exp <exp_name>`
主な処理:
1. `yq` v4+ を要求
2. `experiments/<exp>/config.yaml` を読み取り
3. 整合チェック
   - `experiment.name == <exp_name>`
   - `output.results_dir == results/<exp_name>`
   - `execution.command` に `--config experiments/<exp_name>/config.yaml` が含まれる
   - `execution.command` に実行時パラメータ（`--nx` 等）が直書きされていない
4. `results/<exp>` と `logs/` を作成
5. `logs/<exp>.json` を出力（project/framework commit・dirty 状態・実行コマンドを記録）
6. `execution.command` を実行
7. `postprocess.command`（単数）と `postprocess.commands`（複数）を順次実行
   - 失敗しても warning で継続

理由:
- `yq` と整合チェックで「設定と実行の不一致」を早期に検知するため。
- `logs/<exp>.json` に commit/dirty/command を残し、結果の provenance を最小コストで確保するため。
- postprocess の失敗を致命扱いにしないことで、主要実験結果の取得を優先しつつ失敗を可視化するため。

### 7.3.1 `run_exp` の非責務（Non-Goals）
- ソルバ実装を持たない。
- 問題固有パラメータの意味を解釈しない。
- 結果の妥当性評価や採否判定を行わない。

方針:
- `run_exp` は「実験起動・整合チェック・実行記録」の薄いラッパーに限定する。

### 7.4 `bin/run_exp_patterns '<glob>'`
- `experiments/` 直下ディレクトリ名を glob マッチ
- 対象ごとに `./bin/run_exp <exp>` を実行
- 失敗・スキップ（config 欠落）を集計表示

理由:
- 系列実験の一括実行を可能にし、同条件群の比較実験を回しやすくするため。
- 失敗を集計して最後に提示し、再実行対象の切り分けを容易にするため。

### 7.5 `bin/generate_notes <exp_name> [mode]`
モード:
- `--stdout-prompt`（既定）: 参照ファイルベースのプロンプトを標準出力
- `--llm-internal`: 内部LLM向けプロンプトを標準出力（ファイル更新なし）
- `--llm-external`: 外部LLMコマンドで生成し `notes.md` を更新

入力ファイル:
- 必須: `experiments/<exp>/config.yaml`, `results/<exp>/run_summary.json`
- 任意: `ai_context/intent.md`

更新仕様:
- 対象: `experiments/<exp>/notes.md`
- 置換: `## 1. AI Summary` と `## 2. AI Analysis` のみ
- 保持: `## 3. Human Thoughts`
- セクション構造が壊れている場合はエラー停止
- `--dry-run` は差分表示のみ
- 既定でバックアップ（`notes.md.bak.<timestamp>`）作成

理由:
- AI生成を Section 1/2 に限定し、人間の判断記録（Section 3）を保全するため。
- dry-run / backup を標準化し、AI更新の安全性と可逆性を確保するため。
- モード分離（prompt出力 / 内部 / 外部LLM）で運用環境差を吸収するため。

### 7.5.1 `generate_notes` モード選定ガイド
- `--stdout-prompt`:
  人間が外部LLMに手動投入する運用向け。
- `--llm-external`:
  非対話で notes 更新まで自動化する運用向け。
- `--llm-internal`:
  既に LLM CLI セッション内にいる場合の再帰呼び出し回避向け（LLM呼び出しは行わない）。

### 7.5.2 `generate_notes` 安全設計
- 空出力、必須見出し欠落（`## 1`, `## 2`）をエラーとして拒否する。
- `notes.md` の構造不正時は停止し、全体再生成を行わない。
- 更新範囲を Section 1/2 に限定し、Section 3 を常に保持する。
- `--dry-run` とバックアップで変更の可逆性を担保する。

### 7.6 `bin/new_analysis <analysis_name>`
- 作成物
  - `analysis/<name>/meta.json`
  - `analysis/<name>/discussion.md`
  - `analysis/<name>/events/`
- `analysis_name` は `[A-Za-z0-9._-]+` のみ許可
- 既存名は作成拒否
- 分析開始はユーザープロンプト起点で行い、分析名（topic）を受け取って `./bin/new_analysis <analysis_name>` を実行する
- 入力追加は専用CLIを使わず、プロンプト駆動で `events/NNN_add_input.md` 記録と `meta.json` 更新を行う
- `discussion.md` の追記粒度は AGENTS.md を正とし、objective ごとに Quantitative / Qualitative / Baseline / Verdict / Proposed Status を記録する

理由:
- 分析単位を明示ディレクトリ化し、議論の履歴を後から辿れるようにするため。
- 名前制約で path traversal や不正文字混入を防ぎ、安全に自動生成できるようにするため。

### 7.7 外部データ実験のAIチェック項目
外部データを含む実験をレビューする際は、以下を確認する。
1. `config.yaml` に `external_data`（参照条件）があるか。
2. `run_summary.json` に `external_data_used`（使用値）があるか。
3. `locator` と `values_used` に矛盾がないか。
4. baseline 比較時に外部データ条件が揃っているか。

満たさない場合は「要修正」として扱う。

## 8. Git Hook 仕様（`hooks/pre-commit`）
- staged に `results/<exp>/...` が含まれる場合、`logs/<exp>.json` の同時 staged を必須化
- 未同時コミット時は commit をブロック

理由:
- 「結果だけあるが実行情報がない」状態を防ぎ、再現不能コミットを事前に遮断するため。

## 9. notes-updater スキル仕様（テンプレート）
`templates/SKILLS/notes-updater/SKILL.md` の定義:
- 読み取り対象を限定（config/run_summary/intent/notes）
- `notes.md` の更新対象を Section 1,2 に限定
- Section 3 を不変とする
- 出力は日本語、Facts と Evaluation を分離

理由:
- AGENTS の基本原則（事実と評価の分離、人間最終決定）を運用手順に落とし込むため。

## 10. 仕様上の運用前提
- 実行環境は bash と `yq`（v4+）を前提。
- 実験実行は `bin/run_exp` 経由を基本とし、`results` と `logs` の対応を保つ。
- `notes.md` 更新はセクション境界の厳密一致に依存するため、手修正で見出しを崩さないこと。
- 外部データは原則コピーせず、参照情報（`external_data`）と使用値要約（`external_data_used`）を記録して再評価可能性を担保する。

## 11. 将来拡張候補（現時点では未実装）
- `docs/how2make_run_exp.md` には `execution.working_dir`, `execution.timeout`, `execution.environment` の拡張案が示されている。
- 現行 `bin/run_exp` は上記キーを解釈しないため、採用する場合は実装修正と仕様更新を同時に行う。

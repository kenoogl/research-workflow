# 2026-02-26

このフレームワークは

> **AIによる思考支援を最大化する研究OS**

です。

単なる実験管理ではなく、

- 実験
- 分析
- 仮説生成
- 目的管理
- 論文化接続

まで含む設計。

------

# 1️⃣ 実験フェーズの整理

## 最小AI入力セット

実験後、AIに渡す最低限のもの：

- `config.yaml`
- `logs/<exp>.json`
- `results/<exp>/run_summary.json`

これで：

- 要約
- 比較
- 仮説生成
- 異常検出
- 論文化可能性評価

が可能。

------

## run_summary.json の役割

- 結果のみを記録
- solver依存を最小化
- 実験間で共通キーを持つ

設計原則：

- 人が読める
- AIが比較しやすい（フラット）
- solver依存を減らす
- provenanceを持つ

------

# 2️⃣ notes.md 設計確定

各実験ごとに：

```
experiments/<exp>/notes.md
```

構造：

```markdown
## 1. AI Summary (Facts)
## 2. AI Analysis (Evaluation)
## 3. Human Thoughts (Decision)
```

AIは：

- 事実整理
- 評価
- 仮説生成
- 最小次実験提案

人は：

- 採用／却下／保留を決める

------

# 3️⃣ generate_notes スクリプト

3モード：

1. `--stdout-prompt`
   → Atlas等に貼る
2. `--llm "<cmd>"`
   → 外部CLI LLMに渡して自動更新
3. `--llm-internal`
   → Codex CLI内部実行

思想：

- 自動化は可能
- でも責任は人間

------

# 4️⃣ 分析フェーズの導入

実験とは別に：

```
analysis/<ana>/
```

を導入。

------

## 構造確定

```
analysis/<ana>/
├── meta.json
├── discussion.md
├── events/
│   ├── 001_prompt.md
│   ├── 001_response.md
│   ├── 002_prompt.md
│   ├── 002_response.md
│   └── ...
```

------

## 設計思想

- 1分析 = 1ディレクトリ
- events は連番
- LLMとの対話は全て保存
- provenanceを担保
- 制約は最小限

------

## inputs_snapshot/

- new_analysisでは作らない
- LLMに指示されたら保存
- 横断分析では複数可

------

# 5️⃣ objective 設計

intent.md は：

> 複数objectiveを持つ

フラット構造。

------

## objective の仕様

各 objective は必ず持つ：

- Claim
- Quantitative Criteria
- Qualitative Criteria
- Comparison Baseline
- Status

------

# 6️⃣ Status導入

Status種類：

- exploratory
- active
- partially_validated
- validated
- rejected
- abandoned
- merged

------

## Status更新ルール

AIが：

- 提案する

人が：

- 承認する

AIは intent.md を直接変更しない。

------

# 7️⃣ analysis と objective の接続

analysis//objective.md に：

```markdown
- O1
- O3
```

と対象objectiveを明示。

AIは：

- listed objectivesのみ評価
- activeを優先

------

# 8️⃣ AI思考支援の最大化方針

AIが強い：

- 比較
- 要約
- 論点抽出
- 反証
- 代替案生成

AIが弱い：

- 入力が散乱
- 何を見るか不明
- 曖昧な成功条件

だから：

- 実験結果を構造化
- objectiveを明示
- 成功基準を明確化

------

# 9️⃣ Success Criteria設計

基本：

- 自然言語

補助：

- 半構造化hintも可

制限しないが：

- 全objectiveに必須

------

# 権限分離設計

- AIは提案者
- 人は決定者
- Gitは記録者

三者分離が明確。

------

# 全体構造

```
intent.md              ← 研究の地図（複数objective）
experiments/<exp>/     ← 実験の事実
analysis/<ana>/        ← 思考の履歴
results/               ← 数値証拠
logs/                  ← 実行証拠
```



------

# 本質

> AIを使う方法を設計した

のではなく

> AIが考えやすい研究構造を設計した




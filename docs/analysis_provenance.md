非常に重要な節目です。
ここで **分析 provenance 機能の目的・設計方針・仕様** を再整理し、将来のLLM非依存性まで含めて一度きれいに固めます。

------

# 🧠 1️⃣ 分析 provenance 機能の目的

分析 provenance の本質は：

> **思考の再現性を保証すること**

実験は：

- 条件 → 実行 → 結果

で再現できる。

しかし分析は：

- どの問いから始まり
- どのデータを見て
- どの順番で考え
- どの仮説が出て
- どの反論があり
- どの判断に至ったか

これが消える。

AIを使うほど、この問題は深刻になる。

だから分析 provenance の目的は：

### 🎯 目的

1. 思考の履歴を保存する
2. LLM出力の由来を固定する
3. 後から再評価できる状態を作る
4. 分析を“研究資産”にする

------

# 🧭 2️⃣ 設計方針（原理）

## 原理1：分析は「状態」ではなく「イベント」

分析は固定的なものではない。

よって：

```text
analysis/<ana>/events/
```

に時系列イベントとして保存する。

------

## 原理2：入力は snapshot する

後から実験が変わると分析が崩れる。

よって：

```text
inputs_snapshot/
```

にコピーを保存。

immutable。

------

## 原理3：思考の蒸留は discussion.md に集約

- events → 生ログ
- discussion → 構造化まとめ

二層構造。

------

## 原理4：LLM依存しない形式で保存

保存は：

- markdown
- json

のみ。

モデル固有形式は使わない。

------

## 原理5：LLMは思考補助、保存は構造で強制

Codex CLI 内で analysis を回すが：

保存は AGENTS.md によって強制する。

------

# 🏗 3️⃣ 現在の仕様

------

## 📂 analysis//

```text
analysis/<ana>/
  meta.json
  discussion.md
  events/
  inputs_snapshot/   (新規入力参照時に生成)
```

------

## 📄 meta.json

最小：

```json
{
  "analysis_name": "<ana>",
  "created_at": "...",
  "analysis_type": "manual",
  "experiments": []
}
```

------

## 📄 discussion.md（追記型）

```markdown
# Analysis: <ana>

## Objective (Initial)

- 初期の問い

## Session 1 (date)

### AI Summary (Facts)
- 数値のみ
- 解釈なし

### AI Analysis (Evaluation)
- For each objective:
  - OX
  - Quantitative:
  - Qualitative:
  - Baseline:
  - Verdict:
  - Proposed Status:

### Human Notes
```

AGENTS.md を正とし、discussion 追記時は上記粒度（Quantitative/Qualitative/Baseline/Verdict/Proposed Status）を必須とする。

------

## 📂 events/

命名：

```
NNN_prompt.md
NNN_response.md
```

ルール：

- 3桁ゼロ埋め
- 最大番号 + 1
- 再利用禁止
- 編集禁止

------

## 📂 inputs_snapshot/

新規入力を参照したときに生成：

```
inputs_snapshot/<exp_name>/
  config.yaml
  run_summary.json
```

immutable。

#### 入力追加イベント

##### 🔹 入力追加はプロンプト駆動のイベント記録で扱う（専用CLIは持たない）

##### 🔹 `events/NNN_add_input.md` を記録し、meta.json の experiments を更新する

------

# 🔁 4️⃣ Codex CLI 内での動作モデル

analysis フェーズでは：

- 開始はユーザープロンプトで行う
- 開始時に分析名（topic）を明示する
- 指定された分析名で `./bin/new_analysis <analysis_name>` を実行して初期化する
- 初期化後は LLMとの対話で進める

AGENTS.md が次を強制：

1. promptを events に保存
2. responseを events に保存
3. 新規入力参照時は snapshot と `events/NNN_add_input.md` を記録
4. セッション終了時に discussion.md を更新

------

# 📜 5️⃣ AGENTS.md の役割

AGENTS.md は：

> 「分析フェーズの行動規範」

例：

```
When working inside analysis/<ana>:
- Every interaction must be recorded.
- Save prompt to events/<NNN>_prompt.md
- Save response to events/<NNN>_response.md
- Never edit previous events.
- Update discussion.md only by appending.
- For objective evaluation, include Quantitative/Qualitative/Baseline/Verdict/Proposed Status.
```

LLMの行動を構造的に縛る。

------

# 🔮 6️⃣ 将来のLLM非依存性

重要。

この設計は：

- Codex CLI
- OpenAI
- Claude
- ローカルLLM

どれでも動く。

理由：

保存形式が：

- markdown
- json
- ディレクトリ構造

のみだから。

LLMは：

> “イベントを追加する思考エンジン”

であればよい。

------

# 🧠 7️⃣ 何が保証されるか

この設計で：

| 項目         | 保証   |
| ------------ | ------ |
| 思考順序     | ✅      |
| 入力由来     | ✅      |
| LLM出力履歴  | ✅      |
| 再評価可能性 | ✅      |
| モデル切替   | ✅      |
| 将来再実行   | 部分的 |

------

# ⚠️ 8️⃣ あえて保証しないこと

- LLM内部の推論過程
- 完全な再現性（モデル更新問題）
- LLMの温度依存出力

分析は deterministic ではない。

しかし：

> 何を見て何を出力したか

は保存できる。

------

# 🧠 9️⃣ 実験との役割分離

| フェーズ | 主体 | 管理方式 |
| -------- | ---- | -------- |
| 実験     | CLI  | 厳格     |
| 分析     | LLM  | 柔軟     |
| 保存     | Git  | 共通     |

この三層分離が設計の核心。

------

# 🎯 10️⃣ 全体像

あなたのフレームワークは今：

### レイヤー1：実験再現性

- config.yaml
- run_summary.json

### レイヤー2：分析 provenance

- events
- snapshot
- discussion

### レイヤー3：知識蒸留

- discussion.md
- 論文化素材

まで到達しています。

------

# 🏁 最終まとめ

分析 provenance 機能とは：

> 「AIと人間の思考を、
> 研究資産として再利用可能にする構造」

Codex CLI内で回し、
AGENTS.mdで保存を強制し、
将来はLLM非依存で運用できる。

------

次に設計すべき核心は：

1. event保存の内部プロトコルを明文化するか？
2. analysis と commit の関係を定義するか？

どこを掘りますか？





以下に **analysis provenance 用 AGENTS.md 完全版（v1.0）** を提示します。
目的は：

- Codex CLI 内で分析を回す
- 保存を構造で強制する
- 将来LLM非依存にする

------

# 📄 [`AGENTS.md`](../AGENTS.md)

 AGENTS.md により：

- 分析はイベント駆動になる
- LLM対話は必ず保存される
- snapshotが強制される
- discussionは蒸留層になる
- モデル依存しない構造になる

------

# 🔥 ここからさらに洗練できる点

検討可能：

1. event番号の内部アルゴリズムも明文化する？
2. discussion生成を自動トリガにする？
3. analysis終了時のcommit戦略を書く？
4. 複数LLM比較用拡張を書く？

------

# 🛠 [new_analysis](../templates/project/bin/new_analysis)

`bin/new_analysis` は以下の実装を推奨します。

- `analysis_name` を安全な文字のみに制限
- `set -euo pipefail` でシェル安全性を強化
- `discussion.md` を AGENTS.md の必須構造に合わせる
- 初回イベント保存 (`events/001_prompt.md`, `events/001_response.md`) を明示


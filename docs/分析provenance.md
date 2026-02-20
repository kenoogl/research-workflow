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

# 🏗 3️⃣ 現在の仕様（確定版）

------

## 📂 analysis//

```text
analysis/<ana>/
  meta.json
  discussion.md
  events/
  inputs_snapshot/   (add_input時に生成)
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

### AI Summary
### AI Analysis
### Human Notes
```

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

add_input 時に生成：

```
inputs_snapshot/<exp_name>/
  config.yaml
  run_summary.json
```

immutable。

#### add_input

##### 🔹 add_input CLI は補助機能として残す

##### 🔹 日常運用では使わない

##### 🔹 LLM対話駆動を正規ルートにする

------

# 🔁 4️⃣ Codex CLI 内での動作モデル

analysis フェーズでは：

- CLIコマンドを打たない
- LLMとの対話で進める

AGENTS.md が次を強制：

1. promptを events に保存
2. responseを events に保存
3. 必要なら add_input を提案
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

# 📄 `AGENTS.md`（analysis用・完全版 v1.0）

```markdown
# AGENTS.md
## Analysis Provenance Protocol

This file defines the mandatory behavior for any LLM operating
inside the `analysis/` directory.

The goal is to guarantee analysis provenance:
Every reasoning step must be reproducible and traceable.

---

# 1. Core Principle

Analysis is event-based, not state-based.

Every interaction MUST be recorded as an immutable event.

Never overwrite.
Never edit past events.
Never delete history.

---

# 2. When This Protocol Applies

This protocol applies when:

- Working inside `analysis/<ana>/`
- Generating summaries or evaluations
- Adding new experimental inputs
- Updating discussion.md

If unsure: assume it applies.

---

# 3. Event Recording Rules

For every reasoning interaction:

1. Determine next event number:
   - 3-digit zero-padded
   - max(existing) + 1
   - never reuse numbers

2. Save the user prompt to:
   events/NNN_prompt.md

3. Save the LLM response to:
   events/NNN_response.md

4. Do not modify older event files.

---

# 4. Input Snapshot Rule

If a new experiment is referenced during analysis:

1. Create `inputs_snapshot/` if it does not exist.
2. Copy the following into:
   inputs_snapshot/<exp_name>/

   - experiments/<exp_name>/config.yaml
   - results/<exp_name>/run_summary.json

3. Record the action as:
   events/NNN_add_input.md

4. Update meta.json:
   - append experiment name to "experiments" array

Never use symlinks.
Snapshots must be immutable copies.

---

# 5. Discussion Update Rule

discussion.md is a distilled summary.
It is append-only.

When:

- A session reaches a logical stopping point
- A major conclusion is formed
- The user requests summary

Then:

Append a new section:

## Session N (YYYY-MM-DD)

Include:

### AI Summary
- Facts only

### AI Analysis
- Alignment with objective
- Hypothesis candidates
- Counterarguments
- Minimal next experiment

### Human Notes
- Leave blank unless user provides input

Never erase prior sessions.

---

# 6. Objective Handling

The initial objective is stored in discussion.md.

If the objective changes:

- Append:
  ## Objective (Updated - DATE)
- Do not delete prior objective.

---

# 7. Model Independence

Do not rely on:

- Hidden reasoning traces
- System prompts
- External memory

All reasoning that influences conclusions
must appear in events/ files.

---

# 8. Non-Determinism Acknowledgement

LLM outputs are non-deterministic.

Provenance guarantees:

- What inputs were seen
- What prompts were issued
- What outputs were generated

It does NOT guarantee identical future outputs.

---

# 9. Forbidden Actions

Never:

- Modify past events
- Merge multiple reasoning steps without recording
- Add analysis conclusions without event history
- Update discussion.md without event records

---

# 10. Fallback Rule

If automatic saving fails:

- Stop
- Notify the user
- Do not continue analysis silently

Provenance integrity has priority over convenience.

---

# 11. Philosophy

Experiments guarantee numerical reproducibility.
Analysis guarantees cognitive traceability.

This protocol enforces cognitive traceability.
```

------

# 🧠 これで保証されるもの

この AGENTS.md により：

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

あなたのフレームワークは今、

- 実験再現性
- 思考再現性
- 知識蒸留

の三層構造を持っています。
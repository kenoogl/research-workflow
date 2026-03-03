# 📌 generate_notes v3 仕様

------

# 1️⃣ コマンド形式

```
generate_notes <exp_name> [MODE] [OPTIONS]
```

------

# 2️⃣ モード一覧（3モード）

| モード            | 用途                  | LLM呼び出し |
| ----------------- | --------------------- | ----------- |
| `--stdout-prompt` | 人間が外部LLMに貼る   | ❌ 呼ばない  |
| `--llm-external`  | bashからLLM CLIを呼ぶ | ✅ 呼ぶ      |
| `--llm-internal`  | 既にLLM CLI内         | ❌ 呼ばない  |

------

# 3️⃣ デフォルト動作

何も指定しない場合：

```
--stdout-prompt
```

安全優先。

------

# 4️⃣ 必須入力ファイル

```
experiments/<exp>/config.yaml
results/<exp>/run_summary.json
```

存在しない場合は終了。

------

# 5️⃣ オプション一覧

| オプション          | 説明                                     |
| ------------------- | ---------------------------------------- |
| `--stdout-prompt`   | プロンプトのみ出力                       |
| `--llm-external`    | 外部LLM実行                              |
| `--llm-internal`    | 内部LLMセッション用                      |
| `--llm-cmd "<cmd>"` | LLMコマンド指定                          |
| `--dry-run`         | 書き込みなし                             |
| `--force`           | notes.md テンプレートを再作成（既存でも上書き） |
| `--backup`          | 更新前にバックアップ作成（デフォルトON） |

------

# 6️⃣ 共通処理フロー

------

## Step 1: 入力チェック

- config.yaml
- run_summary.json

------

## Step 2: notes.md 準備

通常は無ければテンプレ生成。`--force` 指定時は既存でも再作成：

```
experiments/<exp>/notes.md
```

標準構造を保証。

------

## Step 3: プロンプト生成

入力内容：

- config.yaml
- run_summary.json
- ai_context/intent.md（存在すれば）

固定フォーマットで生成。

------

# 7️⃣ モード別動作

------

# 🟢 A) --stdout-prompt

### 動作

- プロンプトをstdoutに出力
- notes.mdは変更しない
- 終了

------

# 🔵 B) --llm-external

### 前提

- `--llm-cmd` または
- 環境変数 `RW_LLM_CMD`

が必要。

### 動作

1. プロンプト生成

2. 外部LLM呼び出し

   ```
   OUTPUT=$(printf "%s\n" "$PROMPT" | bash -lc "$LLM_CMD")
   ```

   補足:
   - `LLM_CMD` に `codex run` が含まれる場合、`codex exec` に自動置換して非対話実行する。

3. 出力検証

   必須見出し：

   - `## 1. AI Summary`
   - `## 2. AI Analysis`

4. notes.md 更新（AI部分のみ）

5. Human Thoughts保持

6. バックアップ作成（`notes.md` が既存のとき）

7. 完了メッセージ

------

# 🟣 C) --llm-internal

### 想定環境

- 既に codex / claude CLI 内にいる

### 動作

1. プロンプト出力

2. 追記：

   ```
   You are inside LLM CLI.
   Write AI Summary and AI Analysis
   into: experiments/<exp>/notes.md
   Only replace sections 1 and 2.
   ```

3. generate_notes はここで終了（notes.md は変更しない）

### generate_notesはここで終了

------

# 8️⃣ notes.md 更新仕様

------

## 標準構造

```md
## 1. AI Summary (Facts)
...
## 2. AI Analysis (Evaluation)
...
## 3. Human Thoughts (Decision)
...
```

------

## 更新範囲

- `## 1.` から
- `## 3.` の直前まで

のみ置換。

------

# 9️⃣ 安全設計

------

## 出力検証

LLM出力に：

- Summary見出し無し → エラー
- Analysis見出し無し → エラー
- 空出力 → エラー

------

## バックアップ

```
notes.md.bak.<timestamp>
```

`BACKUP=true` かつ `notes.md` が既存の場合に作成。

------

## dry-run

- 差分表示のみ
- 書き込みしない

------

# 🔟 失敗ケース設計

| 状況              | 動作   |
| ----------------- | ------ |
| LLMコマンド未設定 | エラー |
| 出力不正          | 中止   |
| notes.md構造破損  | 中止   |
| 実験未実行        | エラー |

------



# 🎯 internal モードの前提

あなたは今：

- Codex CLI や Claude CLI の中にいる
- つまり **LLMがコマンドを実行できる環境**

例：

```
codex
>
```

この状態。

------

# 🧠 なぜ internal モードが必要か？

外部モードでは：

```
generate_notes
  ↓
  codex run
```

になります。

でも LLM CLI の中でそれをやると：

> LLMが自分自身を呼ぶ

再帰になって壊れます。

なので internal モードでは：

> LLMを呼ばない
>  プロンプトだけ出す

------

# 🔥 実際の使い方（Codex CLI内）

------

## ① Codex CLIを起動

```
codex
```

------

## ② LLM内でコマンド実行

```
> ./bin/generate_notes exp_001 --llm-internal
```

------

## ③ generate_notes が出力するもの

ターミナルに：

```
================ INTERNAL LLM MODE =================

You are inside LLM CLI.

Write AI Summary and AI Analysis
into: experiments/exp_001/notes.md

Only replace sections:
- ## 1. AI Summary (Facts)
- ## 2. AI Analysis (Evaluation)

Do not modify:
- ## 3. Human Thoughts (Decision)

-----------------------------------------------------

<プロンプト全文>
```

が表示される。

------

## ④ LLMがそれを読む

LLMは：

- 表示されたプロンプトを読む
- config と run_summary を読む
- notes.md を直接編集する

------

# 🧠 internalモードで起きていること

generate_notes は：

- 何も更新しない
- LLMを呼ばない
- プロンプトを整形するだけ

編集は：

> LLM自身がやる

------

# 🧩 ワークフロー例

```
codex
> ./bin/run_exp exp_omega_1.6
> ./bin/generate_notes exp_omega_1.6 --llm-internal
```

LLMが：

- Summaryを書く
- Analysisを書く
- notes.md更新

あなたが：

- Human Thoughtsを書く











# 1️⃣ 研究フェーズ別使い分け

------

## 探索フェーズ

```
generate_notes exp --llm-external
```

高速化。

------

## LLM内対話型開発

```
generate_notes exp --llm-internal
```

安全・柔軟。

------

## 論文化前精査

```
generate_notes exp --stdout-prompt
```

慎重モード。



責任は常に：

```
## 3. Human Thoughts (Decision)
```



以降は実装準拠の具体例

## **現実に使える具体例**

前提：

```
./bin/generate_notes <exp_name> --llm-external
```

は内部で：

```
printf "%s\n" "$PROMPT" | bash -lc "$RW_LLM_CMD"
```

を実行する設計。

------

# 🎯 基本形

環境変数でLLMを指定：

```bash
export RW_LLM_CMD="codex run"
```

または直接：

```bash
./bin/generate_notes exp_001 --llm-external --llm-cmd "codex run"
```

------

# 🔥 パターン別具体例

------

# 1️⃣ Codex CLI

### パターンA（標準）

```bash
./bin/generate_notes exp_001 --llm-external --llm-cmd "codex run"
```

または：

```bash
export RW_LLM_CMD="codex run"
./bin/generate_notes exp_001 --llm-external
```

------

### パターンB（モデル指定）

```bash
./bin/generate_notes exp_001 --llm-external \
  --llm-cmd "codex run --model gpt-4.1"
```

------

### パターンC（低温度・安定出力）

```bash
./bin/generate_notes exp_001 --llm-external \
  --llm-cmd "codex run --temperature 0.2"
```

------

# 2️⃣ Claude CLI

（例：anthropic CLI がある場合）

```bash
./bin/generate_notes exp_001 --llm-external \
  --llm-cmd "claude"
```

モデル指定：

```bash
./bin/generate_notes exp_001 --llm-external \
  --llm-cmd "claude --model claude-3-opus"
```

------

# 3️⃣ OpenAI CLI（仮想例）

```bash
./bin/generate_notes exp_001 --llm-external \
  --llm-cmd "openai chat.completions.create -m gpt-4.1"
```

※この場合は入力形式に注意が必要

------

# 4️⃣ Ollama（ローカルLLM）

```bash
./bin/generate_notes exp_001 --llm-external \
  --llm-cmd "ollama run llama3"
```

軽量モデル：

```bash
./bin/generate_notes exp_001 --llm-external \
  --llm-cmd "ollama run mistral"
```

------

# 5️⃣ llama.cpp

```bash
./bin/generate_notes exp_001 --llm-external \
  --llm-cmd "./main -m model.gguf"
```

------

# 6️⃣ Wrapperスクリプト経由（おすすめ）

`bin/llm_notes` を自作して：

```bash
#!/usr/bin/env bash
codex run --model gpt-4.1 --temperature 0.3
```

実行：

```bash
./bin/generate_notes exp_001 --llm-external --llm-cmd "./bin/llm_notes"
```

👉 将来の変更に強い。

------

# 🧠 実運用おすすめ構成

### ~/.bashrc に固定

```bash
export RW_LLM_CMD="codex run --model gpt-4.1 --temperature 0.2"
```

そして：

```bash
./bin/generate_notes exp_001 --llm-external
```

だけで動く。

------

# 🎯 研究用途での推奨

| フェーズ   | 推奨                |
| ---------- | ------------------- |
| 探索高速化 | 低温度（0.2）       |
| 論文化前   | 標準温度（0.3-0.5） |
| 仮説発散   | 高温度（0.7）       |

------

# ⚠ 注意点

1. LLM出力形式が崩れると更新拒否される設計にする
2. 長文出力でtoken制限に注意
3. ローカルLLMは精度が落ちる可能性

------

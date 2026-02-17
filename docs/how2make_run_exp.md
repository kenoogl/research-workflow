# bin/run_expスクリプトの作り方

> **run_exp は「実験を“起動・記録する”ための薄いラッパー」**
> 問題固有ロジックは一切入れない。

- ❌ ソルバ実装を書かない
- ❌ パラメータを解釈しない
- ❌ 結果を評価しない



------

## run_exp の3つの役割

#### ① 実験を一意に同定する

- exp_name
- config.yaml
- 出力ディレクトリ

#### ② 実行の“事実”を run.json に記録する

- project commit
- framework commit
- 実行コマンド
- config の所在

#### ③ 実行を「1点」に集約する

- python / julia / MPI を **直接叩かせない**
- run_exp を唯一の入口にする

------

## run_exp の全体構造（例）

```text
bin/run_exp
    │
    ├─ 引数チェック
    ├─ パス解決（config / results）
    ├─ Git 情報取得
    ├─ run.json 書き出し
    └─ 問題固有ランナーを呼ぶ（1行）
```



------

## run_exp（例）

### 前提ディレクトリ

```text
project/
├── bin/
│   └── run_exp
├── experiments/
│   └── mg_2level/
│       └── config.yaml
├── src/
│   └── main.jl          # Poisson/MG solver
├── logs/
└── results/
```

------

### 正式スキーマ

~~~
execution:
  command: <string>          # 必須
  working_dir: <string>      # 任意
  timeout: <integer>         # 任意（秒）
  environment:               # 任意
    <KEY>: <VALUE>
~~~

### 1️⃣ 必須フィールド

#### `command`（必須）

#### 型

string

#### 意味

実際に実行されるシェルコマンド。

#### ルール

- **絶対パス禁止**
- `results/<exp_name>` を必ず出力先に含める
- config.yaml のパスを含めることを推奨

### 2️⃣ 任意フィールド

#### `working_dir`

#### 型

string

#### 意味

コマンド実行時の作業ディレクトリ。

例：

```
working_dir: src
```

run_exp は：

```
(cd "$working_dir" && bash -c "$command")
```

で実行。

#### `timeout`

#### 型

integer（秒）

将来拡張用。

例：

```
timeout: 600
```

v0.1 では未実装でもよい。

#### `environment`

#### 型

辞書

実行時の環境変数。

例：

```
environment:
  JULIA_NUM_THREADS: "8"
  OMP_NUM_THREADS: "8"
```

run_exp 側では：

```
export JULIA_NUM_THREADS=8
```

してから実行。



## run_exp の最小実装（bash）

```bash
#!/usr/bin/env bash
set -euo pipefail

# ============================================
# 依存チェック
# ============================================
if ! command -v yq >/dev/null 2>&1; then
  echo "[ERROR] yq がインストールされていません。"
  echo "インストール方法:"
  echo "  macOS: brew install yq"
  echo "  Ubuntu: sudo snap install yq"
  exit 1
fi

REQUIRED_YQ_MAJOR=4
INSTALLED_YQ_MAJOR=$(yq --version | awk '{print $NF}' | cut -d. -f1)

if [ "$INSTALLED_YQ_MAJOR" -lt "$REQUIRED_YQ_MAJOR" ]; then
  echo "[ERROR] yq v4 以上が必要です"
  exit 1
fi


# ============================================
# 0. 引数
# ============================================
EXP_NAME="${1:-}"

if [ -z "$EXP_NAME" ]; then
  echo "Usage: ./framework/bin/run_exp <experiment_name>" >&2
  exit 1
fi

CONFIG="experiments/${EXP_NAME}/config.yaml"

if [ ! -f "$CONFIG" ]; then
  echo "[ERROR] Config not found: $CONFIG" >&2
  exit 1
fi

# ============================================
# 1. YAML読み取り（yq 必須）
# ============================================
if ! command -v yq >/dev/null 2>&1; then
  echo "[ERROR] yq is required" >&2
  exit 1
fi

NAME_IN_CONFIG=$(yq -r '.experiment.name' "$CONFIG")
RESULTS_IN_CONFIG=$(yq -r '.output.results_dir' "$CONFIG")
EXEC_CMD=$(yq -r '.execution.command' "$CONFIG")

# ============================================
# 2. 整合チェック
# ============================================

if [ "$NAME_IN_CONFIG" != "$EXP_NAME" ]; then
  echo "[ERROR] experiment.name mismatch"
  echo "  directory: $EXP_NAME"
  echo "  config:    $NAME_IN_CONFIG"
  exit 1
fi

EXPECTED_RESULTS="results/${EXP_NAME}"

if [ "$RESULTS_IN_CONFIG" != "$EXPECTED_RESULTS" ]; then
  echo "[ERROR] output.results_dir mismatch"
  echo "  expected: $EXPECTED_RESULTS"
  echo "  config:   $RESULTS_IN_CONFIG"
  exit 1
fi

if [ -z "$EXEC_CMD" ] || [ "$EXEC_CMD" = "null" ]; then
  echo "[ERROR] execution.command not defined" >&2
  exit 1
fi

# execution.command に exp_name が含まれているか
if ! echo "$EXEC_CMD" | grep -q "experiments/${EXP_NAME}"; then
  echo "[ERROR] execution.command does not reference its own config file" >&2
  exit 1
fi

if ! echo "$EXEC_CMD" | grep -q "results/${EXP_NAME}"; then
  echo "[ERROR] execution.command does not reference its own results directory" >&2
  exit 1
fi

# ============================================
# 3. 出力ディレクトリ作成
# ============================================
OUTDIR="results/${EXP_NAME}"
LOGDIR="logs"
RUN_JSON="${LOGDIR}/run.json"

mkdir -p "$OUTDIR" "$LOGDIR"

# ============================================
# 4. Git情報（project）
# ============================================
PROJECT_COMMIT=$(git rev-parse --short HEAD)
if git diff --quiet && git diff --cached --quiet; then
  PROJECT_DIRTY=false
else
  PROJECT_DIRTY=true
  echo "[WARNING] Project repo dirty=true"
fi

# ============================================
# 5. Git情報（framework submodule）
# ============================================
FRAMEWORK_COMMIT="none"
FRAMEWORK_DIRTY="none"

if [ -d "framework/.git" ]; then
  FRAMEWORK_COMMIT=$(git -C framework rev-parse --short HEAD)
  if git -C framework diff --quiet && git -C framework diff --cached --quiet; then
    FRAMEWORK_DIRTY=false
  else
    FRAMEWORK_DIRTY=true
    echo "[WARNING] Framework repo dirty=true"
  fi
fi

# ============================================
# 6. run.json 出力
# ============================================
cat <<EOF > "$RUN_JSON"
{
  "run_id": "${EXP_NAME}",
  "timestamp": "$(date -Iseconds)",
  "project": {
    "commit": "${PROJECT_COMMIT}",
    "dirty": ${PROJECT_DIRTY}
  },
  "framework": {
    "commit": "${FRAMEWORK_COMMIT}",
    "dirty": ${FRAMEWORK_DIRTY}
  },
  "execution": {
    "entrypoint": "./framework/bin/run_exp",
    "command": "$(printf '%s' "$EXEC_CMD" | sed 's/"/\\"/g')"
  },
  "inputs": {
    "config": "${CONFIG}"
  },
  "outputs": {
    "results_dir": "${OUTDIR}"
  }
}
EOF

echo "[run_exp] run.json written"

# ============================================
# 7. 実行
# ============================================
echo "[run_exp] Executing:"
echo "$EXEC_CMD"
bash -c "$EXEC_CMD"

if [ -n "$POSTPROCESS_COMMAND" ]; then
  POSTPROCESS_COMMANDS=$(printf '%s\n%s' "$POSTPROCESS_COMMANDS" "$POSTPROCESS_COMMAND")
fi

POSTPROCESS_COUNT=0
if [ -n "$POSTPROCESS_COMMANDS" ]; then
  while IFS= read -r POST_CMD; do
    [ -z "$POST_CMD" ] && continue
    POSTPROCESS_COUNT=$((POSTPROCESS_COUNT + 1))
    echo "[run_exp] Postprocess #${POSTPROCESS_COUNT}: ${POST_CMD}"
    if ! bash -c "$POST_CMD"; then
      echo "[WARNING] postprocess command failed (continuing): ${POST_CMD}" >&2
    fi
  done <<< "$POSTPROCESS_COMMANDS"
fi

echo "[run_exp] Experiment completed: ${EXP_NAME}"
```



------

### 数値実験の再現性に必要な情報が揃う

- 格子サイズ・BC → config.yaml
- 実装バージョン → project commit
- 手法バージョン → framework commit

👉 **論文で必要な provenance が自動で揃う**



------

### 試行錯誤に強い

- 実装をいじっても run_exp は変えない
- 実験を増やしても run_exp は増えない

👉 **run_exp が安定点になる**



------

## よくある NG 実装（やらない）

#### ❌ config を parse して条件分岐

```bash
if smoother == taylor; then ...
```

→ **solver の仕事**

------

#### ❌ 複数実験をループで回す

```bash
for exp in exp1 exp2 exp3; do ...
```

→ **再現性が壊れる**。必要な場合にはスクリプト自体も変更

------

#### ❌ 評価を書く

```bash
echo "looks converged" >> results
```

→ **Judge の仕事**

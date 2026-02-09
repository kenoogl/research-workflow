# bin/run_expスクリプトの作り方

------

## 結論（先に）

> **run_exp は「実験を“起動する”ための薄いラッパー」**
> 問題固有ロジックは一切入れない。

- ❌ ソルバ実装を書かない
- ❌ パラメータを解釈しない
- ❌ 結果を評価しない

👉 **run_exp の責務は 3 つだけ**。

------

## run_exp の3つの責務（固定）

### ① 実験を一意に同定する

- exp_name
- config.yaml
- 出力ディレクトリ

### ② 実行の“事実”を run.json に記録する

- project commit
- framework commit
- 実行コマンド
- config の所在

### ③ 実行を「1点」に集約する

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

👉 **問題固有なのは最後の1行だけ**

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

## run_exp の最小実装（bash）

```bash
#!/usr/bin/env bash
set -e

# -------------------------
# 0. 引数
# -------------------------
EXP_NAME="$1"
if [ -z "$EXP_NAME" ]; then
  echo "Usage: ./bin/run_exp <experiment_name>"
  exit 1
fi

CONFIG="experiments/${EXP_NAME}/config.yaml"
OUTDIR="results/${EXP_NAME}"
LOGDIR="logs"
RUN_JSON="${LOGDIR}/run.json"

if [ ! -f "$CONFIG" ]; then
  echo "Config not found: $CONFIG"
  exit 1
fi

mkdir -p "$OUTDIR" "$LOGDIR"

# -------------------------
# 1. Git 情報
# -------------------------
PROJECT_COMMIT=$(git rev-parse --short HEAD)
FRAMEWORK_COMMIT=$(git -C framework rev-parse --short HEAD 2>/dev/null || echo "none")
GIT_DIRTY=$(git diff --quiet || echo true)

# -------------------------
# 2. run.json 作成
# -------------------------
cat <<EOF > "$RUN_JSON"
{
  "run_id": "${EXP_NAME}",
  "timestamp": "$(date -Iseconds)",
  "framework": {
    "name": "research-workflow",
    "commit": "${FRAMEWORK_COMMIT}"
  },
  "project": {
    "commit": "${PROJECT_COMMIT}",
    "dirty": "${GIT_DIRTY}"
  },
  "execution": {
    "entrypoint": "./bin/run_exp",
    "command": "./bin/run_exp ${EXP_NAME}"
  },
  "inputs": {
    "config": "${CONFIG}"
  },
  "outputs": {
    "results_dir": "${OUTDIR}"
  }
}
EOF

echo "[run_exp] run.json written to ${RUN_JSON}"

# -------------------------
# 3. 実行
# -------------------------
# ↓ ここだけが問題依存
julia src/main.jl --config "${CONFIG}" --out "${OUTDIR}"
```

------

## なぜこの形が実験に合うか

### ① “比較軸”を壊さない

- 比較は **config.yaml の差分**
- run_exp は config を **解釈しない**

👉 MG level / smoother を変えても run_exp は不変。

------

### ② 数値実験の再現性に必要な情報が揃う

- 格子サイズ・BC → config.yaml
- 実装バージョン → project commit
- 手法バージョン → framework commit

👉 **論文で必要な provenance が自動で揃う**

------

### ③ 試行錯誤に強い

- 実装をいじっても run_exp は変えない
- 実験を増やしても run_exp は増えない

👉 **run_exp が安定点になる**

------

## よくある NG 実装（やらない）

### ❌ config を parse して条件分岐

```bash
if smoother == taylor; then ...
```

→ **solver の仕事**

------

### ❌ 複数実験をループで回す

```bash
for exp in exp1 exp2 exp3; do ...
```

→ **再現性が壊れる**。必要な場合にはスクリプト自体も変更

------

### ❌ 評価を書く

```bash
echo "looks converged" >> results
```

→ **Judge の仕事**

------

## run_exp と他ファイルの関係（再確認）

| ファイル         | 役割               |
| ---------------- | ------------------ |
| run_exp          | 実行入口・事実記録 |
| config.yaml      | 実験条件           |
| main.jl          | Poisson/MG 実装    |
| run.json         | 実行台帳           |
| codex_results.md | 結果要約           |
| judge_reviews.md | 評価・分岐         |

------

## 最短ルール（覚える用）

> **run_exp は
> config を渡して、
> run.json を書いて、
> solver を1回呼ぶだけ**

それ以上やりたくなったら、
**それは run_exp の責務じゃない**。


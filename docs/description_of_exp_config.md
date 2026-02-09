いい問い。ここを曖昧にすると **run.json も Judge も全部ブレる**ので、
**「何を書くか／何を書かないか」を明確に固定**しよう。

------

## 結論（先に）

> **`experiments/<exp_name>/config.yaml` に書くのは
> 「この実験を再実行するために最低限必要な“事実”だけ」**

- 実装の都合
- 思考の過程
- 評価コメント

は **絶対に書かない**。

------

## config.yaml の役割（1行定義）

> **この実験を「もう一度、同じ条件で」走らせるための入力仕様書**

------

## 書くべきもの（必須）

### 1️⃣ 実験の識別情報（最低限）

```yaml
experiment:
  name: mg_2level_baseline
  description: 2-level MG with Taylor smoother
```

- name：ディレクトリ名と一致
- description：**人間向け1行**

👉 Judge は **ここをほぼ見ない**。人間用。

------

### 2️⃣ 問題設定（PDE / 領域 / BC）

Poisson/MG ならここが核心。

```yaml
problem:
  equation: poisson
  dimension: 3
  domain:
    type: cartesian
    size: [1.0, 1.0, 1.0]
  boundary_condition:
    type: dirichlet
    value: 0.0
```

👉
**「何を解いたか」**が一意に分かること。

------

### 3️⃣ 離散化・格子

```yaml
discretization:
  grid:
    nx: 64
    ny: 64
    nz: 64
  layout: cell-centered
  ghost_cells: 1
```

- MG では grid 情報は **Judge の重要チェック項目**

------

### 4️⃣ アルゴリズムの選択（構造レベル）

**数値の意味を持つパラメータだけ**。

```yaml
solver:
  method: multigrid
  levels: 2
  smoother:
    type: taylor
    order: 2
  coarse_solver: direct
```

❌ NG 例

- `alpha: 0.1234`（意味不明）
- `magic_factor: true`

👉 **論文で説明できる粒度だけ**

------

### 5️⃣ 収束・停止条件

```yaml
convergence:
  residual_norm: L2
  tolerance: 1.0e-6
  max_iterations: 5000
```

Judge が **PASS / REVISE** を決める根拠。

------

### 6️⃣ 出力仕様（超重要）

```yaml
output:
  results_dir: results/mg_2level_baseline
  save_residual_history: true
  figures:
    - residual_vs_iter
```

👉
**何が成果物かを明示**しないと、Judge が評価できない。

------

##  config.yaml（例）

```yaml
experiment:
  name: mg_2level_baseline
  description: 2-level MG with Taylor smoother (order 2)

problem:
  equation: poisson
  dimension: 3
  domain:
    type: cartesian
    size: [1.0, 1.0, 1.0]
  boundary_condition:
    type: dirichlet
    value: 0.0

discretization:
  grid:
    nx: 64
    ny: 64
    nz: 64
  layout: cell-centered
  ghost_cells: 1

solver:
  method: multigrid
  levels: 2
  smoother:
    type: taylor
    order: 2
  coarse_solver: direct

convergence:
  residual_norm: L2
  tolerance: 1.0e-6
  max_iterations: 5000

output:
  results_dir: results/mg_2level_baseline
  save_residual_history: true
```

------

## 書いてはいけないもの（重要）

### ❌ 思考・評価・判断

```yaml
# NG
this_looks_good: true
expectation: faster convergence
```

→ **Judge の仕事**

------

### ❌ 実装依存の内部変数

```yaml
# NG
tmp_buffer_size: 128
loop_unroll_factor: 4
```

→ 再現性を壊すだけ

------

### ❌ 実行環境の詳細

```yaml
# NG
cpu: amd
threads: 16
```

→ run.json 側に出る

------

## config.yaml と他ファイルの役割分担

| ファイル         | 役割                           |
| ---------------- | ------------------------------ |
| config.yaml      | **再実行条件（入力）**         |
| run.json         | 実行事実（いつ・どのcommitで） |
| codex_results.md | 結果の要約（事実）             |
| judge_reviews.md | 評価と分岐                     |
| atlas_notes.md   | 思考・仮説                     |

👉 **混ぜないことが最重要**

------

## Judge 視点のチェックリスト（裏側）

Judge は config.yaml をこう見る：

- 問題は一意か？
- 比較対象と同じ条件か？
- パラメータは説明可能か？
- 出力が定義されているか？

👉
**YES が揃わないと REVISE**

------

## 最短ルール（覚える用）

> **config.yaml は
> 「論文の Methods にそのまま書ける内容だけ」**

それ以上でも以下でもない。


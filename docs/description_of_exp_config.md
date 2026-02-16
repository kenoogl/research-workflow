# config.yaml

> **`experiments/<exp_name>/config.yaml` には
> 「この実験を再実行するために最低限必要な“情報”だけ」を書く**

config.yamlの内容は実験によって記述する内容が変わり、ある一連の実験ではパラメータAを変える。別の実験ではパラメータBを変える。更に別の実験では新たな項目が追加される、など柔軟に対応していく必要がでてくる。ただし、フレームワークが要求する最低限の記述はあるので、フレームワークとしては、そのひな形を提供する。これをベースとして、実験のベースをユーザが作成して、バリエーションの作成をAIが補助するという方針をとる。この場合もシステム側でできるチェックは行う。

## 

### 1. フレームワークが要求するコア項目情報（最低限）

```yaml
experiment:
  name: __EXP_NAME__
  description: __DESCRIPTION__

output:
  results_dir: results/__EXP_NAME__

execution:
  command: >
  julia --project=. src/main.jl 
  --output-dir results/__EXP_NAME__
```

- `__EXP_NAME__` は実験名を表し、プレースホルダにする
- `__DESCRIPTION__` は人のための注釈
- `execution.command`は例として提示。実際にはユーザのコマンドに置換。

- `templates/config_core.yaml`がひな形

#### `bin/new_config`

- コマンドで実験用のベースconfigを生成

~~~
./bin/new_config mg_baseline
~~~

次のディレクトリに生成される

~~~
experiments/mg_baseline/config.yaml
~~~

------

### 2. コア項目以外は自由領域

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

👉ここは個別の実験に依存
**「何を解いたか」**が一意に分かること。

------

### 3. 出力仕様（超重要）

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

### 4. フレームワーク側がやること

run_exp がチェックするのは **コア部分だけ**。

### チェック項目（最低限）

1. experiment.name == exp_name
2. output.results_dir == results/<exp_name>
3. execution.command 存在
4. execution.command に results/<exp_name> が含まれる（実行コマンド依存だが安全策）

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



ユーザは`config.yaml`に実験に必要な項目を追加していく。作成の過程でAIプロンプトによる支援が効果的。

- AIに「この実験をベースにgridを128に変えた新configを作成」依頼
- AIに「levelsを3にしたバリエーションを作って」





### 書いてはいけないもの

#### ❌ 思考・評価・判断

→ **Judge の仕事**

------

#### ❌ 実装依存の内部変数

→ 再現性を壊すだけ

------

#### ❌ 実行環境の詳細

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




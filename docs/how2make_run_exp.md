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

#### ② 実行の“事実”を `logs/<exp>.json` に記録する

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
    ├─ 実行メタデータ書き出し（logs/<exp>.json）
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

postprocess:
  commands:                  # 任意（複数）
    - <string>
  command: <string>          # 任意（単数互換）
~~~

### 1️⃣ 必須フィールド

#### `command`（必須）

#### 型

string

#### 意味

実際に実行されるシェルコマンド。

#### ルール

- `--config experiments/<exp_name>/config.yaml` を必ず含める
- 実行時パラメータ（`--nx`, `--omega` など）を command に直書きしない
- 実行条件は config.yaml 側に集約する

### 2️⃣ 任意フィールド

#### `postprocess.commands` / `postprocess.command`

- 実験本体の実行後に追加コマンドを実行する。
- `postprocess.commands`（複数）と `postprocess.command`（単数互換）の両方を受け付ける。
- 後処理コマンドが失敗しても warning を出して継続する。

#### 将来拡張（現時点では未実装）

- `working_dir`
- `timeout`
- `environment`



## [run_exp](../templates/project/bin/run_exp) の実装

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

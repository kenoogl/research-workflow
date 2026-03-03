# README.md

# research-workflow

AIによる思考支援のための、ミニマム研究フレームワーク。

---

## 🎯 目的

このフレームワークは、

- 実験再現性
- 思考再現性
- 知識蒸留

の三層構造を持ち、

**実験の記録と分析 provenance 機能**

を提供することを目的としています。

---

## 🧠 [基本思想](docs/CONCEPT.md)

AIが強いのは：

- 比較
- 要約
- 論点抽出
- 反証
- 代替案生成

AIが弱いのは：

- 条件が曖昧な入力
- ファイルが散乱している状態
- 実験の意図が不明な状態
- 記録が残らないと再利用できない

そのため、本フレームワークは、

**実験結果をAIが扱いやすい形で固定し、AIによる分析支援を行う**という設計を採用しています。



### 分析 Provenance

 分析の再現性を担保するため、`analysis/<ana>/` では思考過程をイベントとして保存します。

-  分析は状態ではなくイベントで管理（`events/NNN_prompt.md`, `events/NNN_response.md`）

-  イベントは追記のみ（連番再利用・過去編集・削除は禁止）

-  参照した実験入力は `inputs_snapshot/<exp>/` に不変コピー（`config.yaml`, `run_summary.json`）

-  `discussion.md` は追記型サマリ（Facts と Analysis を分離）

-  結論に影響した推論は必ずイベントとして記録

-  保存失敗時は停止し、黙って継続しない

 詳細は [`docs/analysis_provenance.md`](docs/analysis_provenance.md) を参照。

結果として、実験と思考のプロベナンスが担保され、実験の再現性が高められます。



## このリポジトリの役割

### framework repo（このリポジトリ）

- 思想・ルール・安全装置・雛形を提供
- 実行された成果物は **一切置かない**

### project repo（利用者が作る）

- 実際の研究・実験・提案書作成を行う
- 実験結果・ログ・論文原稿を保持
- **framework repo を submodule として固定利用**



---

## 🏗 構成（framework repo）

~~~
research-workflow/
├── AGENTS.md
├── README.md  (this document)
├── VERSION.md
├── setup.sh
├── docs/
│    ├── CONCEPT.md
│    ├── description_of_exp_config.md
│    ├── how2make_run_exp.md
│    ├── roleAI.md
│    └── spec_generate_notes.md
├── hooks/
│    ├── pre-commit
│    └── README.md
└── templates/
     ├── project/
     │    ├── SKILLS/
     │    │    └── note_updater/
     │    │         └── SKILL.md
     │    ├── ai_context/
     │    │    ├── intent.md
     │    │    └── project_notes.md
     │    ├── bin/
     │    ├── experiments/
     │    ├── logs/
     │    ├── results
     │    └── src
     ├── codexrc
     ├── config_core.yaml
     └── notes.md
~~~

※ framework repo には実験結果は保存しません。

---

## 🧩 利用の準備

### -1. 前提

- Git が使える
- bash が使える
- `yq` がインストール済み

```bash
yq --version
```

エラーが出る場合は README を参照。

- このリポジトリ（research-workflow）を **framework repo** として参照する
- 実際の作業は、すべて project repo で行います。

### 0. プロジェクトのルートディレクトリを決める

```
(anywhere)
 └── project-A/        ← ★ここが project repo のルート
```

### 1. project repo を作る

```
mkdir project-A
cd project-A
git init
```

### 2. framework を submodule として追加

framework を submodule として追加する。

```
git submodule add https://github.com/kenoogl/research-workflow.git framework
```

この時点で

```
project-A/
├── .git/
├── .gitmodules
└── framework/        ← framework repo（submodule）
```

### 3. 初期設定

~~~
framework/setup.sh
~~~

これにより、

- `framework/templates/project/*` を project ルートへコピー
- `framework/templates/codexrc` を `.codexrc` として配置
- `framework/AGENTS.md` を `AGENTS.md` として配置
- `framework/hooks/pre-commit` を `.git/hooks/pre-commit` にシンボリックリンクし、実行権限を付与
- `.codex/skills/notes-updater/SKILL.md` を作成し、テンプレートの `SKILL.md` をコピー
- 以上の処理が終了後、`framework`ディレクトリは読み出しのみに許可権を変更。



以降、project repo 側で作業します。

ディレクトリ構成は次のようになっている。

```
project-A/            ← cd ここ
├── .git/
├── .gitmodules
├── .codexrc
├── framework/        ← submodule（触らない）
│   └── templates
│       ├── project
│       │    └── ...
│       ├── config_core.yaml
│       └── notes.md
│
├── ai_context/       ← 思考ガイド
├── bin/
│    ├── generate_notes
│    ├── new_exp
│    ├── run_exp
│    └── run_exp_patterns
├── experiments/      ← 実験定義
├── logs/             ← 実行ログ
├── results/          ← 成果物
└── src/              ← コード
```

この状態を **project repository として確定**し、framework の参照も一緒にコミット

```
git commit -m "add research-workflow framework"
```

これで、どのバージョンのワークフローを使ってプロジェクトを進めているかがわかる。

#### framework のバージョン

- このプロジェクトで利用している framework のバージョンを確認
  👉 再現性・論文化のときに効く。

- プロジェクトのルートディレクトリで


~~~
cd framework
git describe --tags --dirty --always
~~~

- tag があれば → `v0.1.1`

- tag が無ければ → commit hash
- 改変があれば → `-dirty`

##### 実行時の注意（重要）

本プロジェクトでは、実行時点で未コミットの変更がある場合（git dirty）、
その状態が `logs/run.json` に記録されます。

dirty=true の結果は、

- 再現性が保証されない可能性がある
- 論文化・正式成果には適さない場合がある

ことに注意してください。

実行自体は可能ですが、判断は人間が行います。

run_exp は、実行時点の git commit と dirty 状態を自動で記録し、
dirty=true の場合は警告を表示します（実行は停止しません）。



---

## 🚀 基本フロー

### 1. 実験意図を書く

~~~
ai_context/intent.md
~~~

~~~
# Intent

## Objective
- Reference: Asai Asaithambi, Numerical solution of the Burgers’ equation by automatic differentiation,
  Applied Mathematics and Computation, 216 (2010), 2700–2708.
- ...

## Goal:
- To clarify the fundamental convergence characteristics of the Taylor-series-based pseudo-time method for the Poisson equation, including its residual decay behavior and spectral smoothing properties.
- ...

## Success Criteria:
- Compared with baseline methods, the proposed Taylor-based approaches achieve faster convergence in terms of iteration counts and/or wall-clock time.
- ...

## Comparison Baseline:
- ...
~~~

必要に応じて、`project_notes.md`にプロジェクトに関するメモを書く。



### 2. 実験を定義する（[config の書き方](docs/description_of_exp_config.md)）

~~~
./bin/new_exp <exp>
~~~

`config.yaml`がひな形から生成される。また、`notes.md`のコピーが作られる。

~~~
experiments/<exp>/config.yaml
experiments/<exp>/notes.md
~~~

- 「この実験は何を解いたのか」を一意にするため、要件を記述

- ##### 実験名`<exp>`の考え方

  - 実験を議論・論文で呼ぶ名前
  - １つの実験について固有の名前をつける
  - 条件が変わったら exp_name を変える

  

### 3. [run_exp](docs/how2make_run_exp.md)による実行

`run_exp`は`experiments/<exp>/config.yaml`にある`execution.command`のコマンドを実行する。

~~~
./bin/run_exp <exp>
~~~

生成されるファイル：

~~~
logs/<exp>.json
results/<exp>/run_summary.json <= solverが生成する
~~~

#### 📊 run_summary.json の役割

AI思考支援の中核です。

最低限含まれるべき項目：

- iterations
- runtime_sec
- converged
- final_residual
- error_l2
- error_max

AIが比較可能な「共通キー」を揃えることが重要です。

#### `run_exp_patterns`

~~~
./bin/run_exp_patterns '<pattern>'
~~~

- `experiments/`ディレクトリ下で、文字列`<pattern>`に合致するディレクトリ名を探し、run_expを実行する。複数の実験を実行する場合に利用。ワイルドカード利用可。



### 4. 後処理

- 必要であれば、後処理などを行い、結果を`results/<exp>/`へ保存
- 結果のコメントなどは`experiments/<exp>/notes.md`に記述する。



### 5. [実験ノート作成](docs/spec_generate_notes.md)

AIが`intent.md`、`config.yaml`、`run_summary.json`から

- 要約
- 仮説生成
- 次実験提案

を行い、`notes.md`に追記する。

AIへの依頼は下記コマンドでトリガーをかける。３つのモードがあるが、ここでは`internal`モードとcodex appでの利用法を説明。

~~~
bin/generate_notes <exp_name> [MODE] [OPTIONS]
~~~

| モード            | 用途                  | LLM呼び出し |
| ----------------- | --------------------- | ----------- |
| `--stdout-prompt` | 人間が外部LLMに貼る   | ❌ 呼ばない  |
| `--llm-external`  | bashからLLM CLIを呼ぶ | ✅ 呼ぶ      |
| `--llm-internal`  | 既にLLM CLI内         | ❌ 呼ばない  |

#### LLMを用いる方法

`generate_notes`コマンドを使う方法もあるが、ここではLLMに依頼する方法を説明

#####  AGENTS.mdのルールを利用する場合、次のプロンプト（CLIとcodex appn両方で利用可能）

~~~
AGENTS.md準拠で、sor_n16_omega1.5 の notes.md を更新
~~~

##### SKILLを利用する場合、次のプロンプト（CLIのみ）

~~~
$notes-updater sor_n16_omega1.4 実行
~~~

##### 人は評価・コメントを記述する。



### 6. 結果を保存する

👉 results/ をコミットするには run.json が必須 （git hook が自動でチェックします）

もし hook が効かない場合：

```
ln -s framework/hooks/pre-commit .git/hooks/pre-commit
```



### 7. 分析する

このフレームワークでは、**思考の履歴を再利用可能な資産にする**ことを目的として、analysis フェーズを導入する。

#### 分析で保存するもの

analysis は：

- どの問いから始まったか
- どの実験を見たか
- どんな順番で考えたか
- どんな仮説が出たか
- どんな反論があったか

を **イベント履歴として保存** する。

~~~
analysis/<analysis_name>/
  meta.json
  discussion.md
  events/
  inputs_snapshot/ (必要時のみ)
~~~

#### 基本の流れ

#### 1️⃣ 分析開始

```
./bin/new_analysis <name>
```

これで分析用ディレクトリが作られる。または、`○○の分析を始めます。分析名を"hoge"にします。`と指示してもよい。

------

#### 2️⃣ LLMと対話する

analysis フェーズでは：

- CLIコマンドで分析を進めない
- LLMとの自然言語対話で進める

LLMは：

- prompt を events に保存
- response を events に保存
- 必要なら実験を snapshot
- discussion.md にまとめを追記



------

#### 3️⃣ セッションのまとめ

議論が一区切りついたら：

- discussion.md にまとめが追記される。次の指示で実行。

- ~~~
  サマリをdiscussion.mdに作成してください
  ~~~

- ここが蒸留された知識になる。





## 補足

### 🔹 dirty=true の扱い

- 実行は可能
- run.json に必ず記録
- Judge は原則 REVISE / ESCALATE

### 🔹 同じ exp_name の再実行

- run.json は上書き

- 意味が変わるなら exp_name を変える

  

------

### 安全について

- このフレームワークは人がミスする前提で設計されています。

- 危険なコマンドは `.codexrc` で防止

- 直接 `python / julia` 実行は禁止（事故防止）

  

---

## 🧠 このフレームワークの本質

これは

- 実験管理ツールではありません
- 自動論文化ツールでもありません

これは、

> AIが思考を拡張しやすい形に実験を固定するための最小構造

です。

### フレームワークとプロジェクトの関係

#### framework repo

- 参照点・道具箱
- 編集しない（更新は tag / version 切替）

#### project repo

- 実践の場
- run_exp や hook は 自由に改変してよい

フレームワークは利用者を縛りません。 再現性のための「基準点」を提供するだけです。



---

## 🔄 バージョン管理

各 project repo は

- 特定の framework version を固定

framework は進化しても、
project の再現性は守られます。

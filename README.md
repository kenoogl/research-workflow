# README.md

# research-workflow

AIによる思考支援のための、ミニマム研究フレームワーク。

---

## 🎯 目的

このフレームワークは、

> 実験を回すたびに  
> AIが「比較・要約・仮説生成・批判」を自然に行える状態を作る

ことを目的としています。

---

## 🧠 [基本思想](CONCEPT.md)

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

**実験結果をAIが扱いやすい形で固定する**という設計を採用しています。

結果として、実験の再現性が担保されます。



## このリポジトリの役割（重要）

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
├── CONCEPT.md
├── README.md  (this document)
├── VERSION.md
├── .codexrc
├── docs/
│    ├── description_of_exp_config.md
│    ├── how2make_run_exp.md
│    ├── how2use_framework.md
│    ├── quickstart_15min.md
│
├── hooks/
│    └── pre-commit
└── templates/
     ├── project/
     │    ├── ai_context/
     │    │    ├── intent.md
     │    │    └── project_notes.md
     │    ├── bin/
     │    ├── experiments/
     │    ├── logs/
     │    ├── results
     │    ├── src
     │    └── README.md
     ├── config_core.yaml
     └── notes.md
~~~

※ framework repo には実験結果は保存しません。

---

## 🧩 利用の準備

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

### 3. テンプレートを project 側にコピー

framework が用意した **project 用ひな形**を**project-A/ の直下にコピー**する。

~~~
cp -r framework/templates/project/* .
~~~

以降、project repo 側で作業します。

ディレクトリ構成は次のようになっている。

```
project-A/            ← cd ここ
├── .git/
├── .gitmodules
├── framework/        ← submodule（触らない）
│   └── templates
│       ├── project
│       │    └── ...
│       ├── config_core.yaml
│       └── notes.md
│
├── ai_context/       ← 思考ガイド
├── bin/
│    ├── install_hooks
│    ├── new_config
│    ├── run_exp
│    └── run_exp_patterns
├── experiments/      ← 実験定義
├── logs/             ← 実行ログ
├── results/          ← 成果物
└── src/              ← コード
```

##### [git hookを有効にする](hooks/README.md)

~~~
ln -sf framework/hooks/pre-commit .git/hooks/pre-commit
chmod +x framework/hooks/pre-commit
~~~

この状態を **project repository として確定**し、framework の参照も一緒にコミット

```
git commit -m "add research-workflow framework"
```

これで、どのバージョンのワークフローを使ってプロジェクトを進めているかがわかる。



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



### 2. 実験を定義する（config を作る）

~~~
./bin/new_config <exp>
~~~

`config.yaml`がひな形から生成される。また、`notes.md`のコピーが作られる。

~~~
experiments/<exp>/config.yaml
experiments/<exp>/notes.md
~~~



### 3. 実行

`run_exp`は`experiments/<exp>/config.yaml`にある`execution.command`のコマンドを実行する。

~~~
./bin/run_exp <exp>
~~~

生成される：

~~~
logs/<exp>.json
results/<exp>/run_summary.json <= solverが生成する
~~~



### 4. 後処理

- 必要であれば、後処理などを行い、結果を`results/<exp>/`へ保存
- 結果のコメントなどは`experiments/<exp>/notes.md`に記述する。



### 5. AIに渡す

- `intent.md`
- `config.yaml`
- `run_summary.json`

AIが：

- 要約
- 仮説生成
- 次実験提案

を行い、`notes.md`に追記する。



### 6. 結果を保存する

👉 results/ をコミットするには run.json が必須 （git hook が自動でチェックします）

もし hook が効かない場合：

```
ln -s framework/hooks/pre-commit .git/hooks/pre-commit
```



---

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



---

## 🧠 AIとの正しい付き合い方

### AIは

- 思考を拡張する
- 論点を整理する
- 批判する
- 次の可能性を提示する

### 人間は

- 採用する
- 捨てる
- 責任を持つ



---

## 🔐 なぜ hook と run_exp があるのか

人は：

- 忘れる
- 急ぐ
- 記録を怠る

そのため、

- 実行は run_exp 経由
- 成果物は results/<exp>/
- 実行情報は logs/<exp>.json

という **物理的制約** を設けています。



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

## 💡 使いこなすコツ

最初は：

- new_config
- run_exp
- run_summary.json

だけ使えば十分です。

Judgeやディベートは後から追加できます。



---

## 🔄 バージョン管理

各 project repo は

- 特定の framework version を固定

framework は進化しても、
project の再現性は守られます。



---

## 📘 詳細

- 設計思想 → `CONCEPT.md`
- 15分クイックスタート → `docs/quickstart_15min.md`



---

## 🎯 最後に

このフレームワークは

> 研究を速くする魔法ではありません。

しかし、

> 進めた研究が、後から使える形で残る

確率は大きく上がります。

そして、

AIが本当に役立つのは  この状態になってからです。




# Research Workflow

## これは何？
**研究・実験・設計を進めると、  
結果の由来が自動で残り、  
論文・提案書の材料が自然に揃う**  
ためのミニマルな研究ワークフレームワークです。

このリポジトリ（research-workflow）は **フレームワーク本体**であり、  
実際の研究や実験は **別の project repo** で行います。

> **本フレームワークは、project repo から submodule として利用することを前提**  
> としています。

LLM（ChatGPT / Codex など）は  
**相談役・実行補助**として使います。  
判断と責任は常に **人間** が持ちます。

---

## このリポジトリの役割（重要）

### framework repo（このリポジトリ）
- 思想・ルール・安全装置・雛形を提供
- 実行された成果物は **一切置かない**
- 方法論として **進化**する

### project repo（利用者が作る）
- 実際の研究・実験・提案書作成を行う
- 実験結果・ログ・論文原稿を保持
- **framework repo を submodule として固定利用**

---

## 何が嬉しい？
- 「この結果、どのコードで出た？」を考えなくてよくなる
- 実験・設計の **意図と結果** が自然に残る
- 論文／提案書／実験制御に同じ流れで使える
- フレームワーク更新と再現性を **両立**できる

---



## 最低限の使い方（全体像）



### 0. プロジェクトのルートディレクトリを決める

~~~
(anywhere)
└── project-A/        ← ★ここが project repo のルート
~~~



### 1. project repo を作る
```bash
mkdir project-A
cd project-A
git init
```



### 2. framework を submodule として追加

~~~
git submodule add https://github.com/kenoogl/research-workflow.git framework
~~~

この時点で

~~~
project-A/
├── .git/
├── .gitmodules
└── framework/        ← framework repo（submodule）
~~~



### 3. テンプレートを project 側にコピー

framework が用意した **project 用ひな形**を**project-A/ の直下にコピー**する

~~~
cp -r framework/templates/project/* .
~~~

以降、project repo 側で作業します。

ディレクトリ構成は次のようになっている。

~~~
project-A/            ← cd ここ
├── framework/        ← submodule（触らない）
│   └── templates
│       └── project
│           └── ...
├── ai_context/       ← あなたの思考
├── bin/run_exp       ← 実行入口
├── experiments/      ← 実験定義
├── logs/             ← 実行ログ
├── results/          ← 成果物
└── src/              ← コード
~~~

今の状態を **project repository として確定**し、framework の参照も一緒にコミット

~~~
git commit -m "add research-workflow framework"
~~~

これで、どのバージョンのワークフローを使ってプロジェクトを進めているかがわかる。



### 4. 実験を定義する

~~~
experiments/exp_001/config.yaml
~~~



### 5. 実行する（唯一の入口）

~~~
./bin/run_exp exp_001
~~~

→ logs/run.json が自動生成されます
（どのコード・設定・commit で実行したかの記録）



### 6. 結果を保存する

~~~
results/exp_001/
~~~

👉 results/ をコミットするには run.json が必須
（git hook が自動でチェックします）

もし hook が効かない場合：

```bash
ln -s framework/hooks/pre-commit .git/hooks/pre-commit
```



### LLMの使い分け（迷ったらこれ）

- 考える・評価する → Atlas（ChatGPT）

- 構造を整える → Codex App

- 動かす・実験する → Codex CLI


迷ったら Atlas に戻ればOK。



### codex_plan.md について（重要）

Codex に何かさせる前に、
雑でいいので司令書を書きます。

例（これで十分）：

~~~
## Objective

- バグ修正

## Tasks

- indexずれ直す

## Success

- テスト通る
~~~

- 完璧さは不要

- 箇条書きでOK

- 後から読めれば十分




### 安全について

- このフレームワークは人がミスする前提で設計されています。

- 危険なコマンドは `.codexrc` で防止

- 直接 `python / julia` 実行は禁止（事故防止）

- 再現できない結果は成果として残らない

- 成果物と由来は 物理的にセットで管理

- これは監視ではなく、研究を続けるための安全装置です。



### フレームワークとプロジェクトの関係

#### framework repo

- 参照点・道具箱

- 編集しない（更新は tag / version 切替）


#### project repo

- 実践の場

- run_exp や hook は 自由に改変してよい


フレームワークは利用者を縛りません。
再現性のための「基準点」を提供するだけです。



### 向いている用途

- 論文研究

- 提案書作成

- 数値実験・実験制御

- システム設計・検証


成果物の形式が違っても、
流れと考え方は同じです。



### 覚えるのはこれだけ

- 考える → Atlas

- 整える → App
- 動かす → CLI

それ以外は、使いながら分かります。



### 次に読むもの

- CONCEPT.md

  → なぜこの設計なのか

- docs/quickstart_15min.md

  → 15分で一周回す

- principles.md

  → 削れない設計原則



このフレームワークは、
最初から完璧に使うためのものではありません。

まずは 1 実験、1 結果、1 commit。
そこから自然に広がります。



------

------



## 既にあるプロジェクトに適用させる場合

- 新規プロジェクトとして作り直すのではなく、既存プロジェクトを「このフレームワークの型に寄せる」方針



### STEP 1：現状をそのまま project repo にする（最小）

まずは **既存 ディレクトリをそのまま project repo にする**。

```
cd project-hoge
git status   # まず現状確認
```

- ここでは **構造を変えない**
- コードも動かさない

👉 **“現場保存”が最優先**

------

### STEP 2：framework を submodule として「後付け」する

```
git submodule add https://github.com/kenoogl/research-workflow.git framework
```

これで：

```
project-hoge/
├── framework/   ← 追加される
├── src/         ← これ以降は既存ファイル群
├── results/
├── scripts/
└── ...
```

👉 **ここではまだ run_exp も hook も使わない**

------

### STEP 3：最低限の3点だけ合わせる

#### ① bin/run_exp を導入（コピーでOK）

```
cp framework/templates/project/bin/run_exp bin/
chmod +x bin/run_exp
```

- 中身は **まだ実行しなくていい**
- 入口を「1つある」状態にする

------

#### ② logs/run.json を“これから”作り始める

過去の実験は無理に遡らない。

👉 **「今日以降の実行」だけ**：

```
./bin/run_exp mg_exp_resume
```

- 実行しなくても run.json が出ればOK

------

#### ③ ai_context を“これから”書き始める

```
mkdir -p ai_context
```

最低限これだけ（例）：

```
# ai_context/atlas_notes.md

## 状態
- project-hoge は既に baseline / xxxx を実装済み
- 残差停滞が低周波誤差由来と仮定

## これから
- restriction/prolongation の設計見直し
- smoother としての Taylor iteration 再解釈
```

👉 **過去を完璧に再構築しない**のがコツ。

------

### STEP 4：ここからは「通常運用」に入る

ここから先は、新規プロジェクトと同じ。

- 実行 → run_exp
- 結果 → results/
- 評価 → judge_reviews.md
- 判断 → 人間（あなた）

------

## やらなくていいこと（重要）

❌ 過去の全実験に run.json を付け直す
 ❌ ディレクトリ構成を全部 templates に合わせる
 ❌ いきなり hook を有効にする
 ❌ 既存コードを無理に書き換える

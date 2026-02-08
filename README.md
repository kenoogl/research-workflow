

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

### プロジェクトのルートディレクトリを決める

~~~
(anywhere)
└── project-A/        ← ★ここが project repo のルート
~~~



## framework 導入（submodule）

```bash
cd project-A
git init
git submodule add https://github.com/kenoogl/research-workflow.git framework
```

この時点で

~~~
project-A/
├── .git/
├── .gitmodules
└── framework/        ← framework repo（submodule）
~~~

framework が用意した **project 用ひな形**を**project-A/ の直下にコピー**する

~~~
cp -r framework/templates/project/* .
~~~

📍 結果

~~~
project-A/            ← cd ここ
├── framework/        ← submodule（触らない）
│   └── research-workflow
│
├── ai_context/       ← あなたの思考
├── experiments/      ← 実験定義
├── logs/             ← 実行ログ
├── results/          ← 成果物
├── src/              ← コード
└── bin/run_exp       ← 実行入口
~~~

今の状態を **project repo として確定**し、framework の参照 commit も一緒に固定される

~~~
git commit -m "init project with research-workflow framework"
~~~

📍 これで：

> 「この project は framework の **このバージョン**を使って始まった」

が、**再現可能な形で記録**される。



---

### これで起きていること（読む必要なし）

- framework が `framework/` に固定される
- project repo で成果物を作る準備が整う
- 再現性は Git が勝手に守る

---

### 協力者メモ（非公開でもOK）

もし hook が効かない場合：

```bash
ln -s framework/hooks/pre-commit .git/hooks/pre-commit
```



### 1️⃣ project repo を作る
```bash
mkdir project-A
cd project-A
git init
```



### 2️⃣ framework を submodule として追加

~~~
git submodule add <URL-to-research-workflow> framework
git commit -m "add research-workflow framework"
~~~



### 3️⃣ テンプレートを project 側にコピー

~~~
cp -r framework/templates/project/* .
~~~

以降、project repo 側で作業します。



### 4️⃣ 実験を定義する

~~~
experiments/exp_001/config.yaml
~~~



### 5️⃣ 実行する（唯一の入口）

~~~
./bin/run_exp exp_001
~~~

→ logs/run.json が自動生成されます
（どのコード・設定・commit で実行したかの記録）



### 6️⃣ 結果を保存する

~~~
results/exp_001/
~~~

👉 results/ をコミットするには run.json が必須
（git hook が自動でチェックします）



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

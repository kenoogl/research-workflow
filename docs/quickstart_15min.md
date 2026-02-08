# 15分クイックスタート  
## ― submodule 前提で、何も考えずに1周回す ―

このチュートリアルの目的はただ一つ。

> **「この仕組み、ちゃんと動くな」  
> と体験的に理解すること**

思想理解・最適設計・正しさは不要です。  
**手を動かして、1回まわす**ことだけをやります。

---

## 0. 前提（読むだけ・1分）

- Git が使える
- bash が使える
- このリポジトリ（research-workflow）を **framework repo** として参照する

👉 **実際の作業は、すべて project repo で行います。**

---

## 1. project repo を作る（2分）

まず、作業用ディレクトリを作ります。

```bash
mkdir project-A
cd project-A
git init
```

ここが **成果物・実験・コードが生まれる場所**です。



## 2. framework を submodule として追加（2分）

~~~
git submodule add https://github.com/kenoogl/research-workflow.git framework
~~~

結果：

~~~
project-A/
├── .git/
├── .gitmodules
└── framework/        # research-workflow（submodule）
~~~



## 3. テンプレートを project 側にコピー（2分）

~~~
cp -r framework/templates/project/* .
~~~

これで、project repo に必要な最小構成が揃います。

~~~
project-A/
├── framework/
├── ai_context/
├── experiments/
├── bin/
├── src/
├── logs/
├── results/
└── README.md
~~~



## 4. hook を有効化（1分・任意だが推奨）

成果物と由来を常にセットで残すため、
 pre-commit hook を有効にします。

~~~
ln -s framework/hooks/pre-commit .git/hooks/pre-commit
~~~

※ 失敗しても致命的ではありません（後で設定可）。



## 5. ダミーの実験設定を書く（1分）

```
cat experiments/exp_001/config.yaml

name: exp_001
description: first test run
parameter_a: 1.0
parameter_b: 2.0
```

意味はありません。
 **存在すればOK**。



## 6. 実行してみる（1分）

~~~
./bin/run_exp exp_001
~~~

成功すると：

~~~
logs/run.json
~~~

が生成されます。

👉 **この時点で成功です。**
 まだ何も計算していません。



## 7. ダミー結果を置く（1分）

~~~
mkdir -p results/exp_001
echo "dummy result" > results/exp_001/output.txt
~~~



## 8. Git に保存する（2分）

~~~
git add .
git commit -m "exp001: first run"
~~~

- `results/` がある
- `logs/run.json` がある

この2つが揃っていれば、
 hook が有効でもコミットは通ります



## 9. ここまでで何が起きたか（読むだけ・2分）

あなたは今：

- project repo を作り
- framework を **参照点として固定**し
- 実行の由来（run.json）と成果を
- **機械的にセットで保存**しました

まだ：

- 仮説を書いていない
- LLMを使っていない
- コードを書いていない

それでも、
 **「後から使える成果の最小形」**は完成しています。



## 10. 余力があれば（＋3分）

### codex_plan.md を1行だけ書く

~~~
cat ai_context/codex_plan.md

## Objective
- first test run
~~~

完璧さは不要です。



## 11. この先に自然につながること

- `src/` にコードを書く
- `run_exp` の最後に実行行を足す
- Atlas に「この結果どう思う？」と聞く
- `codex_results.md` を1段落書く

**順番は自由**です。



## 12. まとめ（重要）

この15分でやったことは：

- 正しい研究ではない
- 良い実験でもない

でも、

> **「結果が迷子にならない状態」**

は、もう手に入っています。

それだけで、このワークフローを使う価値は十分です。



次に読むなら：

- `CONCEPT.md`（なぜこの設計なのか）
- `README.md`（全体像）
- project repo の `README.md`（日常運用）

どれも、急ぐ必要はありません。

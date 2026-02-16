# 📘 15分クイックスタート

## ― submodule前提で、AIが賢く見える瞬間まで行く ―

このチュートリアルの目的はただ一つ。

> 「この仕組み、AIがちゃんと使えるな」
> と体験的に理解すること

思想の完全理解は不要です。
**1周回して、AIに渡してみる**ところまでやります。

------

## 0. 前提（1分）

- Git が使える
- bash が使える
- `yq` がインストール済み

```bash
yq --version
```

エラーが出る場合は README を参照。

- このリポジトリ（research-workflow）を **framework repo** として参照する
- 実際の作業は、すべて project repo で行います。

------

## 1. project repo を作る（2分）

```bash
mkdir project-A
cd project-A
git init
```

ここが成果物の場所です。

------

## 2. framework を submodule として追加（2分）

```bash
git submodule add https://github.com/kenoogl/research-workflow.git framework
```

結果：

```
project-A/
├── framework/　# research-workflow（submodule）
├── .git/
└── .gitmodules
```

------

## 3. テンプレートをコピー（2分）

```bash
cp -r framework/templates/project/* .

project-A/
├── framework/
├── ai_context/
├── experiments/
├── bin/
├── logs/
├── results/
└── src/
```

------

## 4. hook を有効化（任意・1分）

成果物と由来を常にセットで残すため、
 pre-commit hook を有効にします。

```bash
ln -s framework/hooks/pre-commit .git/hooks/pre-commit
```

※ 失敗しても致命的ではありません（後で設定可）。

------

## 5. 実験設定を作る（1分）

```bash
./bin/new_config exp_001
```

生成される：

```
experiments/exp_001/config.yaml
```

中身はひな形です。
まだ何も計算しません。

------

## 6. 実行してみる（1分）

```bash
./bin/run_exp exp_001
```

生成される：

```
logs/exp_001.json
results/exp_001/run_summary.json
```

👉 **ここが重要です。**

まだ solver は動いていませんが、

- 実験定義
- 実行履歴
- 比較可能な summary

が自動生成されています。

------

## 7. 中身を見てみる（2分）

### logs/exp_001.json

- git commit
- framework commit
- config path
- timestamp

### results/exp_001/run_summary.json

- iterations
- runtime
- converged
- residual

👉 AIが比較できる構造になっています。

------

## 8. AIに渡してみる（3分）

Atlas に次を渡してください：

- `experiments/exp_001/config.yaml`
- `results/exp_001/run_summary.json`

そして聞いてみる：

> この実験の要約と、次にやるべき最小実験を提案してください。

AIは：

- 要約
- 仮説生成
- 追加実験提案

を自然に行います。

ここで初めて、

> AIが「考えている」感じ

を体験できます。

------

## 9. Git に保存（2分）

```bash
git add .
git commit -m "exp001: first structured run"
```

hook が有効なら：

- results と logs がセットでないと止まります。

------

## 10. ここまでで何が起きたか

あなたは今：

- 実験条件を固定し
- 実行履歴を保存し
- 比較可能な summary を生成し
- AIが思考可能な形に整えました

まだ：

- 仮説を書いていない
- 数値計算していない
- 論文化していない

それでも、

> AI思考支援の土台

は完成しています。

------

## 11. 次の一歩

### 実際に solver を動かす

`bin/run_exp` の中に実行コマンドを追加。

### notes.md を作る

```
experiments/exp_001/notes.md
```

AIに：

- Summary
- Analysis
- Next experiment

を書かせる。

------

## 12. このフレームワークの本質

これは：

- 実験管理ツールではありません
- 自動論文化ツールでもありません

これは、

> AIが迷わず思考できる最小構造

を作るための枠組みです。

------

## まとめ

15分で得たもの：

- 実験は構造化された
- AIは比較可能になった
- 結果は再現可能になった

この3点が揃えば、

仮説生成も論文化も、
自然に加速します。


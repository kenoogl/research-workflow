# 研究フレームワークの使い方

このフレームワークは、

> **意図 → 定義 → 実行 → 結果 → 判断 → 記録**

を **必ずこの順で通る**ことを保証するためのもの。

## 

> 1. **意図を書く**（codex_plan.md）
> 2. **条件を定義**（config.yaml）
> 3. **run_exp で実行**
> 4. **結果は results/**
> 5. **事実を書く**（codex_results.md）
> 6. **Judge が評価**
> 7. **人が判断**
> 8. **commit**



------

## 0️⃣ 前提（最初に1回だけ）

- project repo が存在する
- framework は submodule として導入済み
- テンプレート構成がコピーされている

```
project/
├── ai_context/
├── experiments/
├── bin/run_exp
├── logs/
├── results/
└── src/
```

------

## 1️⃣ 実験の意図を書く（必須・最初）

### 目的

**「なぜこの実験をやるのか」**を失わないため。

### 書く場所

```
ai_context/codex_plan.md
```

### 書く内容（最低限）

```md
# Codex Plan

## Objective
- Poisson 擬似時間法に 2-level MG を導入する

## Comparison
- baseline（MGなし）との残差履歴比較

## Success Criteria
- 残差停滞点が baseline より遅れる
```

### 重要ルール

- **実行前に必ず書く**
- 完璧でなくてよい
- 後から「この実験は何だったか」分かればOK

------

## 2️⃣ 実験を定義する（条件の固定）

### 目的

**「この実験は何を解いたのか」**を一意にする。

### 書く場所

```
experiments/<exp_name>/config.yaml
```

### exp_name の考え方

- 実験を議論・論文で呼ぶ名前
- 条件が変わったら exp_name を変える

例：

```
experiments/mg_2level_h64/config.yaml
```

### config.yaml に書くもの

- 問題定義（PDE / BC / 次元）
- 離散化条件（格子・レイアウト）
- アルゴリズム選択（MG / smoother など）
- 収束条件
- 出力仕様（results の場所）

👉 **Methods に書ける内容だけを書く**

------

## 3️⃣ 実行する（唯一の入口）

### 実行コマンド

```bash
./bin/run_exp <exp_name>
```

例：

```bash
./bin/run_exp mg_2level_h64
```

------

### run_exp が内部でやること（自動）

#### ① 入力チェック

- `experiments/<exp_name>/config.yaml` が存在するか

#### ② 実行台帳の作成

```
logs/run.json
```

**必ず書かれる内容**

- 実行時刻
- project repo の git commit
- project dirty 状態
- framework の git commit
- 使用した config.yaml
- 結果出力先

#### ③ 出力ディレクトリ作成

```
results/<exp_name>/
```

- 中身は空でもOK
- 「成果物の箱」を先に作る

#### ④ solver を1回呼ぶ

- `python` / `julia` / `MPI` は **ここからのみ**
- run_exp 自体は評価・解釈をしない

------

## 4️⃣ 実験結果の後処理（solverの責務）

### solver が出力するもの（例）

```
results/<exp_name>/
├── residual_history.csv
├── solution.vtk
├── figures/
│   └── residual_vs_iter.png
└── runtime.txt
```

### 重要ルール

- **成果物は必ず results/<exp_name>/ に置く**
- logs/ や experiments/ に混ぜない

------

## 5️⃣ 実験結果を言語化する（事実のみ）

### 書く場所

```
ai_context/codex_results.md
```

### 書く内容

```md
## Summary
- MG 導入で初期残差減衰が加速

## Observations
- 停滞点が約 2 倍遅延

## Issues
- 境界付近で振動あり
```

### 注意

- 評価・採用判断はまだ書かない
- **「起きた事実」だけ**

------

## 6️⃣ Judge による評価（分岐）

### 書く場所

```
ai_context/judge_reviews.md
```

### Judge が見るもの

- logs/run.json
- config.yaml
- results/<exp_name>/
- codex_results.md

### Judge の分岐例

```md
## Decision
- REVISE

## Reason
- 境界条件の扱いが不明確
```

------

## 7️⃣ 人間が判断する（最重要）

ここで **必ず人が決める**。

- この実験を続けるか？
- 論文候補か？
- exploratory として捨てるか？

### 書く場所（推奨）

```
ai_context/atlas_notes.md
```

------

## 8️⃣ コミットする（記録の確定）

### コミットするもの

- `experiments/<exp_name>/config.yaml`
- `logs/run.json`
- `results/<exp_name>/`
- `ai_context/*.md`

### コミットタイミングの原則

> **「判断が終わったら commit」**

- 実行直後ではない
- 評価と判断が揃った時点

------

## 9️⃣ このフローで防げる事故

- 実験の意図が分からなくなる
- どのコードで出た結果か不明
- 結果だけ残って意味が消える
- 失敗実験が迷子になる

------

## 抜けがちな補足（重要）

### 🔹 dirty=true の扱い

- 実行は可能
- run.json に必ず記録
- Judge は原則 REVISE / ESCALATE

### 🔹 同じ exp_name の再実行

- run.json は上書き
- 意味が変わるなら exp_name を変える

------

------



# 各工程における AI の関与と役割（v0.1）

> 原則：
> **AIは「考える補助」と「評価の視点」を提供する。
> 決定と責任は人間に残す。**

------

## 1️⃣ 実験の意図を書く（codex_plan.md）

### AI の関与：★★★☆☆（強）

**主に使う AI**

- Atlas（対話型）
- 必要なら Codex App（構造整理）

### AI の役割

- 仮説を言語化するのを助ける
- 比較軸・成功条件の抜けを指摘する
- 「それ、論文になる？」という視点を出す

### 人間の役割

- 何をやりたいかを決める
- AIが出した案を取捨選択する
- **最終的な意図を承認する**

👉
AIは「問いを整える」。
**意図を持つのは人間**。

------

## 2️⃣ 実験の定義（config.yaml）

### AI の関与：★☆☆☆☆（弱）

**主に使う AI**

- Codex App（レビュー補助）

### AI の役割

- config の項目漏れを指摘
- 他実験との非整合を警告
- 命名・構造のレビュー

### 人間の役割

- 問題設定を固定する
- 条件を確定する

👉
config は **事実の宣言**。
AIに判断させない。

------

## 3️⃣ 実行（run_exp）

### AI の関与：☆☆☆☆☆（なし）

**使わない AI**

- Atlas
- Codex App

### run_exp の役割（機械）

- commit / dirty 状態を記録
- 実行を起動
- 出力先を用意

### 人間の役割

- run_exp を叩くだけ

👉
**ここは完全自動化領域**。
AIも人も「判断しない」。

------

## 4️⃣ 実験結果の生成（solver 実行）

### AI の関与：☆☆☆☆☆（なし）

### AI の役割

- なし（数値計算は決定的処理）

### 人間の役割

- コードを書く
- 数値実装を正しくする

👉
ここは **純粋な工学・数値計算**。
AIを入れると再現性が壊れる。

------

## 5️⃣ 結果の言語化（codex_results.md）

### AI の関与：★★☆☆☆（中）

**主に使う AI**

- Codex App
- Atlas（整理）

### AI の役割

- 数値結果を文章に変換
- 観察事項を箇条書きに整理
- ノイズと事実を分離

### 人間の役割

- 何が重要かを選ぶ
- 書きすぎを止める

👉
AIは「書記」。
**解釈はまだしない**。

------

## 6️⃣ Judge による評価（judge_reviews.md）

### AI の関与：★★★★☆（最重要）

**主に使う AI**

- Atlas（LLM-as-Judge）
- 別 LLM（視点の多様化）

### AI の役割

- Reviewer 視点での批判
- 妥当性・一般性のチェック
- PASS / REVISE / REJECT の提案

### 人間の役割

- Judge の結論を読む
- 同意する／反論する
- **採用するか決める**

👉
AIは「厳しい査読者」。
**決定権は人間**。

------

## 7️⃣ 人間の判断（atlas_notes.md）

### AI の関与：★★☆☆☆（補助）

**主に使う AI**

- Atlas

### AI の役割

- 判断理由を言語化する補助
- 次の選択肢を整理
- 判断の一貫性チェック

### 人間の役割

- 採用／却下／保留を決める
- 研究の方向を選ぶ

👉
**ここが PI の仕事**。
AIは責任を取らない。

------

## 8️⃣ コミット（記録の確定）

### AI の関与：★☆☆☆☆（弱）

**主に使う AI**

- Codex App（commit message補助）

### AI の役割

- 差分の要約
- 意味のある commit message 案の生成

### 人間の役割

- commit のタイミング判断
- push / tag

👉
**記録を確定させるのは人間**。

------

## 9️⃣ 振り返り・次の実験設計

### AI の関与：★★★☆☆（強）

**主に使う AI**

- Atlas
- Judge（再利用）

### AI の役割

- 実験間の比較整理
- 次にやるべき仮説候補提示
- 「やらなくていいこと」の提案

### 人間の役割

- 研究戦略の決定
- リソース配分

------

# まとめ：AI と人間の役割分担

| フェーズ | AIの役割 | 人間の役割 |
| -------- | -------- | ---------- |
| 意図     | 仮説整理 | 決断       |
| 定義     | レビュー | 固定       |
| 実行     | なし     | 起動       |
| 計算     | なし     | 実装       |
| 記述     | 整理     | 選択       |
| 評価     | 批判     | 決定       |
| 判断     | 補助     | 責任       |
| 記録     | 補助     | 確定       |
| 戦略     | 発想     | 選択       |


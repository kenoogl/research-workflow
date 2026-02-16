# CONCEPT.md

## ― AI思考支援を最大化する研究ワークフロー ―

------

## 0. このワークフローは何を目指すのか

このフレームワークの目的は、

> **AIによる思考支援を最大化すること**

である。

研究を自動化するのではない。
AIに考えさせるのでもない。

**人間の思考を拡張するための構造を作る**。

------

## 1. なぜ構造が必要か

AIが強いのは：

- 比較
- 要約
- 論点抽出
- 反証
- 代替案生成
- 仮説提案

AIが弱いのは：

- 情報が散乱している
- 何を成功とみなすか分からない
- ファイルが多すぎる
- どれが事実でどれが主観か曖昧

したがって必要なのは、

> **AIが迷わず読める最小構造**

である。

------

## 2. 最小入力セット（AIが考えるための材料）

実験後、AIに渡すものはこれだけでよい：

- `intent.md`
  （目的・成功基準・比較対象）

- `project_notes.md`
  （プロジェクトに関するアイデア、メモなど）

- `experiments/<exp>/config.yaml`
  （実験条件）

- `logs/<exp>.json`
  （実行環境・provenance）

- `results/<exp>/`
  （実験結果）

- `results/<exp>/run_summary.json`
  （結果の要約）

- `experiments/<exp>/notes.md`

  （実験の評価、判断）

これで十分である。

------

## 3. なぜこれで十分なのか

AIは：

- `config.yaml` → 条件
- `run_summary.json` → 結果
- `intent.md` → 意図
- `logs` → 実行証拠
- `notes.md`→ 評価

を組み合わせて、

- 比較
- 異常検出
- 仮説生成
- 追加実験提案
- 論文化可能性評価
- Reviewer視点批判

を行える。

------

## 4. run_summary.json の設計思想

- `run_summary.json` は**solverが出力**し、**結果の要約のみを持つ**。

- 条件は `config.yaml` が真実。




#### 設計原則

1. 人間が読める
2. AIが比較しやすい
3. 実験間で共通キーがある
4. solverに依存しすぎない
5. 将来拡張可能

### 

```json
{
  "timestamp": "2026-02-14T09:46:01",
  "config_path": "experiments/ssor_n128_omega1.8/config.yaml",
  "script": "scripts/run_solver.jl",
  
  "iterations": 162,
  "runtime_sec": 2.5548958778381348,
  
  "converged": false,
  "residual_l2": "inf",
  "error_l2": 4.39e146,
  "error_max": 2.04e149,
  
  "artifacts": {
    "history": "history_ssor_nx128_ny128_nz128_steps162.txt"
  }
}
```

------

## 5. history と特徴量

生データは保存する：

```
history.txt
```

AI思考支援を強化するなら：

```
history_stats.json
```

のような特徴量も出力できる。

```json
{
  "history_stats": {
    "monotonic": false,
    "oscillation_detected": true,
    "diverged": true,
    "initial_residual": 1.0,
    "min_residual": 0.9640102,
    "final_residual": 3.605399,
    "convergence_rate_estimate": -0.12
  }
}
```

ただし、これは拡張機能であり必須ではない。

------

## 6. AI思考支援シナリオ

### ① 最適値探索

AIは：

- ω vs iterations を比較
- 非単調性検出
- 安定域推定
- 次の実験提案

を行う。

------

### ② 異常検出

AIは：

- 発散検出
- 収束不安定
- runtime異常
- 誤差爆発

を即座に抽出する。

------

### ③ 論文化可能性評価

AIは：

- 新規性
- 一般化可能性
- 比較不足
- 理論整合性

を指摘できる。

------

### ④ 二役ディベート

同じ材料で：

- Pro（推進派）
- Con（懐疑派）

を生成することで、
思考が立体化する。

### ⑤ AIに比較させる

複数実験の logs を渡し：

> どれが最も論文価値が高い？

と評価させる。

------

## 7. notes.md の役割

各実験に：

```
experiments/<exp>/notes.md
```

を置く。

構造：

```md
# Experiment Notes: sor_omega_1p25

---

## 1. AI Summary (Facts)
(自動生成)
### Run Overview
- iterations:
- runtime_sec:
- converged:
- final_residual:
- error_l2:
- error_max:

### Observed Behavior
- (収束傾向 / 発散 / 振動など)
- (history_stats があれば参照)

※ ここでは解釈しない。run_summary.json の内容を整理するのみ。
---

## 2. AI Analysis (Evaluation)
(自動生成)
### Alignment with Intent
- 成功基準との整合性
- 比較対象との優劣

### Hypotheses 仮説候補
- 仮説1
- 仮説2

### Counterarguments 他実験との比較
- 他解釈の可能性
- 実装依存の可能性
- 条件依存の可能性

### Minimal Next Experiment 次実験提案
- exp_name:
- change:
- expected_effect:
---

## 3. Human Thoughts (Decision)
(手書き)
- 採用 / 保留 / 却下
- なぜそう判断したか
- 次の実験名
- 気になる点
- 投資するかどうか
---
```

#### 🧠 重要なルール

##### ① AI Summary は run_summary.json だけを見る

- config から推測しない
- 人のメモを読まない
- 解釈しない

これは「事実層」。

------

##### ② AI Analysis は intent + config + run_summary を使う

ここで初めて：

- 比較
- 仮説
- 批判

を行う。

------

##### ③ Human Thoughts は責任層

- AIに決定させない
- 主語は「私は」



------

## 8. 人とAIの役割

AI：

- 比較する
- 要約する
- 批判する
- 仮説を出す

人間：

- 方向を決める
- 採用する
- 捨てる
- 責任を持つ



### 🔥 実際のAI支援の流れ

##### あなた：

> 以下の intent, config, run_summary を元に notes.md の AI部分を書いて

##### AI：

- Summary を生成
- Analysis を生成

##### あなた：

- Decision を書く

これでループ完成。



------

## 9. provenance と再現性

`logs/<exp>.json` は：

- project commit
- framework commit
- 実行コマンド

を記録する。

これは管理のためではない。

> 後から説明できる研究にするためである。

------

## 10. ファイルは増やさない

AIは：

- ファイルが多いと弱い
- 意図が曖昧だと弱い
- 情報が散乱していると弱い

したがって：

> **最小構造を維持することが最重要**

------

## 11. このワークフローの本質

このフレームワークは、

- 研究を速くする魔法ではない
- 良いアイデアを保証しない

しかし、

> 実験が思考材料として構造化される

ことは保証する。

そのとき、

AIは強力な思考拡張装置になる。

------

## 12. 最後に

困ったら：

- intent を明確にする
- metrics を整える
- 比較させる

それだけでよい。

考える場所は、
いつでもそこにある。

# CONCEPT.md
## 設計思想

このフレームワークは、以下の原則に基づいて設計されています。

---

## 原理1：記憶はGitに置く

- チャットは思考の場
- 記録はファイル
- 履歴はGit

人間やLLMの記憶を信頼しない。

---

## 原理2：目的駆動型研究

研究は「実験の集合」ではなく、

> Objective（目的）の集合

である。

各Objectiveは次の項目を必ず持つ：

- Claim
- Quantitative Criteria
- Qualitative Criteria
- Comparison Baseline
- Status

---

## 原理3：AIは思考増幅器

AIは：

- 比較
- 要約
- 反証
- 仮説生成
- 代替案提示

が強い。

AIは決定しない。
人間が決定する。

---

## 原理4：実験と分析を分離する

- experiments/ は事実
- analysis/ は思考

混ぜない。

---

## 原理5：Statusによる研究進化管理

Objectiveは状態を持つ：

- exploratory
- active
- validated
- rejected
- ...

AIが提案し、人が承認する。



==========================

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

これで十分である。AIはこれらのファイルセットを組み合わせて、

- 比較
- 異常検出
- 仮説生成
- 追加実験提案
- 論文化可能性評価
- Reviewer視点批判

を行う。

------

## 3. run_summary.json の設計思想

- `run_summary.json` は**solverが出力**し、**結果の要約のみを持つ**。

- 条件は `config.yaml` が真実。


#### 設計原則

1. 人間が読める
2. AIが比較しやすい
3. 実験間で共通キーがある
4. solverに依存しすぎない
5. 将来拡張可能

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

## 4. 特徴量

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
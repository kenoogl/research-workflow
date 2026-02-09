# Judge Review
## LLM-as-Judge Evaluation (v0.1.1)

> 注意：
> このレビューは **実行者（Executor）とは独立した視点**で行う。
> Judge は実装・修正・実行を行わない。
> 判断は最終的に **Human (PI)** が行う。

---

## 0. Review Metadata

- Review date:
- Judge model:
- Reviewed artifacts:
  - results/
  - logs/run.json
  - codex_results.md
  - (others, if any)

※ プロンプト履歴・思考過程は参照しない

---

## 1. Evaluation Criteria

### 1.1 Numerical / Technical Validity
- 計算は定義された問題設定に従っているか？
- 明らかなバグ・不整合は見られないか？
- 数値結果は最低限、理論・経験と矛盾していないか？

**Assessment:**
- [ ] OK
- [ ] Minor concerns
- [ ] Major concerns

**Notes:**
- 

---

### 1.2 Reproducibility
- run.json から実行条件は一意に特定できるか？
- 成果物と設定・コードの対応は明確か？
- 再実行不能と思われる要素はあるか？

**Assessment:**
- [ ] Reproducible
- [ ] Partially reproducible
- [ ] Not reproducible

**Notes:**
- 

---

### 1.3 Novelty / Insight Signal
- 既知の結果の再確認か？
- 新しい挙動・傾向・解釈の兆しはあるか？
- 「論文化に向かう可能性」を感じるか？

**Assessment:**
- [ ] No novelty
- [ ] Weak signal
- [ ] Clear signal

**Notes:**
- 

---

### 1.4 Failure Modes & Risks
- 結果が誤解されやすい点はあるか？
- 条件依存・スケール依存の懸念はあるか？
- Reviewer が突きそうな弱点はどこか？

**Notes:**
- 

---

## 2. Judge Decision (Select One)

> Judge は **提案のみ**を行う。
> 決定権は持たない。

### ☐ PASS
- 次のステージに進んでよい
- 論文化・一般化を検討する価値あり

### ☐ REVISE
- 改善・追加実験が必要
- 実行内容を修正して再評価

### ☐ REJECT
- 現時点では成果として扱わない
- Archive（Not for Paper）へ

### ☐ ESCALATE
- 判断が困難
- 人間（PI）の判断を仰ぐべき

---

## 3. Rationale (Why this decision?)

- 

（3〜5行で十分）

---

## 4. Suggested Next Actions (Optional)

※ **命令ではなく提案**

- 
- 

---

## 5. Notes for Human (PI)

- この判断で特に注意すべき点
- 人間判断が必要な理由（ESCALATE の場合）

---

## Footer

Judge never executes.  
Executor never judges.  
Human decides.
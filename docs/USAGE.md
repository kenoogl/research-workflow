# USAGE.md
## 基本フロー

1. Objectiveを書く（intent.md）
2. 実験を定義（bin/new_exp）
3. 実行（run_exp）
4. 結果を保存
5. generate_notesでAI分析
6. 必要ならanalysisを開始
7. ObjectiveのStatusを更新（人が承認）
8. commit

---

## 実験後にAIへ渡す最小セット

- config.yaml
- logs/<exp>.json
- results/<exp>/run_summary.json

これだけで分析可能。

---

## 分析フェーズ

analysis/<ana> を作成。

LLMとの対話は：

analysis/<ana>/events/

に連番保存。

---

## Objective更新

AIがStatus変更を提案。
人がintent.mdを更新。

---

## 原則

- AIは提案者
- 人は決定者
- Gitは記録者

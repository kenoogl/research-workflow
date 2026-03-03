# Role of AI



## AGENTS.mdへの指示

#### フレームワークでの基本的な振る舞いを書いておく

**常に守る運用ルール**  

次の2つをセクションを分けて記述

- フレームワークとしての基本的な挙動
- コード開発時の挙動



## notes.mdの作成方法についての指示

- AIが結果を基に文書を生成する。
- CLIやcodex appで書かせるのが柔軟でよい。
- その仕組みについては、AGENT.mdとスキルを使う2種類の実装



### スキル化する  

- **手順化された反復作業**
- 例: `notes-updater` スキルを作って、`intent/config/summary` を読んで `notes.md` の 1/2 節だけ更新するワークフローを固定
- 効果: 実行の一貫性が上がる、プロンプトを短くできる



### 実務推奨:

1. `AGENTS.md` に最小ルール（更新範囲・禁止事項）を書く  
2. 実作業はスキルに寄せる  



##### 使い方：プロンプトを次のように。（）内は念のため。

~~~
AGENTS.md準拠で、sor_n16_omega1.5 の notes.md を更新。（section 1/2 のみ、section 3 は保持。）
~~~



#### スキル案（notes-updater）

- 名前: `notes-updater`
- 目的: `--llm-internal` 実行後の定型更新を短指示で実行
- 入力: `<exp_name>`
- 動作:
  1. `intent/config/run_summary` を読む
  2. `notes.md` の section 1/2 を生成
  3. section 3 を保持したまま置換
  4. 構造不整合なら停止して報告

##### `AGENTS.md`に`SKILL.md`の利用を明記

~~~
### Project-Local Skill Policy

- This project uses local skills under:
  - `.codex/skills/`
- For notes update workflows, prioritize:
  - `.codex/skills/notes-updater/SKILL.md`
- If both global and project-local skills exist, prefer project-local skills.
- Do not use global skill variants for this project unless explicitly requested.
- If the project-local skill file is missing or broken, report it and fall back to AGENTS.md rules.
~~~

##### ファイルの配置

~~~
`.codex/skills/notes-updater/SKILL.md`
~~~

##### スキル運用:

「`$notes-updater sor_n16_omega1.5` 実行」



## 複数実験同時比較モード

複数の `run_summary.json` を同時にAIに渡し、
横断的に比較・順位付け・傾向抽出により仮説生成と戦略設計をさせるモード

- 複数の実験を一瞬で俯瞰
- 傾向検出
- 最適候補抽出
- 外れ値検出
- 非線形挙動検出

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
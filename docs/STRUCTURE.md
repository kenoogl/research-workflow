# STRUCTURE.md
## 全体構造

~~~
project/
├── ai_context/
│   └── intent.md
├── experiments/
├── results/
├── logs/
├── analysis/
└── ...
~~~

---

## `ai_context/intent.md`

研究の地図。

複数Objectiveを持つ。
各Objectiveは成功基準とStatusを持つ。

---

## `experiments/<exp>/`

実験定義。

- config.yaml
- notes.md

---

## `results/<exp>/`

実験結果。

- run_summary.json
- 数値データ
- 図

---

## `logs/<exp>.json`

実行環境とcommit情報。

---

## `analysis/<ana>/`

分析単位。

- meta.json
- discussion.md
- events/

---

## 分離原則

| 層          | 内容           |
| ----------- | -------------- |
| experiments | 何をやったか   |
| results     | 何が起きたか   |
| analysis    | どう考えたか   |
| intent      | 何を目指したか |

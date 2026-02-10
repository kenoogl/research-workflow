# Project README

このリポジトリは、実際の研究・実験・提案書作成を行う **project repo** です。  
方法論と仕組みは `framework/`（research-workflow）にあります。

この README に書かれたコマンドは、すべて **project repo のルート**で実行します。

---

## まずやること

1. 実験設定を書く  

  ~~~
  experiments/exp_001/config.yaml
  ~~~


2. 実行する（唯一の入口）  
  ~~~
  ./bin/run_exp exp_001
  ~~~


3. 結果を見る  
  ~~~
  results/exp_001/
  ~~~

  


---

## ルール（最低限）

- 実行は必ず `bin/run_exp` 経由
- `results/` をコミットする場合、`logs/run.json` が必要
- 意図・観察は `ai_context/` に残す（雑でOK）

---

## フレームワークについて

- `framework/` は submodule（編集しない）
- 更新する場合は framework の version/tag を切り替える

詳しい考え方は `framework/README.md` を参照してください。

#### なぜこの README が「最小で強い」か

framework の説明を一切しない
→ 役割分離が壊れない

最初の3ステップが明確
→ 迷う前に実行できる

禁止事項を増やさない
→ 運用で疲れない

補足（やらなくていいが、後で効く）
もし余力があれば、README の末尾に1行だけ足すとさらに良い：



## メモ

- このプロジェクトで利用している framework のバージョンを確認
👉 再現性・論文化のときに効く。

##### 確認方法

プロジェクトのルートディレクトリで

~~~
cd framework
git describe --tags --dirty --always
~~~

- tag があれば → `v0.1.1`
- tag が無ければ → commit hash
- 改変があれば → `-dirty`

👉
 **「どのバージョンを、改変あり／なしで使っているか」**
 が一発で分かる。



## 実行時の注意（重要）

本プロジェクトでは、実行時点で
未コミットの変更がある場合（git dirty）、
その状態が `logs/run.json` に記録されます。

dirty=true の結果は、
- 再現性が保証されない可能性がある
- 論文化・正式成果には適さない場合がある

ことに注意してください。

実行自体は可能ですが、
判断は人間が行います。

run_exp は、実行時点の git commit と dirty 状態を自動で記録し、
dirty=true の場合は警告を表示します（実行は停止しません）。



## ユーザがすべきこと（v0.1）

**ユーザの仕事は「判断」と「保存」だけ。実行や評価は仕組みに任せる。**

------

## ユーザがやることは、この5つだけ

> 1. **意図を書く**
> 2. **run_exp で動かす**
> 3. **結果を見る**
> 4. **Judge を読む**
> 5. **決める**

### ① project repo を作る

- 作業ディレクトリを決める
- framework を **submodule として追加**する
- テンプレートをコピーする

👉 これは **最初に1回だけ**

------

### ② 実験・作業の“意図”を1メモ残す

場所：`ai_context/`

- `codex_plan.md`（これから何をするか）
- 3行でOK

例：

```
- 何を試すか
- 何と比べるか
- 何が分かれば成功か
```

👉 **完璧さ不要。後で読めれば十分。**

------

### ③ 実行は必ず run_exp 経由で行う

```
./bin/run_exp exp_001
```

- 実行ログ（run.json）は **自動生成**
- ユーザは中身を理解しなくてよい

👉 **「直接 python / julia を叩かない」だけ守る**



実行時に生成される `logs/run.json` には、以下が含まれます。

- project commit
- project dirty（未コミット変更の有無）
- framework commit（submodule時）
- framework dirty（将来拡張）

これにより、「この結果はどのコードで出たか」を後から一意に特定できます。

------

### ④ 結果を置く

- `results/exp_001/` に図・表・数値を置く
- 手動でも自動でもよい

👉 **成果は必ず results/** に集める

------

### ⑤ Judge の評価を読む → 判断する

- `judge_reviews.md` を読む
- 分岐は4択だけ：

```
PASS / REVISE / REJECT / ESCALATE
```

👉 **最終判断はユーザ（人間）**

------

## ユーザの責任はどこにあるか

| 項目                   | 誰の責任              |
| ---------------------- | --------------------- |
| 実行                   | Codex / run_exp       |
| 記録                   | 仕組み（Git + files） |
| 評価案                 | Judge（LLM）          |
| **採用・却下**         | **ユーザ**            |
| **論文・提案に使うか** | **ユーザ**            |

👉 **責任は明示的に人に残る**





------

------



## 既にあるプロジェクトに適用させる場合

- 新規プロジェクトとして作り直すのではなく、既存プロジェクトを「このフレームワークの型に寄せる」方針



### STEP 1：現状をそのまま project repo にする（最小）

まずは **既存 ディレクトリをそのまま project repo にする**。

```
cd project-hoge
git status   # まず現状確認
```

- ここでは **構造を変えない**
- コードも動かさない

👉 **“現場保存”が最優先**

------

### STEP 2：framework を submodule として「後付け」する

```
git submodule add https://github.com/kenoogl/research-workflow.git framework
```

これで：

```
project-hoge/
├── framework/   ← 追加される
├── src/         ← これ以降は既存ファイル群
├── results/
├── scripts/
└── ...
```

👉 **ここではまだ run_exp も hook も使わない**

------

### STEP 3：最低限の3点だけ合わせる

#### ① bin/run_exp を導入（コピーでOK）

```
cp framework/templates/project/bin/run_exp bin/
chmod +x bin/run_exp
```

- 中身は **まだ実行しなくていい**
- 入口を「1つある」状態にする

------

#### ② logs/run.json を“これから”作り始める

過去の実験は無理に遡らない。

👉 **「今日以降の実行」だけ**：

```
./bin/run_exp mg_exp_resume
```

- 実行しなくても run.json が出ればOK

------

#### ③ ai_context を“これから”書き始める

```
mkdir -p ai_context
```

最低限これだけ（例）：

```
# ai_context/atlas_notes.md

## 状態
- project-hoge は既に baseline / xxxx を実装済み
- 残差停滞が低周波誤差由来と仮定

## これから
- restriction/prolongation の設計見直し
- smoother としての Taylor iteration 再解釈
```

👉 **過去を完璧に再構築しない**のがコツ。

------

### STEP 4：ここからは「通常運用」に入る

ここから先は、新規プロジェクトと同じ。

- 実行 → run_exp
- 結果 → results/
- 評価 → judge_reviews.md
- 判断 → 人間（あなた）

------

## やらなくていいこと（重要）

❌ 過去の全実験に run.json を付け直す
 ❌ ディレクトリ構成を全部 templates に合わせる
 ❌ いきなり hook を有効にする
 ❌ 既存コードを無理に書き換える

# 15分クイックスタート  
## ― 何も考えずに1回まわす ―

このチュートリアルの目的はただ一つ。

> **「この仕組み、動くな」  
> と思ってもらうこと**

思想理解・最適設計・正しさは不要です。

---

## 0. 前提（読むだけ・1分）

- Git 管理されたリポジトリ
- bash が使える
- Codex CLI / ChatGPT は「あるもの」とする

LLMを使わなくても、このチュートリアルは成立します。

---

## 1. ディレクトリを用意する（2分）

以下があれば十分です。

~~~
project/
├── bin/
│ └── run_exp
├── experiments/
│ └── exp_001/
│ └── config.yaml
├── logs/
├── results/
└── src/
~~~

まだコードは書きません。

---

## 2. ダミーの設定を書く（1分）

`experiments/exp_001/config.yaml`

```yaml
name: exp_001
description: first test run
parameter_a: 1.0
parameter_b: 2.0
```



意味はありません。
**存在すればOK**。

------

## 3. run_exp を置く（3分）

`bin/run_exp` を作成し、以下を貼り付けてください。

```bash
#!/usr/bin/env bash
set -e

EXP_NAME="$1"
CONFIG="experiments/${EXP_NAME}/config.yaml"
OUTDIR="results/${EXP_NAME}"
LOGDIR="logs"
META="${LOGDIR}/run.json"

mkdir -p "${OUTDIR}" "${LOGDIR}"

GIT_COMMIT=$(git rev-parse --short HEAD)
GIT_DIRTY=$(git diff --quiet || echo true)

cat <<EOF > "${META}"
{
  "timestamp": "$(date -Iseconds)",
  "git_commit": "${GIT_COMMIT}",
  "git_dirty": "${GIT_DIRTY}",
  "config": "${CONFIG}",
  "output": "${OUTDIR}"
}
EOF

echo "[run_exp] run.json written"
```

権限を付与：

```
chmod +x bin/run_exp
```

------

## 4. 実行してみる（1分）

```
./bin/run_exp exp_001
```

成功すると：

```
logs/run.json
```

が生成されます。

👉 **この時点で成功です。**
まだ何も計算していません。

------

## 5. ダミー結果を置く（1分）

```
mkdir -p results/exp_001
echo "dummy result" > results/exp_001/output.txt
```

------

## 6. Git に保存する（2分）

```
git add logs/run.json results/exp_001
git commit -m "exp001: first run"
```

もし hook が入っていれば：

- run.json が無いと止まる
- あると普通に通る

これを体験できればOK。

------

## 7. ここまでで何が起きたか（読むだけ・2分）

あなたは今：

- 実験名を決め
- 実行したことを **機械的に記録**し
- 結果と由来を **セットで保存**しました

まだ：

- 仮説を書いていない
- LLMを使っていない
- コードを書いていない

それでも、
**「後から使える成果の最小形」**は完成しています。

------

## 8. 余力があれば（＋3分）

### codex_plan.md を1行で書く

```
ai_context/codex_plan.md
## Objective
- first test
```

完璧さは不要です。

------

## 9. この先に自然につながること

- `src/` にコードを書く
- run_exp の最後に実行行を足す
- Atlas に「この結果どう思う？」と聞く
- codex_results.md を1段落書く

**順番は自由**です。

------

## 10. まとめ（重要）

この15分でやったことは：

- 正しい研究ではない
- 良い実験でもない

でも、

> **「結果が迷子にならない状態」**

は、もう手に入っています。

それだけで、このワークフローを使う価値はあります。

------

次に読むなら：

- `CONCEPT.md`（なぜこうしているか）
- README（全体像）
- FAQ（よくある詰まりポイント）

どれも、急ぐ必要はありません。


# Project README

このリポジトリは、実際の研究・実験・提案書作成を行う **project repo** です。  
方法論と仕組みは `framework/`（research-workflow）にあります。

この README に書かれたコマンドは、すべて **project repo のルート**で実行する。

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

# hooks/pre-commit の役割と使い方

このディレクトリの `pre-commit` は、**実験結果コミット時の整合性チェック**を行うための hook です。

## 役割

- `results/` 配下をコミットする際に、対応する実行メタデータ（`logs/<exp>.json`）の同時コミットを要求する
- `run_exp` を経由しない不完全な成果物コミットを防ぐ
- 実験の再現性（設定・実行情報の追跡可能性）を維持する

## 仕組み

Git hook は、`framework/hooks/pre-commit` に置くだけでは自動実行されません。  
実際に動くのは **project repo の `.git/hooks/pre-commit`** にあるスクリプトだけです。

そのため、初回に project 側で hook を有効化する必要があります。

## 有効化方法（初回のみ）

```bash
ln -sf framework/hooks/pre-commit .git/hooks/pre-commit
chmod +x framework/hooks/pre-commit
```

## 動作

1. `git commit` 実行時に `pre-commit` が自動実行される
2. staged ファイルに `results/` 配下が含まれるか確認する
3. 含まれる場合は、staged に `logs/*.json` も存在するか確認する
4. 条件を満たさない場合はエラー終了し、commit をブロックする

## 期待される運用

- 実験実行は `bin/run_exp <exp_name>` を使う
- 生成された `results/<exp_name>/` と `logs/<exp_name>.json` をセットでコミットする


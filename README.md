# dependency-expander-java: multi-libraries (__Experimental__)

複数の場所にライブラリが存在する場合はこちらを使用して下さい. ただし, まだテストを十分に出来ていません.

## 変更点

以下の点以外はライブラリが一つの場合と同じです.

1. [dependency-expander-java/scripts/paths.sh](scripts/paths.sh) の `source_paths` と `class_paths` を自分のライブラリの source path および class path に書き換えて下さい. 複数のパスを記述する場合は, `:` (コロン) で連結して下さい.

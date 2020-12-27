# dependency-expander-java

ライブラリや標準ライブラリへの依存関係を解決し, 単一ファイルで実行可能となるようにソースコードを展開する競技プログラミング向けのツールです.

## 使用法

### 準備

次の 2 つは __初めの一回だけ__ 設定すれば十分です.

1. 必要な `java` ファイルをコンパイルします.

    ```shell
    $ dependency_expander/scripts/compile_expander.sh
    ```

2. [dependency_expander/scripts/paths.sh](dependency_expander/scripts/paths.sh) の `CLASS_PATH` と `SOURCE_PATH` を自分のライブラリの class path および source path に書き換えて下さい.

### ライブラリの更新

__ライブラリの依存関係 (標準ライブラリへの依存を含む) が変化した場合は, 必ず以下の 2 つを実行して下さい.__

1. ライブラリを再コンパイルします

    ```shell
    $ dependency_expander/scripts/compile_library.sh
    ```

2. 依存関係を表す有向グラフを構築します

    ```shell
    $ dependency_expander/scripts/build_dependency_graph.sh
    ```

### 使用

ライブラリを更新している場合は, 先に[上節](#ライブラリの更新)の内容を必ず実行して下さい.

以下のコマンドによりライブラリが展開されます.

```
$ dependency_expander/scripts/expander.sh <source file> [destination file]
```

- `source file` (必須): 展開したいファイル (*.java)
- `destination file` (オプション): 出力先のファイル (*.java)

`destination file` を指定しなかった場合, `source file` と同じディレクトリに `Main.java` が生成されます. `source file` と `destination file` が同じファイルを指していてもよいです.

__注意__:

- ライブラリを更新した後は, 必ず [ライブラリの更新](#ライブラリの更新) に従って依存関係を更新して下さい.
- `source file` において, 実行クラス名とファイル名 (拡張子を除く) を一致させて下さい (常に `public class` とするのが確実です). つまり, 実行クラスが `A` であれば `A.java` と命名して下さい.
- 実行クラスは `package` 文, `import` 文に次いでコメントを挟まずに記述してください (改行や空行は問題ありません).
  
  ```java
  package ...;

  import ...;
  import ...;

  <ここに何も書かない>

  public class A {
      public static void main(String[] args) {
          <ここには String s = "class A"; のような記述があっても置換されない>
      }
  }
  ```

  理由としては, クラス名の置換は正規表現により簡易的に行っているので, 実行クラスの前にコメントや他のクラスを書くと置換に失敗する可能性があるためです.

  正確には, 以下の置換に引っかかるような文字列を手前に書くと壊れます.

  ```bash
  sed -zE "s/class[ \r\n\t]+${class_name}([^a-zA-Z0-9])/<省略>/"
  ```

  また, 実行クラスを `interface` とすると, 今度は上の正規表現にマッチしないので壊れます.

- クラス名の置換は初めの `[public] class <class name> {...` のみに対して適用されます. これは, クラス名と同名の変数が存在する場合や, 文字列中に現れた場合の対処が難しいためです. 従って, 実行クラス名に依存するコードを書くと壊れます. 例えば, 実行クラス名が `A` であるような場合に, 以下のようなコードにおいて `A` の部分は置換されません.

  ```java
  A obj = new A();
  A.Inner obj = new A.Inner();
  int x = A.MOD;
  ```

  同時に, 以下のようなコードを書いても壊れないことを意味しています.

  ```java
  int A = 0;    // もし A が Main に置換されると, 次の行でエラーとなる
  int Main = 5;
  ```

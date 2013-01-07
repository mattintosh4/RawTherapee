2012-12-28: 作業場所を Gist に移動しました。

https://gist.github.com/4389088

***

## RawTherapee 自動ビルドスクリプトの使い方

bash のプロセス置換と `curl` コマンドでこのリポジトリから直接実行できます。ソースディレクトリのルートに移動してから実行して下さい。

```bash
cd /path/to/source_root
bash <(curl -L raw.github.com/mattintosh4/RawTherapee/buildkit)
```

### オプション ###

#### GTK_PREFIX ####

GTK ライブラリの場所を指定できます。これは主に JHBuild ユーザー向けです。

```bash
GTK_PREFIX=$HOME/gtk/inst \
bash <(curl -L raw.github.com/mattintosh4/RawTherapee/buildkit)
```

#### CC/CXX ####
	
デフォルトでは `/opt/local/bin/gcc-mp-4.*` を使用しますが、CC や CXX を指定することができます。

```bash
CC=/usr/local/bin/clang \
CXX=/usr/local/bin/clang++ \
bash <(curl -L raw.github.com/mattintosh4/RawTherapee/buildkit)
```

Xcode に同梱のコンパイラなど一部のコンパイラでは auto_ptr のエラーを回避するために以下のファイルの修正が必要です。

- rtgui/darkframe.h
- rtgui/flatfield.h
- rtgui/icmpanel.h

各ファイルの前方にある `#include <auto_ptr.h>` の行を以下のように変更します。

```
#ifndef __APPLE__
#include <auto_ptr.h>
#endif
```

※4.0.9.167(Changeset: 2092:08bde0937a32) 以降、ソースに問題があり、LLVM/Clang でのビルドができなくなっています。
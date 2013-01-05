
2012-12-28: 作業場所を Gist に移動しました。

https://gist.github.com/4389088

***

## RawTherapee 自動ビルドスクリプトの使い方

bash のプロセス置換と `curl` コマンドでこのリポジトリから直接実行できます。ソースディレクトリのルートに移動してから実行して下さい。

```bash
$ cd /path/to/source_root
$ bash <(curl https://github.com/mattintosh4/RawTherapee/blob/master/tools/osx/buildRT_mac)
```

### オプション

- __GTK_PREFIX__
	
	GTK ライブラリの場所を指定できます。これは主に JHBuild ユーザー向けです。
	
	```bash
$ GTK_PREFIX=$HOME/gtk/inst bash <(curl https://github.com/mattintosh4/RawTherapee/blob/master/tools/osx/buildRT_mac)
```

- __CC__/__CXX__
	
	デフォルトでは `/opt/local/bin/gcc-mp-4.*` を使用しますが、CC や CXX を指定することができます。

	```bash
CC=/usr/local/bin/clang \
CXX=/usr/local/bin/clang++ \
bash <(curl https://github.com/mattintosh4/RawTherapee/blob/master/tools/osx/buildRT_mac)
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
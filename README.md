# Private Portfile for MacPorts users #

1) Create local private port repository.

```bash
$ mkdir -P $HOME/macports/graphics/rawtherapee
```

2) Add path to `/opt/local/etc/macports/sources.conf`.

```
#  MacPorts system wide sources configuration file
#  $Id: sources.conf 79599 2011-06-19 21:18:18Z jmr@macports.org $

#  To setup a local ports repository, insert a "file://" entry following
#  the example below that points to your local ports directory:
#  Example: file:///Users/landonf/misc/MacPorts/ports
file:///Users/yourname/macports
```

3) Download private Portfile. Save to `$HOME/macports/graphics/rawtherapee`.

https://raw.github.com/mattintosh4/RawTherapee/master/macports/Portfile

4) Setup repository.

```sh
$ portindex
```

5) Install RawTherapee.

```sh
$ sudo port install rawtherapee
```

note: If you want to build the latest source, add "+devel" variants.

```sh
$ sudo port install rawtherapee +devel
```

6) Launch application from terminal

```sh
$ rawtherapee
```

# How to use RawTherapee build script #

## Build and make bundle ##

bash のプロセス置換と `curl` コマンドでこのリポジトリから直接実行できます。ソースディレクトリのルートに移動してから実行して下さい。

```bash
cd /path/to/source_root
bash <(curl -L raw.github.com/mattintosh4/RawTherapee/buildkit)
```

## Only make bundle ##

バンドル化のみを行う場合は `make-app-bundle` を実行して下さい。

Run the `make-app-bundle` script.

https://github.com/mattintosh4/RawTherapee/blob/master/tools/osx/make-app-bundle

```bash
cd /path/to/source_root
bash <(curl https://raw.github.com/mattintosh4/RawTherapee/master/tools/osx/make-app-bundle)
```

## Options ##

### $GTK_PREFIX ###

GTK ライブラリの場所を指定できます。これは主に JHBuild ユーザー向けです。

You can set GTK libraries path. This variable is for JHBuild users.

```bash
GTK_PREFIX=$HOME/gtk/inst \
bash <(curl -L raw.github.com/mattintosh4/RawTherapee/buildkit)
```

### $CC/$CXX ###

デフォルトでは `/opt/local/bin/gcc-mp-4.*` を使用しますが、CC や CXX を指定することができます。

You can override compiler by these variables.

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
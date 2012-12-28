
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

- GTK_PREFIX
	
	GTK ライブラリの場所を指定できます。これは主に JHBuild ユーザー向けです。
	
	```bash
$ GTK_PREFIX=$HOME/gtk/inst bash <(curl https://github.com/mattintosh4/RawTherapee/blob/master/tools/osx/buildRT_mac)
```

- USE_CLANG
	
	デフォルトでは `/opt/local/bin/gcc-mp-4.*` を使用しますが、`USE_CLANG=1` を指定することで clang/clang++ を使用するようになります。事前に clang にパスを通して下さい。
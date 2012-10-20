# ここは RawTherapee 4.0.9 for MacOS 非公式版の開発ページです #

勉強として MacOS 向けに RawTherapee のビルドテストなどを行っています。

ここで公開されているものはあくまでビルド初心者が個人で開発しているものであり、アプリケーション本来の動作をしない可能性もあります。ご利用される場合は自己責任でお願いします。また、このページは公式と無関係です（公式フォーラムの情報等はチェックさせていただいています。開発者の皆さんには感謝しています！）。

RawTherapee のソースコードやマニュアル、既知の問題については公式ページで確認して下さい。

-	http://rawtherapee.com/
-	http://code.google.com/p/rawtherapee/

「動いた」「動かなかった」など動作報告等いただけると助かります。

-	[開発記録](http://mattintosh.blog.so-net.ne.jp/archive/c2303145195-1)
-	[Twitter:@mattintosh4](https://twitter.com/mattintosh4)

### 非公式版の仕様について ###

日本語入力には対応していません。また、64bit 版では一部の IM との不具合が確認されています。詳しくは下記を参照して下さい。

CPU 最適化は公式の指針に乗っ取り `-mtune=generic` を設定しています。その他は `BUILD_TYPE=Release` をベースにしていますが、一部変更している箇所があるためビルドタイプの表記を「Release (Development)」としています。

```bash
CMAKE_OSX_DEPLOYMENT_TARGET="10.6"
CMAKE_OSX_SYSROOT="/Developer/SDKs/MacOSX10.6.sdk"
RTENGINE_CXX_FLAGS="-ffast-math -funroll-loops -fomit-frame-pointer"
```

同梱の AboutThisBuild.txt には公式版との見分けがつけやすいように「非公式」の表記が追加されています。設定画面左下の「About」から確認が出来ます。

### 64bit 版の利用時の注意事項 ###

IM に Google 日本語入力や MacUIM などを使用していると一定時間操作を受け付けないバグがあります（ことえりでの動作は問題ありません）。起動中に IM を切り替えるとアプリケーションがクラッシュする可能性がありますので事前にお使いの IM でテストすることをおすすめします。

エラー内容を確認するには `RawTherapee.app/Contents/MacOS/start` から起動して下さい。下記のエラーが表示流れている間は操作が出来なくなります。

```no-highlight:rawtherapee
(rawtherapee:582): GLib-CRITICAL **: g_hash_table_lookup: assertion `hash_table != NULL' failed
(rawtherapee:582): GLib-CRITICAL **: g_hash_table_insert_internal: assertion `hash_table != NULL' failed
```

※X11 版ではこの問題は確認されていません。

## ダウンロードページ ##

https://github.com/mattintosh4/RawTherapee/downloads

## 更新履歴 ##

### 2012.10.21 ###

[X11 版 RawTherapee 4.0.9.147](https://github.com/mattintosh4/RawTherapee/downloads) をアップしました。fontconfig の問題を修正したので XQuartz.app だけで動くと思います。［[詳細](http://mattintosh.blog.so-net.ne.jp/56423785)］

### 2012.10.18 ###

X11 版 RawTherapee をアップしました。Quartz 版よりも動作が快適だと思います。XQuartz.app の他、pango、cairo、fontconfig などが必要です。MacPorts からインストールして下さい。

X11 版では UIM 系のインプットメソッドとの相性問題は確認されていないので 64bit のみです。

### 2012.09.12 ###

MacPorts で GTK のアップデートがあったのでバンドルを更新しました。

### 2012.09.06 ###

__[RawTherapee 4.0.9.124](https://github.com/mattintosh4/RawTherapee/downloads)__ をアップしました。UIM 使用時の不具合があるため 32bit 版も置いてあります。

```no-highlight:AboutThisBuild.txt
Branch: denoise
Version: 4.0.9.124
Changeset: 50bf15b11495
Compiler: gcc-mp-4 4.7.1
Processor: generic x86
System: Apple
Bit depth: 64 bits
Gtkmm: V2.24.2
Build type: Release (Development)
Build flags:  -mtune=generic -fopenmp -O3 -DNDEBUG
Link flags:   -mtune=generic
OpenMP support: ON
MMAP support: ON
```

[issue 1545 #3](http://code.google.com/p/rawtherapee/issues/detail?id=1546&sort=-modified&colspec=ID%20Opened%20Modified%20Type%20Status%20Priority%20Milestone%20Summary%20Owner%20Stars) で natureh.510 氏がパッチを作って下さいました。Thanks natureh.510 !!

### 2012.8.28 ###

一部のアイコンが表示されない問題を修正。［[不正な MIME タイプの問題と XDG_DATA_DIRS](http://mattintosh.blog.so-net.ne.jp/2012-08-29)］

### 2012.8.26 ###

起動スクリプト変更と Pango モジュールのエラーを修正。［[pango.modules の @executable_path の問題](http://mattintosh.blog.so-net.ne.jp/2012-08-26)］

---

Thanks to all developers :)

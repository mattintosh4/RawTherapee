# ここは RawTherapee 4.0.9 for MacOS 非公式版の開発ページです #

時期バージョンが正式にリリースされるまで勉強としてビルドテストなどを行っています。

あくまで個人でビルドしている開発版であり、正常に動作することが確認されたわけではありません。ご利用される場合は自己責任でお願いします。また、このページは公式とは無関係です（フォーラムの内容等は確認させていただいています。全ての開発者の皆さんに感謝します）。

CPU 最適化は公式の指針に乗っ取り `-mtune=generic` を設定しています。その他は `BUILD_TYPE=Release` をベースにしていますが、一部変更している箇所があるためビルドタイプの表記を「Release (Development)」としています。

同梱の AboutThisBuild.txt には公式版との見分けがつけやすいように「非公式」の表記が追加されています。設定画面左下の「About」から確認が出来ます。

動作報告等いただけると助かります。

-	[開発記録](http://mattintosh.blog.so-net.ne.jp/archive/c2303145195-1)
-	[Twitter:@mattintosh4](https://twitter.com/mattintosh4)

RawTherapee のソースコードやマニュアル、既知の問題については公式ページで確認して下さい。

-	http://rawtherapee.com/
-	http://code.google.com/p/rawtherapee/

## 更新履歴 ##

__[RawTherapee 4.0.9.123](https://github.com/mattintosh4/RawTherapee/downloads)__ をアップしました。UIM 使用時の不具合があるため 32bit 版も置いてあります。

```no-highlight:AboutThisBuild.txt
Branch: denoise
Version: 4.0.9.123
Changeset: 65ecb9acc978
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

[issue 1545 #3](http://code.google.com/p/rawtherapee/issues/detail?id=1546&sort=-modified&colspec=ID%20Opened%20Modified%20Type%20Status%20Priority%20Milestone%20Summary%20Owner%20Stars) より natureh.510 氏のパッチを使わせていただきました。感謝します。

### 2012.8.28 ###

一部のアイコンが表示されない問題を修正。［[不正な MIME タイプの問題](http://mattintosh.blog.so-net.ne.jp/2012-08-29)］

### 2012.8.26 ###

起動スクリプト変更と Pango モジュールのエラーを修正。［[pango.modules の @executable_path の問題](http://mattintosh.blog.so-net.ne.jp/2012-08-26)］

## 64bit 版使用時の注意事項 ##

IM に Google 日本語入力や MacUIM などを使用していると一定時間操作を受け付けないバグがあります（ことえりでの動作は問題ありません）。起動中に IM を切り替えるとアプリケーションがクラッシュする可能性がありますので事前にお使いの IM でテストすることをおすすめします。

エラー内容を確認するには `RawTherapee.app/Contents/MacOS/start` から起動して下さい。下記のエラーが表示流れている間は操作が出来なくなります。

```no-highlight:rawtherapee
(rawtherapee:582): GLib-CRITICAL **: g_hash_table_lookup: assertion `hash_table != NULL' failed
(rawtherapee:582): GLib-CRITICAL **: g_hash_table_insert_internal: assertion `hash_table != NULL' failed
```
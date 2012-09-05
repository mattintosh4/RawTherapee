ここは RawTherapee 4.0.9 for MacOS 非公式版の開発ページです

公式版配信停止中につき時期バージョンが正式にリリースされるまでのつなぎとしてビルドテストなどを行っています。

10.7 以降の動作報告などをいただけると助かります。

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

## 64bit 版使用時の注意事項 ##

IM に Google 日本語入力や MacUIM などを使用していると一定時間操作を受け付けないバグがあります（ことえりでの動作は問題ありません）。起動中に IM を切り替えるとアプリケーションがクラッシュする可能性がありますので事前にお使いの IM でテストすることをおすすめします。

エラー内容を確認するには `RawTherapee.app/Contents/MacOS/start` から起動して下さい。下記のエラーが表示流れている間は操作が出来なくなります。

```no-highlight:rawtherapee
(rawtherapee:582): GLib-CRITICAL **: g_hash_table_lookup: assertion `hash_table != NULL' failed
(rawtherapee:582): GLib-CRITICAL **: g_hash_table_insert_internal: assertion `hash_table != NULL' failed
```

## RawTherapee 4.0.9 for MacOS 非公式開発版について ##

### 「非公式」の表記について ###

非公式版の AboutThisBuild.txt には公式版との見分けがつけやすいように「非公式」の表記が追加されています。設定画面左下の「About」から確認が出来ます。

### 最適化フラグについて ###

公式の指針に乗っ取り `-mtune=generic` を設定しています。また、`BUILD_TYPE=Release` をベースに一部フラグを変更している箇所があるためビルドタイプの表記を「Release (Development)」としています。

### pango.modules と gtk.immodules の内部パス変更 ###

`@executable_path` が動作しなかったため、`/tmp` に RawTherapee.app のシンボリックリンクを配置し、各ファイルの内部パスを絶対パスに変更しています。

エラー内容

```no-highlight:rawtherapee
(rawtherapee:2057): Pango-WARNING **: dlopen(/tmp/@executable_path/lib/pango/1.6.0/modules/pango-basic-coretext.so, 2): image not found
(rawtherapee:2057): Pango-WARNING **: failed to choose a font, expect ugly output. engine-type='PangoRenderCoreText', script='common'
(rawtherapee:2057): Pango-WARNING **: failed to choose a font, expect ugly output. engine-type='PangoRenderCoreText', script='hiragana'
(rawtherapee:2057): Pango-WARNING **: failed to choose a font, expect ugly output. engine-type='PangoRenderCoreText', script='han'
(rawtherapee:2057): Pango-WARNING **: failed to choose a font, expect ugly output. engine-type='PangoRenderCoreText', script='latin'
(rawtherapee:2057): Pango-WARNING **: failed to choose a font, expect ugly output. engine-type='PangoRenderCoreText', script='katakana'
```

変更前

```no-highlight:pango.modules
@executable_path/lib/pango/1.6.0/modules/pango-basic-coretext.so BasicScriptEngineCoreText PangoEngineShape PangoRenderCoreText common:
```

変更後

```no-highlight:pango.modules
/tmp/RawTherapee.app/Contents/MacOS/lib/pango/1.6.0/modules/pango-basic-coretext.so BasicScriptEngineCoreText PangoEngineShape PangoRenderCoreText common:
```

### 不正な MIME タイプへの対処 ###

一部のアイコンの MIME タイプが不正と判断されていたため、`MacOS/share/mime` を読みに行くように起動スクリプトに `XDG_DATA_DIRS` 変数を追加しました。

エラー内容

```no-highlight:rawtherapee
(rawtherapee:6357): Gtk-WARNING **: Error loading theme icon 'edit-find' for stock: Unrecognized image file format
(rawtherapee:6357): Gtk-WARNING **: Error loading theme icon 'edit-find' for stock: Unrecognized image file format
(rawtherapee:6357): Gtk-WARNING **: Error loading theme icon 'document-open' for stock: Unrecognized image file format
(rawtherapee:6357): Gtk-WARNING **: Error loading theme icon 'folder' for stock: Unrecognized image file format
```

`start` への `XDG_DATA_DIRS` の追加

```bash:start
export XDG_DATA_DIRS="${CWD}/share:$XDG_DATA_DIRS"
```
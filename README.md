# Lua library for Japanese FONT handler of FlashAir.

これはFlashAirで日本語フォントを扱うためのライブラリです。  
UTF-8やShift-JIS、EUC-JP文字に対応するビットマップデータを取得できます。  

## 動作確認済みフォント  
フォント本体は収録していませんので、BDF形式のビットマップフォントを別途ご用意ください。  
縦×横が32x32以下のJIS並びのBDFフォントを想定して作成しています。可変幅フォントにも対応しています。  
ご参考までにデバッグに使用したフォントは以下の通りです。  

### 半角文字  
misaki_4x8_iso8859.bdf  *1  
misaki_4x8_jisx0201.bdf *1  
3x8.bdf    *2  
k6x10.bdf  *3  
mplus_q06r.bdf *.4 (可変幅)

### 全角文字  
misaki_gothic.bdf *1  
misaki_mincho.bdf *1  
k6x8.bdf   *2  
k12x10.bdf *3  
shnmk12p.bdf *5 (可変幅)

### 入手元  
*1) 8×8 ドット日本語フォント「美咲フォント」  
http://littlelimit.net/misaki.htm  
X11 BDF 形式：misaki_bdf_2012-06-03.tar.gz (210,238 bytes)  

*2) 漢字12x10ドットフォント - k12x10  
http://z.apps.atjp.jp/k12x10/  
X11 bdf形式 (k12x10bdf.tar.gz, 155Kbyte)  

*3) 6×8 ドット日本語フォント「k6x8」  
http://littlelimit.net/k6x8.htm  
X11 BDF形式：k6x8bb02.tar.gz (86,333 bytes)  

*4) M+ BITMAP FONTS  
http://mplus-fonts.osdn.jp/mplus-bitmap-fonts/design/index.html  

*5) 東雲 ビットマップフォント  
http://openlab.ring.gr.jp/efont/shinonome/


## インストール方法  

    lib/SlibJfont.lua  -- ライブラリ  
    lib/Utf8Euc_jp.tbl -- UTF-8をEUC-JPに変換する際の変換テーブル  
    font/bdf2sef.lua   -- ファイル形式変換プログラム  
    sample.lua      -- UTF-8サンプルプログラム  
    sample_jis.lua  -- Shift-JISサンプルプログラム  
    sample_jis.txt  -- Shift-JISプログラム  
上記をFlashAir内の好きな場所においてください


## 使い方  
### 事前準備  
アプリ実行時にBDFフォントを直接扱うのは効率が悪いので、事前に  
BDFフォントをFlashAirで扱いやすい形式に変換しておきます。  
BDFフォントファイル（拡張子 .bdf)をfontフォルダに置き、
bdf2sef.lua ファイルの末尾に
    convBdf2Bin("BDFファイル名")
を１行追加して実行します。
例
    convBdf2Bin("k6x10.bdf")

全角文字の変換には数分かかります。
FTLE(*6)上で実行すると「Break(F8)」で中断、「GetMsg(F9)」で残り時間を確認することができます。

*6) FlashTools Lua Editor  
https://sites.google.com/site/gpsnmeajp/tools/flashair_tiny_lua_editer

### Description of the command

command | description
--- | ---
strEUC, ank_cnt=<BR>SlibJfont:sjis2euc(strSJIS) | **Shit-JISコード文字列をEUC-JPコードに変換します**<BR>**strEUC:** EUC文字列<BR>**ank_cnt**: 半角文字単位で数えた文字数<BR><BR>**strSJIS:** Shift-JIS文字列<BR>
strEUC, ank_cnt=<BR>SlibJfont:utf82euc(strUTF8) | **UTF-8コード文字列をEUC-JPコードに変換します**<BR>**strEUC:** EUC文字列<BR>**ank_cnt**: 半角文字単位で数えた文字数<BR><BR>**strUTF8:** UTF-8文字列<BR>
font = SlibJfont:open(fontPath, convTablePath) | **フォントファイルをオープンし、管理情報を取得します**
ret = SlibJfont:close(font) | **フォントファイルをクローズします**
SlibJfont:setFont(font1,font2) | **getFontで使用するフォントを指定します**
bitmap, fh, fw, p =<BR> SlibJfont:getFont(euc, p) | **指定した文字に対応するビットマップを取得します**

### utf82euc()について
UTF-8コードからEUC-JPコードに変換する関数は、mgo-tecさんの"SD_UTF8toSJIS"をアレンジさせていただきました。
JIS第一水準、第二水準、１３区、半角カナが変換可能です。  


### サンプルコード  

    sample.lua      -- UTF-8サンプルプログラム  
    sample_jis.lua  -- Shift-JISサンプルプログラム  
    sample_jis.txt  -- Shift-JISプログラム  
sample.lua または、sample_jis.lua を実行すると、
sample_out.txt ファイルに文字列に対応したバナーが出力されます。


## Licence

[MIT](https://github.com/AoiSaya/FlashAir-SlibILI9341/blob/master/LICENSE)

## Author

[GitHub/AoiSaya](https://github.com/AoiSaya)  
[Twitter ID @La_zlo](https://twitter.com/La_zlo)

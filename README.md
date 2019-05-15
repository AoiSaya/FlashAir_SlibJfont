# Lua library for Japanese FONT handler of FlashAir.  

これはFlashAirで日本語フォントを扱うためのライブラリです。  
UTF-8やShift-JIS、EUC-JP文字に対応するビットマップデータを取得できます。  

## 動作確認済みフォント  
フォント本体は収録していませんので、BDF形式のビットマップフォントを別途ご用意ください。  
縦×横が32dot x 32dot以下のJIS並びのBDFフォントを想定して作成しています。  
半角カタカナを使用する場合は、半角カタカナに対応した半角文字フォントをお選びください。  
デバッグに使用したフォントは以下の通りです。  

### 半角文字  

misaki_4x8_iso8859.bdf	*1)  
misaki_4x8_jisx0201.bdf *1)  
3x8.bdf    *2)  
k6x10.bdf  *3)  
mplus_q06r.bdf *4) (可変幅)  

### 全角文字  

misaki_gothic.bdf *1)  
misaki_mincho.bdf *1)  
k6x8.bdf   *2)  
k12x10.bdf *3)  
shnmk12p.bdf *5) (可変幅)  

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
    sample.lua		-- UTF-8サンプルプログラム  
    sample_jis.lua	-- Shift-JISサンプルプログラム  
    sample_jis.txt	-- Shift-JISプログラム  
上記をFlashAir内の好きな場所においてください  

## getFont()で取得できるbitmapのフォーマット  

ビットマップフォントデータは、列ごとに配列に格納されます。  
bitmapの要素数とフォントの幅は一致しています。  
各列は文字の上端がLSB、下端がMSBを表します。  
例えば、4x8ドットの”F"  

    @@@.  
    @...  
    @...  
    @@@.  
    @...  
    @...  
    @...  
    ....  

であれば、下記のように格納されます。  

    bitmap	= {}  
    bitmap[1] = 0xFE -- 11111110  
    bitmap[2] = 0x90 -- 10010000  
    bitmap[3] = 0x90 -- 10010000  
    bitmap[4] = 0x00 -- 00000000  

## 使い方  

### 事前準備  

アプリ実行時にBDFファイルを直接扱うのは効率が悪いので、事前にFlashAirで扱いやすい形式に変換しておきます。  
BDFファイル（拡張子 .bdf)をfontフォルダに置き、bdf2sef.lua ファイルの末尾に  

    convBdf2Bin("BDFファイル名")  

を１行追加して実行します。  
追加する行の例：  

    convBdf2Bin("k6x10.bdf")  

変換が終わると拡張子 .sef の独自形式のフォントファイルが生成されます。  
全角文字の変換には数分かかります。  
FTLE *6)* 上で実行すると「Break(F8)」で中断、「GetMsg(F9)」で残り時間を確認することができます。  
変換後のフォントの高さは全ての文字で共通の高さになります。幅は元のフォントの情報を維持します。  
  
*6) FlashTools Lua Editor*  
https://sites.google.com/site/gpsnmeajp/tools/flashair_tiny_lua_editer  


### 関数の説明  

関数 | 説明  
--- | ---  
strEUC, ank_cnt=<BR>SlibJfont:sjis2euc(strSJIS) | **Shit-JISコード文字列をEUC-JPコードに変換します**<BR>**strEUC:** EUC文字列<BR>**ank_cnt**: 半角文字単位で数えた文字数<BR>**strSJIS:** Shift-JIS文字列  
strEUC, ank_cnt=<BR>SlibJfont:utf82euc(strUTF8) | **UTF-8コード文字列をEUC-JPコードに変換します**<BR>**strEUC:** EUC文字列<BR>**ank_cnt**: 半角文字単位で数えた文字数<BR>**strUTF8:** UTF-8文字列  
font,mes = SlibJfont:open(fontPath, convTablePath) | **フォントファイルをオープンし、管理情報を取得します**<BR>**font:** フォント管理情報、ファイルオープンに失敗した場合はnil<BR>**mes:** エラーメッセージ<BR>**fontPath:** .sef形式のフォントファイル名<BR>**convTablePath:** " Utf8Euc_jp.tbl"をフルパスで指定、utf82euc()を使用しないときや2回目以降は省略可  
SlibJfont:close(font) | **フォントファイルをクローズします**<BR>**font:** フォント管理情報、省略すると全てクローズ  
SlibJfont:setFont(font1,font2) | **getFont()で使用するフォントを指定します**<BR>**font1:** 半角文字用フォント管理情報、変更しないときは省略可<BR>**font2:** 全角文字用フォント管理情報、変更しないときは省略可  
bitmap, fh, fw, next_p =<BR> SlibJfont:getFont(euc, p) | **指定した文字に対応するビットマップを取得します**<BR>**bitmap:** ビットマップ<BR>**fh:** フォントの高さ<BR>**fw:** フォントの幅<BR>**next_p:** 次の文字の位置<BR>**euc:** EUC-JPコード文字列<BR>**p:** 文字の位置(1～#euc)、省略時は1（先頭）  

### utf82euc()について  
UTF-8コードからEUC-JPコードに変換する関数は、mgo-tecさんの"SD_UTF8toSJIS"をアレンジさせていただきました。  
JIS第一水準、第二水準、１３区、半角カナが変換可能です。  


### サンプルコード  

    sample.lua      -- UTF-8文字列のサンプルプログラム  
    sample_jis.lua  -- Shift-JIS文字列のサンプルプログラム  
    sample_jis.txt  -- Shift-JIS文字列テキスト  

BDFフォントファイル "k6x10.bdf" と "k12x10.bdf" を *3)* から入手して  
font/ の下に置き、bdf2sef.lua の末尾に  

    convBdf2Bin("k6x10.bdf")  
    convBdf2Bin("k12x10.bdf")  

を追加してください。  
bdf2sef.lua を実行すると、"k6x10.sef" と "k12x10.sef" が生成されます。  
.sefファイルがある状態で、sample.lua または、sample_jis.lua を実行すると、  
文字列に対応したバナーが sample_out.txt ファイルに出力されます。  


## Licence  

[MIT](https://github.com/AoiSaya/FlashAir-SlibJFont/blob/master/LICENSE)  

## Author  

[GitHub/AoiSaya](https://github.com/AoiSaya)  
[Twitter ID @La_zlo](https://twitter.com/La_zlo)  

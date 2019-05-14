# Lua library for Japanese FONT handler of FlashAir.

これはFlashAirで日本語フォントを扱うためのライブラリです。  
UTF-8またはEUC-JP文字列に対応するビットマップを取得できます。  
  
【更新履歴】  
(0.01)  

　
UTF-8からEUC-JPに変換する関数を

現バージョンは、BDFフォント(JIS並び)に対応しています。  

## 動作確認済みフォント  
###半角文字  
misaki_4x8_iso8859.bdf  *1  
misaki_4x8_jisx0201.bdf *1  
3x8.bdf    *2  
k6x10.bdf  *3  

###全角文字  
misaki_gothic.bdf *1  
misaki_mincho.bdf *1  
k6x8.bdf   *2  
k12x10.bdf *3  

###入手元  
*1) http://littlelimit.net/misaki.htm  
X11 BDF 形式：misaki_bdf_2012-06-03.tar.gz (210,238 bytes)  
*2) http://z.apps.atjp.jp/k12x10/  
X11 bdf形式 (k12x10bdf.tar.gz, 155Kbyte)  
*3) http://littlelimit.net/k6x8.htm  
X11 BDF形式：k6x8bb02.tar.gz (86,333 bytes)  

http://mplus-fonts.osdn.jp/mplus-bitmap-fonts/download/index.html
http://openlab.ring.gr.jp/efont/shinonome/

##インストール方法  
    lib/SlibJfont.lua  -- ライブラリ
    lib/Utf8Euc_jp.tbl -- UTF-8をEUC-JPに変換する際の変換テーブル
    bdf2sef.lua -- ファイル形式変換プログラム
    sample.lua  -- サンプルプログラム
をFlashAir内の好きな場所においてください。

##使い方  
###事前準備  
アプリ実行時に、BDF形式を直接扱うのは効率が悪いので、事前に  
BDF形式のフォントファイルを独自形式のフォントファイルに変換  
しておきます。  
変換プログラム(bdf2sef.lua)はLuaで書いてありますので、別途  
環境を用意することなくFlashAir内で変換することができます。  
フォントサイズにもよりますが、変換には５分程度かかります。  

###フォント  
サンプルをご参照下さい。

###utf82euc()について
UTF-8コードからEUC-JPコードに変換する関数は、mgo-tecさんの"SD_UTF8toSJIS"をアレンジさせていただきました。
JIS第一水準、第二水準、１３区、半角カナが変換可能です。  

## Install

SlibBME280.lua -- Copy to somewhere in Lua's search path.


## Usage
### Description of the command

command | description
--- | ---
ILI9341:init(type,rotate,xSize,ySize,rOffset,dOffset,gm) | Parameter initialization and reset LCD module.<br>**type:** 1:D3=RST,  2:D3=PIO, 3:D3=LED, 4:with SPI, 21:primaly, 22:secondaly, 23:twin <br> See module connections information.<br>**rotate:** 0:Vertical default, 1:Horizontal default, 2:Vertical reverse, 3:Horizontal reverse<br>**xSize,ySize:** LCD x size, y size<br>**rOffset,dOffset:** RAM address offset<br>**gm:** module GM pad
ILI9341:flip(rFlip,dFlip) | Filp x-axis or y-axis for graphic writing.<br>**rFlip,dFlip:** 0:normal, 1:flip
tbl=ILI9341:duplicate() | Duplicate ILI9341 library, if you use two deferent TFT module of ILI9341 or rotation.<br>**return:** duplicated table of library.
ILI9341:writeStart([flag]) | Enable control.<br>**flag:** 1:primaly, 2:secondly, 3:both<br>default is 2 at TYPE22, 3 at TYPE23, 1 at others.
ILI9341:writeEnd()   | Disable control.
ILI9341:cls()        | Clear screen.
ILI9341:dspOn()      | Display contents of RAM.
ILI9341:dspOff()     | Do not display contents of RAM.
ILI9341:pset(x,y,color) | Plot point at (x,y).
ILI9341:line(x1,y1,x2,y2,color) | Plot line (x1,y1)-(x2,y2).
ILI9341:box(x1,y1,x2,y2,color) | Plot box (x1,y1)-(x2,y2).
ILI9341:boxFill(x1,y1,x2,y2,color) | Plot filled box (x1,y1)-(x2,y2).
ILI9341:circle(x,y,xr,yr,color) | Plot circle of center(x,y), radius(xr,yr).
ILI9341:circleFill(x,y,xr,yr,color) | Plot filled circle of center(x,y), radius(xr,yr).
ILI9341:put(x,y,bitmap) | Put 16bpp bitmap at upper left coordinates with (x,y).
ILI9341:put2(x,y,bitmap)| Put 16bpp flat bitmap faster at upper left coordinates with (x,y).
ILI9341:locate(x,y,mag,color,bgcolor,font) | Locate cursor, set print area(x,y)-(xSize-1,ySize-1), attributions and font.<br>If you do not want to change any arguments you can substitute nil.
x,y=ILI9341:print(str) | Print alphabets and return next cursor position.
x,y=ILI9341:println(str) | Print alphabets, creates a new line and return next cursor position.
ILI9341:ledOn() | LED backlight ON at TYPE2.
ILI9341:ledOff() | LED backlight OFF at TYPE2.
ret=ILI9341:pio(ctrl,data) | PIO control of DAT3 at TYPE3.<br>PIO default is input.<br>**ctrl:** 0:input, 1:output. data: value for output<br>**return:** input value or nil at TYPE1
ILI9341:spiInit(period,mode,bit,cstype)|SPI init for TYPE4.<br>**period,mode,bit:** same as fa.spi(...)<br>**cstype:** 0:low enable, 1:high enable, 2:always High-Z
res = ILI9341:spiWrite(data_num)<br>res = ILI9341:spiWrite(data_str,xfer_num)|SPI write for TYPE4.<br>**data_num,data_str,xfer_num,res:** same as fa.spi("write", ...)
res_num = ILI9341:spiRead()<br>res_tbl = ILI9341:spiRead(xfer_num,data_num)|SPI read for TYPE4.<br>**xfer_num,data_num,res_num,res_tbl:** same as fa.spi("read", ...)


## Sample program

>sample.lua       `-- draw graphics demo`  
>lib/SlibILI9341.lua  
>lib/SlibBMP.lua  `-- Copy from FlashAir-SlibBMP repository`  
>img/balloon01.bmp  
>img/balloon02.bmp  
>font/font74.lua  

These files copy to somewhere in FlashAir.


## Licence

[MIT](https://github.com/AoiSaya/FlashAir-SlibILI9341/blob/master/LICENSE)

## Author

[GitHub/AoiSaya](https://github.com/AoiSaya)  
[Twitter ID @La_zlo](https://twitter.com/La_zlo)

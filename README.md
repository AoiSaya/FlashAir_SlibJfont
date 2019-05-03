# FlashAir_SlibJfont

Lua library for FONT Handring of FlashAir.

## Convert table information
Original idea and convert table by mgo-tec.
https://github.com/mgo-tec/UTF8_to_Shift_JIS

アドレス0xB0 "￠" UTF8= C2A2～、Shift_JIS= 0x8191

アドレス0x1EEC "‐" UTF8= E28090～、Shift_JIS= 0x815D

アドレス0x9DCC スペース UTF8= E38080～、Shift_JIS= 0x8140

アドレス0x11CCC "一" UTF8= E4B880～、Shift_JIS= 0x88EA

アドレス0x12BCC "倅" UTF8= E58085～、Shift_JIS= 0x98E4

アドレス0x1AAC2 "怎" UTF8= E6808E～、Shift_JIS= 0x9C83

アドレス0x229A6 "瀁" UTF8= E78081～、Shift_JIS= 0xE066

アドレス0x2A8A4 "耀" UTF8= E88080～、Shift_JIS= 0x9773

アドレス0x327A4 "退" UTF8= E98080～、Shift_JIS= 0x91DE

アドレス0x3A6A4 "！" UTF8= EFBC81～、Shift_JIS= 0x8149

アドレス0x3A8DE "～" UTF8= EFBD9E、Shift_JIS= 0x8160

半角カナ UTF8= EFBDA1～EFBE9F をASCIIコードに変換。２バイト目はゼロ。


JIS第一水準、第二水準、１３区が変換可能


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

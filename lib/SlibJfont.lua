-----------------------------------------------
-- SoraMame libraly of handling japanese font for FlashAir.
-- Based on Mgo-tec/SD_UTF8toSJIS version 1.21
-- Copyright (c) 2019 AoiSaya
-- Copyright (c) 2016 Mgo-tec
-- Blog URL ---> https://www.mgo-tec.com
-- 2019/08/30 rev.0.15 BUG fix
-----------------------------------------------
local SlibJfont = {
	fontList = {},
	cnvtbl={
		[0xE2] = {0xE28090, 0x01EEC}; --文字"‐" UTF8コード E28090～
		[0xE3] = {0xE38080, 0x09DCC}; --スペース UTF8コード E38080～
		[0xE4] = {0xE4B880, 0x11CCC}; --文字"一" UTF8コード E4B880～
		[0xE5] = {0xE58085, 0x12BCC}; --文字"倅" UTF8コード E58085～
		[0xE6] = {0xE6808E, 0x1AAC2}; --文字"怎" UTF8コード E6808E～
		[0xE7] = {0xE78081, 0x229A6}; --文字"瀁" UTF8コード E78081～
		[0xE8] = {0xE88080, 0x2A8A4}; --文字"耀" UTF8コード E88080～
		[0xE9] = {0xE98080, 0x327A4}; --文字"退" UTF8コード E98080～
	};
}

-- sub functions --
function SlibJfont:script_path()
	local  str = debug.getinfo(2, "S").source:sub(2)
	str = str:match("(.*/)")
	str = str:gsub("/lib/$","/")
	return str
end

--***********UTF-8コードをSD内の変換テーブルを読み出してEUC-JPコードに変換****
function SlibJfont:utf82euc_code_cnv(utf8_1, utf8_2, utf8_3) --return: SD_addrs
	local SD_addrs = 0xA1A1 --スペース

	if utf8_1>=0xC2 and utf8_1<=0xD1 then
		--0xB0からEUC-JPコード実データ。0x00-0xAFまではライセンス文ヘッダ。
		SD_addrs = ((utf8_1*256 + utf8_2)-0xC2A2)*2 + 0xB0 --文字"¢" UTF8コード C2A2～
	elseif utf8_2>=0x80 then
		local UTF8uint = (utf8_1*65536) + (utf8_2*256) + utf8_3

		local tbl = self.cnvtbl[utf8_1]
		if tbl then
			SD_addrs = (UTF8uint-tbl[1])*2 + tbl[2]
		elseif utf8_1>=0xEF and utf8_2>=0xBC then
			SD_addrs = (UTF8uint-0xEFBC81)*2 + 0x3A6A4 --文字"！" UTF8コード EFBC81～
			if utf8_1==0xEF and utf8_2==0xBD and utf8_3==0x9E then
				SD_addrs = 0x3A8DE -- "～" UTF8コード EFBD9E
			end
		end
	end
	return SD_addrs
end

function SlibJfont:utf82euc_Table_Read(ff, addrs) --return: euc1, euc2
	if ff then
		ff:seek("set", addrs)
		return (ff:read(2)):byte(1,2)
	else
		return " SlibJfont file has not been uploaded to the flash in SD file system"
	end
end

-- public functions --
--***********Shit-JISコード文字列をEUC-JPコードに変換************************************
function SlibJfont:sjis2euc(strSJIS) -- return strEUC, euc_length
	local str_length = strSJIS:len()
	local fnt_cnt = 1
	local euc_cnt = 1
	local ank_cnt = 0
	local SJIS1, SJIS2, EUC1, EUC2, strEUC
	local euc_byte = {}

	strEUC=""

	while fnt_cnt<=str_length do
		SJIS1 = strSJIS:byte(fnt_cnt)
		fnt_cnt = fnt_cnt + 1

		if SJIS1<0x80 then -- 1バイト文字
			euc_byte[euc_cnt] = SJIS1
			euc_cnt	= euc_cnt + 1
			ank_cnt = ank_cnt + 1
		elseif SJIS1>=0xA1 and SJIS1<=0xDF then -- 半角カナ
			euc_byte[euc_cnt]	= 0x8E
			euc_byte[euc_cnt+1] = SJIS1
			euc_cnt	= euc_cnt + 2
			ank_cnt = ank_cnt + 1
		else -- 2バイト文字
			SJIS2 = strSJIS:byte(fnt_cnt)
			fnt_cnt = fnt_cnt + 1
			if SJIS1>=0xE0 then SJIS1 = SJIS1-0x40 end
			if SJIS2>=0x80 then SJIS2 = SJIS2-1 end
			EUC1 = (SJIS1-0x70)*2+0x80
			EUC2 = SJIS2+3
			if SJIS2<0x9E then
				EUC1 = EUC1-1
				EUC2 = EUC2+0x5E
			end
			euc_byte[euc_cnt]	= EUC1
			euc_byte[euc_cnt+1] = EUC2
			euc_cnt	= euc_cnt + 2
			ank_cnt = ank_cnt + 2
		end
		if euc_cnt>500 then
			strEUC	 = strEUC .. string.char(unpack(euc_byte))
			euc_byte = {}
			euc_cnt  = 1
		end
		sleep(0)
	end
	if euc_cnt>1 then
		strEUC = strEUC .. string.char(unpack(euc_byte))
	end
	euc_byte = nil
	collectgarbage()
	return strEUC, ank_cnt
end

--***********UTF-8コード文字列をEUC-JPコードに変換************************************
function SlibJfont:utf82euc(strUTF8) -- return strEUC, euc_length
	local str_length = strUTF8:len()
	local fp_table
	local fnt_cnt = 1
	local euc_cnt = 1
	local ank_cnt = 0
	local utf8_byte
	local sp_addres = 0xA1A1 --スペース
	local EUC1, EUC2, strEUC
	local euc_byte = {}

--	local UTF8EUC_file = "Utf8Euc.tbl"
--	local fp_table = io.open(UTF8EUC_file, "rb")

	fp_table = self.fp
	if fp_table==nil then
		return nil
	end

	strEUC=""

	while fnt_cnt<=str_length do
		utf8_byte = strUTF8:byte(fnt_cnt)
		if utf8_byte>=0xC2 and utf8_byte<=0xD1 then --2バイト文字
			sp_addres = self:utf82euc_code_cnv(strUTF8:byte(fnt_cnt,fnt_cnt+1))
			EUC1, EUC2 = self:utf82euc_Table_Read(fp_table, sp_addres)
			euc_byte[euc_cnt]	= EUC1
			euc_byte[euc_cnt+1] = EUC2
			euc_cnt	= euc_cnt + 2
			fnt_cnt = fnt_cnt + 2
			ank_cnt = ank_cnt + 2
		elseif utf8_byte>=0xE2 and utf8_byte<=0xEF then
			sp_addres = self:utf82euc_code_cnv(strUTF8:byte(fnt_cnt,fnt_cnt+2))
			EUC1, EUC2 = self:utf82euc_Table_Read(fp_table, sp_addres)
			euc_byte[euc_cnt]	= EUC1
			euc_byte[euc_cnt+1] = EUC2
			euc_cnt	= euc_cnt + 2
			fnt_cnt = fnt_cnt + 3
			ank_cnt = ank_cnt + 2
			if EUC1==0x8E then --EUC-JPで半角カナコードが返ってきた場合の対処
				ank_cnt = ank_cnt - 1
			end
		elseif utf8_byte>=0x20 and utf8_byte<=0x7E then
			euc_byte[euc_cnt] = utf8_byte
			euc_cnt	= euc_cnt + 1
			fnt_cnt = fnt_cnt + 1
			ank_cnt = ank_cnt + 1
		else --その他は全て半角スペースとする。
			euc_byte[euc_cnt] = 0x20
			euc_cnt	= euc_cnt + 1
			fnt_cnt = fnt_cnt + 1
			ank_cnt = ank_cnt + 1
		end
		if euc_cnt>500 then
			strEUC	 = strEUC .. string.char(unpack(euc_byte))
			euc_byte = {}
			euc_cnt  = 1
		end
		sleep(0)
	end
	if euc_cnt>1 then
		strEUC = strEUC .. string.char(unpack(euc_byte))
	end
	euc_byte = nil
	collectgarbage()
	return strEUC, ank_cnt
end

function SlibJfont:open(fontPath, convTablePath)
	local fp, header, ofs
	local font={}
	local curPath = self:script_path()

	if not self.fp and not convTablePath then
		convTablePath = "Utf8Euc_jp.tbl"
	end
	if convTablePath then
		fp = io.open(convTablePath, "rb")
		if not fp then
			fp = io.open(curPath..convTablePath, "rb")
			if not fp then
				fp = io.open(curPath.."lib/"..convTablePath, "rb")
				if not fp then
					return nil, "Can't open table file!"
				end
			end
		end
		self.fp = fp
	end

	if not fontPath then
		return nil
	end

	fp = io.open(fontPath, "rb")
	if not fp then
		fp = io.open(curPath.."font/"..fontPath, "rb")
		if not fp then
			return nil, "Can't open font file!"
		end
	end
	header = fp:read(64)
	if header:sub(1,3)~="SEF" then
		return nil, "Not FONT.SLF format file!"
	end

	font.fp 	= fp
	font.getFont= self.getFont
	font.format= header:sub(1,3)
	font.hsize = tonumber(header:sub( 4, 6),16)
	font.rev   = tonumber(header:sub( 7, 8),16)
	font.width = tonumber(header:sub( 9,10),16)
	font.height= tonumber(header:sub(11,12),16)
	font.size  = tonumber(header:sub(13,15),16)
	font.ofs   = tonumber(header:sub(16,19),16)
	font.aofs  = font.ofs
	if font.ofs<0x100 then
		font.ofs  = 0xA1A1-0x300
	end
	font.hnum  = math.floor((font.height+3)/4)
	ofs = 0x20	-font.aofs
	font.aspos = (bit32.extract(ofs,8,8)*0x5E+bit32.band(ofs,0xFF))*font.size+font.hsize
	ofs = 0xA1A1-font.ofs
	font.spos = (bit32.extract(ofs,8,8)*0x5E+bit32.band(ofs,0xFF))*font.size+font.hsize

	table.insert(self.fontList,font)
	collectgarbage()
	return font
end

function SlibJfont:close(font)
	if font then
		if self.fp then self.fp:close() end
		for key,v in pairs(self.fontList) do
			if font==v then
				table.remove(self.fontList,key)
				break
			end
		end
		font = nil
	else
		if self.fp then self.fp:close() end
		for key,font in pairs(self.fontList) do
			font.fp:close()
			font = nil
		end
		self.fontList = {}
	end
	collectgarbage()
end

function SlibJfont:setFont(font1,font2,font3,font4) -- Hankaku,Zenkaku,Zenkaku-kana,Zenkaku-ank
	local ofs

	if font1 then
		self.font1 = font1
	end
	if font2 then
		self.font2 = font2
	end
	if font3 then
		self.font3 = font3
	end
	if font4 then
		self.font4 = font4
	end
end

function SlibJfont:getFont(euc, p)
	local p = p or 1
	local c, d, font, ank, data
	local fp, hnum, fh, ofs, pos, fw
	local bitmap = {}

	c,d = euc:byte(p,p+1)
	if c>0x8E then
		c = c*256+d
		p = p+2
		font = self.font2

		if self.font4 and c<0x30 then -- 全角記号
			font = self.font4
		end
		if self.font3 and 0x24<=c and c<26 then -- 全角ひらがな＋カタカナ
			font = self.font3
		end
		ofs = c-font.ofs
	else -- 半角コード
		if c==0x8E then -- 半角カナコード
		ofs = c-font.ofs
			c = d
			p = p+1
		end
		p = p+1
		font = self.font1
		ofs = c-font.aofs
		ank = 1
	end

	fp	 = font.fp
	hnum = font.hnum
	fh	 = font.height
	if fp then
		pos = (bit32.extract(ofs,8,8)*0x5E+bit32.band(ofs,0xFF))*font.size+font.hsize
		fp:seek("set", pos)
		data = fp:read(2)
		if not data or ofs<0 then
			fp:seek("set", ank and font.aspos or font.spos )
			data = fp:read(2)
		end
		fw = tonumber(data,16)
		for i=1,fw do
			bitmap[i] = tonumber(fp:read(hnum),16)
		end
	else
		c = ank and string.char(c) or c
		bitmap, fw = font[c], font.width
		if not bitmap then
			bitmap, fw = font[ank and " " or 0xA1A1], font.width
		end
	end

	return bitmap, fh, fw, p
end

collectgarbage()
return SlibJfont

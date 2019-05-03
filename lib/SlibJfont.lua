-----------------------------------------------
-- SoraMame libraly of handling japanese font for FlashAir.
-- Based on Mgo-tec/SD_UTF8toSJIS version 1.21
-- Copyright (c) 2019 AoiSaya
-- Copyright (c) 2016 Mgo-tec
-- Blog URL ---> https://www.mgo-tec.com
-- 2019/05/03 rev.0.05
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
--***********UTF-8コード文字列をEUC-JPコードに変換************************************
function SlibJfont:utf82euc(strUTF8) -- return strEUC, euc_length
	local euc_cnt = 1
	local fnt_cnt = 1
	local ank_cnt = 0
	local sp_addres = 0xA1A1 --スペース
	local EUC1, EUC2, strEUC
	local fp_table
	local utf8_byte
	local euc_byte = {}
	local str_length = strUTF8:len()

--	local UTF8EUC_file = "Utf8Euc.tbl"
--	local fp_table = io.open(UTF8EUC_file, "rb")

	fp_table = self.fp
	if fp_table==nil then
		return nil
	end

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
			if EUC1==0x8E then --EUC-JPで半角カナコードが返ってきた場合の対処
				ank_cnt = ank_cnt + 1
			else
				ank_cnt = ank_cnt + 2
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
		sleep(0)
	end
	strEUC = string.char(unpack(euc_byte))
	euc_byte = nil
	collectgarbage()
	return strEUC, ank_cnt
end

function SlibJfont:open(fontPath, convTablePath)
	local fp,header
	local font={}

	if convTablePath then
		fp = io.open(convTablePath, "rb")
		self.fp = fp
	end

	fp = io.open(fontPath, "rb")
	if not fp then
		return nil, "Can't open file!"
	end
	header = fp:read(64)
	if header:sub(1,3)~="SEF" then
		return nil, "Not FONT.SLF format file!"
	end

	font.fp = fp
	font.getFont= self.getFont
	font.format= header:sub(1,3)
	font.hsize = tonumber(header:sub( 4, 6),16)
	font.rev   = tonumber(header:sub( 7, 8),16)
	font.width = tonumber(header:sub( 9,10),16)
	font.height= tonumber(header:sub(11,12),16)
	font.size  = tonumber(header:sub(13,15),16)
	font.ofs   = tonumber(header:sub(16,19),16)
	font.hnum  = math.floor((font.height+3)/4)

	table.insert(self.fontList,font)
	collectgarbage()
	return font
end

function SlibJfont:close(font)
	if font then
		font.fp:close()
		font = nil
	else
		self.fp:close()
		for key,font in pairs(self.fontList) do
			font.fp:close()
			font = nil
		end
	end
	collectgarbage()

	return "OK"
end

function SlibJfont:setFont(font1,font2)
	if font1 then
		self.font1 = font1
	end
	if font2 then
		self.font2 = font2
	end
end

function SlibJfont:getFont(euc, p)
	local p = p or 1
	local bitmap={}
	local c, d, font, ank
	local fp, hnum, ofs, pos, fh, fw

	c,d = euc:byte(p,p+1)
	if c>0x8E then
		c = c*256+d
		p = p+2
		font = self.font2
	else
		if c==0x8E then
			c = d
			p = p+1
		end
		p = p+1
		font = self.font1
		ank = 1
	end

    fp   = font.fp
	hnum = font.hnum
	fh = font.height
	if fp then
		ofs = c-font.ofs
		pos = (bit32.extract(ofs,8,8)*0x5E+bit32.band(ofs,0xFF))*font.size+font.hsize

		fp:seek("set", pos)
		fw = tonumber(fp:read(2),16)
        for i=1,fw do
			bitmap[i] = tonumber(fp:read(hnum),16)
		end
	else
		c = ank and string.char(c) or c
		bitmap, fw = self.font[c], font.width
	end

	return bitmap, fh, fw, p
end

collectgarbage()
return SlibJfont

-------------------------------------------------------
-- bdf2sef.lua for FlashAir W4.00.03
-- *.SEF(Saya Euc Font format) is original format based on EUC
-- 2019/08/01 rev.0.8
-------------------------------------------------------
function chkBreak(n)
	sleep(n or 0)
	if fa.sharedmemory("read", 0x00, 0x01, "") == "!" then
		error("Break!",2)
	end
end
function putMessage(msg)
	fa.sharedmemory("write", 0x01, 0xFE, msg)
end

fa.sharedmemory("write", 0x00, 0x01, "-")

function script_path()
	local  str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
end

function getData(sfh,format,base)
	local buf, v, ret
	while 1 do
		buf = sfh:read("*l")
		v = {buf:match(format)}
		if v[1] then break end
		chkBreak()
	end
	if base then
		ret ={}
		for i=1,#v do
			ret[i] = tonumber(v[i],base)
		end
	else
		ret = v
	end

	return table.unpack(ret)
end

function getCharTbl(sfh,chars)
	local	curDir, parDir, JfontName, pathTbl, func, jfont
	local	charTbl={}
	local	t, num, unicode, uni_1, uni_2, uni_3, utf8, euc, euc_1, euc_2, char, pos
	local	ratio = 0
	local	bx = bit32.extract
	local	sc = string.char

	curDir = script_path()
	parDir = curDir:match("(.*/).*/")
	JfontName = "SlibJfont.lua"
	pathTbl   = {curDir 	   ..JfontName,
				 parDir 	   ..JfontName,
				 parDir.."lib/"..JfontName
				}
	for i=1, #pathTbl do
		func = loadfile(pathTbl[i])
		if func then
			break
		end
	end
	if not func then
		return nil, "Can't open "..JfontName
	end
	jfont = func()
	jfont:open()

	collectgarbage()
	t = os.clock()
	num = 0
	for i=1, chars do
--	  for i=1, 300 do
		chkBreak()
		unicode  = getData(sfh, "^ENCODING%s+(%w+)",10)
		if unicode<0x80 then
			euc  = sc(unicode)
		elseif unicode<0x800 then
			uni_1, uni_2 = bx(unicode,6,5),bx(unicode,0,6)
			utf8 = sc(uni_1+0xC0, uni_2+0x80)
			euc  = jfont:utf82euc(utf8)
		elseif unicode<0x10000 then
			uni_1, uni_2, uni_3 = bx(unicode,12,4),bx(unicode,6,6),bx(unicode,0,6)
			utf8 = sc(uni_1+0xE0, uni_2+0x80, uni_3+0x80)
			euc  = jfont:utf82euc(utf8)
		else
			euc  = " "
		end
		euc_1, euc_2 = string.byte(euc,1,#euc)
		if euc_1>0 then
			num = num+1
			if euc_2 then
				char = (euc_1-0x80)*0x80+euc_2-0x80
			else
				char = euc_1
			end
			pos = math.floor(sfh:seek()/16)
			charTbl[num] = char*131072+pos
		end
		if ratio*chars <= i*100 then
			collectgarbage()
			left = math.ceil((os.clock()-t)*(100-ratio)/ratio)
			putMessage("ISO10646 to JIS converting. : "..ratio.."%, Time remaining: About "..left.." seconds")
			ratio = ratio+1
		end
	end
	jfont:close()
	jfont = nil
	func  = nil
	collectgarbage()
	table.sort(charTbl)

	return charTbl, num
end

function convBdf2Bin(srcFname,dstFname)
	local sfh, Fname, mes, dfh
	local bbw, bbh, box, boy
	local encode, chars, ndeg, sz, blank, header_size
	local t, char, char_base, char_next, num
	local buf, charL, dwidth, bin, u, bm, d, left
	local fbw, fbh, fox, foy
	local head = "SEF"
	local rev = 4
	local ratio = 1
	local ba = bit32.band
	local bx = bit32.extract

	sfh = io.open(srcFname,"r")
	if not sfh then
		Fname = script_path()..srcFname
		sfh = io.open(Fname,"r")
		if not sfh then
			mes = "Can't open "..'"'..srcFname..'".'
			putMessage(mes)
			return nil, mes
		end
		srcFname = Fname
	end

	if not dstFname then
		dstFname = srcFname:gsub("[^\\.]*$","sef",1)
	end
	dfh = io.open(dstFname,"wb")
	if not dfh then
		sfh:close()
		mes = "Can't open "..'"'..dstFname..'".'
		putMessage(mes)
		return nil, mes
	end

	bbw, bbh, box, boy = getData(sfh, "^FONTBOUNDINGBOX%s+(%w+)%s+(%w+)%s+(-?%w+)%s+(-?%w+)",10)
	encode = getData(sfh, '^CHARSET_REGISTRY%s+"(.+)"')
	chars  = getData(sfh, "^CHARS%s+(%w+)",10)
	ndeg   = bx(bbh+3,2,30)
	sz	   = ndeg * bbw + 3
	blank  = string.format("%02X",bbw)..string.rep("0", sz-3) .. "\n"
	header_size = 64
	isUnicode = (encode=="ISO10646")

	if isUnicode then
		charTbl, num = getCharTbl(sfh,chars)
	else
		num = chars
	end

	collectgarbage()
	t = os.clock()
	bin = {}
	for i=1, num do
		chkBreak()
		if isUnicode then
			d = charTbl[i]
			char = bx(d,24,7)*0x100 + bx(d,17,7)
			sfh:seek("set",bx(d,0,17)*16)
			collectgarbage()
		else
			char = getData(sfh, "^ENCODING%s+(%w+)",10)
		end
		if i==1 then
			if char<0x100 then
				char_base = char
			else
				char_base = 0xA1A1
			end
			char_next = char_base
			buf = string.format(head.."%3X%2X%2X%2X%3X%4X\n",header_size,rev,bbw,bbh,sz,char_base)
			dfh:write(buf)
			buf = string.rep(" ", header_size-#buf-1).."\n"
			dfh:write(buf)
			buf = nil
			collectgarbage()
		end
		if char<0x100 then
			char = char
		elseif char<0x0F00 then
			char = char-0x0D80
		else
			char = char+0x8080
		end
		if char>char_next then
			if char_next<0x100 and char>=0x100 then
				for j=char_next, 0x5E*3+char_base-1 do
					dfh:write(blank)
				end
				char_next = 0xA1A1
			end
			for j=char_next, char-1 do
				charL = ba(j,0x00FF)
				if char<0x100 or (0xA1<=charL and charL<=0xFE) then
					dfh:write(blank)
				end
			end
			char_next = char
		end
		if char==char_next then
			char_next = char_next+1

			dwidth	= getData(sfh, "^DWIDTH (%w+)",10)
			fbw, fbh, fox, foy = getData(sfh, "^BBX%s+(%w+)%s+(%w+)%s+(-?%w+)%s+(-?%w+)",10)
			getData(sfh, "^BITMAP")
			for k=1, bbw do
				bin[k] = 0
			end
			u = 2^(bbh+boy-(fbh+foy))
			bm = ba(fbw+7,0xFFFFFFF8)
			for j= 1, fbh do
				d = getData(sfh, "(%w+)",16)
				for k=1, fbw do
					bin[k+fox] = bin[k+fox]+bx(d,bm-k)*u
				end
				u = u+u
			end
			dfh:write(string.format("%02X",dwidth))
			for k=1, bbw do
				dfh:write(string.format("%0"..ndeg.."X",bin[k]))
			end
			dfh:write("\n")
--			dfh:write(string.format(" %04X %s\n",char,string.char(bx(char,8,8),bx(char,0,8))))
		end
		if ratio*num <= i*100 then
			collectgarbage()
			left = math.ceil((os.clock()-t)*(100-ratio)/ratio)
			putMessage('"'..dstFname:match("[^/]*$")..'": '..ratio.."%, Time remaining: About "..left.." seconds")
			ratio = ratio+1
		end
	end
	putMessage('"'..dstFname:match("[^/]*$")..'": Completed')

	sfh:close()
	dfh:close()

	collectgarbage()
	return "OK"
end

-- main ----------------------------------------------------------------

--[[
convBdf2Bin("misaki_4x8_iso8859.bdf")
convBdf2Bin("misaki_4x8_jisx0201.bdf")
convBdf2Bin("misaki_mincho.bdf")
convBdf2Bin("misaki_gothic.bdf")
convBdf2Bin("misaki_gothic_2nd.bdf")
convBdf2Bin("k6x8.bdf")
convBdf2Bin("k6x10.bdf")
convBdf2Bin("k12x10.bdf")
convBdf2Bin("3x8.bdf")
convBdf2Bin("shnmk12p.bdf")
convBdf2Bin("mplus_q06r.bdf")
--]]

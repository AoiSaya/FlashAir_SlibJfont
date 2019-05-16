-------------------------------------------------------
-- bdf2sef.lua for FlashAir W4.00.03
-- *.SEF(Saya Euc Font format) is original format based on EUC
-- 2019/05/16 rev.0.6
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
	ret ={}
	for i=1,#v do
		ret[i] = tonumber(v[i],base)
	end
	return table.unpack(ret)
end

function convBdf2Bin(srcFname,dstFname)
	local sfh, dfh
	local bbw, bbh, box, boy, ndeg, sz, blank, chars, charL
	local char, char_next, char_base, buf, bin, d, u
	local dwidth, fbw, fbh, fox, foy
	local head = "SEF"
	local rev = 3
	local ba = bit32.band
	local bx = bit32.extract
	local ratio = 0
	local left, mes, Fname

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
	chars  = getData(sfh, "^CHARS%s+(%w+)",10)
	ndeg   = bx(bbh+3,2,30)
	sz	   = ndeg * bbw + 3
	blank  = string.format("%02X",bbw)..string.rep("0", sz-3) .. "\n"
	header_size = 64

	t = os.clock()
	for i=1, chars do
		chkBreak()
		collectgarbage()
		char  = getData(sfh, "^ENCODING%s+(%w+)",10)
		if i==1 then
			if char<0x100 then
				byte = 1
				char_base = char
			else
				byte = 2
				char_base = ba(char,0xFF00)+0x0021+0x8080
			end
			char_next = char_base
			buf = string.format(head.."%3X%2X%2X%2X%3X%4X\n",header_size,rev,bbw,bbh,sz,char_base)
			dfh:write(buf)
			buf = string.rep(" ", header_size-#buf-1).."\n"
			dfh:write(buf)
		end
		if byte==2 then
			char = char+0x8080
		end
		if char~=char_next then
			for j=char_next, char-1 do
				charL = ba(j,0x00FF)
				if byte==1 or (byte==2 and 0xA1<=charL and charL<=0xFE) then
					dfh:write(blank)
				end
			end
		end
		char_next = char+1

		dwidth	= getData(sfh, "^DWIDTH (%w+)",10)
		fbw, fbh, fox, foy = getData(sfh, "^BBX%s+(%w+)%s+(%w+)%s+(-?%w+)%s+(-?%w+)",10)
		getData(sfh, "^BITMAP")
		bin = {}
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
		if ratio <= i*100/chars then
			left = math.ceil((os.clock()-t)*(100-ratio)/ratio)
			putMessage('"'..dstFname:match("[^/]*$")..'": '..ratio.."%, Time remaining: About "..left.." seconds")
			ratio = ratio+1
		end
	end

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
convBdf2Bin("k6x8.bdf")
convBdf2Bin("k6x10.bdf")
convBdf2Bin("k12x10.bdf")
convBdf2Bin("3x8.bdf")
convBdf2Bin("shnmk12p.bdf")
convBdf2Bin("mplus_q06r.bdf")
--]]

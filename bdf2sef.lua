-------------------------------------------------------
-- bdf2sef.lua for FlashAir W4.00.03
-- *.SEF(Saya Euc Font format) is original format based on EUC
-- 2018/11/28 rev.0.2
-------------------------------------------------------
function chkBreak(n)
	sleep(n or 0)
	if fa.sharedmemory("read", 0x00, 0x01, "") == "!" then
		error("Break!",2)
	end
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

function idiv(num,dev)
	return (num-num%dev)/dev,num%dev
end

function convBdf2Sef(srcFname,dstFname,byte)
	local sfh, dfh
	local bw, bh, ox, oy, ndeg, sz, blank, chars, charL
	local char, char_next, char_base, buf, bin, d, u
	local dwidth, fbw, fbh, fox, foy
	local head = "SEF"
	local rev = 2

	sfh = io.open(srcFname,"r")
	if not sfh then
		return nil, "Can't open "..'"'..srcFname..'".'
	end
	dfh = io.open(dstFname,"wb")
	if not dfh then
		sfh:close()
		return nil, "Can't open "..'"'..dstFname..'".'
	end

	bw, bh, ox, oy = getData(sfh, "^FONTBOUNDINGBOX (%w+) (%w+) (-?%w+) (-?%w+)",10)
	chars  = getData(sfh, "^CHARS (%w+)",10)
	bm	   = idiv(bw+7,8) * 8
	ndeg   = idiv(bh+3,4)
	sz	   = ndeg * bw + 3
	blank  = string.format("%02X",bw)..string.rep("0", sz-3) .. "\n"
	if rev==0 then
		sz = sz + 4
	end
	char_base = (byte==1) and 0x20 or 0x2121+0x8080
	char_next = char_base
	header_size = 64

	buf = string.format(head.."%3X%2X%2X%2X%3X%4X\n",header_size,rev,bw,bh,sz,char_base)
	dfh:write(buf)
	buf = string.rep(" ", header_size-#buf-1).."\n"
	dfh:write(buf)

	for i=1, chars do
--	for i=1, 100 do
		chkBreak()
		collectgarbage()
		char  = getData(sfh, "^STARTCHAR (%w+)",16)
		if byte==2 then
			char = char+0x8080
		end
		if char~=char_next then
			for j=char_next, char-1 do
				charL = j % 256
				if byte==1 or (byte==2 and 0xA1<=charL and charL<=0xFE) then
					if rev==0 then
						dfh:write(string.format("%4X",j))
					end
					dfh:write(blank)
				end
			end
		end
		char_next = char+1

		dwidth	= getData(sfh, "^DWIDTH (%w+)",10)
		fbw, fbh, fox, foy = getData(sfh, "^BBX (%w+) (%w+) (-?%w+) (-?%w+)",10)
		getData(sfh, "^BITMAP")
		bin = {}
		for k=1, bw do
			bin[k] = 0
		end
		for j= 1, bh do
			d = getData(sfh, "(%w+)",16)
			u = 2^(j-1)
			for k=1, bw do
				bin[k]=bin[k]+bit32.extract(d,bm-k)*u
			end
		end
		if rev==0 then
			dfh:write(string.format("%4X",char))
		end
		dfh:write(string.format("%02X",fbw))
		for k=1, bw do
			dfh:write(string.format("%0"..ndeg.."X",bin[k]))
		end
		dfh:write("\n")
	end

	sfh:close()
	dfh:close()
end


local myDir  = script_path()
--[[
local srcFname = myDir .. "misaki_4x8_iso8859.bdf"
local dstFname = myDir .. "misaki_4x8_iso8859.sef"
convBdf2Sef(srcFname,dstFname,1)
--]]
--[[
local srcFname = myDir .. "misaki_4x8_jisx0201.bdf"
local dstFname = myDir .. "misaki_4x8_jisx0201.sef"
convBdf2Sef(srcFname,dstFname,1)
--]]
--[[
local srcFname = myDir .. "misaki_gothic.bdf"
local dstFname = myDir .. "misaki_gothic.sef"
convBdf2Sef(srcFname,dstFname,2)
--]]
--[[
local srcFname = myDir .. "misaki_mincho.bdf"
local dstFname = myDir .. "misaki_mincho.sef"
convBdf2Sef(srcFname,dstFname,2)
--]]
---[[
local srcFname = myDir .. "k6x8.bdf"
local dstFname = myDir .. "k6x8.sef"
convBdf2Sef(srcFname,dstFname,2)
--]]
--[[
local srcFname = myDir .. "k6x10.bdf"
local dstFname = myDir .. "k6x10.sef"
convBdf2Sef(srcFname,dstFname,1)
--]]
--[[
local srcFname = myDir .. "k12x10.bdf"
local dstFname = myDir .. "k12x10.sef"
convBdf2Sef(srcFname,dstFname,2)
--]]

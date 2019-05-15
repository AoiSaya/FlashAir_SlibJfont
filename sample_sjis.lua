-----------------------------------------------
-- Sample of SlibJfont.lua for W4.00.03
-- Copyright (c) 2019, Saya
-- All rights reserved.
-- 2019/05/15 rev.0.02
-----------------------------------------------
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

-- main
local myDir  = script_path()
local libDir = myDir.."lib/"
local fontDir= myDir.."font/"
local jfont  = require(libDir .. "SlibJfont")
local k12x10 = jfont:open(fontDir .. "k12x10.sef")
local k6x10  = jfont:open(fontDir .. "k6x10.sef")

local SJIS_file = "sample_sjis.txt"
local EUC_file = "sample_out.txt"
local fpr = io.open(myDir..SJIS_file, "r")
local fpw = io.open(myDir..EUC_file, "w")
local strSJIS, strEUC, euc_length
local bitmap, fh, fw, s, p, kmax
local be = bit32.extract

jfont:setFont(k6x10,k12x10)

kmax = jfont.font2.height

while 1 do
	strSJIS = fpr:read("*l")
	if not strSJIS then break end

	strEUC, euc_length = jfont:sjis2euc(strSJIS)
	s = {}
	for k=1, kmax do
		s[k] = ""
	end
	p=1
	while p<=#strEUC do
		bitmap,fh,fw,p = jfont:getFont(strEUC, p)
		for j=1, fw do
			for k=1, kmax do
				s[k] = s[k] .. ((be(bitmap[j],k-1)>0) and "@" or ".")
			end
		end
	end
	for k=1, kmax do
		fpw:write(s[k], "\n")
	end
	fpw:write("\n")
	chkBreak()
	collectgarbage()
end

fpr:close()
fpw:close()
jfont:close()
return

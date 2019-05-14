-----------------------------------------------
-- Sample of SlibJfont.lua for W4.00.03
-- Copyright (c) 2019, Saya
-- All rights reserved.
-- 2019/05/02 rev.0.01
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
local shnmk12p = jfont:open(fontDir .. "shnmk12p.sef")
local k6x10  = jfont:open(fontDir .. "k6x10.sef")
local mplus_q06r  = jfont:open(fontDir .. "mplus_q06r.sef")
local str={
  "‚t‚s‚e‚W¨‚d‚t‚b@‘SŠp“ú–{ŒêŠ¿š•ÏŠ·ƒeƒXƒg•\",
  "ABV‘]@ˆê˜äœƒàf—s‘ŞIê¤`",
  "¦§ËÌôƒ¶ƒ¿ƒÀƒÁƒÆƒÎƒÓœ›Ÿ¡ š™", --‚æ‚­g‚í‚ê‚é‹L†
  "‡@‡A‡B‡C‡D‡E‡F‡G‡H‡I‡J‡K‡L‡M‡N‡O‡P‡Q‡R‡S‡T‡U‡V‡W‡X‡Y‡Z‡[‡\‡]", --JIS ‚P‚R‹æ•¶š
  "‡_‡`‡a‡b‡c‡d‡e‡f‡g‡h‡i‡j‡k‡l‡m‡n‡o‡p‡q‡r‡s‡t‡u‡€‡‡‚‡ƒ‡„", --JIS ‚P‚R‹æ•¶š
  "‡…‡†‡‡‡ˆ‡‰‡Š‡‹‡Œ‡‡‡‡~‡“‡”‡˜‡™¾¿ÚÛßàãæç", --JIS ‚P‚R‹æ•¶š
  "”¼Šp/ABC ‘SŠp/‚`‚a‚b@”¼ŠpƒJƒi/±¶»ÀÅÜ¦İ ¶ŞÊß §¨©ª«¬­®"
}

local EUC_file = "sample_out.txt"
local fhw = io.open(myDir..EUC_file, "w")
local strUTF8, strEUC, euc_length
local bitmap, fh, fw, s, p, kmax
local be = bit32.extract

--jfont:setFont(k6x10,k12x10)
jfont:setFont(mplus_q06r,shnmk12p)

kmax = jfont.font2.height

for key,strSJIS in ipairs(str) do
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
		fhw:write(s[k], "\n")
	end
	fhw:write("\n")
	chkBreak()
	collectgarbage()
end

fhw:close()
jfont:close()
return

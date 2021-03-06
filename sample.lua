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
local jfont  = require(libDir .. "SlibJfont")
local k12x10 = jfont:open("k12x10.sef")
local k6x10  = jfont:open("k6x10.sef")
local str={
  "ＵＴＦ８→ＥＵＣ　全角日本語漢字変換テスト表",
  "、。〃¢‐　一倅怎瀁耀退！￥熙～",
  "※〒℃⇒⇔♪Ωαβγθπφ●○◎◆◇■□★☆", --よく使われる記号
  "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ", --JIS １３区文字
  "㍉㌔㌢㍍㌘㌧㌃㌶㍑㍗㌍㌦㌣㌫㍊㌻㎜㎝㎞㎎㎏㏄㎡〝〟№㏍℡", --JIS １３区文字
  "㊤㊥㊦㊧㊨㈱㈲㈹㍾㍽㍼㍻∮∑∟⊿∪∩∠⊥≡≒√∵∫", --JIS １３区文字
  "半角/ABC 全角/ＡＢＣ　半角カナ/ｱｶｻﾀﾅﾜｦﾝ ｶﾞﾊﾟ ｧｨｩｪｫｬｭｮ"
}

local EUC_file = "sample_out.txt"
local fpw = io.open(myDir..EUC_file, "w")
local strUTF8, strEUC, euc_length
local bitmap, fh, fw, s, p, kmax
local be = bit32.extract

jfont:setFont(k6x10,k12x10)

kmax = jfont.font2.height

for key,strUTF8 in ipairs(str) do
	strEUC, euc_length = jfont:utf82euc(strUTF8)
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

fpw:close()
jfont:close()
return

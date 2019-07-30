local GenerateCode;

do
	local alphabet = "abcdefijklmnopqrstuvwxyz"
	local letters = {}
	alphabet:gsub(".", function(...) table.insert(letters, ...) end)

	local function GenCode(length)
		local str = ''
		for i = 1, length do
			str = str .. letters[math.random(1, #letters)]
		end
		return str
	end

	local GenSerial;
	function GenSerial(codes)
		local tab = {GenCode(8), GenCode(8), GenCode(8)}
		local Code = table.concat(tab, "_")
		
		if codes[Code] then
			return GenSerial()
		end

		codes[Code] = true
		return Code
	end

	GenerateCode = GenSerial
end

local plex, lex = unpack(require("serializer"))

local function str2byte(str, offset)
	offset = offset or 5
	str = str:gsub(".", function(...) return string.byte(...) + offset .. "\\\\" end)
	str = str:sub(0, -3)
	return str
end
local function byte2str(hexs, offset)
	offset = offset or 5
	local s = "" hexs:gsub("%d[%d-]%d", function(t) s=s..string.char(t - offset) end)
	return s
end


local function obsfusticate(code)
	local Codes = {}
	local proxies = {}
	local data, easyget, instrings = lex(code)
	table.sort(data, function(a, b) return a[2] < b[2] end)

	local function genserial()
		return GenerateCode(Codes)
	end
	local False, True = genserial(), genserial()
	local NewCode = ""

	local b2s = genserial()
	local getf = genserial()

	local bytecodeOffset = os.time()%6

	local function newline()
		NewCode = NewCode .. "\n"
	end
	local function addon(str)
		NewCode = NewCode .. str .. ";"
	end

	addon([[function ]]..b2s..[[(...)local s = "" (...):gsub("%d+", function(t) s=s..string.char(t - ]]..bytecodeOffset..[[) end)return s end]])
	newline()
	addon([[]]..getf..[[ = setmetatable({}, {__index = function(_, i) return getfenv()[]]..b2s..[[(i)] end,__newindex = function(s, i, v)getfenv()[]]..b2s..[[(i)] = v end})]])
	newline()

	local n = 0
	local addGlobals = {}
	for _, b in next, data do
		if b[3] == "KEYWORD" and not instrings[b[2]] then
			addGlobals[b[1]] = true
		end
	end

	for a, b in next, addGlobals do
		local code = genserial()
		proxies[a] = code
		n = n + 1
		addon(code .. " = " .. getf .. "[\"" .. str2byte(a, bytecodeOffset) .. "\"]")
		addon(getf.. "[\"" .. str2byte(code, bytecodeOffset) .. "\"] = " .. getf .. "[\"" .. str2byte(a, bytecodeOffset) .. "\"]")
		if n%10 == 0 then
			newline()
		end
	end
	newline()

	proxies["false"] = False
	proxies["true"] = True
	addon(getf.. "[\"" .. str2byte(False, bytecodeOffset) .. "\"] = false")
	addon(getf.. "[\"" .. str2byte(True, bytecodeOffset) .. "\"] = not " .. False)

	local d = {}

	local i = 0
	local skipLines = {}

	local function getNum(i)
		return data[i]
	end
	local function getNextNotSpace(i)
		if i == nil then return end
		for i = i, #code do
			local x = getNum(i)
			if x and not(x[1]:match("%s")) then
				return i
			end
		end
		return #code
	end
	local function getBeforeNotSpace(i)
		if i == nil then return end
		for i = i, 0, -1 do
			local x = getNum(i)
			if x and not(x[1]:match("%s")) then
				return i
			end
		end
		return 0
	end

	local function handle_default(b)
		if b[1] == "local" and not(instrings[b[2]]) then return end
		table.insert(d, b[1])
	end

	for i, b in next, data do
		if skipLines[i] == nil then
			local word = b[1]
			if proxies[word] and b[4] == false then -- if there's a set var and not in a string
				table.insert(d, proxies[word])
			elseif b[3] == "CHAR" then
				local next = getNum(getNextNotSpace(i + 1))
				if next and next[1] == "=" then
					local next2 = getNum(getNextNotSpace(i + 2))
					if next2 then
						proxies[b[1]] = genserial() 
						local a = getf.. "[\"" .. str2byte(proxies[b[1]], bytecodeOffset) .. "\"] = "
						skipLines[i + 1] = true
						skipLines[i + 2] = true
						table.insert(d, a)
					end
				else
					handle_default(b)
				end
			else
				handle_default(b)
			end
		end
	end

	local c = NewCode .. table.concat(d, "")
	print(c)
end

obsfusticate(io.open("text.txt"):read("*all"))
local GenerateCode;

local function minify(msg)
    local scr = {
        msg
        
    }
        
    local result = ""
    local result = ""
        
    function getLines(src)
        local result = {}
        local start = 1
        for i = 1,#src do
            if string.sub(src, i, i) == "\n" then
                table.insert(result, #result + 1, src:sub(start, i - 1))
                start = i + 1
            end
        end
        table.insert(result, #result + 1, src:sub(start, #src))
        return result
    end
        
    for i,v in pairs(getLines(unpack(scr))) do
        local s,e = string.find(v, "%-%-")
        if string.find(v, "%-%-") then
            result = result..v:sub(1, s - 1)
        else
            result = result..v.." "
        end
        result=result.."\n" 
    end
        
    result = {result}
    
    local new = string.gsub(unpack(result)," +"," ")
    new = string.gsub(new,"(\r?\n)%s*\r?\n","%1")
    new = string.gsub(new," \n","; ")
    new = string.gsub(new,"\t","")
    new = string.gsub(new,"do;","do")
    new = string.gsub(new,"do ;","do")
    new = string.gsub(new,"then;","then")
    new = string.gsub(new,"then ;","then")
    new = string.gsub(new,"else;","else")
    new = string.gsub(new,"else ;","else")
    new = string.gsub(new,"repeat;","repeat")
    new = string.gsub(new,"repeat ;","repeat")
    new = string.gsub(new,";;",";")
    new = string.gsub(new,",,",",")
    new = string.gsub(new,"};","}") 
    new = string.gsub(new,"{;","{")
    new = string.gsub(new,"%);","%)")
    new = string.gsub(new,"%(;","%(")
    new = string.gsub(new," ;","")
    new = string.gsub(new,"%);",")")
    if new:sub(1,1) == ";" then
        new = new:gsub("; ","",1)
    end
    return new:sub(1,new:len() - 1)
end

------------

math.randomseed(os.clock())

local function roperation()
	local n = math.random(0, 3)
	return n == 0 and "+" or n == 1 and "-" or n == 2 and "/" or n == 3 and "*"
end
local function gentable()
	local t = {}
	for i = 1, math.random(1, 5) do
		table.insert(t, math.random(10, 36))
	end
	return "(#{" .. table.concat(t, ", ") .. "})"
end
local function isCloser(a, b, c)
	local dif1, dif2 = a-b, a-c
	dif1, dif2 = dif1 < 0 and -dif1 or dif1, dif2 < 0 and -dif2 or dif2
	if dif1 < dif2 then return b else return c end
end
local function funnumber2(difference)
	local current, concats = 5, {}
	for i = 1, difference*2 / math.random(2, 3) do
		local number = math.floor(math.random(1, current))
		local closist = isCloser(difference, current - number, current + number)
		local og = number == closist - current and number or -number
		table.insert(concats, og)
		current = current + og
	end
	current = current + (difference-current)
	return table.concat(concats, " + ")
end
local function funnumber(number)
	local pos = number<0 and -1 or 1
	local ran = {}
	--if number*pos / 10 <= 1 then return tostring(number) end
	for i = 1, math.random(0, number*pos / 10) do
		if math.random(1, 10) < 7 then
			table.insert(ran, math.random(1, i))
		else
			table.insert(ran, gentable())
		end
		table.insert(ran, roperation())
	end
	table.remove(ran, #ran)
	--print(table.concat(ran, ""))
	local finalnumber = loadstring("return " .. table.concat(ran, ""))()
	if finalnumber == nil then return number end
	local p1, p2 = 	finalnumber < 0 and -finalnumber or finalnumber, 
					number < 0 and -number or number

	local difference = p1 > p2 and p1 - p2 or p2 - p1
	local x = table.concat(ran, "") .. "+" .. funnumber2(difference)
	local finalagain = loadstring("return " .. x)
	if finalagain == nil then return tostring(number) else finalagain=finalagain()end
	local p1, p2 = 	finalagain < 0 and -finalagain or finalagain, 
					number < 0 and -number or number

	local difference = p1 > p2 and p1 - p2 or p2 - p1
	local f = number > finalagain and finalagain + difference or finalagain - difference
	x = f == -number and x .. " * -1" or x
	local a = loadstring("return " .. x)()
	local p1, p2 = 	a < 0 and -a or a, 
					number < 0 and -number or number

	local difference = p1 > p2 and p1 - p2 or p2 - p1
	local f = number > a and a + difference or a - difference
	x = x .. (number > a and " + " .. tostring(difference) or " - " .. tostring(difference))
	x = f == -number and x .. " * -1" or x
	x = "math.floor(" .. x .. " )"
	return x
end

local codes, generate_random = {}
function generate_random(add)
	add = add or 0
	local string = ("iI"):rep(math.random(3 + add, 10 + add))
	if codes[string] then
		return generate_random()
	else
		codes[string] = true
		return string
	end
end

local function ruin_numbers(src)
	return ({src:gsub("%d+", function(t) 
		if tonumber(t) and tonumber(t) > 0 then
			if tonumber(t)< 1000 then 
				return funnumber(tonumber(t))
			end
		end
		return t
	end)})[1]
end

------------

do
	local alphabet = "ilI"--"abcdefijklmnopqrstuvwxyz"
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
	code = ruin_numbers(code)
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

	local f=genserial()

	addon([[function ]]..b2s..[[(...)local s = "" (...):gsub("%d+", function(t) s=s..string.char(t - ]]..bytecodeOffset..[[) end)return s end]])
	addon(getf..[[ = setmetatable({}, {__index = function(_, i) return getfenv()[]]..b2s..[[(i)] end,__newindex = function(s, i, v)getfenv()[]]..b2s..[[(i)] = v end})]])

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
		--print(b[2], b[1])
		--if (b[1] == "local") and not(instrings[b[2]]) then return end
		table.insert(d, b[1])
	end

	for i, b in next, data do
		if skipLines[i] == nil then
			local word = b[1]
			local possible = (word):match("%w+")
			if proxies[word] and b[4] == false or proxies[possible] and b[4] == false then -- if there's a set var and not in a string\
				if d[#d] and d[#d] == data[i - 1][1] and d[#d]:match("%w") then table.remove(d,#d) end
				table.insert(d, proxies[word] or proxies[possible] .. "[")
				--table.insert(d, str2byte(proxies[word] or proxies[possible], bytecodeOffset) .. "[")
			elseif b[3] == "CHAR" then
				local next = getNum(getNextNotSpace(i + 1))
				local before = getNum(getNextNotSpace(i - 2))[1]
				local b4b4 = getNum(getNextNotSpace(i - 3))[1]
				if next and next[1] == "=" and before ~= "for" and b4b4 ~= "\"" and b4b4 ~= "'" and b[1] ~= "]" and b[1] ~= "}" then
					local next2 = getNum(getNextNotSpace(i + 2))
					if next2 then
						proxies[b[1]] = genserial() 
						--local a = " "..getf.. "[\"" .. str2byte(proxies[b[1]], bytecodeOffset) .. "\"] = "
						local a = " " .. proxies[b[1]] .. " = "
						skipLines[i + 1] = true
						skipLines[i + 2] = true
						if before == "local" then table.insert(d,genserial()) end
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

	local c = minify(NewCode .. table.concat(d, ""))
	print(c)
end

obsfusticate(io.open("text.txt"):read("*all"))
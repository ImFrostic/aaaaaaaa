local KEYWORDS = {}

for a in next, getfenv() do
	KEYWORDS[a] = true
end

local DATATYPE = {
	["false"] = "boolean",
	["true"] = "boolean",
}

local EXPRESSIONS = {
	["%{"] = true, 
	["%}"] = true, 
	["%("] = true, 
	["%)"] = true,
	['"'] = true,
	["'"] = true,
	["="] = true,

	["local"] = true,

	[" "] = true,
	["	"] = true,
	["\n"] = true,
}

local function handlekey(key)
	return key:sub(1, 1) == "%" and key:sub(2) or key
end

local function lex(source)
	local data, taken = {}, {[0] = true}
	local inString1, inString2, inString3 = false, false, false
	local lastS = 0
	local CharsinStrings, easyget, inStrings = {}, {}, {}

	local function handle(key, type)
		local i = 0
		while true do
			i = string.find(source, key, i + 1)
			if i == nil then break end
			local handledkey = handlekey(key)

			for x = 0, #handledkey-1 do
				taken[x + i] = handledkey
			end

			--// string handling * check if it's in a string
			if inString1 or inString2 or inString3 then
				for i = lastS, i do
					CharsinStrings[i] = true
					inStrings[i] = true
					easyget[i] = d
				end
			end
			local c = source:sub(i, i)
			if c == "'" and not inString2 and not inString2 then
				inString1 = not inString1
				lastS = inString1 and i or lastS
			elseif c == '"' and not inString1 and not inString3 then
				inString2 = not inString2
				lastS = inString2 and i or lastS
			elseif c == "[[" and not inString1 and not inString2 then
				inString3 = true
				lastS = i
			elseif c == "]]" and inString3 then
				inString3 = false
			end
			--//
			local d = {handledkey, i, type, CharsinStrings[i] or (inString1 or inString2 or inString3) or false}

			easyget[i] = d
			table.insert(data, d)
		end
	end

	for keyword in next, KEYWORDS do
		handle(keyword, "KEYWORD")
	end
	for expr in next, EXPRESSIONS do
		handle(expr, "EXPRESSION")
	end
	for ty in next, DATATYPE do
		handle(ty, "DATATYPE")
	end

	local lastChar = 1
	local currentword = ""
	for i = 0, #source do
		if not(taken[i]) then
			local start = i
			local word = true
			for i = lastChar, i do
				if taken[i] then
					word = false
					break
				end
			end
			if word then
				start = lastChar
				currentword = source:sub(start, i)
				if taken[i + 1] then
					local d = {currentword, i, "CHAR", CharsinStrings[i] or false}
					table.insert(data, d)
					easyget[i] = d
				end
			else
				lastChar = start + 1
				currentword = source:sub(start, i)

				local d = {currentword, i, "CHAR", CharsinStrings[i] or false}
				table.insert(data, d)
				easyget[i] = d
			end
		end
	end

	return data, easyget, inStrings
end


return {parse_lex, lex}
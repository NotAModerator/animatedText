--Animated Text API v0.0
local api, tasks = {}, {}

function trueLength(tbl)
	local length = 0
	for _, v in pairs(tbl) do
		for i = 1, #v.chars do
			if #v.chars[i] <= 1 then length = length + client:getTextWidth(v.chars[i]) else length = length + 8 end
		end
	end
	return length
end

function trueCharWidth(char)
	if #char <= 1 then return client:getTextWidth(char) else return 8 end
end

function deconstructString(string, tbl) --if tbl argument is provided, all characters will be appended to it, otherwise append to a separate table
	if not tbl then _tbl = {} else _tbl = tbl end
	local escape, str, charsLeft, charIndex = false, '', 0, 0
	for char in string:gmatch('[\x00-\x7F\xC2-\xF4][\x80-\xBF]*') do
		if escape then str = str .. char else str = char end --look for emojis, if str is complete, add as char
		if char == ':' then escape = not escape end
		if char == ' ' and escape or not string:find(char, charIndex + 1) and escape then
			escape, charsLeft = false, #str - 1
			for i = 1, #str do table.insert(_tbl, str:sub(i, i)) end
		end
		if not escape and charsLeft < 1 then table.insert(_tbl, str) end
		charsLeft = charsLeft - 1
		charIndex = charIndex + 1
	end
	return {{raw = string, chars = _tbl}}
end

function deconstructJson(json, r) --deconstruct json into separate characters with the appropriate components
	if type(json) == "string" and not r then _json = parseJson(json) else _json = json end
	if not r then tbl = {} end
	local charTbl = {chars = {}}
	for k, v in pairs(_json) do
		if type(v) ~= "table" then
			if k == "text" then
				charTbl.raw = v
				deconstructString(v, charTbl.chars)
			else
				if not charTbl.properties then charTbl.properties = {} end
				charTbl.properties[k] = v
			end
		else
			deconstructJson(v, true) --recursive
		end
	end
	if json.text then table.insert(tbl, charTbl) end --tables with nested objects inside will be ignored if that table doesn't include "text".
	return tbl
end

function createTasks(task, text)
	if type(text) == "table" then _text = deconstructJson(text) elseif type(text) == "string" then _text = deconstructString(text) end
	local span, length = 0, trueLength(_text)
	for _, v in ipairs(_text) do
		for _, char in pairs(v.chars) do
			table.insert(task.textTasks, {
				anchor = vec((span - length / 2) * -task.scale.x, 0, 0) + task.offset,
				task = task.root:newText(#task.textTasks)
			})
			local textTask = task.textTasks[#task.textTasks]
			textTask.task:pos(textTask.anchor)
			:scale(task.scale)
			:setAlignment('LEFT')
			:text(v.properties and "{'text': '" .. char .. "', " .. toJson(v.properties):sub(2, -2) .. "}" or char)
			span = span + trueCharWidth(char)
		end
	end
end

function api.remove(name)
	for _, v in pairs(tasks[name].root:getTask()) do v:remove() end
	tasks[name].textTasks = {}
end

function api.new(name, parent, offset, scale, parentType, json)
	if tasks[name] then api.remove(name) end
	tasks[name] = {offset = offset, scale = scale, root = parent:newPart(name):setParentType(parentType), textTasks = {}}
	if json then createTasks(tasks[name], json) end
end

function api.setText(name, json)
	if tasks[name].textTasks then api.remove(name) end
	createTasks(tasks[name], json)
end

function api.getTask(name) return tasks[name] end

function api.transform(name, pos, rot, scale, char)
	char.task:pos(char.anchor + (pos or vec(0, 0, 0)))
	:rot(rot or vec(0, 0, 0))
	:scale(tasks[name].scale + (scale or vec(0, 0, 0)))
end

return api

--Animated Text API v0.1.0
local api, tasks = {}, {}

local function trueLength(tbl)
	local length, _tbl = 0, {}
	for k, v in pairs(tbl) do
		for i = 1, #v.chars do
			if #v.chars[i] <= 1 then 
				length = length + client:getTextWidth(v.chars[i]) 
			else 
				length = length + 8 
			end
			if v.chars[i] == "\n" or i == #v.chars and k >= #tbl then
				table.insert(_tbl, length)
				length = 0
			end
		end
	end
	return _tbl
end

local function trueCharWidth(char)
	if #char <= 1 or char == "\n" then return client:getTextWidth(char) else return 8 end
end

local function deconstructString(str)
	local match = '[\x00-\x7F\xC2-\xF4][\x80-\xBF]*'
	local tbl, i, lastCapture, capturing = {}, 1, 1, false
	for char in str:gmatch(match) do
		local substring = str:sub(lastCapture, i)
		if char == ":" then
			if capturing then table.insert(tbl, substring) end
			if not capturing and i == #str then table.insert(tbl, char) end
			capturing, lastCapture = not capturing, i
		elseif capturing and char:match("[%s]") or capturing and i == #str then
			for _char in substring:gmatch(match) do table.insert(tbl, _char) end
			capturing = false
		elseif not capturing then
			table.insert(tbl, char)
		end
		i = i + #char
	end
	return tbl
end

local function deconstructJson(json, _tbl)
	local tbl, charTbl = _tbl or {}, {chars = {}, properties = {}}
	for k, v in pairs(json) do
		if type(v) ~= "table" then
			if k == "text" then
				charTbl.chars = deconstructString(v)
			else
				charTbl.properties[k] = v
			end
		else
			deconstructJson(v, tbl)
		end
	end
	if json.text then table.insert(tbl, charTbl) end
	return tbl
end

local function createTasks(task, _text)
	local text = type(_text) == "table" and deconstructJson(_text) or deconstructString(_text)
	local span, length, line = 0, trueLength(text), 1
	for _, v in pairs(text) do
		for _, char in pairs(v.chars) do
			if char == "\n" then span, line = 0, line + 1 end
			table.insert(task.textTasks, {
				anchor = vec(
					(span - length[line] / 2) * -task.scale.x, 
					(line - 1) * -task.scale.y * client:getTextHeight(""), 
					0
				) + task.offset,
				task = task.root:newText(#task.textTasks)
			})
			local textTask, _json = task.textTasks[#task.textTasks], {text = char}
			for k, v in pairs(v.properties) do _json[k] = v end
			textTask.task:pos(textTask.anchor)
			:scale(task.scale)
			:setAlignment('LEFT')
			:text(v.properties and toJson(_json) or char)
			span = span + trueCharWidth(char)
		end
	end
end

function api.remove(name)
	for i, v in pairs(tasks[name].root:getTask()) do 
		v:remove()
		tasks[name].textTasks[i + 1] = nil
	end
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

function api.applyFunc(name, func)
	for i, v in pairs(tasks[name].textTasks) do 
		local pos, rot, scale = func(v.task, i)
		v.task:pos(v.anchor + (pos or vec(0, 0, 0)))
		:rot(rot or vec(0, 0, 0))
		:scale(tasks[name].scale + (scale or vec(0, 0, 0)))
	end
end

return api
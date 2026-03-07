# Animated Text API v0.2.0
Provides functions for creating groups of TextTasks to move independently in Figura.

# Installation

- 1: Download and Extract the .zip containing an example avatar or download the standalone script.
- 2: Take the script and move it to your desired avatars' folder.
- 3: Go to `script.lua` or any script you may have set to run automatically and insert the following snippet. (Recommended to include at the beginning of your script.)
```lua
local animatedText = require("animatedText")
 ```
- 4: Bone Apple Tea or whatever they say lmao

# Documentation

## new(name, parent, offset, scale, parentType, json)
Creates a new task given the 5 parameters. The main ones to focus on are `name`, `parent`, and `json`.
- `name`: Specifies the name or ID of what this task will be called for further use.
- `parent`: The modelpart that the task will be parented to. This cannot be changed after the task is created.
- `offset`: A vector3 that changes the position relative to the parent.
- `scale`: A vector3 determining the scale of the characters and how far they will be spaced.
- `json`: The text that the task will display. Accepts JSON-formatted data.

## remove(name)
Removes any task created with the associated name.

## setText(name, json)
Sets the text of a task with the associated name. This will replace all TextTasks previously created. This can also be called if `new()` is missing the `json` argument.

## applyFunc(name, func)
Applies transformations/display changes to all textTasks inside an animated task.
- `name`: Target task to apply transformations to.
- `func`: A function that accepts 2 arguments.
	- `char`: 1 textTask out of n characters in the string. Can have functions such as `setOutline` or `setBackground` applied.
   	- `i`: Numerical index of `char`.

If you wish to apply transformations relative to the character's anchor position and scale, `func` can return `pos`, `rot`, and `scale`. If these are nil, they will default to what their setting is in `new()`.

# Example
```lua
vanilla_model.ALL:visible(false)
nameplate.ENTITY:visible(false)
local animatedText = require("animatedText")

local myJson = {
	{text = 'This is line 1. :notepad++::java:\nThis is line 2.'},
	{text = avatar:getBadges(), font = "figura:badges", color = avatar:getColor()}
}

animatedText.new("myTask", models.model.root.Head, vec(0,20,0), vec(.4,.4,0), "Billboard", myJson)
function events.render(delta, context)
	if context ~= "FIRST_PERSON" and context ~= "RENDER" then return end
	animatedText.applyFunc("myTask", function(char, i)
		return vec(0, math.sin((world:getTime() + delta) / 8 + i) * .25, 0)
	end)
end
```
This example script and the rest of the example avatar can be found in `Example.zip`.

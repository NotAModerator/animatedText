# Animated Text API
A script for the Figura Mod capable of providing more fluid movements to the otherwise mundane and stiff TextTasks.

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
- `json`: The text that the task will display. This is the most modular when using JSON-formatted data, but does accept regular strings.

## remove(name)
Removes any task created with the associated name.

## getTask(name)
A means for retrieving information about an animated task. Returns a table.
- `offset`: The original offset of the task.
- `scale`: The original scale of the task.
- `root`: This is a modelpart bound to the parent that contains all the TextTasks displayed.
- `textTasks`: The TextTasks themselves that are displayed.

## setText(name, json)
Sets the text of a task with the associated name. This will replace all TextTasks previously created. This can also be called if `new()` is missing the `json` argument.

> [!NOTE]
> This function is likely to cause issues if it runs every frame. This is because all TextTasks in the animated task need to be refreshed in order to display correctly.

## transform(name, pos, rot, scale, char)
Applies a transformation to a certain character inside of an animated task. `pos`, `rot`, and `scale` can be left nil for the sake of readability.
- `pos`: A vector3 that moves a character relative to its anchor point in the task. This can be viewed through the `textTasks` table inside the task.
- `rot`, `scale`: 2 other vector3s that will apply rotation and scaling without being relative to another value.
- `char`: A numerical index for which character should be affected. This is best used within a for loop to allow for certain effects.

# Example
```lua
vanilla_model.PLAYER:visible(false)

--require the script for use
local animatedText = require("animatedText") 

--create text, can be a regular string if you wish
local myJson = { 
      {text = 'now playing: lorem ipsum ™:notepad++::java:', italic = true},
      {text = avatar:getBadges(), font = "figura:badges", color = avatar:getColor()}
}

--add text as a new set of tasks
animatedText.new("myTask", models.model.root.Head, vec(0, 15, 0), vec(.5, .5, 1), "BILLBOARD", myJson) 
for _, v in pairs(animatedText.getTask("myTask").textTasks) do v.task:outline(true) end

local tickTime = 0 
function events.tick() tickTime = tickTime + 1 end

--in this example, we use a formula to offset the sine of each character based on its index (i) and amplify its motion by .5
function events.render(delta, context)
	if context ~= "FIRST_PERSON" and context ~= "RENDER" then return end
	for i, v in pairs(animatedText.getTask("myTask").textTasks) do
		animatedText.transform("myTask", vec(0, math.sin((tickTime + delta) / 8 + i) * .5, 0), nil, nil, v)
	end
end
```
This example script and the rest of the example avatar can be found under the `animatedText` folder.

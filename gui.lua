GUI = {
	styleprefix = "st_",
	
	defaultStyles = {
		label = "label",
		button = "button",
		checkbox = "checkbox"
	},
	
	windows = {
		root = "stGui",
		settings = {"settings"},
		trainInfo = {"trainInfo"}
	},
	
	position = "left",

	new = function(index, player)
		local new = {}
		setmetatable(new, {__index = GUI})
		return new
	end,

	create_or_update = function(trainInfo, player_index)
		local player = game.players[player_index]
		if player.valid then
			local main = GUI.buildGUI(player)
			GUI.showSettingsButton(main)
			if player.opened and player.opened.type == "locomotive" then
				GUI.showTrainInfoWindow(main, trainInfo, player_index)
			end
			GUI.showTrainLinesWindow(main, trainInfo, player_index)
		end
	end,

	buildGUI = function(player)
		GUI.destroyGui(player.gui[GUI.position][GUI.windows.root])
		local stGui = GUI.add(player.gui[GUI.position], {type = "frame", name = "stGui", direction = "vertical", style = "outer_frame_style"})
		return GUI.add(stGui, {type = "table", name = "rows", colspan = 1})
	end,

	showSettingsButton = function(parent)
		local gui = parent
		if gui.toggleSTSettings ~= nil then
			gui.toggleSTSettings.destroy()
		end
		GUI.addButton(gui, {name="toggleSTSettings", caption = {"text-st-settings"}})
	end,

	destroyGui = function(guiA)
		if guiA ~= nil and guiA.valid then
			guiA.destroy()
		end
	end,

	destroy = function(player_index)
		local player = false
		if type1(player_index) == "number" then
			player = game.players[player_index]
		else
			player = player_index
		end
		if player.valid then
			GUI.destroyGui(player.gui[GUI.position][GUI.windows.root])
		end
	end
}

function gui_init(player, after_research)
	if not player.gui.top["filtered-deconstruction-planner-config-button"] and (player.force.technologies["automated-construction"].researched or after_research) then
		player.gui.top.add{
			type = "button",
			name = "filtered-deconstruction-planner-config-button",
			style = "filtered-deconstruction-planner-button-"..global["config"][player.name]["mode"]
		}
	end
end

local function add_label(parent, text)
	parent.add{
		type = "label",
		caption = text
	}
end

function gui_open_frame(player)
	local frame = player.gui.left["filtered-deconstruction-planner-frame"]

	if frame then
		frame.destroy()
		global["config-tmp"][player.name] = nil
		return
	end

	global["config"][player.name] = global["config"][player.name] or {}
	global["config-tmp"][player.name] = {}
	global["config-tmp"][player.name]["filter"] = {}

	local i = 0
	for i = 1, MAX_FILTER_COUNT do
		if i > #global["config"][player.name]["filter"] then
			global["config-tmp"][player.name]["filter"][i] = ""
		else
			global["config-tmp"][player.name]["filter"][i] = global["config"][player.name]["filter"][i]
		end
	end

	frame = player.gui.left.add{
		type = "frame",
		caption = {"filtered-deconstruction-planner-config-frame-title"},
		name = "filtered-deconstruction-planner-frame",
		direction = "vertical"
	}

	local mode_grid = frame.add{
		type = "flow",
		name = "filtered-deconstruction-planner-mode-grid",
		direction = "horizontal"
	}
	mode_grid.add{
		type = "label",
		name = "filtered-deconstruction-planner-mode-label",
		caption = {"filtered-deconstruction-planner-mode-label"}
	}
	add_label(mode_grid, "  ")
	mode_grid.add{
		type = "checkbox",
		name = "filtered-deconstruction-planner-mode-normal",
		state = global["config"][player.name]["mode"] == "normal"
	}
	mode_grid.add{
		type = "label",
		name = "filtered-deconstruction-planner-mode-normal-label",
		caption = {"filtered-deconstruction-planner-mode-normal-label"}
	}
	add_label(mode_grid, "  ")
	mode_grid.add{
		type = "checkbox",
		name = "filtered-deconstruction-planner-mode-target",
		state = global["config"][player.name]["mode"] == "target"
	}
	mode_grid.add{
		type = "label",
		name = "filtered-deconstruction-planner-mode-target-label",
		caption = {"filtered-deconstruction-planner-mode-target-label"}
	}
	add_label(mode_grid, "  ")
	mode_grid.add{
		type = "checkbox",
		name = "filtered-deconstruction-planner-mode-exclude",
		state = global["config"][player.name]["mode"] == "exclude"
	}
	mode_grid.add{
		type = "label",
		name = "filtered-deconstruction-planner-mode-exclude-label",
		caption = {"filtered-deconstruction-planner-mode-exclude-label"}
	}

	if global["config"][player.name]["mode"] ~= "normal" then
		local filter_grid = frame.add{
			type = "flow",
			name = "filtered-deconstruction-planner-filter-grid",
			direction = "horizontal"
		}
		for i = 1, MAX_FILTER_COUNT do
			local style = global["config"][player.name]["filter"][i] or "style"
			style = style == "" and "style" or style

			filter_grid.add{
				type = "checkbox",
				name = "filtered-deconstruction-planner-icon-"..i,
				style = "fdp-icon-"..style,
				state = false
			}
		end
	end

	if global["config"][player.name]["mode"] ~= "normal" then
		local button_grid = frame.add{
			type = "flow",
			name = "filtered-deconstruction-planner-button-grid",
			direction = "horizontal"
		}
		button_grid.add{
			type = "button",
			name = "filtered-deconstruction-planner-save",
			caption = {"filtered-deconstruction-planner-button-save"},
			style = "filtered-deconstruction-planner-small-button"
		}
		button_grid.add{
			type = "button",
			name = "filtered-deconstruction-planner-clear",
			caption = {"filtered-deconstruction-planner-button-clear"},
			style = "filtered-deconstruction-planner-small-button"
		}
	end
end

function gui_save(player, name)
	if global["config-tmp"][player.name] then
		local i = 0
		local mode = global["config"][player.name]["mode"]
		global["config"][player.name] = {}
		global["config"][player.name]["mode"] = mode
		global["config"][player.name]["filter"] = {}

		for i = 1, #global["config-tmp"][player.name]["filter"] do
			global["config"][player.name]["filter"][i] = global["config-tmp"][player.name]["filter"][i]
		end
		global["config-tmp"][player.name] = nil
	end

	local frame = player.gui.left["filtered-deconstruction-planner-frame"]
end

function gui_clear(player)
	local i = 0
	local frame = player.gui.left["filtered-deconstruction-planner-frame"]

	if not frame then
		return
	end

	local filter_grid = frame["filtered-deconstruction-planner-filter-grid"]

	for i = 1, #global["config-tmp"][player.name]["filter"] do
		global["config-tmp"][player.name]["filter"][i] = ""
		filter_grid["filtered-deconstruction-planner-icon-"..i].style = "fdp-icon-style"
	end
end

function gui_set_rule(player, index)
	local frame = player.gui.left["filtered-deconstruction-planner-frame"]
	if not frame or not global["config-tmp"][player.name] then
		player.print("No config?!")
		return
	end

	local stack = player.cursor_stack
	if not stack.valid_for_read then
		stack = {type = "empty", name = ""}
		global["config-tmp"][player.name]["filter"][index] = ""
	end

	local i = 0
	for i = 1, #global["config-tmp"][player.name]["filter"] do
		if stack.type ~= "empty" and index ~= i and global["config-tmp"][player.name]["filter"][i] == stack.name then
			player.print({"filtered-deconstruction-planner-duplicate"})
			return
		end
	end

	global["config-tmp"][player.name]["filter"][index] = stack.name

	local filter_grid = frame["filtered-deconstruction-planner-filter-grid"]
	local style = global["config-tmp"][player.name]["filter"][index] ~= "" and "fdp-icon-"..global["config-tmp"][player.name]["filter"][index] or "fdp-icon-style"

	filter_grid["filtered-deconstruction-planner-icon-"..index].style = style
	filter_grid["filtered-deconstruction-planner-icon-"..index].state = false
end

function gui_set_mode(player, mode)
	local frame = player.gui.left["filtered-deconstruction-planner-frame"]
	if not frame or not global["config"][player.name] then
		return
	end

	global["config"][player.name]["mode"] = mode

	player.gui.top["filtered-deconstruction-planner-config-button"].style = "filtered-deconstruction-planner-button-"..mode

	frame.destroy()
	global["config-tmp"][player.name] = nil
	gui_open_frame(player)
end
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

-- Initializes the GUI
function gui_init(player, after_research)
	if not player.gui.top["filtered-deconstruction-planner-config-button"] and (player.force.technologies["automated-construction"].researched or after_research) then
		player.gui.top.add{
			type = "button",
			name = "filtered-deconstruction-planner-config-button",
			style = "filtered-deconstruction-planner-button-"..global["config"][player.name]["mode"]
		}
	end
end

-- Refreshes the configuration window if it is currently showing
function gui_refresh(player)
	local frame = player.gui.left["filtered-deconstruction-planner-frame"]

	if frame then
		frame.destroy()
		gui_open_frame(player)
	end
end

-- Helper method to add a text as label to the given parent
local function add_label(parent, text)
	parent.add{
		type = "label",
		caption = text
	}
end

-- Shows or hides the configuration window
function gui_open_frame(player)
	local frame = player.gui.left["filtered-deconstruction-planner-frame"]

	if frame then
		frame.destroy()
		return
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
		local filter_grid

		for i = 1, #global["config"][player.name]["filter"] do
			if i % 8 == 1 then
				filter_grid = frame.add{
					type = "flow",
					name = "filtered-deconstruction-planner-filter-grid-"..(((i-(i%8))/8)+1),
					direction = "horizontal"
				}
			end

			local style = global["config"][player.name]["filter"][i] or "style"
			style = style == "" and "style" or style

			filter_grid.add{
				type = "checkbox",
				name = "filtered-deconstruction-planner-icon-"..i,
				style = "fdp-icon-"..style,
				state = false
			}
		end

		local counter = (#global["config"][player.name]["filter"] + 1)
		if counter % 8 == 1 then
			filter_grid = frame.add{
				type = "flow",
				name = "filtered-deconstruction-planner-filter-grid-"..(((counter-(counter%8))/8)+1),
				direction = "horizontal"
			}
		end
		filter_grid.add{
			type = "checkbox",
			name = "filtered-deconstruction-planner-icon-"..counter,
			style = "fdp-icon-style",
			state = false
		}
	end

	if global["config"][player.name]["mode"] ~= "normal" then
		local tmp_grid = frame.add{
			type = "flow",
			direction = "horizontal"
		}
		tmp_grid.add{
			type = "label",
			caption = "                                                                                                                                                                                                                                                                    ",
			style = "filtered-deconstruction-planner-mini-label"
		}

		local button_grid = frame.add{
			type = "flow",
			name = "filtered-deconstruction-planner-button-grid",
			direction = "horizontal"
		}

		if global["eyedropper-list"][player.name] then
			button_grid.add{
				type = "button",
				name = "filtered-deconstruction-planner-remove-eyedropper",
				style = "filtered-deconstruction-planner-button-eyedropper-remove"
			}
		else
			button_grid.add{
				type = "button",
				name = "filtered-deconstruction-planner-insert-eyedropper",
				style = "filtered-deconstruction-planner-button-eyedropper-insert"
			}
		end

		button_grid.add{
			type = "button",
			name = "filtered-deconstruction-planner-clear",
			style = "filtered-deconstruction-planner-button-clear"
		}
	end
end

-- Clears all filter configuration slots
function gui_clear(player)
	global["config"][player.name]["filter"] = {}
	gui_refresh(player)
end

-- Called when a filter configuration slot is clicked and sets filter if valid
function gui_set_rule(player, index)
	local stack = player.cursor_stack
	local entity_name

	if not stack.valid_for_read then
		table.remove(global["config"][player.name]["filter"], index)
	else
		entity_name = stack.name
		if is_in_filter(player, entity_name) then
			player.print({"filtered-deconstruction-planner-duplicate"})
		elseif entity_name ~= "fdp-eyedropper" then
			global["config"][player.name]["filter"][index] = entity_name
		end
	end
	
	gui_refresh(player)
end

-- Change mode of filtered deconstruction planner
function gui_set_mode(player, mode)
	global["config"][player.name]["mode"] = mode
	player.gui.top["filtered-deconstruction-planner-config-button"].style = "filtered-deconstruction-planner-button-"..mode

	gui_refresh(player)
end

-- Insert eyedropper tool into player cursor stack if possible
function gui_insert_eyedropper(player)
	if player.cursor_stack.valid_for_read then
		player.print({"filtered-deconstruction-planner-hands"})
	else
		player.cursor_stack.set_stack({name = "fdp-eyedropper", count = 1})
		global["eyedropper-list"][player.name] = true
		script.on_event(defines.events.on_tick, on_tick)
		gui_refresh(player)
	end
end

-- Remove eyedropper tool from hand and inventory
function gui_remove_eyedropper(player)
	if player.cursor_stack.valid_for_read then
		if player.cursor_stack.name == "fdp-eyedropper" then
			player.cursor_stack.clear()
			global["eyedropper-list"][player.name] = nil
			gui_refresh(player)

			if #global["eyedropper-list"] == 0 then
				script.on_event(defines.events.on_tick, nil)
			end
		end
	end
end
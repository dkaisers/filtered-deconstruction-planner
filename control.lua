require "defines"
require "util"
require "config"
require "lib"
require "gui"

function update_gui()
	pcall(function()
		for i, player in pairs(game.players) do
			if player.valid and player.gui.top["filtered-deconstruction-planner-config-button"] then
				player.gui.top["filtered-deconstruction-planner-config-button"].destroy()
			end
			gui_init(player)
		end
	end)
end

local function init_global()
	global["config"] = global["config"] or {}
	global["config"]["eyedropping"] = global["config"]["eyedropping"] or {}

	global["eyedropper-list"] = global["eyedropper-list"] or {}

	if #global["eyedropper-list"] > 0 then
		script.on_event(defines.events.on_tick, on_tick)
	end
end

local function init_player(player)
	global["config"][player.name] = global["config"][player.name] or {}
	global["config"][player.name]["mode"] = global["config"][player.name]["mode"] or DEFUALT_FILTER_MODE
	global["config"][player.name]["filter"] = global["config"][player.name]["filter"] or {}
end

local function init_players()
	for i, player in pairs(game.players) do
		init_player(player)
	end
end

local function on_player_created(event)
	init_player(game.players[event.player_index])
end

local function on_init()
	init_global()
	init_players()
	update_gui()
end

local function on_configuration_changed(data)
	if not data or not data.mod_changes then
		return
	end

	if data.mod_changes["filtered-deconstruction-planner"] and data.mod_changes["filtered-deconstruction-planner"].old_version then
		if data.mod_changes["filtered-deconstruction-planner"].old_version < "0.2.0" then
			if global["config"] then
				for player_name, filter_data in pairs(global["config"]) do
					global["config"][player_name] = {}
					global["config"][player_name]["mode"] = DEFUALT_FILTER_MODE
					global["config"][player_name]["filter"] = filter_data or {}
				end
			end
		elseif data.mod_changes["filtered-deconstruction-planner"].old_version < "0.3.0" then
			if global["config"] then
				for player_name, player_data in pairs(global["config"]) do
					local tmp_data = {}

					for _, filter_entry in pairs(player_data["filter"]) do
						if filter_entry and filter_entry ~= "" then
							table.insert(tmp_data, filter_entry)
						end
					end

					global["config"][player_name]["filter"] = tmp_data
				end
			end
		end
	end

	init_global()
	update_gui()
end

function on_tick()
	for player_name, _ in pairs(global["eyedropper-list"]) do
		if remove_from_player(game.get_player(player_name), "fdp-eyedropper") then
			global["eyedropper-list"][player_name] = nil
			gui_refresh(game.get_player(player_name))

			if #global["eyedropper-list"] == 0 then
				script.on_event(defines.events.on_tick, nil)
			end
		end
	end
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	pcall(function()
		local entity = event.entity
		local player = nil
		local found_deconstruction_item = false

		for _, p in pairs(game.players) do
			local stack = p.cursor_stack
			if stack.valid_for_read then
				if stack.type == "deconstruction-item" then
					if stack.name == "filtered-deconstruction-planner" and not found_deconstruction_item then
						player = p
					elseif found_deconstruction_item then
						entity.cancel_deconstruction(entity.force)
						return
					end

					found_deconstruction_item = true
				end
			end
		end

		if not player then
			return
		end

		local is_configured = is_in_filter(player, get_entity_name(entity))

		if global["config"][player.name]["mode"] == "target" and not is_configured then
			entity.cancel_deconstruction(player.force)
		elseif global["config"][player.name]["mode"] == "exclude" and is_configured then
			entity.cancel_deconstruction(player.force)
		end
	end)
end)

script.on_event(defines.events.on_gui_click, function(event)
	pcall(function ()
		local element = event.element
		local player = game.get_player(event.player_index)

		if element.name == "filtered-deconstruction-planner-config-button" then
			gui_open_frame(player)
		elseif element.name == "filtered-deconstruction-planner-clear" then
			gui_clear(player)
		elseif string.sub(element.name, 1, string.len("filtered-deconstruction-planner-icon-")) == "filtered-deconstruction-planner-icon-" then
			local index = string.match(element.name, "filtered%-deconstruction%-planner%-icon%-*(%d*)")
			if index then
				gui_set_rule(player, tonumber(index))
			end
		elseif element.name == "filtered-deconstruction-planner-mode-normal" then
			gui_set_mode(player, "normal")
		elseif element.name == "filtered-deconstruction-planner-mode-target" then
			gui_set_mode(player, "target")
		elseif element.name == "filtered-deconstruction-planner-mode-exclude" then
			gui_set_mode(player, "exclude")
		elseif element.name == "filtered-deconstruction-planner-insert-eyedropper" then
			gui_insert_eyedropper(player)
		elseif element.name == "filtered-deconstruction-planner-remove-eyedropper" then
			gui_remove_eyedropper(player)
		end
	end)
end)

script.on_event(defines.events.on_research_finished, function(event)
	if event.research.name == 'automated-construction' then
		for _, player in pairs(event.research.force.players) do
			gui_init(player, true)
		end
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.name == "fdp-eyedropper-proxy" then
		event.created_entity.destroy()
		gui_insert_eyedropper(game.get_player(event.player_index))

		local player = game.get_player(event.player_index)
		if player.selected then
			if player.selected.type == "resource" or player.selected.type == "simple-entity" or player.selected.type == "unit" or player.selected.type == "unit-spawner" then
				return
			end

			local entity_name = get_entity_name(player.selected)
			if is_in_filter(player, entity_name) then
				player.print({"filtered-deconstruction-planner-duplicate"})
			elseif entity_name ~= "fdp-eyedropper" then
				table.insert(global["config"][player.name]["filter"], entity_name)
			end
		end

		gui_refresh(player)
	end
end)

remote.add_interface("fdp", {
	init = function ()
		init_global()
		update_gui();
	end
})
require "defines"
require "util"
require "config"
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
	global["config-tmp"] = global["config-tmp"] or {}
end

local function init_player(player)
	global["config"][player.name] = global["config"][player.name] or {}
	global["config-tmp"][player.name] = global["config-tmp"][player.name] or {}

	global["config"][player.name]["mode"] = global["config"][player.name]["mode"] or DEFUALT_FILTER_MODE
	global["config-tmp"][player.name]["mode"] = global["config-tmp"][player.name]["mode"] or DEFUALT_FILTER_MODE

	global["config"][player.name]["filter"] = global["config"][player.name]["filter"] or {}
	global["config-tmp"][player.name]["filter"] = global["config-tmp"][player.name]["filter"] or {}
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

			if global["config-temp"] then
				for playername, filter_data in pairs(global["config-tmp"]) do
					global["config-tmp"][player_name] = {}
					global["config-tmp"][player_name]["mode"] = DEFUALT_FILTER_MODE
					global["config-tmp"][player_name]["filter"] = filter_data or {}
				end
			end
		end
	end

	init_global()
	update_gui()
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	pcall(function()
		local entity = event.entity
		local player = nil

		for _, p in pairs(game.players) do
			local stack = p.cursor_stack
			if stack.valid_for_read then
				if stack.name == "filtered-deconstruction-planner" then
					player = p
				else
					return
				end
			end
		end

		if not player then
			return
		end

		local is_configured = false
		for i = 1, MAX_FILTER_COUNT do
			if global["config"][player.name]["filter"][i] == entity.name then
				is_configured = true
			end
		end

		if global["config"][player.name]["mode"] == "target" and not is_configured then
			entity.cancel_deconstruction(entity.force)
		elseif global["config"][player.name]["mode"] == "exclude" and is_configured then
			entity.cancel_deconstruction(entity.force)
		end
	end)
end)

script.on_event(defines.events.on_gui_click, function(event)
	pcall(function ()
		local element = event.element
		local player = game.get_player(event.player_index)

		if element.name == "filtered-deconstruction-planner-config-button" then
			gui_open_frame(player)
		elseif element.name == "filtered-deconstruction-planner-save" then
			gui_save(player)
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

remote.add_interface("fdp", {
	init = function ()
		init_global()
		update_gui();
	end
})
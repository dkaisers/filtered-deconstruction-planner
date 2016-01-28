require "defines"
require "util"

MAX_CONFIG_SIZE = 8

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

		local to_deconstruct = false
		for i = 1, MAX_CONFIG_SIZE do
			if global["config"][player.name][i] == entity.name then
				to_deconstruct = true
			end
		end

		if not to_deconstruct then
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
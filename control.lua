require "util"
require "config"
require "lib"
require "gui"

-- Initializes the mod config
function fdp_init_global()
  global["config"] = global["config"] or {}
end

-- Initializes the mod config for the given player
function fdp_init_player(player)
  global["config"][player.index] = global["config"][player.index] or {}
  global["config"][player.index]["mode"] = global["config"][player.index]["mode"] or FDP_DEFAULT_FILTER_MODE
  global["config"][player.index]["filter"] = global["config"][player.index]["filter"] or {}
  global["config"][player.index]["eyedropping"] = global["config"][player.index]["eyedropping"] or false

  gui_init(player)
end

-- Initializes the mod config for all players
function fdp_init_players()
  for _, player in pairs(game.players) do
    fdp_init_player(player)
  end
end

-- Initializes the gui for all players
function fdp_init_gui()
  for _, player in pairs(game.players) do
    gui_init(player)
  end
end

-- on_init event handler
script.on_init(function()
    fdp_init_global()
    fdp_init_players()
    fdp_init_gui()
  end)

-- on_configuration_changed event handler
script.on_configuration_changed(function(data)
    if not data or not data.mod_changes then
      return
    end

    if data.mod_changes["filtered-deconstruction-planner"] and data.mod_changes["filtered-deconstruction-planner"].old_version then
      if data.mod_changes["filtered-deconstruction-planner"].old_version < "0.4.7" then
        global["config"] = {}
      end
    end

    for _, player in pairs(game.players) do
      if global ~= nil and global["config"] ~= nil and global["config"][player.index] ~= nil and global["config"][player.index]["filter"] ~= nil then
        for i = #global["config"][player.index]["filter"], 1, -1 do
          if not player.gui.is_valid_sprite_path(get_sprite_for_filter(global["config"][player.index]["filter"][i])) then
            table.remove(global["config"][player.index]["filter"], i)
          end
        end
      end
    end

    fdp_init_global()
    fdp_init_players()
    fdp_init_gui()
  end)

-- on_player_create event handler
script.on_event(defines.events.on_player_created, function(event)
    fdp_init_player(game.players[event.player_index])
  end)

-- on_research_finished event handler
script.on_event(defines.events.on_research_finished, function(event)
    if event.research.name == 'automated-construction' then
      for _, player in pairs (event.research.force.players) do
        gui_init(player, true)
      end
    end
  end)

-- on_gui_click event handler
script.on_event(defines.events.on_gui_click, function(event)
    local event_element = event.element.name
    local event_player = game.players[event.player_index]
    if not global["config"][event_player.index] then
      fdp_init_player(event_player)
    end

    if event_element == "fdp-gui-button" then
      game.raise_event(FDP_EVENTS.on_gui_clicked, {player = event_player})
    elseif event_element == "fdp-gui-normal-checkbox" then
      game.raise_event(FDP_EVENTS.on_mode_changed, {player = event_player, mode = "normal"})
    elseif event_element == "fdp-gui-target-checkbox" then
      game.raise_event(FDP_EVENTS.on_mode_changed, {player = event_player, mode = "target"})
    elseif event_element == "fdp-gui-exclude-checkbox" then
      game.raise_event(FDP_EVENTS.on_mode_changed, {player = event_player, mode = "exclude"})
    elseif string.sub(event_element, 1, string.len("fdp-gui-filter-")) == "fdp-gui-filter-" then
      local event_index = string.match(event_element, "fdp%-gui%-filter%-*(%d)")
      if event_index then
        game.raise_event(FDP_EVENTS.on_button_filter_clicked, {player = event_player, index = event_index})
      end
    elseif event_element == "fdp-gui-eyedropper-button" then
      game.raise_event(FDP_EVENTS.on_button_eyedropper_clicked, {player = event_player})
    elseif event_element == "fdp-gui-clear-button" then
      game.raise_event(FDP_EVENTS.on_button_clear_clicked, {player = event_player})
    elseif event_element == "fdp-gui-cut-button" then
      game.raise_event(FDP_EVENTS.on_button_cut_clicked, {player = event_player})
    end
  end)

-- on_marked_for_deconstruction event handler
script.on_event(defines.events.on_marked_for_deconstruction, function(event)
    if not event.player_index then
      return
    end
    local player = game.players[event.player_index]

    if not global["config"][player.index] then
      fdp_init_player(player)
    end

    if global["config"][player.index]["mode"] == "normal" and not global["config"][player.index]["eyedropping"] then
      return
    end

    local entity_name = get_entity_name(event.entity)
    local is_configured = is_in_filter(player, entity_name)

    if global["config"][player.index]["eyedropping"] then
      event.entity.cancel_deconstruction(player.force)
      if not is_configured then
        table.insert(global["config"][player.index]["filter"], entity_name)
      end
      gui_refresh(player)
    else
      if global["config"][player.index]["mode"] == "target" and not is_configured then
        event.entity.cancel_deconstruction(player.force)
      elseif global["config"][player.index]["mode"] == "exclude" and is_configured then
        event.entity.cancel_deconstruction(player.force)
      end
    end
  end)

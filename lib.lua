-- Give LuaEntity and get the corresponding entity-name for the filter
-- Different tree entities get pooled under "fdp-tree-proxy"
function get_entity_name(entity)
	if not entity then
		return nil
	elseif entity.name == "item-on-ground" then
		return entity.stack.name
	elseif not string.find(entity.name, "rock") and entity.type == "tree" then
		return "fdp-tree-proxy"
	else
		return entity.name
	end
end

-- Check if the given entity-name is in the current filter configuration
function is_in_filter(player, entity_name)
	for _, filter_name in pairs(global["config"][player.name]["filter"]) do
		if filter_name == entity_name then
			return true
		end
	end

	return false
end

-- Removes an item from all player inventories and returns true if at least one was removed
function remove_from_player(player, item)
	local count = 0

	for _, inventory in pairs({defines.inventory.player_main, defines.inventory.player_quickbar, defines.inventory.player_trash}) do
		if player.get_inventory(inventory).get_item_count(item) > 0 then
			count = count + player.get_inventory(inventory).remove({name = item, count = 9999})
		end
	end

	return count > 0
end
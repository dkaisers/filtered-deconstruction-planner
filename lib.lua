-- Give LuaEntity and get the corresponding entity-name for the filter
-- Different tree entities get pooled under "fdp-tree-proxy"
function get_entity_name(entity)
  if not entity then
    return nil
  elseif entity.name == "item-on-ground" then
    return entity.stack.name
  elseif entity.type == "tree" then
    return "fdp-tree-proxy"
  else
    return entity.name
  end
end

-- Check if the given entity-name is in the current filter configuration
function is_in_filter(player, entity_name)
  for i = 1, #global["config"][player.index]["filter"] do
    if global["config"][player.index]["filter"][i] == entity_name then
      return true
    end
  end

  return false
end

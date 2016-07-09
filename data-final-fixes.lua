for typename, sometype in pairs(data.raw) do
  local _, object = next(sometype)
  for name, item in pairs(sometype) do
    if item.icon then
      local style = {
        type = "checkbox_style",
        parent = "fdp-icon-style",
        default_background = {
          filename = item.icon,
          width = 32,
          height = 32,
          scale = 1.75
        },
        hovered_background = {
          filename = item.icon,
          width = 32,
          height = 32,
          scale = 1.75
        },
        checked_background = {
          filename = item.icon,
          width = 32,
          height = 32
        },
        clicked_background = {
          filename = item.icon,
          width = 32,
          height = 32
        }
      }
      data.raw["gui-style"].default["fdp-icon-"..name] = style
    end
  end
end

data.raw["gui-style"].default["fdp-icon-style"] = {
  type = "checkbox_style",
  parent = "checkbox_style",
  width = 32,
  height = 32,
  bottom_padding = 8,
  default_background = {
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    width = 32,
    height = 32,
    x = 111
  },
  hovered_background = {
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    width = 32,
    height = 32,
    x = 111
  },
  clicked_background = {
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    width = 32,
    height = 32,
    x = 111
  },
  checked = {
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    width = 32,
    height = 32,
    x = 111
  }
}

data.raw["gui-style"].default["fdp-icon-fdp-tree-proxy"] = {
  type = "checkbox_style",
  parent = "fdp-icon-style",
  width = 32,
  height = 32,
  bottom_padding = 8,
  default_background = {
    filename = "__base__/graphics/icons/tree-03.png",
    width = 32,
    height = 32
  },
  hovered_background = {
    filename = "__base__/graphics/icons/tree-03.png",
    width = 32,
    height = 32
  },
  clicked_background = {
    filename = "__base__/graphics/icons/tree-03.png",
    width = 32,
    height = 32
  },
  checked = {
    filename = "__base__/graphics/icons/tree-03.png",
    width = 32,
    height = 32
  }
}

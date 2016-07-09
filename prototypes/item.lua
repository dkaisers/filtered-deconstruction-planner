data:extend({
    {
      type = "deconstruction-item",
      name = "filtered-deconstruction-planner",
      icon = "__filtered-deconstruction-planner__/graphics/icon.png",
      flags = {"goes-to-quickbar"},
      subgroup = "tool",
      order = "c[automated-construction]-b[filtered-deconstruction-planner]",
      stack_size = 1,
      selection_color = { r = 1, g = 0, b = 0 },
      alt_selection_color = { r = 0, g = 0, b = 1 },
      selection_mode = {"deconstruct"},
      alt_selection_mode = {"cancel-deconstruct"},
      selection_cursor_box_type = "not-allowed",
      alt_selection_cursor_box_type = "not-allowed"
    }
  })

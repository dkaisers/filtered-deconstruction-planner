data:extend(
{
	{
		type = "decorative",
		name = "fdp-eyedropper-proxy",
		icon = "__filtered-deconstruction-planner__/graphics/icon-eyedropper.png",
		flags = {"placeable-neutral", "not-on-map"},
		collision_mask = {"ghost-layer"},
		collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
		selection_box = {{-0.1, -0.1}, {0.1, 0.1}},
		selectable_in_game = false,
		render_layer = "cursor",
		pictures = {
			filename = "__filtered-deconstruction-planner__/graphics/icon-eyedropper.png",
			width = 32,
			height = 32
		}
	}
})
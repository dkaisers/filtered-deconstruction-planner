data:extend(
{
	{
		type = "deconstruction-item",
		name = "filtered-deconstruction-planner",
		icon = "__filtered-deconstruction-planner__/graphics/icon.png",
		flags = {"goes-to-quickbar"},
		subgroup = "tool",
		order = "c[automated-construction]-b[filtered-deconstruction-planner]",
		stack_size = 1
	},
	{
		type = "item",
		name = "fdp-eyedropper",
		icon = "__filtered-deconstruction-planner__/graphics/icon-eyedropper.png",
		flags = { "goes-to-quickbar" },
		stack_size = 1,
		place_result = "fdp-eyedropper-proxy"
	}
}
)
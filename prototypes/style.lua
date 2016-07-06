data:extend({
	{
		type = "font",
		name = "fdp-small-font",
		from = "default",
		size = 16
	},
    {
        type = "font",
        name = "fdp-mini-font",
        from = "default",
        size = 4
    }
})

-- Mini label to force line break after configuration slots
data.raw["gui-style"].default["fdp-mini-label"] = {
    type   = "label_style",
    parent = "label_style",
    font   = "fdp-mini-font",
}

-- Insert GUI button styles
local modes = {
    "normal",
    "target",
    "exclude",
    "eyedropper"
}

for _, mode in pairs(modes) do
    data.raw["gui-style"].default["fdp-gui-button-"..mode] = {
        type   = "button_style",
        parent = "button_style",
        width  = 33,
        height = 33,
        font   = "fdp-small-font",
        top_padding    = 6,
        right_padding  = 6,
        bottom_padding = 6,
        left_padding   = 0,
        default_graphical_set = {
            type = "monolith",
            monolith_image = {
                filename = "__filtered-deconstruction-planner__/graphics/gui-"..mode..".png",
                priority = "extra-high-no-scale",
                width    = 32,
                height   = 32,
                x        = 0
            }
        },
        hovered_graphical_set = {
            type = "monolith",
            monolith_image = {
                filename = "__filtered-deconstruction-planner__/graphics/gui-"..mode..".png",
                priority = "extra-high-no-scale",
                width    = 32,
                height   = 32,
                x        = 32
            }
        },
        clicked_graphical_set = {
            type = "monolith",
            monolith_image = {
                filename = "__filtered-deconstruction-planner__/graphics/gui-"..mode..".png",
                priority = "extra-high-no-scale",
                width    = 32,
                height   = 32,
                x        = 32
            }
        }
    }
end

-- Insert eyedropper and trash buttons
local buttons = {
    {key = "eyedropper-activate",   filename = "eyedropper", x = {default =  0, hovered = 30, clicked = 60}},
    {key = "eyedropper-deactivate", filename = "eyedropper", x = {default = 60, hovered = 30, clicked =  0}},
    {key = "clear",                 filename = "clear",      x = {default =  0, hovered = 30, clicked = 30}},
    {key = "cut",                   filename = "cut",        x = {default =  0, hovered = 30, clicked = 30}}
}

for _, button in pairs(buttons) do
    data.raw["gui-style"].default["fdp-button-"..button.key] = {
        type   = "button_style",
        parent = "button_style",
        width  = 32,
        height = 32,
        default_graphical_set = {
            type = "monolith",
            monolith_image = {
                filename = "__filtered-deconstruction-planner__/graphics/button-"..button.filename..".png",
                priority = "extra-high-no-scale",
                width    = 30,
                height   = 30,
                x        = button.x.default
            }
        },
        hovered_graphical_set = {
            type = "monolith",
            monolith_image = {
                filename = "__filtered-deconstruction-planner__/graphics/button-"..button.filename..".png",
                priority = "extra-high-no-scale",
                width    = 30,
                height   = 30,
                x        = button.x.hovered
            }
        },
        clicked_graphical_set = {
            type = "monolith",
            monolith_image = {
                filename = "__filtered-deconstruction-planner__/graphics/button-"..button.filename..".png",
                priority = "extra-high-no-scale",
                width    = 30,
                height   = 30,
                x        = button.x.clicked
            }
        }
    }
end
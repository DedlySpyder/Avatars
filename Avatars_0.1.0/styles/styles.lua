data:extend(
{
  {
    type = "font",
    name = "font-button-control",
    from = "default",
    size = 12
  },
  {
    type = "font",
    name = "font-button-change-page",
    from = "default",
    size = 12
  },
  {
    type = "font",
    name = "font-label-center",
    from = "default",
    align = "center",
	size = 16
  }
})

data.raw["gui-style"].default["avatar_table"] =
{
    type = "table_style",
	font = "font-label-center",
    minimal_height = 100,
    cell_padding = 2,
    horizontal_spacing=4,
    vertical_spacing=0,
	align = "center",
	text_align = "center",
    column_graphical_set =
    {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {8, 0}
    }
}

data.raw["gui-style"].default["avatar_label_center"] =
{
	type = "label_style",
	font = "font-label-center",
	align = "center",
	text_align = "center"
}

data.raw["gui-style"].default["avatar_button_rename"] =
{
    type = "button_style",
    parent = "button_style",
    width = 22,
    height = 22,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
	default_graphical_set = {
      type = "monolith",
      monolith_image = {
         filename = "__Avatars__/graphics/gui-rename.png",
         width = 22,
         height = 22
      }
   },
   hovered_graphical_set = {
      type = "monolith",
      monolith_image = {
         filename = "__Avatars__/graphics/gui-rename-hover.png",
         width = 22,
         height = 22
      }
   },
   clicked_graphical_set = {
      type = "monolith",
      monolith_image = {
         filename = "__Avatars__/graphics/gui-rename-clicked.png",
         width = 22,
         height = 22
      }
   }
}

data.raw["gui-style"].default["avatar_button_control"] =
{
    type = "button_style",
    parent = "button_style",
	font = "font-button-control",
    width = 100,
    height = 24,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0
}

data.raw["gui-style"].default["avatar_button_change_page"] =
{
    type = "button_style",
    parent = "button_style",
	font = "font-button-change-page",
    width = 20,
    height = 26,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0
}
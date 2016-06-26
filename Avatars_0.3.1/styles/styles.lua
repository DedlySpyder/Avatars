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
    name = "font-table",
    from = "default",
    align = "center",
	size = 16
  }
})

--General style for the table's labels
data.raw["gui-style"].default["avatar_table_general"] =
{
	type = "label_style",
	font = "font-table",
	align = "center",
	text_align = "center"
}

--Style for the checkboxes
data.raw["gui-style"].default["avatar_table_checkbox_general"] =
{
	type = "checkbox_style",
	top_padding = 35
}

data.raw["gui-style"].default["avatar_table_checkbox_top"] =
{
	type = "checkbox_style",
	top_padding = 15
}

data.raw["gui-style"].default["avatar_table_checkbox_bottom"] =
{
	type = "checkbox_style",
	top_padding = 3
}

data.raw["gui-style"].default["avatar_table_header_flow_top_padding"] =
{
	type = "flow_style",
	top_padding = 13
}

data.raw["gui-style"].default["avatar_table_header_label_general"] =
{
	type = "label_style",
	font = "font-table",
	align = "center",
	text_align = "center",
	--top_padding = 15
}

--Header for the Avatar Name column **This may throw off localized versions**
data.raw["gui-style"].default["avatar_table_header_avatar_name"] =
{
	type = "label_style",
	font = "font-table",
	align = "center",
	text_align = "center",
	left_padding = table_avatar_name_header_left_padding,
	--top_padding = 8
}

data.raw["gui-style"].default["avatar_table_header_avatar_distance"] =
{
	type = "label_style",
	font = "font-table",
	align = "center",
	text_align = "center",
	width = 140,
	--top_padding = 15
}

--Label for the number column
data.raw["gui-style"].default["avatar_table_label_avatar_number"] =
{
	type = "label_style",
	font = "font-table",
	align = "center",
	text_align = "center",
	width = 25
}

--Label for the individual names
--This stops the label from pushing the rename button under the other columns
--Name Length is approximately 30 before it runs under other elements
data.raw["gui-style"].default["avatar_table_label_avatar_name"] =
{
	type = "label_style",
	font = "font-table",
	width = table_avatar_name_labels_width
}

--Configures the entire Avatar Name column 
data.raw["gui-style"].default["avatar_table_avatar_name_frame"] =
{
    type = "frame_style",
    parent = "frame_style",
	font = "font-table",
    width = table_avatar_name_column_width,
	align = "center"
}

--Label for the locations
data.raw["gui-style"].default["avatar_table_label_avatar_distance"] =
{
	type = "label_style",
	font = "font-table",
	width = 140
}

--Configures the entire Avatar Location column 
data.raw["gui-style"].default["avatar_table_avatar_distance_frame"] =
{
    type = "frame_style",
    parent = "frame_style",
	font = "font-table",
    width = 165,
	align = "center"
}

--Rename button
data.raw["gui-style"].default["avatar_table_button_rename"] =
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
         filename = "__Avatars__/graphics/gui/gui-rename.png",
         width = 22,
         height = 22
      }
   },
   hovered_graphical_set = {
      type = "monolith",
      monolith_image = {
         filename = "__Avatars__/graphics/gui/gui-rename-hover.png",
         width = 22,
         height = 22
      }
   },
   clicked_graphical_set = {
      type = "monolith",
      monolith_image = {
         filename = "__Avatars__/graphics/gui/gui-rename-clicked.png",
         width = 22,
         height = 22
      }
   }
}

--Control button
data.raw["gui-style"].default["avatar_table_button_control"] =
{
    type = "button_style",
    parent = "button_style",
	font = "font-button-control",
    width = 100,
    height = 25,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0
}

--Change page button
data.raw["gui-style"].default["avatar_table_button_change_page"] =
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

--Total avatars footer
data.raw["gui-style"].default["avatar_table_total_avatars"] =
{
	type = "label_style",
	font = "font-table",
	left_padding = 5
}

--ARDU current name
data.raw["gui-style"].default["avatar_ARDU_current_name"] =
{
	type = "label_style",
	minimal_width = 200
}
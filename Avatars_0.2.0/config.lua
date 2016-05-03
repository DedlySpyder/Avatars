--GUI
--This number sizes the column for avatar names
--The number is about charactarers/10 (so default of 300 means about a 30 character length on each name)
table_avatar_name_column_width = 300

--This is the width of each item in the Avatar Name column
--This needs to be 50 less than the total column width
table_avatar_name_labels_width = 250

--Width of the Avatar Location column and labels
table_avatar_location_column_width = 150
table_avatar_location_labels_width = 140

--This is how many avatars are shown per page
table_avatars_per_page = 10

--The default name that the avatars will spawn with, with an incrementing number afterward
default_avatar_name = "Avatar #"

--Avatar color, using RGBA values
avatarTint = {r = 188, g = 198, b = 204, a = 1.0}


--This may need changed if translated to other languages
--If the translated header runs off the column, then lower this
--Requires a full game restart when changed
table_avatar_name_header_left_padding = 40 

--DEBUG MODE
debug_mode = false
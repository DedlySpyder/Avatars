data:extend({
	{
		name = "Avatars_debug_mode",
		type = "bool-setting",
		setting_type = "runtime-global",
		default_value = false
	},
	{
		name = "Avatars_default_avatar_name",
		type = "string-setting",
		setting_type = "runtime-global",
		default_value = "Avatar #"
	},
	{
		name = "Avatars_default_avatar_remote_deployment_unit_name",
		type = "string-setting",
		setting_type = "runtime-global",
		default_value = "ARDU #"
	},
	{
		name = "Avatars_default_avatar_remote_deployment_unit_name_deployed_prefix",
		type = "string-setting",
		setting_type = "runtime-global",
		default_value = "Mk"
	},
	{
		name = "Avatars_avatar_color_red",
		type = "double-setting",
		setting_type = "startup",
		default_value = "0.737",
		minimum_value = "0",
		maximum_value = "1"
	},
	{
		name = "Avatars_avatar_color_green",
		type = "double-setting",
		setting_type = "startup",
		default_value = "0.776",
		minimum_value = "0",
		maximum_value = "1"
	},
	{
		name = "Avatars_avatar_color_blue",
		type = "double-setting",
		setting_type = "startup",
		default_value = "0.90",
		minimum_value = "0",
		maximum_value = "1"
	},
	{
		name = "Avatars_avatar_color_alpha",
		type = "double-setting",
		setting_type = "startup",
		default_value = "0.7",
		minimum_value = "0",
		maximum_value = "1"
	}
})

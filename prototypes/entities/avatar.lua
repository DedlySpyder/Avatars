local avatar_tint = {
	r = settings.startup["Avatars_avatar_color_red"].value,
	g = settings.startup["Avatars_avatar_color_green"].value,
	b = settings.startup["Avatars_avatar_color_blue"].value,
	a = settings.startup["Avatars_avatar_color_alpha"].value
}

avatar_animations = util.table.deepcopy(data.raw["character"]["character"]["animations"])
avatar_corpse_pictures = util.table.deepcopy(data.raw["character-corpse"]["character-corpse"]["pictures"])

function updateTint(animations)
	if "table" == type(animations) then
		for _, value in pairs(animations) do
			if "table" == type(value) then
				if value["apply_runtime_tint"] then
					value["tint"] = avatar_tint
					value["apply_runtime_tint"] = false
				end
				updateTint(value)
			end
		end
	end
end
updateTint(avatar_animations)
updateTint(avatar_corpse_pictures)

local avatar_corpse = util.table.deepcopy(data.raw["character-corpse"]["character-corpse"])

avatar_corpse.name = "avatar-corpse"
avatar_corpse.pictures = avatar_corpse_pictures

local avatar = util.table.deepcopy(data.raw["character"]["character"])

avatar.name = "avatar"
avatar.flags = {"placeable-off-grid", "player-creation", "not-flammable"}
avatar.minable = {hardness = 0.2, mining_time = 2, result = "avatar"}
avatar.alert_when_damaged = true
avatar.healing_per_tick = 0
avatar.crafting_categories = {"crafting"}
avatar.mining_categories = {"basic-solid"}
avatar.character_corpse = "avatar-corpse"
avatar.heartbeat = { { filename = "__Avatars__/sounds/fizzle.wav" } }
avatar.animations = avatar_animations

data:extend ({ avatar_corpse })
data:extend ({ avatar })

local avatar_corpse = util.table.deepcopy(data.raw["character-corpse"]["character-corpse"])

avatar_corpse.name = "avatar-corpse"
avatar_corpse.pictures =
{
  {
	layers =
	{
	  avataranimations.level1.dead,
	  avataranimations.level1.dead_mask,
	  avataranimations.level1.dead_shadow,
	}
  },
  {
	layers =
	{
	  avataranimations.level1.dead,
	  avataranimations.level1.dead_mask,
	  avataranimations.level2addon.dead,
	  avataranimations.level2addon.dead_mask,
	  avataranimations.level1.dead_shadow,
	}
  },
  {
	layers =
	{
	  avataranimations.level1.dead,
	  avataranimations.level1.dead_mask,
	  avataranimations.level3addon.dead,
	  avataranimations.level3addon.dead_mask,
	  avataranimations.level1.dead_shadow,
	}
  }
}

local avatar = util.table.deepcopy(data.raw["player"]["player"])

avatar.name = "avatar"
avatar.flags = {"placeable-off-grid", "player-creation", "not-flammable"}
avatar.minable = {hardness = 0.2, mining_time = 2, result = "avatar"}
avatar.alert_when_damaged = true
avatar.healing_per_tick = 0
avatar.crafting_categories = {"crafting"}
avatar.mining_categories = {"basic-solid"}
avatar.character_corpse = "avatar-corpse"
avatar.heartbeat = { { filename = "__Avatars__/sounds/fizzle.wav" } }
avatar.animations =
{
  {
	idle =
	{
	  layers =
	  {
		avataranimations.level1.idle,
		avataranimations.level1.idle_mask,
		avataranimations.level1.idle_shadow,
	  }
	},
	idle_with_gun =
	{
	  layers =
	  {
		avataranimations.level1.idle_gun,
		avataranimations.level1.idle_gun_mask,
		avataranimations.level1.idle_gun_shadow,
	  }
	},
	mining_with_hands =
	{
	  layers =
	  {
		avataranimations.level1.mining_hands,
		avataranimations.level1.mining_hands_mask,
		avataranimations.level1.mining_hands_shadow,
	  }
	},
	mining_with_tool =
	{
	  layers =
	  {
		avataranimations.level1.mining_tool,
		avataranimations.level1.mining_tool_mask,
		avataranimations.level1.mining_tool_shadow,
	  }
	},
	running_with_gun =
	{
	  layers =
	  {
		avataranimations.level1.running_gun,
		avataranimations.level1.running_gun_mask,
		avataranimations.level1.running_gun_shadow,
	  }
	},
	running =
	{
	  layers =
	  {
		avataranimations.level1.running,
		avataranimations.level1.running_mask,
		avataranimations.level1.running_shadow,
	  }
	}
  },
  {
	-- heavy-armor is not in the demo
	armors = data.is_demo and {"light-armor"} or {"light-armor", "heavy-armor"},
	idle =
	{
	  layers =
	  {
		avataranimations.level1.idle,
		avataranimations.level1.idle_mask,
		avataranimations.level2addon.idle,
		avataranimations.level2addon.idle_mask,
		avataranimations.level1.idle_shadow,
	  }
	},
	idle_with_gun =
	{
	  layers =
	  {
		avataranimations.level1.idle_gun,
		avataranimations.level1.idle_gun_mask,
		avataranimations.level2addon.idle_gun,
		avataranimations.level2addon.idle_gun_mask,
		avataranimations.level1.idle_gun_shadow,
	  }
	},
	mining_with_hands =
	{
	  layers =
	  {
		avataranimations.level1.mining_hands,
		avataranimations.level1.mining_hands_mask,
		avataranimations.level2addon.mining_hands,
		avataranimations.level2addon.mining_hands_mask,
		avataranimations.level1.mining_hands_shadow,
	  }
	},
	mining_with_tool =
	{
	  layers =
	  {
		avataranimations.level1.mining_tool,
		avataranimations.level1.mining_tool_mask,
		avataranimations.level2addon.mining_tool,
		avataranimations.level2addon.mining_tool_mask,
		avataranimations.level1.mining_tool_shadow,
	  }
	},
	running_with_gun =
	{
	  layers =
	  {
		avataranimations.level1.running_gun,
		avataranimations.level1.running_gun_mask,
		avataranimations.level2addon.running_gun,
		avataranimations.level2addon.running_gun_mask,
		avataranimations.level1.running_gun_shadow,
	  }
	},
	running =
	{
	  layers =
	  {
		avataranimations.level1.running,
		avataranimations.level1.running_mask,
		avataranimations.level2addon.running,
		avataranimations.level2addon.running_mask,
		avataranimations.level1.running_shadow,
	  }
	}
  },
  {
	-- modular armors are not in the demo
	armors = data.is_demo and {} or {"modular-armor", "power-armor", "power-armor-mk2"},
	idle =
	{
	  layers =
	  {
		avataranimations.level1.idle,
		avataranimations.level1.idle_mask,
		avataranimations.level3addon.idle,
		avataranimations.level3addon.idle_mask,
		avataranimations.level1.idle_shadow,
	  }
	},
	idle_with_gun =
	{
	  layers =
	  {
		avataranimations.level1.idle_gun,
		avataranimations.level1.idle_gun_mask,
		avataranimations.level3addon.idle_gun,
		avataranimations.level3addon.idle_gun_mask,
		avataranimations.level1.idle_gun_shadow,
	  }
	},
	mining_with_hands =
	{
	  layers =
	  {
		avataranimations.level1.mining_hands,
		avataranimations.level1.mining_hands_mask,
		avataranimations.level3addon.mining_hands,
		avataranimations.level3addon.mining_hands_mask,
		avataranimations.level1.mining_hands_shadow,
	  }
	},
	mining_with_tool =
	{
	  layers =
	  {
		avataranimations.level1.mining_tool,
		avataranimations.level1.mining_tool_mask,
		avataranimations.level3addon.mining_tool,
		avataranimations.level3addon.mining_tool_mask,
		avataranimations.level1.mining_tool_shadow,
	  }
	},
	running_with_gun =
	{
	  layers =
	  {
		avataranimations.level1.running_gun,
		avataranimations.level1.running_gun_mask,
		avataranimations.level3addon.running_gun,
		avataranimations.level3addon.running_gun_mask,
		avataranimations.level1.running_gun_shadow,
	  }
	},
	running =
	{
	  layers =
	  {
		avataranimations.level1.running,
		avataranimations.level1.running_mask,
		avataranimations.level3addon.running,
		avataranimations.level3addon.running_mask,
		avataranimations.level1.running_shadow,
	  }
	}
  }
}

data:extend ({ avatar_corpse })
data:extend ({ avatar })
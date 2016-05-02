data:extend({

 {
    type = "car",
    name = "avatar-control-center",
    icon = "__Avatars__/graphics/icons/avatar-control-center.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 3, result = "avatar-control-center"},
	mined_sound = { filename = "__core__/sound/deconstruct-large.ogg" },
    max_health = 200,
    corpse = "big-remnants",
    dying_explosion = "massive-explosion",
    energy_per_hit_point = 1,
    resistances =
    {
      {
        type = "fire",
        percent = 50
      }
    },
	collision_box = {{-1.4, -1.2}, {1.5, 1.2}},
    selection_box = {{-1.65, -1.65}, {1.65, 1.75}},
    effectivity = 0,
    braking_power = "0W",
    burner =
    {
      effectivity = 0.01,
      fuel_inventory_size = 1,
    },
    consumption = "0W",
    friction = 1,
    light = {intensity = 0, size = 0},
	pictures =
    {
      filename = "__Avatars__/graphics/entity/avatar-control-center.png",
      priority = "low",
      width = 169,
      height = 140,
      apply_projection = false,
      direction_count = 64,
      line_length = 8,
    },
    animation =
    {
      layers =
      {
        {
          width = 169,
          height = 140,
          frame_count = 8,
          direction_count = 1,
		  shift = {1.2, 0.8},
          animation_speed = 5,
          max_advance = 1,
		  scale = 1,
		  priority = "extra-high",
		  filename = "__Avatars__/graphics/entity/avatar-control-center.png",
        },
      }
    },
    sound_minimum_speed = 0.2;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.75 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/radar.ogg",
        volume = 0.6
      },
      activate_sound =
      {
        filename = "__base__/sound/radar.ogg",
        volume = 0
      },
      deactivate_sound =
      {
        filename = "__base__/sound/radar.ogg",
        volume = 0
      },
      match_speed_to_activity = false,
    },
    rotation_speed = 0,
    weight = 700,
    inventory_size = 0
 }
})
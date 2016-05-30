data:extend({

 {
    type = "player",
    name = "avatar",
    icon = "__base__/graphics/icons/player.png",
    flags = {"pushable", "placeable-off-grid", "player-creation"},
	minable = {hardness = 0.2, mining_time = 2, result = "avatar"},
    max_health = 100,
    alert_when_damaged = true,
    healing_per_tick = 0,
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.4, -1.4}, {0.4, 0.2}},
    crafting_categories = {"crafting"},
    mining_categories = {"basic-solid"},
    inventory_size = 60,
    build_distance = 6,
    drop_item_distance = 6,
    reach_distance = 6,
    reach_resource_distance = 2.7,
    ticks_to_keep_gun = 600,
    ticks_to_keep_aiming_direction = 100,
    damage_hit_tint = {r = 1, g = 0, b = 0, a = 0},
    running_speed = 0.15,
    distance_per_frame = 0.13,
    maximum_corner_sliding_distance = 0.7,
    subgroup = "creatures",
    order="a",
    eat =
    {
      {
        filename = "__base__/sound/eat.ogg",
        volume = 1
      }
    },
    heartbeat =
    {
      {
        filename = "__Avatars__/sounds/fizzle.wav"
      }
    },

    animations =
    {
      {
        idle =
        {
          layers =
          {
            avataranimations.level1.idle,
            avataranimations.level1.idlemask,
          }
        },
        idle_with_gun =
        {
          layers =
          {
            avataranimations.level1.idlewithgun,
            avataranimations.level1.idlewithgunmask,
          }
        },
        mining_with_hands =
        {
          layers =
          {
            avataranimations.level1.miningwithhands,
            avataranimations.level1.miningwithhandsmask,
          }
        },
        mining_with_tool =
        {
          layers =
          {
            avataranimations.level1.miningwithtool,
            avataranimations.level1.miningwithtoolmask,
          }
        },
        running_with_gun =
        {
          layers =
          {
            avataranimations.level1.runningwithgun,
            avataranimations.level1.runningwithgunmask,
          }
        },
        running =
        {
          layers =
          {
            avataranimations.level1.running,
            avataranimations.level1.runningmask,
          }
        }
      },
      {
        -- heavy-armor is not in the demo
        armors = data.is_demo and {"basic-armor"} or {"basic-armor", "heavy-armor"},
        idle =
        {
          layers =
          {
            avataranimations.level1.idle,
            avataranimations.level1.idlemask,
            avataranimations.level2addon.idle,
            avataranimations.level2addon.idlemask
          }
        },
        idle_with_gun =
        {
          layers =
          {
            avataranimations.level1.idlewithgun,
            avataranimations.level1.idlewithgunmask,
            avataranimations.level2addon.idlewithgun,
            avataranimations.level2addon.idlewithgunmask,
          }
        },
        mining_with_hands =
        {
          layers =
          {
            avataranimations.level1.miningwithhands,
            avataranimations.level1.miningwithhandsmask,
            avataranimations.level2addon.miningwithhands,
            avataranimations.level2addon.miningwithhandsmask,
          }
        },
        mining_with_tool =
        {
          layers =
          {
            avataranimations.level1.miningwithtool,
            avataranimations.level1.miningwithtoolmask,
            avataranimations.level2addon.miningwithtool,
            avataranimations.level2addon.miningwithtoolmask,
          }
        },
        running_with_gun =
        {
          layers =
          {
            avataranimations.level1.runningwithgun,
            avataranimations.level1.runningwithgunmask,
            avataranimations.level2addon.runningwithgun,
            avataranimations.level2addon.runningwithgunmask,
          }
        },
        running =
        {
          layers =
          {
            avataranimations.level1.running,
            avataranimations.level1.runningmask,
            avataranimations.level2addon.running,
            avataranimations.level2addon.runningmask,
          }
        }
      },
      {
        -- modular armors are not in the demo
        armors = data.is_demo and {} or {"basic-modular-armor", "power-armor", "power-armor-mk2"},
        idle =
        {
          layers =
          {
            avataranimations.level1.idle,
            avataranimations.level1.idlemask,
            avataranimations.level3addon.idle,
            avataranimations.level3addon.idlemask
          }
        },
        idle_with_gun =
        {
          layers =
          {
            avataranimations.level1.idlewithgun,
            avataranimations.level1.idlewithgunmask,
            avataranimations.level3addon.idlewithgun,
            avataranimations.level3addon.idlewithgunmask,
          }
        },
        mining_with_hands =
        {
          layers =
          {
            avataranimations.level1.miningwithhands,
            avataranimations.level1.miningwithhandsmask,
            avataranimations.level3addon.miningwithhands,
            avataranimations.level3addon.miningwithhandsmask,
          }
        },
        mining_with_tool =
        {
          layers =
          {
            avataranimations.level1.miningwithtool,
            avataranimations.level1.miningwithtoolmask,
            avataranimations.level3addon.miningwithtool,
            avataranimations.level3addon.miningwithtoolmask,
          }
        },
        running_with_gun =
        {
          layers =
          {
            avataranimations.level1.runningwithgun,
            avataranimations.level1.runningwithgunmask,
            avataranimations.level3addon.runningwithgun,
            avataranimations.level3addon.runningwithgunmask,
          }
        },
        running =
        {
          layers =
          {
            avataranimations.level1.running,
            avataranimations.level1.runningmask,
            avataranimations.level3addon.running,
            avataranimations.level3addon.runningmask,
          }
        }
      }
    },
    light =
    {
      {
        minimum_darkness = 0.3,
        intensity = 0.4,
        size = 25,
      },
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0, -13},
        size = 2,
        intensity = 0.6
      },
    },
    mining_speed = 0.01,
    mining_with_hands_particles_animation_positions = {29, 63},
    mining_with_tool_particles_animation_positions = {28},
    running_sound_animation_positions = {5, 16}
  }
})
require ("circuit-connector-sprites")

local base_internal_car = {
	type = "car",
	icon_size = 32,
	
	flags = {"placeable-neutral", "player-creation", "not-rotatable"},
	flags = {"not-on-map", "not-blueprintable", "not-deconstructable", "hidden", "hide-alt-info", "not-flammable", "no-automated-item-removal", "no-automated-item-insertion", "no-copy-paste", "not-selectable-in-game", "not-upgradable", "not-in-kill-statistics"},
	max_health = 2147483648,
	collision_mask = {},
	
	-- Vehicle
	weight = 0.1,
	braking_power = "1W",
	friction = 0.1,
	energy_per_hit_point = 1,
	
	-- Car
	animation = {
		filename = "__Avatars__/graphics/entity/avatar-control-center.png", --TODO give this a null image
		direction_count = 1,
		size = 1
	},
	effectivity = 0,
	consumption = "0W",
	rotation_speed = 0,
	energy_source = {
		type = "void"
	},
	inventory_size = 0,
}

function make_internal_car(base_entity_name)
	local new_entity = util.table.deepcopy(base_internal_car)
	new_entity["name"] = base_entity_name .. "-internal"
	return new_entity
end

local vehicle_impact_sound = {
	{
		filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.5
	},
	{
		filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.5
	},
	{
		filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.5
	},
	{
		filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.5
	},
	{
		filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.5
	}
}

data:extend({
	{
		type = "simple-entity-with-force",
		name = "avatar-control-center",
		icon = "__Avatars__/graphics/icons/avatar-control-center.png",
		icon_size = 32,
		flags = {"not-rotatable", "placeable-player", "player-creation", "not-upgradable"},
		minable = {mining_time = 1, result = "avatar-control-center"},
		mined_sound = { filename = "__core__/sound/deconstruct-large.ogg" },
		max_health = 200,
		corpse = "big-remnants",
		dying_explosion = "massive-explosion",
		resistances = {
			{
				type = "fire",
				percent = 70
			},
			{
				type = "impact",
				percent = 30
			}
		},
		collision_box = {{-1.4, -1.2}, {1.5, 1.2}},
		selection_box = {{-1.65, -1.65}, {1.65, 1.75}},
		animations = {
			width = 169,
			height = 140,
			frame_count = 64,
			line_length = 8,
			shift = {1.2, 0.8},
			animation_speed = 0.5,
			scale = 1,
			filename = "__Avatars__/graphics/entity/avatar-control-center.png",
		},
		vehicle_impact_sound = vehicle_impact_sound
	},
	{
		type = "container",
		name = "avatar-remote-deployment-unit",
		icon = "__Avatars__/graphics/icons/avatar-remote-deployment-unit.png",
		icon_size = 32,
		flags = {"not-rotatable", "placeable-player", "player-creation", "not-upgradable"},
		minable = {mining_time = 1, result = "avatar-remote-deployment-unit"},
		mined_sound = { filename = "__core__/sound/deconstruct-large.ogg" },
		max_health = 200,
		corpse = "big-remnants",
		dying_explosion = "massive-explosion",
		resistances = {
			{
				type = "fire",
				percent = 70
			},
			{
				type = "impact",
				percent = 30
			}
		},
		collision_box = {{-1.4, -1.2}, {0.6, 1.2}},
		selection_box = {{-1.65, -1.65}, {0.75, 1.75}},
		picture = {
			filename = "__Avatars__/graphics/entity/avatar-remote-deployment-unit.png",
			width = 160,
			height = 128,
			shift = {0.3, 0},
			scale = 0.75
		},
		vehicle_impact_sound = vehicle_impact_sound,
		inventory_size = 3,
		circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
		circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
		circuit_wire_max_distance = default_circuit_wire_max_distance
	},
	make_internal_car("avatar-control-center"),
	make_internal_car("avatar-remote-deployment-unit")
})

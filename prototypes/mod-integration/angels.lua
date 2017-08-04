--Angel's Petrochem
if data.raw["fluid"]["gas-chlorine"] then
	local purified_water = "water"
	local processed_silica = "solid-resin-1" --Should never be picked honestly, Petrochem requires Refining
	
	--Angel's Refining
	if data.raw["fluid"]["water-purified"] then
		purified_water = "water-purified"
		processed_silica = "quartz"
	end
	
	--Angel's Smelting
	if data.raw["item"]["processed-silica"] then
		processed_silica = "processed-silica"
	end
	
	data:extend ({
		{
			type = "recipe",
			name = "copper-chloride",
			enabled = false,
			ingredients = 
			{
				{"copper-ore", 5},
				{type="fluid", name="gas-chlorine", amount=200}
			},
			results = {{type="fluid", name="copper-chloride", amount=5}},
			category = "chemistry",
			energy_required = 2
		},
		{
			type = "recipe",
			name = "dimethyldichlorosilane",
			enabled = false,
			ingredients = 
			{
				{processed_silica, 5},
				{type="fluid", name="gas-chlor-methane", amount=200},
				{type="fluid", name="copper-chloride", amount=50}
			},
			results = {{type="fluid", name="dimethyldichlorosilane", amount=100}},
			category = "chemistry",
			energy_required = 2
		},
		{
			type = "recipe",
			name = "silicone",
			enabled = false,
			ingredients = 
			{
				{type="fluid", name="dimethyldichlorosilane", amount=100},
				{type="fluid", name=purified_water, amount=100}
			},
			result = "silicone",
			category = "chemistry",
			energy_required = 2
		}
	})
	
	--Avatar Skin
	data.raw["recipe"]["avatar-skin"].ingredients = {
		{"silicone", 5},
		{"plastic-bar", 5}
	}
	data.raw["recipe"]["avatar-skin"].category = "chemistry"
	
	--Items & Fluids
	data:extend({
		{
			type = "fluid",
			name = "copper-chloride",
			default_temperature = 25,
			heat_capacity = "0.1KJ",
			base_color = {r=0, g=0, b=0},
			flow_color = {r=0.5, g=0.5, b=0.5},
			max_temperature = 100,
			icon = "__Avatars__/graphics/icons/copper-chloride.png",
			pressure_to_speed_ratio = 0.4,
			flow_to_energy_ratio = 0.59,
			subgroup = "avatar-silicone-product",
			order = "a[silicone]-a[copper-chloride]"
		},
		{
			type = "fluid",
			name = "dimethyldichlorosilane",
			default_temperature = 25,
			heat_capacity = "0.1KJ",
			base_color = {r=0, g=0, b=0},
			flow_color = {r=0.5, g=0.5, b=0.5},
			max_temperature = 100,
			icon = "__Avatars__/graphics/icons/dimethyldichlorosilane.png",
			pressure_to_speed_ratio = 0.4,
			flow_to_energy_ratio = 0.59,
			subgroup = "avatar-silicone-product",
			order = "a[silicone]-b[dimethyldichlorosilane]"
		},
		{
			type = "item",
			name = "silicone",
			icon = "__Avatars__/graphics/icons/silicone.png",
			flags = {"goes-to-main-inventory"},
			subgroup = "avatar-silicone-product",
			order = "a[silicone]-c[silicone]",
			stack_size = 50
		}
	})
	
	--Technology
	table.insert(data.raw["technology"]["avatars"].effects, {type = "unlock-recipe", recipe = "copper-chloride"})
	table.insert(data.raw["technology"]["avatars"].effects, {type = "unlock-recipe", recipe = "dimethyldichlorosilane"})
	table.insert(data.raw["technology"]["avatars"].effects, {type = "unlock-recipe", recipe = "silicone"})
end

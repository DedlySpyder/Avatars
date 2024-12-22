--Bob's Plates
if data.raw["item"]["nitinol-gear-wheel"] then
	if bobmods.lib then
		--Actuator
		bobmods.lib.recipe.replace_ingredient("actuator", "iron-gear-wheel", "nitinol-gear-wheel")
		table.insert(data.raw["recipe"]["actuator"].ingredients, {type="item", name="nitinol-bearing", amount=3})
		
		--ARDU
		bobmods.lib.recipe.replace_ingredient("avatar-remote-deployment-unit", "iron-gear-wheel", "nitinol-gear-wheel")
		
		--Avatar Torso
		bobmods.lib.recipe.remove_ingredient("avatar-torso", "low-density-structure")
		table.insert(data.raw["recipe"]["avatar-torso"].ingredients, {type="item", name="aluminium-plate", amount=15})
		table.insert(data.raw["recipe"]["avatar-torso"].ingredients, {type="item", name="titanium-plate", amount=5})
		
		--Avatar Internals
		bobmods.lib.recipe.replace_ingredient("avatar-internals", "low-density-structure", "titanium-plate")
		
		--Avatar Head
		bobmods.lib.recipe.replace_ingredient("avatar-head", "low-density-structure", "titanium-plate")
		
		--Avatar Leg
		bobmods.lib.recipe.remove_ingredient("avatar-leg", "low-density-structure")
		table.insert(data.raw["recipe"]["avatar-leg"].ingredients, {type="item", name="ceramic-bearing", amount=12})
		table.insert(data.raw["recipe"]["avatar-leg"].ingredients, {type="item", name="aluminium-plate", amount=7})
		table.insert(data.raw["recipe"]["avatar-leg"].ingredients, {type="item", name="titanium-plate", amount=7})
		
		--Avatar Arm
		bobmods.lib.recipe.remove_ingredient("avatar-arm", "low-density-structure")
		table.insert(data.raw["recipe"]["avatar-arm"].ingredients, {type="item", name="ceramic-bearing", amount=10})
		table.insert(data.raw["recipe"]["avatar-arm"].ingredients, {type="item", name="aluminium-plate", amount=5})
		table.insert(data.raw["recipe"]["avatar-arm"].ingredients, {type="item", name="titanium-plate", amount=5})
	end
end

--Bob's Electronics
if data.raw["item"]["advanced-processing-unit"] then
	if bobmods.lib then
		--Actuator
		table.insert(data.raw["recipe"]["actuator"].ingredients, {type="item", name="advanced-processing-unit", amount=3})
		
		--ARDU
		table.insert(data.raw["recipe"]["avatar-remote-deployment-unit"].ingredients, {type="item", name="advanced-processing-unit", amount=5})
		
		--Avatar Torso
		table.insert(data.raw["recipe"]["avatar-torso"].ingredients, {type="item", name="processing-unit", amount=10})
		table.insert(data.raw["recipe"]["avatar-torso"].ingredients, {type="item", name="advanced-processing-unit", amount=5})
		
		--Avatar Head
		table.insert(data.raw["recipe"]["avatar-head"].ingredients, {type="item", name="advanced-processing-unit", amount=50})
				
		--Avatar Leg
		table.insert(data.raw["recipe"]["avatar-leg"].ingredients, {type="item", name="processing-unit", amount=5})
		table.insert(data.raw["recipe"]["avatar-leg"].ingredients, {type="item", name="advanced-processing-unit", amount=2})
				
		--Avatar Arm
		table.insert(data.raw["recipe"]["avatar-arm"].ingredients, {type="item", name="processing-unit", amount=5})
		table.insert(data.raw["recipe"]["avatar-arm"].ingredients, {type="item", name="advanced-processing-unit", amount=3})
	end
end

--Bob's Warfare
if data.raw["item"]["radar-5"] then
	if bobmods.lib then
		--ARDU
		bobmods.lib.recipe.replace_ingredient("avatar-remote-deployment-unit", "radar", "radar-5")
		
		--Avatar Control Center
		bobmods.lib.recipe.replace_ingredient("avatar-control-center", "radar", "radar-5")
		bobmods.lib.recipe.replace_ingredient("avatar-control-center", "fusion-reactor-equipment", "fusion-reactor-equipment-4")
		bobmods.lib.recipe.replace_ingredient("avatar-control-center", "power-armor", "bob-power-armor-mk5")
		
		--Avatar Internals
		bobmods.lib.recipe.replace_ingredient("avatar-internals", "fusion-reactor-equipment", "fusion-reactor-equipment-4")
		
		--Avatar Head
		bobmods.lib.recipe.replace_ingredient("avatar-head", "radar", "radar-5")
	end
end

--Bob's Modules
if data.raw["item"]["assembling-machine-6"] then
	if bobmods.lib then
		--Avatar Internals
		bobmods.lib.recipe.replace_ingredient("avatar-internals", "effectivity-module-3", "effectivity-module-8")
		bobmods.lib.recipe.replace_ingredient("avatar-internals", "speed-module-3", "speed-module-8")
	end
end
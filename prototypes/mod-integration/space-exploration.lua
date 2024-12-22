-- Space Exploration
if mods["space-exploration"] then
	Util.Tech.addPrerequisite("avatars", "se-rtg-equipment")
	
	Util.Recipe.replaceIngredientName("avatar-control-center", "fusion-reactor-equipment", "se-rtg-equipment")
	Util.Recipe.replaceIngredientName("avatar-internals", "fusion-reactor-equipment", "se-rtg-equipment")
end

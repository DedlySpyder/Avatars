-- Space Exploration
if mods["space-exploration"] then
	Util.Tech.removePrerequisite("avatars", "fission-reactor-equipment")
	Util.Tech.addPrerequisite("avatars", "se-rtg-equipment")
	
	Util.Recipe.replaceIngredientName("avatar-control-center", "fission-reactor-equipment", "se-rtg-equipment")
	Util.Recipe.replaceIngredientName("avatar-internals", "fission-reactor-equipment", "se-rtg-equipment")
end

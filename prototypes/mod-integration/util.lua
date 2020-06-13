Util = {}

Util.Tech = {}

function Util.Tech.addPrerequisite(techName, prereq)
	table.insert(data.raw["technology"][techName].prerequisites, prereq)
end

function Util.Tech.removePrerequisite(techName, prereq)
	local newPreqs = {}
	for _, oldPrereq in ipairs(data.raw["technology"][techName].prerequisites) do
		if oldPrereq ~= prereq then
			table.insert(newPreqs, oldPrereq)
		end
	end
	data.raw["technology"]["avatars"].prerequisites = newPreqs
end

Util.Recipe = {}

function Util.Recipe.replaceIngredientName(recipeName, oldIngredient, newIngredient)
	local recipeIngredients = data.raw["recipe"][recipeName].ingredients
	
	for _, ingredient in ipairs(recipeIngredients) do
		if ingredient[1] and ingredient[1] == oldIngredient then
			ingredient[1] = newIngredient
		end
	end
end

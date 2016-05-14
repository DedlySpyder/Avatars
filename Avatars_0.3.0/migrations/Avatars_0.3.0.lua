--If recipes were changed
for i, force in pairs(game.forces) do 
	force.reset_recipes()
end

--If technologies were changed
for i, force in pairs(game.forces) do 
	force.reset_technologies()
	
	if force.technologies["avatars"].researched then
		force.recipes["avatar-remote-deployment-unit"].enabled = true
	end
end
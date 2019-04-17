AvatarControl = {}

-- Check if the player can control the avatar
--	@param avatarData - the avatars table data
--	@param playerData - the playerData table data
--	@param tick - the current tick or nil to override safety checks
--	@return - true/false if the player can control the avatar now
--			- the error message if false (in the form of a table to be used by player.print() )
AvatarControl.canGainControl = function(avatarData, playerData, tick)
	-- Make sure no one else is controlling it
	if avatarData.playerData then
		return false, {"Avatars-error-already-controlled", avatarData.playerData.player.name}
	end
		
    -- Don't bodyswap too often, Factorio hates it when you do that. -per YARM
    if not AvatarControl.isSafeToSwap(playerData, tick) then
		return false, {"Woah cowboy, slow down"} --TODO - error message about too often
	end
	
	-- Can't gain control if the player is currently in an avatar
	if (playerData.player.character.name == "avatar") then
		return false, {"Avatars-error-control-restriction"}
	end
	
	return true
end


-- We can't body swap too often, "Factorio hates it when you do that." -YARM
--	@param playerData - a player's data from the global table
--	@param tick - the current tick (nil or 0 to force a swap)
AvatarControl.isSafeToSwap = function(playerData, tick)
	if tick and tick > 0 then
		if playerData.lastBodySwap and playerData.lastBodySwap + 10 > tick then
			return false
		end
	end
	
	return true
end

-- Give control of an avatar to a player
--	@param player - a LuaPlayer object
--	@param name - the name of the avatar to control (starts with "ardu_" if it is an ARDU)
--	@param tick - the current tick (for safety checks, leave nil for a forced transfer)
AvatarControl.gainAvatarControl = function(player, name, tick)
	debugLog("Gaining control of " .. name)
	
	-- Find the avatar (deploy it from an ARDU if needed)
	local avatarData
	if string.sub(name, 1, 5) == "ardu_" then
		local arduName = string.sub(name, 6)
		avatarData = Deployment.getOrDeploy(player, arduName)
		
		-- More granular error messages are given by the Deployment function
		if not avatarData then return false end
	else
		avatarData = Storage.Avatars.getByName(name)
	end
	
	local playerData = Storage.PlayerData.getOrCreate(player)
	
	-- See if the player can swap with the avatar
	local canGainControl, err = AvatarControl.canGainControl(avatarData, playerData, tick)
	if not canGainControl then
		player.print(err)
		return false
	end
	
	local avatarControlCenter = player.vehicle
	
	-- Store the real body
	playerData.realBody = player.character
	
	-- Give the avatar to the player
	playerData.currentAvatarData = avatarData
	avatarData.playerData = playerData
	
	-- Final sanity check (to make sure this can be reversed)
	if not playerData.realBody or not playerData.currentAvatarData then
		player.print{"Fuck, something went wrong"} --TODO - fatal unknown error
		return false
	end
	
	if tick then
		playerData.lastBodySwap = tick
	else
		playerData.lastBodySwap = game.tick
	end
	
	avatarData.entity.active = true
	player.character = avatarData.entity
	--TODO - this (and the variable at the beginning of the function) need more research for a MP game, but can remove the body swap if it works fine)
	--avatarControlCenter.set_driver(playerData.realBody) --TODO - oh, that was easy... (how does this work for disconnects though in MP? / How did it work before this?)
	
	-- GUI clean up
	GUI.destroyAll(player)
	GUI.Disconnect.draw(player)
	return true
end

-- Take control from a player
--	@param player - a LuaPlayer object
--	@param tick - the current tick (for safety checks, leave nil for a forced transfer)
AvatarControl.loseAvatarControl = function(player, tick)
	debugLog("Going back to the body")
	
	local playerData = Storage.PlayerData.getOrCreate(player)
	
	-- Test to make sure that player is controlling an avatar
	-- Otherwise there are issues with other control changing mods
	if player.character and player.character.name ~= "avatar" then
		player.print{"Avatars-error-cannot-disconnect-from-nonavatar"}
		return false
	end
	
	if not AvatarControl.isSafeToSwap(playerData, tick) then
		player.print{"Woah cowboy, slow down"} --TODO - error message about too often
		return false
	end
	
	-- Check for the avatarEntity to exist or not
	-- If a player disconnects, it removes the avatarEntity from the table, so it has to be replaced --TODO is this true?
	local avatarData = playerData.currentAvatarData
	if not avatarData.entity then
		avatarData.entity = player.character
	end
	
	--Give back the player's body
	player.character = playerData.realBody
	
	--Clear the table
	avatarData.entity.active = false
	playerData.realBody = nil
	playerData.currentAvatarData = nil
	avatarData.playerData = nil
	
	--GUI clean up
	GUI.destroyAll(player)
end

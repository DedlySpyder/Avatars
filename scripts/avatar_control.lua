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
		return false, {"Avatars-error-rapid-body-swap"}
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

-- A player cannot switch control from one surface to another (because reasons?)
-- So, if a player is gaining/losing control across a surface change, we need to give them a temporary player,
-- teleport it to the other surface, then swap them out of it and kill it
-- Simple
--	@param player - the LuaPlayer who is changing control
--	@param targetEntity - the LuaEntity they are trying to go to
AvatarControl.bodySwap = function(player, targetEntity)
	local sourceSurface = player.character.surface
	local targetSurface = targetEntity.surface
	
	if sourceSurface ~= targetSurface then
		local startingEntity = player.character
		local tempPlayer = sourceSurface.create_entity{name="fake-player", position=startingEntity.position, force=startingEntity.force}
		
		startingEntity.active = false
		player.character = tempPlayer
		
		player.teleport(targetEntity.position, targetSurface)
		
		-- tempPlayer is an invalid reference
		-- https://forums.factorio.com/viewtopic.php?t=30563
		player.character.destroy()
		player.character = targetEntity
	else
		player.character.active = false
		player.character = targetEntity
	end
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
		player.print{"Avatars-fatal-gain-control"}
		
		-- Reverse everything
		playerData.realBody = nil
		playerData.currentAvatarData = nil
		avatarData.playerData = nil
		return false
	end
	
	if tick then
		playerData.lastBodySwap = tick
	else
		playerData.lastBodySwap = game.tick
	end
	
	avatarData.entity.active = true
	AvatarControl.bodySwap(player, avatarData.entity)
	
	-- Put the player back in the ACC (Factorio boots them for disconnect reasons I think)
	-- They will be put back before a disconnect
	avatarControlCenter.set_driver(playerData.realBody)
	
	-- GUI clean up
	GUI.destroyAll(player)
	GUI.Disconnect.draw(player)
	
	-- Provide warnings
	GUI.Refresh.avatarControlChanged(player.force)
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
		player.print{"Avatars-error-rapid-body-swap"}
		return false
	end
	
	local avatarData = playerData.currentAvatarData
	
	-- Give back the player's body
	AvatarControl.bodySwap(player, playerData.realBody)
	
	-- Clear the table
	playerData.realBody.active = true
	playerData.realBody = nil
	playerData.currentAvatarData = nil
	avatarData.playerData = nil
	
	-- GUI clean up
	GUI.destroyAll(player)
	
	-- Provide warnings
	GUI.Refresh.avatarControlChanged(player.force)
end

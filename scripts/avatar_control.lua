AvatarControl = {}

-- Check if the player can control the avatar
--	@param avatarData - the avatars table data
--	@param playerData - the playerData table data
--	@param tick - the current tick or nil to override safety checks
--	@return - true/false if the player can control the avatar now
--			- the error message if false (in the form of a table to be used by player.print() )
AvatarControl.canGainControl = function(avatarData, playerData, tick)
	-- Make sure the avatar is still valid (can happen if the UI is stale)
	if not avatarData or not avatarData.entity or not avatarData.entity.valid then
		return false, {"Avatars-error-avatar-not-found"}
	end

	-- Make sure no one else is controlling it
	if avatarData.playerData then
		return false, {"Avatars-error-already-controlled", avatarData.playerData.player.name}
	elseif avatarData.entity.player then -- Catch all, in case someone is controlling it but we lost track of it
		return false, {"Avatars-error-already-controlled", avatarData.entity.player.name}
	end
		
    -- Don't bodyswap too often, Factorio hates it when you do that. -per YARM
    if not AvatarControl.isSafeToSwap(playerData, tick) then
		return false, {"Avatars-error-rapid-body-swap"}
	end

	-- Player is being cheeky and not in the control center anymore
	if not playerData.player.character or not playerData.player.character.vehicle or playerData.player.character.vehicle.name ~= "avatar-control-center" then
		return false, {"Avatars-error-not-in-control-center"}
	end
	
	-- Can't gain control if the player is currently in an avatar
	if playerData.player.character.name == "avatar" then
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
	
	-- Store the real body & quick bars
	playerData.realBody = player.character
	playerData.realBodyQuickBars = Util.getActiveQuickBars(player)
	
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
	
	-- Handle the swap
	avatarData.entity.active = true
	AvatarControl.bodySwap(player, avatarData.entity)
	Util.setActiveQuickBars(player, playerData.avatarQuickBars[avatarData.name])

	-- Associate the player to their realBody body, so we can always (?) find it
	player.associate_character(playerData.realBody)
	
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
AvatarControl.loseAvatarControl = function(player, tick, forceSwap)
	debugLog("Going back to the body")
	
	local playerData = Storage.PlayerData.getOrCreate(player)

	if not forceSwap then
		-- Test to make sure that player is controlling an avatar
		-- Otherwise there are issues with other control changing mods
		if not player.character or player.character.name ~= "avatar" then
			player.print{"Avatars-error-cannot-disconnect-from-nonavatar"}
			return false
		end

		if not AvatarControl.isSafeToSwap(playerData, tick) then
			player.print{"Avatars-error-rapid-body-swap"}
			return false
		end
	end
	
	local avatarData = playerData.currentAvatarData
	
	if not avatarData then
		debugLog("No avatar data found for " .. player.name)
		return false
	end
	
	-- Store the quickbars
	playerData.avatarQuickBars[avatarData.name] = Util.getActiveQuickBars(player)
	
	-- Give back the player's body
	AvatarControl.bodySwap(player, playerData.realBody)
	Util.setActiveQuickBars(player, playerData.realBodyQuickBars)
	
	-- Clear the table
	playerData.realBody.active = true
	playerData.realBody = nil
	playerData.currentAvatarData = nil
	avatarData.playerData = nil
	
	-- GUI clean up
	GUI.destroyAll(player)
	
	-- Provide warnings
	GUI.Refresh.avatarControlChanged(player.force)
	
	-- Reopen selection GUI
	if player.driving and player.vehicle and player.vehicle.name == "avatar-control-center" then
		GUI.Selection.draw(player)
	end
	
	debugLog(player.get_active_quick_bar_page(1))
	debugLog(player.get_active_quick_bar_page(2))
end

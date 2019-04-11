local GUI = require "scripts/gui"
local Storage = require "storage"

local AvatarControl = {}

-- We can't body swap too often, "Factorio hates it when you do that." -YARM
--	@param playerData - a player's data from the global table
--	@param tick - the current tick (nil or 0 to force a swap)
AvatarControl.isSafeToSwap = function(playerData, tick)
	if tick and tick > 0 then
		if playerData.lastBodySwap and playerData.lastBodySwap + 10 > tick then
			return false
		end
		
		playerData.lastBodySwap = tick
	else
		playerData.lastBodySwap = game.tick
	end
	
	return true
end

-- Give control of an avatar to a player
--	@param player - a LuaPlayer object
--	@param name - the name of the avatar to control
--	@param tick - the current tick (for safety checks, leave nil for a forced transfer)
AvatarControl.gainAvatarControl = function(player, name, tick)
	debugLog("Gaining control of " .. name)
	
	local avatarControlCenter = player.vehicle
	local playerData = Storage.PlayerData.getOrCreate(player)
		
    -- Don't bodyswap too often, Factorio hates it when you do that. -per YARM
    if not AvatarControl.isSafeToSwap(playerData, tick) then
		player.print{"Woah cowboy, slow down"} --TODO - error message about too often
		return false
	end
	
	if (player.character.name == "avatar") then
		player.print{"Avatars-error-control-restriction"}
		return false
	end
	
	-- Find the avatar and make sure no one else is controlling it
	local avatarData = Storage.Avatars.getByName(name)
	
	if avatarData.playerData then
		player.print{"Avatars-error-already-controlled", avatarData.playerData.player.name}
		return false
	end
	
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

return AvatarControl

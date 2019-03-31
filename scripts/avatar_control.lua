local GUI = require "scripts/gui"
local Tables = require "scripts/tables"

local AvatarControl = {}

--Avatar Control

--Give control of an avatar to a player
AvatarControl.gainAvatarControl = function(player, name, tick)
	debugLog("Gaining control of "..name)
	
	
	local playerData = Tables.PlayerData.getPlayerData(player) --{player=nil, realBody=nil, currentAvatar=nil, currentAvatarName=nil, lastBodySwap=nil}
		
    -- Don't bodyswap too often, Factorio hates it when you do that. -per YARM
    if (playerData.lastBodySwap ~= nil) and (playerData.lastBodySwap + 10 > tick) then return end
    playerData.lastBodySwap = tick
	
	if (player.character.name == "avatar") then
		player.print{"Avatars-error-control-restriction"}
		return
	end
	
	--Store the real body
	playerData.realBody = player.character
	
	--Find the avatar
	for _, avatar in ipairs(global.avatars) do
		if (avatar.name == name) then
			debugLog(avatar.name.." found")
			
			local owner = nil
			--Make sure no one else is controlling it
			for _, players in ipairs(global.avatarPlayerData) do
				if (players.currentAvatar == avatar.avatarEntity) then
					owner = players.player.name
					break
				end
			end
			
			if (owner ~= nil) then
				player.print{"Avatars-error-already-controlled", owner}
				return
			end
			--Give it to the player
			playerData.currentAvatar = avatar.avatarEntity
			playerData.currentAvatarName = avatar.name
			break
		end
	end
	
	--Final check
	if (playerData.realBody ~= nil) and (playerData.currentAvatar ~= nil) then
		debugLog("Final check")
		playerData.currentAvatar.active = true
		player.character = playerData.currentAvatar
	end
	
	--GUI clean up
	GUI.destroyAll(player)
	GUI.Disconnect.draw(player)
end

--Take control from a player
AvatarControl.loseAvatarControl = function(player, tick)
	debugLog("Going back to the body")
	
	local playerData = Tables.PlayerData.getPlayerData(player)
	
	--Test to make sure that player is controlling an avatar
	--Otherwise there are issues with other control changing mods
	if (player.character ~= nil) then --This was causing issues in MP only (must be a different way of handling death)
		if (player.character.name ~= "avatar") then
			player.print{"Avatars-error-cannot-disconnect-from-nonavatar"}
			return
		end
	end
	
	-- Don't bodyswap too often, Factorio hates it when you do that. -per YARM
	if (tick ~= 0) then
		if (playerData.lastBodySwap ~= nil) and (playerData.lastBodySwap + 10 > tick) then return end
		playerData.lastBodySwap = tick
	else
		playerData.lastBodySwap = game.tick
	end
	
	--Check for the avatarEntity to exist or not
	--If a player disconnects, it removes the avatarEntity from the table, so it has to be replaced
	for _, avatar in ipairs(global.avatars) do
		if (avatar.name == playerData.currentAvatarName) then
			avatar.avatarEntity = player.character
		end
	end
	
	--Give back the player's body
	player.character = playerData.realBody
	
	--Clear the table
	playerData.realBody = nil
	playerData.currentAvatar = nil
	playerData.currentAvatarName = nil
	
	--GUI clean up
	GUI.destroyAll(player)
end

return AvatarControl

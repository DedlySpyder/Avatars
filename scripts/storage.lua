Storage = {}

-- Initialize all of the tables, as needed
-- Tables:
--		avatars	- an array of all of the avatar entities themselves
--				- {entity, name, playerData, arduData}
--
--		avatarPlayerData	- an array of information about each player
--							- {player, realBody, currentAvatarData, lastBodySwap}
-- 							- Note: avatars and the controlling player (if one) link to each other in the tables, for easy cross reference
--
--		avatarARDUTable	- an array of information for each ARDU
--						- {entity, name, deployedAvatarData, currentIteration}

-- Counts - these are kept so that we will NEVER have a duplicate name
--		avatarDefaultCount	- a sequence count of all of the avatars ever created
--		ARDUCount	- a sequence count of all ARDUs ever created
Storage.init = function()
	-- Tables
	if not global.avatars then
		global.avatars = {}
	end
	
	if not global.avatarPlayerData then
		global.avatarPlayerData = {}
	end
	
	if not global.avatarARDUTable then
		global.avatarARDUTable = {}
	end
	
	-- Counts
	if not global.avatarDefaultCount then
		global.avatarDefaultCount = 0
	end
	
	if not global.ARDUCount then
		global.ARDUCount = 0
	end
end

-- Remove value(s) from a table, if they satify a function
--	@param tbl - a table to remove values from
--	@param func - a function to test each value against, removing the value if this function returns true
--	@return - the removed values (in an array)
Storage.removeFromTable = function(tbl, func)
	local j = 1
	local removed = {}
	
	-- For each value in tbl, if it satifies the function, then remove it
	for i = 1, #tbl do
		if func(tbl[i]) then
			table.insert(removed, tbl[i])
			tbl[i] = nil
		else
			-- If the value is to be kept, then move it up in the table if needed
			if i ~= j then
				tbl[j] = tbl[i]
				tbl[i] = nil
			end
			j = j + 1
		end
	end
	
	return removed
end



--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Avatars Global Table ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- {entity, name, playerData, arduData}
Storage.Avatars = {}

-- Add an avatar to the global table
-- 	@param avatar - a LuaEntity of the avatar
--	@return true or false if the add was successful
Storage.Avatars.add = function(avatar)
	if avatar and avatar.valid then
		debugLog("Adding avatar to the table")
		
		local currentIncrement = global.avatarDefaultCount
		local name = settings.global["Avatars_default_avatar_name"].value .. Util.formatNumberForName(currentIncrement)
		
		global.avatarDefaultCount = currentIncrement + 1
	
		table.insert(global.avatars, {entity=avatar, name=name, playerData=nil, arduData=nil})
		
		GUI.Refresh.avatarControlChanged(avatar.force)
		debugLog("Added avatar: " .. name)
		return true
	end
	
	debugLog("Could not add avatar to table, either is nil or invalid")
	return false
end

-- Remove an avatar from the global table
-- 	@param avatarEntity - a LuaEntity of the avatar
Storage.Avatars.remove = function(avatarEntity)
	debugLog("Attempting to remove avatar. Current count: " .. #global.avatars)
	local newFunction = function(arg) return arg.entity == avatarEntity end
	local removedAvatars = Storage.removeFromTable(global.avatars, newFunction)
	
	if #removedAvatars > 0 then
		GUI.Refresh.avatarControlChanged()
	end
	
	-- Clean up the ARDU data link
	for _, avatar in ipairs(removedAvatars) do
		if avatar.arduData then
			avatar.arduData.deployedAvatarData = nil
		end
	end
	
	debugLog("New count: " .. #global.avatars)
end

-- Get the value from the avatars global table, using the avatar's name
--	@param name - the name of the avatar
--	@return - the table value, or nil if not found
Storage.Avatars.getByName = function(name)
	for _, avatar in ipairs(global.avatars) do
		if avatar.name == name then
			return avatar
		end
	end
end

-- Get the value from the avatars global table, using the avatar's entity
--	@param entity - the LuaEntity of the avatar
--	@return - the table value, or nil if not found
Storage.Avatars.getByEntity = function(entity)
	for _, avatar in ipairs(global.avatars) do
		if avatar.entity == entity then
			return avatar
		end
	end
end

-- Get the value from the avatars global table, using the avatar's controlling player
--	@param player - the LuaPlayer of the avatar's controlling player
--	@return - the table value, or nil if not found
Storage.Avatars.getByPlayer = function(player)
	for _, avatar in ipairs(global.avatars) do
		if avatar.playerData.player == player then
			return avatar
		end
	end
end

-- Repairs the avatar entity reference when a player joins the game when controlling an avatar
-- Factorio basically destroys and recreates the player's character on joining a game, so if it is an avatar then the global reference to it will need repaired
-- If the avatar is missing from the table (possible if a manual repair has happened while they were gone) then it will need readded to the table
Storage.Avatars.repairOnJoinedGame = function(player)
	if player and player.valid and player.character and player.character.valid and player.character.name == "avatar" then
		debugLog("Player rejoined game while controlling an avatar")
		local avatar = Storage.Avatars.getByPlayer(player)
		
		if avatar then
			debugLog("Avatar found in current table, repairing entity reference")
			avatar.entity = player.character
		else
			debugLog("Player connected with avatar that was missing, adding it back to the table")
			Storage.Avatars.add(player.character)
		end
	end
end

-- Repairs the global avatars listing by removing invalid avatars and searching all surfaces for all avatars and adding them back to the list if they were missing
-- This is quite a resource heavy action because of the surface searches, so it shouldn't be done without player permission
Storage.Avatars.repair = function()
	local newGlobal = {}
	local removed = 0
	for _, avatar in ipairs(global.avatars) do
		local entity = avatar.entity
		if entity and entity.valid then
			table.insert(newGlobal, avatar)
		else
			debugLog("Repair: Removing invalid avatar: " .. avatar.name)
			removed = removed + 1
		end
	end
	global.avatars = newGlobal
	
	-- Search everywhere and any any missing avatars
	local added = 0
	for _, surface in pairs(game.surfaces) do
		local allAvatars = surface.find_entities_filtered({name="avatar"})
		for _, entity in ipairs(allAvatars) do
			local found = Storage.Avatars.getByEntity(entity)
			if not found then
				debugLog("Repair: Adding new avatar")
				Storage.Avatars.add(entity)
				added = added + 1
			end
		end
	end
	
	Util.printAll({"Avatars-repair-completed", removed, added})
end



--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Player Data Global Table ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- {player, realBody, currentAvatarData, lastBodySwap}
Storage.PlayerData = {}

-- Get the value from the avatarPlayerData global table, if it exists
-- Or create it otherwise
--	@param player - a LuaPlayer object
--	@return - the table value
Storage.PlayerData.getOrCreate = function(player)
	if player and player.valid then
		-- Check if the player has data in the table already
		for _, playerData in ipairs(global.avatarPlayerData) do
			if playerData.player == player then
				debugLog("PlayerData for " .. player.name .. " was found in the table")
				return playerData
			end
		end
		
		-- Create their data otherwise
		debugLog("Adding PlayerData for " .. player.name)
		local playerData = {player=player, realBody=nil, currentAvatarData=nil, lastBodySwap=nil}
		
		table.insert(global.avatarPlayerData, playerData)
		debugLog("Players in PlayerData: " .. #global.avatarPlayerData)
		
		return playerData
	end
end

-- Get the first value from the avatarPlayerData global table that satifies the provided function, or nil
--	@param func - a function to test the values against
--	@return - the table value
Storage.PlayerData.getByFunc = function(func)
	for _, playerData in ipairs(global.avatarPlayerData) do
		if func(playerData) then
			return playerData
		end
	end
end

-- Get the value from the avatarPlayerData global table, using the player's entity (checking against the realBody)
--	@param entity - the LuaEntity of the player character
--	@return - the table value, or nil if not found
Storage.PlayerData.getByEntity = function(entity)
	return Storage.PlayerData.getByFunc(function(data) return data.realBody == entity end)
end



--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ARDU Global Table ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- {entity, name, deployedAvatarData, currentIteration}
Storage.ARDU = {}

-- Add an ARDU to the global table
-- 	@param entity - a LuaEntity of the ARDU
--	@return true or false if the add was successful
Storage.ARDU.add = function(entity)
	if entity and entity.valid then
		debugLog("Adding ARDU to the table")
		
		local currentIncrement = global.ARDUCount
		local name = settings.global["Avatars_default_avatar_remote_deployment_unit_name"].value .. Util.formatNumberForName(currentIncrement)
		
		global.ARDUCount = currentIncrement + 1
	
		table.insert(global.avatarARDUTable, {
												entity=entity, 
												name=name,
												deployedAvatarData=nil,
												currentIteration=0
											 })
		debugLog("Added ARDU: " .. name)
		
		GUI.Refresh.avatarControlChanged(entity.force)
		return true
	end
	
	debugLog("Could not add ARDU to table, either is nil or invalid")
	return false
end

-- Get the first value from the avatarARDUTable global table that satifies the provided function, or nil
--	@param func - a function to test the values against
--	@return - the table value
Storage.ARDU.getByFunc = function(func)
	for _, currentARDU in ipairs(global.avatarARDUTable) do
		if func(currentARDU) then
			return currentARDU
		end
	end
end

-- Get the value from the avatarARDUTable global table, using the ARDU's entity
--	@param entity - the LuaEntity of the ARDU
--	@return - the table value, or nil if not found
Storage.ARDU.getByEntity = function(ARDU)
	return Storage.ARDU.getByFunc(function(data) return data.entity == ARDU end)
end

-- Get the value from the avatarARDUTable global table, using the ARDU's entity
--	@param name - the name of the ARDU
--	@return - the table value, or nil if not found
Storage.ARDU.getByName = function(name)
	return Storage.ARDU.getByFunc(function(data) return data.name == name end)
end

-- Remove an ARDU from the global table
-- 	@param ARDU - a LuaEntity of the ARDU
Storage.ARDU.remove = function(entity)
	debugLog("Attempting to remove ARDU. Current count: " .. #global.avatarARDUTable)
	local newFunction = function (arg) return arg.entity == entity end
	local removedArdus = Storage.removeFromTable(global.avatarARDUTable, newFunction)
	
	if #removedArdus > 0 then
		GUI.Refresh.avatarControlChanged()
	end
	
	-- Clean up the Avatar data link
	for _, ardu in ipairs(removedArdus) do
		if ardu.deployedAvatarData then
			ardu.deployedAvatarData.arduData = nil
		end
	end
	
	debugLog("New count: " .. #global.avatarARDUTable)
end

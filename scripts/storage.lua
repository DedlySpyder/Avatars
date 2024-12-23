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
	if not storage.avatars then
		storage.avatars = {}
	end
	
	if not storage.avatarPlayerData then
		storage.avatarPlayerData = {}
	end
	
	if not storage.avatarARDUTable then
		storage.avatarARDUTable = {}
	end

	if not storage.avatarMapTags then
		storage.avatarMapTags = {}
	end
	
	-- Counts
	if not storage.avatarDefaultCount then
		storage.avatarDefaultCount = 0
	end
	
	if not storage.ARDUCount then
		storage.ARDUCount = 0
	end
end


Storage.swapCharacter = function(oldCharacter, newCharacter)
	debugLog("Checking for character swap")
	local player = oldCharacter.player or newCharacter.player
	if player and player.valid then
		local playerData = Storage.PlayerData.getOrCreate(player)
		local avatarData = playerData.currentAvatarData
		if avatarData and avatarData.entity and avatarData.entity == oldCharacter then
			debugLog("Old character matches controlled avatar, swapping for new character")
			newCharacter.last_user = player
			avatarData.entity = newCharacter
		end
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

-- Remove a value from a table, if it satifies a function, using the key
--	@param tbl - a table to remove up to one value from
--	@param func - a function to test each key against, removing the value if this function returns true
--	@return - the removed key/value, if any
Storage.removeFromTableByKey = function(tbl, func)
	for k, v in pairs(tbl) do
		if func(k) then
			local removed = {}
			removed[k] = tbl[k]
			tbl[k] = nil
			
			return removed
		end
	end
end


Storage._repairMapping = {}
Storage.repairFromClone = function(source, destination)
	if source and source.valid and destination and destination.valid then
		local sourceName = source.name
		local repairFunc = Storage._repairMapping[sourceName]
		if repairFunc then
			debugLog("Repairing " .. sourceName .. " from " .. source.surface.name .. " (" .. serpent.line(source.position) .. ") to " .. destination.surface.name .. " (" .. serpent.line(destination.position) .. ")")
			repairFunc(source, destination)
		end
	end
end


--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Avatars Storage Table ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- {entity, name, playerData, arduData}
Storage.Avatars = {}

-- Add an avatar to the storage table
-- 	@param avatar - a LuaEntity of the avatar
--	@return true or false if the add was successful
Storage.Avatars.add = function(avatar)
	if avatar and avatar.valid then
		debugLog("Adding avatar to the table")
		
		local currentIncrement = storage.avatarDefaultCount
		local name = settings.global["Avatars_default_avatar_name"].value .. Util.formatNumberForName(currentIncrement)

		storage.avatarDefaultCount = currentIncrement + 1
	
		table.insert(storage.avatars, {entity=avatar, name=name, playerData=nil, arduData=nil})
		
		GUI.Refresh.avatarControlChanged(avatar.force)
		debugLog("Added avatar: " .. name)
		return true
	end
	
	debugLog("Could not add avatar to table, either is nil or invalid")
	return false
end

-- Remove an avatar from the storage table
-- 	@param avatarEntity - a LuaEntity of the avatar
Storage.Avatars.remove = function(avatarEntity)
	debugLog("Attempting to remove avatar. Current count: " .. #storage.avatars)
	local newFunction = function(arg) return arg.entity == avatarEntity end
	local removedAvatars = Storage.removeFromTable(storage.avatars, newFunction)
	
	if #removedAvatars > 0 then
		GUI.Refresh.avatarControlChanged()
	end
	
	-- Clean up references
	for _, avatar in ipairs(removedAvatars) do
		if avatar.arduData then
			avatar.arduData.deployedAvatarData = nil
		end
		
		Storage.PlayerData.migrateAvatarQuickBars(avatar.name, nil)
	end
	
	debugLog("New count: " .. #storage.avatars)
end

-- Get the value from the avatars storage table, using the avatar's name
--	@param name - the name of the avatar
--	@return - the table value, or nil if not found
Storage.Avatars.getByName = function(name)
	for _, avatar in ipairs(storage.avatars) do
		if avatar.name == name then
			return avatar
		end
	end
end

-- Get the value from the avatars storage table, using the avatar's entity
--	@param entity - the LuaEntity of the avatar
--	@return - the table value, or nil if not found
Storage.Avatars.getByEntity = function(entity)
	for _, avatar in ipairs(storage.avatars) do
		if avatar.entity == entity then
			return avatar
		end
	end
end

-- Get the value from the avatars storage table, using the avatar's controlling player
--	@param player - the LuaPlayer of the avatar's controlling player
--	@return - the table value, or nil if not found
Storage.Avatars.getByPlayer = function(player)
	for _, avatar in ipairs(storage.avatars) do
		if avatar.playerData and avatar.playerData.player == player then
			return avatar
		end
	end
end

-- Repairs the avatar entity reference when a player joins the game when controlling an avatar
-- Factorio basically destroys and recreates the player's character on joining a game, so if it is an avatar then the storage reference to it will need repaired
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

-- Repairs the storage avatars listing by removing invalid avatars and searching all surfaces for all avatars and adding them back to the list if they were missing
-- This is quite a resource heavy action because of the surface searches, so it shouldn't be done without player permission
Storage.Avatars.repair = function()
	local newStorage = {}
	local removed = 0
	for _, avatar in ipairs(storage.avatars) do
		local entity = avatar.entity
		if entity and entity.valid then
			table.insert(newStorage, avatar)
		else
			debugLog("Repair: Removing invalid avatar: " .. avatar.name)
			removed = removed + 1
		end
	end
	storage.avatars = newStorage
	
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

				local player = entity.player
				if player and player.valid then
					debugLog("Repair: New avatar is controlled by a player, linking them")
					local avatarData = Storage.Avatars.getByEntity(entity)
					local playerData = Storage.PlayerData.getByPlayer(player)
					playerData.currentAvatarData = avatarData
					avatarData.playerData = playerData
				end
			end
		end
	end
	
	Util.printAll({"Avatars-repair-completed", removed, added})
end

Storage.Avatars.repairAvatar = function(source, target)
	for _, avatar in ipairs(storage.avatars) do
		if avatar.entity == source then
			avatar.entity = target
		end
	end
end
Storage._repairMapping["avatar"] = Storage.Avatars.repairAvatar



--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Player Data Storage Table ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- {player, realBody, currentAvatarData, lastBodySwap, realBodyQuickBars, avatarQuickBars}
--	player				- LuaPlayer
--	realBody			- LuaEntity of the player's character
--	currentAvatarData	- storage.avatars entry
--	lastBodySwap		- tick of last body swap
--	realBodyQuickBars	- array of active quick bar indicies, in order
--	avatarQuickBars		- map of avatar name to array of active quick bar indicies, in order
Storage.PlayerData = {}

-- Get the value from the avatarPlayerData storage table, if it exists
-- Or create it otherwise
--	@param player - a LuaPlayer object
--	@return - the table value
Storage.PlayerData.getOrCreate = function(player)
	if player and player.valid then
		-- Check if the player has data in the table already
		for _, playerData in ipairs(storage.avatarPlayerData) do
			if playerData.player == player then
				debugLog("PlayerData for " .. player.name .. " was found in the table")
				Storage.PlayerData.repairOnRead(playerData)
				return playerData
			end
		end
		
		-- Create their data otherwise
		debugLog("Adding PlayerData for " .. player.name)
		local playerData = {player=player, realBody=nil, currentAvatarData=nil, lastBodySwap=nil, realBodyQuickBars=nil, avatarQuickBars={}}
		
		table.insert(storage.avatarPlayerData, playerData)
		debugLog("Players in PlayerData: " .. #storage.avatarPlayerData)
		
		return playerData
	end
end

-- Get the first value from the avatarPlayerData storage table that satifies the provided function, or nil
--	@param func - a function to test the values against
--	@return - the table value
Storage.PlayerData.getByFunc = function(func)
	for _, playerData in ipairs(storage.avatarPlayerData) do
		if func(playerData) then
			return playerData
		end
	end
end

-- Get the value from the avatarPlayerData storage table, using the player's entity (checking against the realBody)
--	@param entity - the LuaEntity of the player character
--	@return - the table value, or nil if not found
Storage.PlayerData.getByEntity = function(entity)
	return Storage.PlayerData.getByFunc(function(data) return data.realBody == entity end)
end

Storage.PlayerData.getByPlayer = function(player)
	return Storage.PlayerData.getByFunc(function(data) return data.player == player end)
end

-- Moves an all of an avatar's saved quickbars when it gets renamed, or removes it if the avatar dies
--	@param avatarName - old avatar name
--	@param newAvatarName - new avatar name, or nil if it no longer exists
Storage.PlayerData.migrateAvatarQuickBars = function(avatarName, newAvatarName)
	local newFunction = function(key) return key == avatarName end
	for _, playerData in ipairs(storage.avatarPlayerData) do
		if newAvatarName == nil then
			Storage.removeFromTableByKey(playerData.avatarQuickBars, newFunction)
		else
			for name, quickBar in pairs(playerData.avatarQuickBars) do
				if name == avatarName then
					playerData.avatarQuickBars[newAvatarName] = playerData.avatarQuickBars[avatarName]
					playerData.avatarQuickBars[avatarName] = nil
					break
				end
			end
		end
	end
end

Storage.PlayerData.repairOnRead = function(playerData)
	if playerData.realBody and not playerData.realBody.valid then
		local player = playerData.player
		for _, character in ipairs(player.get_associated_characters()) do
			if character and character.valid and character.name == "character" then
				debugLog("Repaired on read for realBody for " .. player.name)
				playerData.realBody = character
				return
			end
		end
	end
end

Storage.PlayerData.repair = function(source, target)
	for _, playerData in ipairs(storage.avatarPlayerData) do
		if playerData.realBody == source then
			playerData.realBody = target
		end
	end
end
Storage._repairMapping["character"] = Storage.PlayerData.repair



--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ARDU Storage Table ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- {entity, name, deployedAvatarData, currentIteration}
Storage.ARDU = {}

-- Add an ARDU to the storage table
-- 	@param entity - a LuaEntity of the ARDU
--	@return true or false if the add was successful
Storage.ARDU.add = function(entity)
	if entity and entity.valid then
		debugLog("Adding ARDU to the table")
		
		local currentIncrement = storage.ARDUCount
		local name = settings.global["Avatars_default_avatar_remote_deployment_unit_name"].value .. Util.formatNumberForName(currentIncrement)

		storage.ARDUCount = currentIncrement + 1
	
		table.insert(storage.avatarARDUTable, {
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

-- Get the first value from the avatarARDUTable storage table that satifies the provided function, or nil
--	@param func - a function to test the values against
--	@return - the table value
Storage.ARDU.getByFunc = function(func)
	for _, currentARDU in ipairs(storage.avatarARDUTable) do
		if func(currentARDU) then
			return currentARDU
		end
	end
end

-- Get the value from the avatarARDUTable storage table, using the ARDU's entity
--	@param entity - the LuaEntity of the ARDU
--	@return - the table value, or nil if not found
Storage.ARDU.getByEntity = function(ARDU)
	return Storage.ARDU.getByFunc(function(data) return data.entity == ARDU end)
end

-- Get the value from the avatarARDUTable storage table, using the ARDU's entity
--	@param name - the name of the ARDU
--	@return - the table value, or nil if not found
Storage.ARDU.getByName = function(name)
	return Storage.ARDU.getByFunc(function(data) return data.name == name end)
end

-- Remove an ARDU from the storage table
-- 	@param ARDU - a LuaEntity of the ARDU
Storage.ARDU.remove = function(entity)
	debugLog("Attempting to remove ARDU. Current count: " .. #storage.avatarARDUTable)
	local newFunction = function (arg) return arg.entity == entity end
	local removedArdus = Storage.removeFromTable(storage.avatarARDUTable, newFunction)
	
	if #removedArdus > 0 then
		GUI.Refresh.avatarControlChanged()
	end
	
	-- Clean up the Avatar data link
	for _, ardu in ipairs(removedArdus) do
		if ardu.deployedAvatarData then
			ardu.deployedAvatarData.arduData = nil
		end
	end
	
	debugLog("New count: " .. #storage.avatarARDUTable)
end

Storage.ARDU.repair = function(source, target)
	for _, currentARDU in ipairs(storage.avatarARDUTable) do
		if currentARDU.entity == source then
			currentARDU.entity = target
		end
	end
end
Storage._repairMapping["avatar-remote-deployment-unit"] = Storage.ARDU.repair



--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ARDU Storage Table ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
Storage.MapTags = {}

-- Add a map tag to the storage table
-- 	@param entity - a LuaEntity of the avatar corpse
-- 	@param tag - a LuaCustomChartTag of the map tag
Storage.MapTags.add = function(entity, tag)
	debugLog("Adding map tag to the table")
	table.insert(storage.avatarMapTags, {
		entity=entity,
		tag=tag
	})
end

-- Remove a map tag to the storage table
-- 	@param entity - a LuaEntity of the avatar corpse
--	@return the LuaCustomChartTag that was successfully removed from the storage table
Storage.MapTags.remove = function(entity)
	debugLog("Removing map tag from the table")
	local newFunction = function (arg) return arg.entity == entity end
	local removedTagData = Storage.removeFromTable(storage.avatarMapTags, newFunction)
	if #removedTagData > 0 then
		return removedTagData[1].tag
	end
end

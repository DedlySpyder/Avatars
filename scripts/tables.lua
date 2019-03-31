local Tables = {}

--Removes an entity from a global table
--Works by adding everything except the old entry to a new table and overwritting the old table
Tables.remove = function(func, oldTable)
	if (oldTable == nil) then return nil end
	local newTable = {}
	for _, row in ipairs(oldTable) do
		if not func(row) then table.insert(newTable, row) end
	end
	return newTable
end

Tables.Avatars = {}

--Counts the number of avatars in the same force as the player
--TODO - unused?
Tables.Avatars.countByPlayersForce = function(player)
	local totalAvatars = 0
	for _, avatar in ipairs(global.avatars) do
		if (avatar == nil) then break end
		if (avatar.avatarEntity.force.name == player.force.name) then
			totalAvatars = totalAvatars + 1
		end
	end
	return totalAvatars
end

--Add the avatar to the table
Tables.Avatars.add = function(entity)
	global.avatars = Tables.Avatars.existsOrCreate(global.avatars)
	
	--Make sure the global increments table exists and initialize it otherwise
	global.avatarDefaultCount = Tables.Avatars.countExistsOrCreate(global.avatarDefaultCount)
	
	--Obtain the increment and increase it for later
	local currentIncrement = global.avatarDefaultCount
	global.avatarDefaultCount = currentIncrement + 1
	
	--Insert the new avatar to the table
	table.insert(global.avatars, {avatarEntity=entity, name=default_avatar_name..string.format("%03d",currentIncrement)})
	debugLog("new avatar: " .. #global.avatars .. ", " .. global.avatars[#global.avatars].name)
end

--Make sure global.avatars exists
Tables.Avatars.existsOrCreate = function(checkTable)
	if checkTable == nil then
		return {avatarEntity=nil,name=""}
	else
		return checkTable
	end
end

--Make sure global.avatarDefaultCount exists
Tables.Avatars.countExistsOrCreate = function(checkVar)
	if checkVar == nil then
		return 0
	else
		return checkVar
	end
end



Tables.PlayerData = {}

--Look up the player in global.avatarPlayerData, or create an entry for them
Tables.PlayerData.getPlayerData = function(player)
	global.avatarPlayerData = Tables.PlayerData.existsOrCreate(global.avatarPlayerData)
	if (player == nil) then return end
	
	--Look up the player
	for _, playerData in ipairs(global.avatarPlayerData) do
		if (playerData.player == player) then
			debugLog(player.name.." was found in the table")
			return playerData
		end
	end
	
	--Add to the table when necessary
	debugLog(player.name.." was added to the table")
	local playerData = {player=player, realBody=nil, currentAvatar=nil, currentAvatarName=nil, lastBodySwap=nil}
	
	table.insert(global.avatarPlayerData, playerData)
	debugLog("Players is PlayerData:"..#global.avatarPlayerData)
	
	return playerData
end

--Table Check/Creation
--Make sure global.avatarPlayerData exists
Tables.PlayerData.existsOrCreate = function(checkTable)
	if checkTable == nil then
		return {player=nil, realBody=nil, currentAvatar=nil, lastBodySwap=nil}
	else
		return checkTable
	end
end


--Table Handling Scripts

Tables.ARDU = {}

--Add the ARDU to the table
Tables.ARDU.add = function(entity)
	global.avatarARDUTable = Tables.ARDU.existsOrCreate(global.avatarARDUTable)
	
	--Make sure the global increments table exists and initialize it otherwise
	global.ARDUCount = Tables.ARDU.countExistsOrCreate(global.ARDUCount)
	
	--Obtain the increment and increase it for later
	local currentIncrement = global.ARDUCount
	global.ARDUCount = currentIncrement + 1
	
	--Inser the new ARDU to the table
	table.insert(global.avatarARDUTable, {
											entity=entity, 
											name=default_avatar_remote_deployment_unit_name..string.format("%03d", currentIncrement),
											flag=false,
											deployedAvatar=nil,
											currentIteration=0
										 })
	debugLog("new ARDU: " .. #global.avatarARDUTable .. ", " .. global.avatarARDUTable[#global.avatarARDUTable].name)
end

--Takes an entity, returns the table value
Tables.ARDU.get = function(ARDU)
	for _, currentARDU in ipairs(global.avatarARDUTable) do
		if (currentARDU.entity == ARDU) then
			return currentARDU
		end
	end
	return nil
end

--Remove ARDUs from the global table
Tables.ARDU.remove = function(entity)
	local newFunction = function (arg) return arg.entity == entity end --Function that returns true or false if the entities match
	global.avatarARDUTable = Tables.remove(newFunction, global.avatarARDUTable)
	debugLog("Deleted ARDU: " .. #global.avatarARDUTable)
end

--Make sure global.avatarARDUTable exists
Tables.ARDU.existsOrCreate = function(checkTable)
	if checkTable == nil then
		return {entity=nil,name="", deployedAvatar=nil}
	else
		return checkTable
	end
end

--Make sure global.ARDUCount exists
Tables.ARDU.countExistsOrCreate = function(checkVar)
	if checkVar == nil then
		return 0
	else
		return checkVar
	end
end



Tables.AvatarAssemblingMachines = {}

--Add the Assembling Machine to the table
Tables.AvatarAssemblingMachines.add = function(entity)
	global.avatarAssemblingMachines = Tables.AvatarAssemblingMachines.existsOrCreate(global.avatarAssemblingMachines)
	
	table.insert(global.avatarAssemblingMachines, {entity=entity})
end

--Remove Assemblers from the global table
Tables.AvatarAssemblingMachines.remove = function(entity)
	global.avatarAssemblingMachines = Tables.AvatarAssemblingMachines.existsOrCreate(global.avatarAssemblingMachines)
	
	local newFunction = function (arg) return arg.entity == entity end --Function that returns true or false if the entities match
	global.avatarAssemblingMachines = Tables.remove(newFunction, global.avatarAssemblingMachines)
	debugLog("deleted Assembler: " .. #global.avatarAssemblingMachines)
end

--Make sure global.avatarAssemblingMachines exists
Tables.AvatarAssemblingMachines.existsOrCreate = function(checkTable)
	if checkTable == nil then
		return {entity=nil}
	else
		return checkTable
	end
end

return Tables

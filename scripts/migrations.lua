Migrations = {}

Migrations.handle = function(data)
	if data.mod_changes.Avatars then
		local oldVersion = data.mod_changes.Avatars.old_version
		if oldVersion then
			if Migrations.versionCompare(oldVersion, "0.4.0") then
				Migrations.to_0_4_0()
			end
			
			if Migrations.versionCompare(oldVersion, "0.5.0") then
				Migrations.to_0_5_0()
			end
			
			if Migrations.versionCompare(oldVersion, "0.5.11") then
				Migrations.to_0_5_11()
			end
		end
	end
end

-- Returns true if oldVersion is older than newVersion
Migrations.versionCompare = function(oldVersion, newVersion)
	_, _, oldMaj, oldMin, oldPat = string.find(oldVersion, "(%d+)%.(%d+)%.(%d+)")
	_, _, newMaj, newMin, newPat = string.find(newVersion, "(%d+)%.(%d+)%.(%d+)")
	
	local lt = function(o, n) return tonumber(o) < tonumber(n) end
	local gt = function(o, n) return tonumber(o) > tonumber(n) end
	
	if gt(oldMaj, newMaj) then return false
	elseif lt(oldMaj, newMaj) then return true end
	
	if gt(oldMin, newMin) then return false
	elseif lt(oldMin, newMin) then return true end
	
	if lt(oldPat, newPat) then return true end
	return false
end

Migrations.to_0_4_0 = function()
	-- Default avatar names need to have leading zeroes in order to sort correctly
	if global.avatars then
		for i, avatar in ipairs(global.avatars) do
			local defaultAvatarName = settings.global["Avatars_default_avatar_name"].value
			local nameSubString = string.sub(avatar.name, 1, #defaultAvatarName)
			if (defaultAvatarName == nameSubString) then
				local avatarNumber = string.format("%03d", tonumber(string.sub(avatar.name, #defaultAvatarName+1, #avatar.name)))
				global.avatars[i].name = defaultAvatarName..avatarNumber
			end
		end
	end
end

Migrations.to_0_5_0 = function()
	Storage.init()
	script.on_event(defines.events.on_tick, nil)
	
	-- Reworked the central GUI, so clean up any that might be open
	for _, player in pairs(game.players) do
		local selectionFrame = player.gui.center.avatarSelectionFrame
		if selectionFrame and selectionFrame.valid then
			selectionFrame.destroy()
		end
		
		local renameFrame = player.gui.center.changeNameFrame
		if renameFrame and renameFrame.valid then
			renameFrame.destroy()
		end
	end
	
	-- Avatars table transistion: (playerData will be added below)
	-- {avatarEntity, name} -> {entity, name}
	--		Just renaming entity
	for _, data in ipairs(global.avatars) do
		data.entity = data.avatarEntity
		data.avatarEntity = nil
	end
	
	-- ARDU table transistion:
	-- {entity, name, flag, deployedAvatar, currentIteration} -> {entity, name, deployedAvatarData, currentIteration}
	--		ARDU is changing from the on_tick to on demand, so flag is unneeded
	--		Changing avatar reference to just be the table entry
	--		Also, having the avatar link back to the spawning ARDU, as needed
	for _, data in ipairs(global.avatarARDUTable) do
		if data.deployedAvatar then
			local deployedAvatarData = Storage.Avatars.getByEntity(data.deployedAvatar)
			data.deployedAvatarData = deployedAvatarData
			data.deployedAvatar = nil
			
			deployedAvatarData.arduData = data
		end
		
		data.flag = nil
	end
	
	-- PlayerData table transistion:
	-- {player, realBody, currentAvatar, currentAvatarName, lastBodySwap} -> {player, realBody, currentAvatarData, lastBodySwap}
	--		Changing avtar references to just be the table entry
	--		Also, having the avatar link back to the controlling player, as needed
	for _, data in ipairs(global.avatarPlayerData) do
		if data.currentAvatar then
			local currentAvatarData = Storage.Avatars.getByEntity(data.currentAvatar)
			data.currentAvatarData = currentAvatarData
			data.currentAvatar = nil
			
			currentAvatarData.playerData = data
			
			AvatarControl.loseAvatarControl(data.player, 0)
		end
		
		data.currentAvatarName = nil
	end
end

Migrations.to_0_5_11 = function()
	for _, playerData in pairs(global.avatarPlayerData) do
		playerData.avatarQuickBars = playerData.avatarQuickBars or {}
	end
end

Migrations = {}

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

--TODO - migration - see below
--clean these up (renamed) player.gui.center.changeNameFrame.destroy()
Migrations.to_0_5_0 = function()
	Storage.init()
	script.on_event(defines.events.on_tick, nil)
	
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
			local deployedAvatarData = Storage.Avatars.getByEntity(data.deployedAvatar) --TODO broken?
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
		end
		
		data.currentAvatarName = nil
	end
end

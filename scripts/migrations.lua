local Storage = require "storage"

local Migrations = {}

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

--TODO - call this in control.lua
Migrations.to_0_5_0 = function()
	Storage.init()
	
	-- Avatars table transistion: (playerData will be added below)
	-- {avatarEntity, name} -> {entity, name}
	for _, data in ipairs(global.avatars) do
		data.entity = data.avatarEntity
		data.avatarEntity = nil
	end
	
	-- PlayerData table transistion:
	-- {player, realBody, currentAvatar, currentAvatarName, lastBodySwap} -> {player, realBody, currentAvatarData, lastBodySwap}
	for _, data in ipairs(global.avatarPlayerData) do
		if data.currentAvatar then
			data.currentAvatarData = Storage.Avatars.getByEntity(data.currentAvatar)
			data.currentAvatar = nil
			
			-- Avatars table is getting a reference back to the controlling player data
			data.currentAvatarData.playerData = data
		end
		
		data.currentAvatarName = nil
	end
end

return Migrations

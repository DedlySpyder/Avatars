Deployment = {}

-- Determine if an ARDU can deploy an avatar
--	@param arduData - the data object from the ARDU global table
--	@return - true/false if the ARDU can deploy a new avatar
--			- the error message if false (in the form of a table to be used by player.print() )
Deployment.canDeploy = function(arduData)
	local entity = arduData.entity
	if entity.get_driver() then
		return false, {"Someone is in here"} --TODO - error message, something is in the ARDU
		
	elseif entity.get_item_count("avatar") < 1 then
		return false, {"No avatars"} --TODO - error message, nothing in the ARDU
	end
	
	return true
end

-- Either get the current avatarData for the deployed avatar, or deploy a new one (if possible)
--	@param player - the LuaPlayer who is trying to deploy the avatar
--	@param arduName - the name of the ARDU
--	@return - the avatar table data for the old/new avatar, or nil if it couldn't be spawned
Deployment.getOrDeploy = function(player, arduName)
	local arduData = Storage.ARDU.getByName(arduName)
	
	-- See if we need to deploy a new avatar or not
	if arduData.deployedAvatarData then
		debugLog("Found old avatar from ARDU: " .. arduData.deployedAvatarData.name)
		return arduData.deployedAvatarData
	else
		local canDeploy, err = Deployment.canDeploy(arduData)
		if not canDeploy then
			player.print(err)
			return
		end
		
		-- Deploy a new avatar
		local arduEntity = arduData.entity
		local avatar = arduEntity.surface.create_entity{name = "avatar", position = arduEntity.position, force = arduEntity.force, raise_built = true}
		arduEntity.set_driver(avatar)
		arduEntity.remove_item({name="avatar", count=1})
		
		local avatarData = Storage.Avatars.getByEntity(avatar)
		
		-- ARDU book keeping
		arduData.deployedAvatarData = avatarData
		arduData.currentIteration = arduData.currentIteration + 1
		avatarData.arduData = arduData
		
		-- Overwrite the avatar's name
		avatarData.name = arduData.name .. " " .. settings.global["Avatars_default_avatar_remote_deployment_unit_name_deployed_prefix"].value
			.. " " .. Storage.formatNumber(arduData.currentIteration)
		
		-- Rollback the sequence increase
		global.avatarDefaultCount = global.avatarDefaultCount - 1
		
		return avatarData
	end
end

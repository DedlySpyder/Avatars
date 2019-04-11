local Storage = require "storage"

local Deployment = {}

---TODO - REWORK - ARDU will not be automatic anymore (after cleaning up other code)


--Avatar Deployment
Deployment.deployFromARDU = function(ARDU)
	local player = ARDU.entity.get_driver()
	if (player == nil) then
		--Verify that the ARDU does not have an avatar deployed
		if (ARDU.deployedAvatar == nil) then
			local entity = ARDU.entity
			debugLog("No prior avatar")
			--Check contents of the ARDU
			if (entity.get_item_count("avatar") > 0) then
				--Create an avatar and place it inside the ARDU
				local avatar = entity.surface.create_entity{name="avatar", position=entity.position, force=entity.force}
				entity.set_driver(avatar)
				entity.remove_item({name="avatar", count=1})
				debugLog("New avatar deployed")
				
				--ARDU book keeping
				ARDU.deployedAvatar = avatar
				ARDU.currentIteration = ARDU.currentIteration + 1
				
				--Add the avatar to the table (normal event is not triggered)
				--TODO - can't I trigger the normal LUA event nowadays?
				Storage.Avatars.add(avatar) --TODO - if I need to stick with this, then can't this return the avatar data table?
				
				-- Overwrite the name
				local avatar = Storage.Avatars.getByEntity(avatar)
				avatar.name = (ARDU.name.." "..settings.global["Avatars_default_avatar_remote_deployment_unit_name_deployed_prefix"].value.." "..string.format("%03d",ARDU.currentIteration))
				
				--Rollback the sequence increase (safer way to do??) --TODO
				global.avatarDefaultCount = global.avatarDefaultCount - 1
				return true
			end
		end
	end
	return false
end

--Avatar Redeployment (based on the old avatar's stats)
Deployment.redeployFromARDU = function(oldAvatar)
	if (global.avatarARDUTable ~= nil) then
		for _, ARDU in ipairs(global.avatarARDUTable) do
			if (ARDU.deployedAvatar == oldAvatar) then
				--Find the ARDU and deploy a new avatar
				ARDU.deployedAvatar = nil
				Deployment.deployFromARDU(ARDU)
			end
		end
	end
end

--Triggered by avatar assembling machines to place avatars
Deployment.deployFromAssemblers = function()
	if (global.avatarAssemblingMachines ~= nil) then
		for _, assembler in ipairs(global.avatarAssemblingMachines) do
			--Get the output inventory
			local avatarOutput = assembler.entity.get_output_inventory()
			
			--Check for avatars
			if (avatarOutput.get_item_count("avatar") > 0) then
				local position = Deployment.getPlacementPosition(assembler.entity)
				if (position ~= nil) then 
					if assembler.entity.surface.can_place_entity{name="avatar", position=position, force=assembler.entity.force} then
						--Place the avatar and add it to the table
						local avatar = assembler.entity.surface.create_entity{name="avatar", position=position, force=assembler.entity.force} 
						Storage.Avatars.add(avatar)
						avatarOutput.remove({name="avatar", count=1})
					end
				end
			end
		end
	end
end

--Finds the direction of the assembling machine and gives the position in front of the output
--Output fluidbox is the opposite of the direction
--top left is -x -y // top right is +x -y
--bottom left is -x +y // bottom right is +x +y
--0 = S, 2 = W, 4 = N, 6 = E
Deployment.getPlacementPosition = function(entity)
	local direction = entity.direction
	local positionX = entity.position.x
	local positionY = entity.position.y
	
	--Output is facing south
	if (direction == 0) then
		return {positionX, positionY+2}
	--Output is facing west
	elseif (direction == 2) then
		return {positionX-2, positionY}
	--Output is facing north
	elseif (direction == 4) then
		return {positionX, positionY-2}
	--Output is facing east
	elseif (direction == 6) then
		return {positionX+2, positionY}
	end
	return nil
end

return Deployment

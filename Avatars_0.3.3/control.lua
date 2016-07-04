require "gui"
require "config"
require "scripts"

--Migration involving global data
script.on_configuration_changed(function(data)
	if data.mod_changes.Avatars then
		local oldVersion = data.mod_changes.Avatars.old_version
		if oldVersion and oldVersion < "0.3.0" then
			migrateTo_0_3_0()
		end
	end
end)

--Check on entering or leaving a vehicle
function on_driving(event)
	local player = game.players[event.player_index]
	
	--Check for entering the Avatar Control Center
	if player.vehicle and player.vehicle.name == "avatar-control-center" then
		drawSelectionGUI(player, 1)
		debugLog("Getting in")
		
	--Check for entering the Avatar Remote Deployment unit (ARDU)
	elseif player.vehicle and player.vehicle.name == "avatar-remote-deployment-unit" then
		drawARDUGUI(player, player.vehicle)
		
	--Otherwise, destroy GUIs
	else
		destroySelectionGUI(player)
		destroyRenameGUI(player)
		destroyARDUGUI(player)
		debugLog("Getting out")
	end
end

script.on_event(defines.events.on_player_driving_changed_state, on_driving)

--Check on GUI click
function checkGUI(event)
	local element = event.element
	local elementName = element.name
	local player = game.players[event.player_index]
	debugLog("Clicked "..elementName)
	
	--Page forward button
	if (elementName == "pageForward") then
		local page = tonumber(player.gui.center.selectionFrame.pageNumber.caption)
		if (avatarCount(player) > page*table_avatars_per_page) then
			drawSelectionGUI(player, page+1)
			if verifyRenameGUI(player) then
				destroyRenameGUI(player)
			end
		end
		return
	end
	
	--Page back button
	if (elementName == "pageBack") then
		local page = tonumber(player.gui.center.selectionFrame.pageNumber.caption)
		if (page > 1) then
			drawSelectionGUI(player, page-1)
			if verifyRenameGUI(player) then
				destroyRenameGUI(player, nil)
			end
		end
		return
	end
	
	--Other button ("avatar_"..4LetterCode...)
	local modSubString = string.sub(elementName, 1, 7)
	
	--Look for button header
	if (modSubString == "avatar_") then
		debugLog("Avatar Mod button press")
		
		--Look for the individual button
		local modButton = string.sub(elementName, 8, 11)
		debugLog("Button pushed: "..modButton)
		
		--Rename button
		if (modButton == "rnam") then
			--Obtain the old name
			local name = string.sub(elementName, 13)
			drawRenameGUI(player, name)
		end
		
		--Control Button
		if (modButton == "ctrl") then
			--Obtain the name of the avatar to control
			local name = string.sub(elementName, 13)
			gainAvatarControl(player, name, event.tick)
		end
		
		--Submit button (to submit a rename)
		if (modButton == "sbmt") then
			changeAvatarNameSubmit(player)
		end
		
		--Cancel button (to cancel a rename)
		if (modButton == "cncl") then
			destroyRenameGUI(player)
		end
		
		--Exit button (to disconnect from the avatar)
		if (modButton == "exit") then
			loseAvatarControl(player, event.tick)
		end
		
		--The ARDU submit button
		if (modButton =="ARDU") then
			changeARDUName(player)
		end
	end
end

script.on_event(defines.events.on_gui_click, checkGUI)

--Check on an entity being built
function on_entityBuilt(event)
	local entity = event.created_entity
		
	--Dummy fuel to avoid the error signal
	if (entity.name == "avatar-control-center") then
		entity.insert{name="coal", count=1}
		entity.operable = false
		return
	end
	
	--Add avatars to the table
	if (entity.name == "avatar") then
		addAvatarToTable(entity)
	end
	
	--Dummy fuel and add to table
	if (entity.name == "avatar-remote-deployment-unit") then
		entity.insert{name="coal", count=1}
		addARDUToTable(entity)
	end
	
	--Add to table
	if (entity.name == "avatar-assembling-machine") then
		addAvatarAssemblerTotable(entity)
	end
end

script.on_event(defines.events.on_robot_built_entity, on_entityBuilt)
script.on_event(defines.events.on_built_entity, on_entityBuilt)

--Check on entity being destroyed or deconstructed
function on_entityDestroyed(event)
	local entity = event.entity
	
	--Destruction of an Avatar Control Center
	if (entity.name == "avatar-control-center") then
		--Remove dummy fuel
		entity.clear_items_inside()
		
		--Check if a player was using it
		local playerDataTable = doesPlayerTableExistOrCreate(global.avatarPlayerData)
		if (playerDataTable ~= nil) then
			for _, playerData in ipairs(playerDataTable) do
				if (entity.passenger == playerData.realBody) then
					if (playerData.currentAvatar ~= nil) then
						--Deactive the current avatar
						--The game will continue it's actions otherwise, which can cause a game crash
						playerData.currentAvatar.active = false
						local player = playerData.player
						loseAvatarControl(player, event.tick)
						destroyAllGUI(player)
						player.print{"Avatars-error-avatar-control-center-destroyed"}
					end
				end
			end
		end
		return
	end
	
	--Destruction of an Avatar
	if (entity.name == "avatar") then
		local player = nil
		local playerDataTable = doesPlayerTableExistOrCreate(global.avatarPlayerData)
		
		--Check if a player was controlling the avatar
		if (playerDataTable ~= nil) then
			for _, playerData in ipairs(playerDataTable) do
				if (playerData.currentAvatar == entity) then
					--Stop a game over screen                        --Will need added functionality for 0.13 to support MP properly
					game.set_game_state{game_finished=false}
					player = playerData.player
					
					--Give back control of the player's body
					--Passing tick 0 to force the swap no matter what
					loseAvatarControl(player, 0)
					player.print{"Avatars-error-controlled-avatar-death"}
				end
			end
		end
		
		--Remove the avatar from the global table
		for _, currentAvatar in ipairs(global.avatars) do
			if (currentAvatar.avatarEntity == entity) then
				local avatarEntity = currentAvatar.avatarEntity
				
				local newFunction = function (arg) return arg.avatarEntity == entity end --Function that returns true or false if the entities match
				global.avatars = removeFromTable(newFunction, global.avatars)
				debugLog("deleted avatar: " .. #global.avatars .. ", " .. currentAvatar.name)
				
				--Will only be set if a player was in the avatar
				if (player ~= nil) then
					--They need the GUI if so
					drawSelectionGUI(player, 1)
				end
				
				--Attempts to deploy a new avatar
				redeployAvatarFromARDU(avatarEntity)
			end
		end
		return
	end
	
	--Destruction of an ARDU
	if (entity.name == "avatar-remote-deployment-unit") then
		entity.clear_items_inside()
		--Remove it from the global table
		for _, currentARDU in ipairs(global.avatarARDUTable) do
			if (currentARDU.entity == entity) then
				removeARDUFromTable(entity)
			end
		end
		return
	end
	
	--Destruction of an Assembling Machine
	if (entity.name == "avatar-assembling-machine") then
		for _, currentAssembler in ipairs(global.avatarAssemblingMachines) do
			if (currentAssembler.entity == entity) then
				removeAvatarAssemlerFromTable(entity)
			end
		end
	end
end

script.on_event(defines.events.on_preplayer_mined_item, on_entityDestroyed)
script.on_event(defines.events.on_robot_pre_mined, on_entityDestroyed)
script.on_event(defines.events.on_entity_died, on_entityDestroyed)

function on_Tick(event)
	--Every 5 seconds - Check to deploy the initial avatar for ARDUs
	if ((game.tick % (60*5)) == 0) then
		if (global.avatarARDUTable ~= nil) then
			for _, ARDU in ipairs(global.avatarARDUTable) do
				if not ARDU.flag then --This only triggers once
					local flag = deployAvatarFromARDU(ARDU)
					if flag then ARDU.flag = flag end
					debugLog("Attempted first deployment from "..ARDU.name)
				end
			end
		end
	end
	
	--Every 15 seconds - check to place avatars in the avatar assembling machines
	if ((game.tick % (60*15)) == 0) then 
		placeAvatarInAssemblers()
	end
end

script.on_event(defines.events.on_tick, on_Tick)

--DEBUG messages
function debugLog(message)
	for _, player in pairs(game.players) do
		if debug_mode then
			player.print(message)
		end
	end
end 


--Remote Calls
--Mod Interfaces

--remote.call("Avatars_avatar_placement", "addAvatar", arg)
remote.add_interface("Avatars_avatar_placement", {
	addAvatar = function(entity)
		if (entity ~= nil and entity.valid) then
			if (entity.name == "avatar") then
				addAvatarToTable(entity)
			end
		end
	end
})

--User Commands
--Sometimes remote calls don't want to work, not sure why
-- /c remote.call("AvatarsSwap", "manualSwapBack")
remote.add_interface("AvatarsSwap", {
	manualSwapBack = function()
		player = game.player
		if (player.character.name ~= "player") then
			local playerData = getPlayerData(player)
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
			destroyAllGUI(player)
		else
			player.print{"avatar-remote-call-in-your-body"}
		end
	end
})

--LAST DITCH EFFORT
--Only use this is your body was destroyed somehow and you can't reload a save (this will create a new body)
-- /c remote.call("AvatarsLastResort", "createNewBody")
remote.add_interface("AvatarsLastResort", {
	createNewBody = function()
		player = game.player
		if (player.character.name ~= "player") then
			local playerData = getPlayerData(player)
			
			if (playerData.realBody ~= nil and playerData.realBody.valid) then
				player.print{"avatar-remote-call-still-have-a-body"}
				return
			end
			local newBody = player.surface.create_entity{name="player", position=player.position, force=player.force}
			
			if (newBody ~= nil) then
				
				
				--Manually lose control
				player.character = newBody
				
				--Clear the table
				playerData.realBody = nil
				playerData.currentAvatar = nil
				
				--GUI clean up
				destroyDisconnectGUI(player)
			end
		else
			player.print{"avatar-remote-call-in-your-body"}
		end
	end
})

--DEBUG
-- /c remote.call("Ava", "testing")
remote.add_interface("Ava", {
	testing = function()
		if debug_mode then
			game.player.insert({name="avatar-control-center", count=5})
			game.player.insert({name="avatar-assembling-machine", count=5})
			game.player.insert({name="avatar-remote-deployment-unit", count=5})
			game.player.insert({name="avatar", count=25})
		end
	end
})
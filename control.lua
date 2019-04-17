require "scripts/storage"
require "scripts/deployment"
require "scripts/avatar_control"
require "scripts/sort"
require "scripts/gui"

require "scripts/migrations"



script.on_init(function()
	Storage.init()
end)

----------TODO - refactoring

--Migration involving global data
script.on_configuration_changed(function(data)
	if data.mod_changes.Avatars then
		local oldVersion = data.mod_changes.Avatars.old_version
		if oldVersion then
			if oldVersion < "0.4.0" then
				Migrations.to_0_4_0()
			end
			
			if oldVersion < "0.5.0" then
				Migrations.to_0_5_0()
			end
		end
	end
end)

--Check on entering or leaving a vehicle
function on_driving(event)
	local player = game.players[event.player_index]
	
	--Check for entering the Avatar Control Center
	if player.vehicle and player.vehicle.name == "avatar-control-center" then
		GUI.Selection.draw(player)
		debugLog("Getting in")
		
	--Check for entering the Avatar Remote Deployment unit (ARDU)
	elseif player.vehicle and player.vehicle.name == "avatar-remote-deployment-unit" then
		GUI.ARDU.draw(player, player.vehicle)
		
	--Otherwise, destroy vehcile GUIs
	else
		GUI.Selection.destroy(player)
		GUI.Rename.destroy(player)
		GUI.ARDU.destroy(player)
		debugLog("Getting out")
	end
end

script.on_event(defines.events.on_player_driving_changed_state, on_driving)

--Check on GUI click
function checkGUI(event)
	local elementName = event.element.name
	local player = game.players[event.player_index]
	debugLog("Clicked "..elementName)
	
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
			GUI.Rename.draw(player, name)
		end
		
		--Control Button
		if (modButton == "ctrl") then
			--Obtain the name of the avatar to control
			local name = string.sub(elementName, 13)
			AvatarControl.gainAvatarControl(player, name, event.tick)
		end
		
		--Submit button (to submit a rename)
		if (modButton == "sbmt") then
			GUI.Trigger.changeAvatarNameSubmit(player)
		end
		
		--Cancel button (to cancel a rename)
		if (modButton == "cncl") then
			GUI.Rename.destroy(player)
		end
		
		--Exit button (for control center ui)
		if (modButton == "exit") then
			GUI.Selection.destroy(player)
		end
		
		--Disconnect button (to disconnect from the avatar)
		if (modButton == "disc") then
			AvatarControl.loseAvatarControl(player, event.tick)
		end
		
		--The ARDU submit button
		if (modButton =="ARDU") then
			GUI.Trigger.changeARDUName(player)
		end
	end
end

script.on_event(defines.events.on_gui_click, checkGUI)

--Handles the checkbox checked event
function checkboxChecked(event)
	local elementName = event.element.name
	local player = game.players[event.player_index]
	
	--Check for avatar sort checkbox ("avatar_sort_")
	local modSubString = string.sub(elementName, 1, 12)
	
	if (modSubString == "avatar_sort_") then
		debugLog("Avatar Mod Radio-button press")
		
		--Look for the individual button
		local modButton = string.sub(elementName, 13, #elementName)
		debugLog("Radio-button pushed: "..modButton)
		
		--Check for each sort button
		GUI.Selection.flipRadioButtons(player, modButton)
		
		--Update the GUIs (GUI.Rename.update triggers both rename and the selection gui, to maintain order)
		GUI.Rename.update(player)
	end
end

script.on_event(defines.events.on_gui_checked_state_changed, checkboxChecked)

--Check on an entity being built
function on_entity_built(entity)
	--Dummy fuel to avoid the error signal
	if (entity.name == "avatar-control-center") then
		entity.operable = false
		return
	end
	
	--Add avatars to the table
	if (entity.name == "avatar") then
		Storage.Avatars.add(entity)
	end
	
	--Add to table
	if (entity.name == "avatar-remote-deployment-unit") then
		Storage.ARDU.add(entity)
	end
end

function on_game_built_entity(event)
	on_entity_built(event.created_entity)
end

function on_script_built_entity(event)
	on_entity_built(event.entity)
end

script.on_event(defines.events.on_robot_built_entity, on_game_built_entity)
script.on_event(defines.events.on_built_entity, on_game_built_entity)
script.on_event(defines.events.script_raised_built, on_script_built_entity)

--Check on entity being destroyed or deconstructed
function on_entity_destroyed(event)
	local entity = event.entity
	
	--Destruction of an Avatar Control Center
	if (entity.name == "avatar-control-center") then
		--Check if a player was using it
		local driver = entity.get_driver()
		local playerData = Storage.PlayerData.getByFunc(function(data) return data.realBody == driver end)
		--TODO - this stopped working a while back, the player isn't the driver anymore (there is another TODO that fixed this maybe)
		--will have to start keeping track of the control center itself
		
		if playerData and playerData.currentAvatarData then
			--Deactive the current avatar
			--The game will continue it's actions otherwise, which can cause a game crash --TODO - what? not if the ACC died? that doesn't kill the player IIRC
			playerData.currentAvatarData.entity.active = false
			local player = playerData.player
			AvatarControl.loseAvatarControl(player, event.tick)
			GUI.destroyAll(player)
			player.print{"Avatars-error-avatar-control-center-destroyed"}
		end
	end
	
	--Destruction of an Avatar
	if (entity.name == "avatar") then
		-- Remove the avatar from the global table
		-- (The player is no longer in control at this point)
		Storage.Avatars.remove(entity)
		return
	end
	
	--Destruction of an ARDU
	if (entity.name == "avatar-remote-deployment-unit") then
		Storage.ARDU.remove(entity)
		return
	end
end

function on_entity_died(event)
	local entity = event.entity
	
	if (entity.name == "player") then
		local playerData = Storage.PlayerData.getByEntity(entity)
		
		if playerData then
			local player = playerData.player
			local realBody = playerData.realBody
			debugLog("Player's real body died")
			
			local newBody = realBody.surface.create_entity{name="dead-player", position=realBody.position, force=realBody.force}
			playerData.realBody = newBody
			AvatarControl.loseAvatarControl(playerData.player, event.tick)
			newBody.die(event.force, event.cause)
			GUI.destroyAll(player)
		end
		return
	end
	
	on_entity_destroyed(event)
end

script.on_event(defines.events.on_pre_player_mined_item, on_entity_destroyed)
script.on_event(defines.events.on_robot_pre_mined, on_entity_destroyed)
script.on_event(defines.events.on_entity_died, on_entity_died)

--Handles a player dying while controlling an avatar
function on_preplayer_died(event)
	local player = game.players[event.player_index]
	
	if (player.character.name == "avatar") then
		AvatarControl.loseAvatarControl(player, 0)
		player.print{"Avatars-error-controlled-avatar-death"}
	end
end

script.on_event(defines.events.on_pre_player_died, on_preplayer_died)

--Handler for the hotkey to disconnect from an avatar
function on_hotkey(event)
	local player = game.players[event.player_index]
	
	AvatarControl.loseAvatarControl(player, event.tick)
end

script.on_event("avatars_disconnect", on_hotkey)

--Remote Calls
--Mod Interfaces

--remote.call("Avatars_avatar_placement", "addAvatar", arg)
remote.add_interface("Avatars_avatar_placement", {
	addAvatar = function(entity)
		if (entity ~= nil and entity.valid) then
			if (entity.name == "avatar") then
				Storage.Avatars.add(entity)
			end
		end
	end
})


--User Commands
remote.add_interface("Avatars", {
	--Used to force a swap back to the player's body
	-- /c remote.call("Avatars", "manual_swap_back")
	
	--TODO - this should just use the normal function to swap back...
			--it should have a force boolean that ignores the safety checks
	manual_swap_back = function()
		player = game.player
		if (player.character.name ~= "player") then
			local playerData = Storage.PlayerData.getOrCreate(player)
			--Check for the avatarEntity to exist or not
			--If a player disconnects, it removes the avatarEntity from the table, so it has to be replaced
			for _, avatar in ipairs(global.avatars) do
				if (avatar.name == playerData.currentAvatarName) then -- TODO - wrong now (but might not need this code)
					avatar.avatarEntity = player.character
				end
			end
			--Give back the player's body
			player.character = playerData.realBody
			
			--Clear the table
			playerData.realBody = nil
			playerData.currentAvatar = nil-- TODO - wrong now (but might not need this code)
			playerData.currentAvatarName = nil-- TODO - wrong now (but might not need this code)
			
			--GUI clean up
			GUI.destroyAll(player)
		else
			player.print{"avatar-remote-call-in-your-body"}
		end
	end,
	--LAST DITCH EFFORT
	--Only use this is your body was destroyed somehow and you can't reload a save (this will create a new body)
	-- /c remote.call("Avatars", "create_new_body")
	create_new_body = function()
		player = game.player
		if (player.character.name ~= "player") then
			local playerData = Storage.PlayerData.getOrCreate(player)
			
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
				playerData.currentAvatarData = nil
				
				--GUI clean up
				GUI.Disconnect.destroy(player)
			end
		else
			player.print{"avatar-remote-call-in-your-body"}
		end
	end
})


--		DEBUG Things
-- Only initialized if the debug_mode setting is true
-- TODO - make this a setting
local debug_mode = settings.global["Avatars_debug_mode"].value
debugLog = function(s) end
if debug_mode then
	debugLog = function (message)
		for _, player in pairs(game.players) do
			player.print(message)
		end
	end
	
	remote.add_interface("Avatars_debug", {
		-- /c remote.call("Avatars_debug", "testing")
		testing = function()
			for _, player in pairs(game.players) do
				player.insert({name="avatar-control-center", count=5})
				player.insert({name="avatar-remote-deployment-unit", count=5})
				player.insert({name="avatar", count=25})
			end
		end,
		
		-- /c remote.call("Avatars_debug", "avatars_list")
		avatars_list = function()
			for _, player in pairs(game.players) do
				local count = 0
				for _, avatar in ipairs(global.avatars) do
					count = count + 1
					
					--Valid entity check
					local validFlag = "false"
					if (avatar.avatarEntity ~= nil and avatar.avatarEntity.valid) then
						validFlag = "true"
					end
					
					player.print(count..", "..avatar.name..", "..validFlag)
				end
			end
		end
	})
end

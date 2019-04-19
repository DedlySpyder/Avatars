require "scripts/util"
require "scripts/storage"
require "scripts/deployment"
require "scripts/avatar_control"
require "scripts/sort"
require "scripts/gui"

require "scripts/migrations"

-- Initialize global tables
script.on_init(function()
	Storage.init()
end)

-- Migrations
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

-- Check when a player leaves the game
function on_player_left_game(event)
	local player = game.players[event.player_index]
	AvatarControl.loseAvatarControl(player, 0)
end

script.on_event(defines.events.on_pre_player_left_game, on_player_left_game)

-- Check on entering or leaving a vehicle
function on_driving(event)
	local player = game.players[event.player_index]
	
	-- Check for entering the Avatar Control Center
	if player.vehicle and player.vehicle.name == "avatar-control-center" then
		GUI.Selection.draw(player)
		debugLog("Getting in")
		
	-- Check for entering the Avatar Remote Deployment unit (ARDU)
	elseif player.vehicle and player.vehicle.name == "avatar-remote-deployment-unit" then
		GUI.ARDU.draw(player, player.vehicle)
		
	-- Otherwise, destroy vehicle GUIs
	else
		GUI.Main.destroy(player)
		GUI.ARDU.destroy(player)
		debugLog("Getting out")
	end
end

script.on_event(defines.events.on_player_driving_changed_state, on_driving)

-- Check on GUI click
function checkGUI(event)
	local elementName = event.element.name
	local player = game.players[event.player_index]
	debugLog("Clicked "..elementName)
	
	-- Avatar button ("avatar_"..4LetterCode...)
	local modSubString = string.sub(elementName, 1, 7)
	
	-- Look for button header
	if modSubString == "avatar_" then
		debugLog("Avatar Mod button press")
		
		-- Look for the individual buttons
		local modButton = string.sub(elementName, 8, 11)
		debugLog("Button pushed: "..modButton)
		
		-- Rename button
		if modButton == "rnam" then
			-- Obtain the old name
			local name = string.sub(elementName, 13)
			GUI.Rename.draw(player, name)
			
		elseif modButton == "ctrl" then
			-- Control button
			-- Obtain the name of the avatar to control
			local name = string.sub(elementName, 13)
			AvatarControl.gainAvatarControl(player, name, event.tick)
			
		elseif modButton == "rfrh" then
			-- Selection Refresh button
			GUI.Main.update(player)
			
		elseif modButton == "sbmt" then
			-- Submit button (to submit a rename)
			GUI.Trigger.changeAvatarNameSubmit(player)
			
		elseif modButton == "cncl" then
			-- Cancel button (to cancel a rename)
			GUI.Rename.destroy(player)
			
		elseif modButton == "exit" then
			-- Exit button (for control center ui)
			GUI.Main.destroy(player)
			GUI.ARDU.destroy(player)
			player.vehicle.set_driver(nil)
			
		elseif modButton == "disc" then
			-- Disconnect button (to disconnect from the avatar)
			AvatarControl.loseAvatarControl(player, event.tick)
			
		elseif modButton == "ARDU" then
			-- The ARDU submit button
			GUI.Trigger.changeARDUName(player)
		end
	end
end

script.on_event(defines.events.on_gui_click, checkGUI)

-- Handles the checkbox checked event
function checkboxChecked(event)
	local elementName = event.element.name
	local player = game.players[event.player_index]
	
	-- Check for avatar sort checkbox ("avatar_sort_")
	local modSubString = string.sub(elementName, 1, 12)
	
	if modSubString == "avatar_sort_" then
		debugLog("Avatar Mod Radio-button press")
		
		-- Look for the individual button
		local modButton = string.sub(elementName, 13, #elementName)
		debugLog("Radio-button pushed: "..modButton)
		
		-- Check for each sort button
		GUI.Selection.flipRadioButtons(player, modButton)
		
		-- Update the Selection GUI
		GUI.Selection.update(player)
	end
end

script.on_event(defines.events.on_gui_checked_state_changed, checkboxChecked)

-- Check on an entity being built
function on_entity_built(entity)
	if entity.name == "avatar-control-center" then
		entity.operable = false
		return
		
	elseif entity.name == "avatar" then
		--Add avatars to the table
		Storage.Avatars.add(entity)
		
	elseif entity.name == "avatar-remote-deployment-unit" then
		--Add ARDU to the table
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

-- Check on entity being destroyed or deconstructed
function on_entity_destroyed(event)
	local entity = event.entity
	
	-- Destruction of an Avatar Control Center
	if entity.name == "avatar-control-center" then
		-- Check if a player was using it
		local driver = entity.get_driver()
		local playerData = Storage.PlayerData.getByEntity(driver)
		
		if playerData and playerData.currentAvatarData then
			local player = playerData.player
			AvatarControl.loseAvatarControl(player, event.tick)
			GUI.destroyAll(player)
			player.print{"Avatars-error-avatar-control-center-destroyed"}
		end
		
	elseif entity.name == "avatar" then
		-- Destruction of an Avatar
		-- Remove the avatar from the global table (The player is no longer in control at this point)
		Storage.Avatars.remove(entity)
		
	elseif entity.name == "avatar-remote-deployment-unit" then
		-- Destruction of an ARDU
		Storage.ARDU.remove(entity)
	end
end

function on_entity_died(event)
	local entity = event.entity
	
	if entity.name == "player" then
		local playerData = Storage.PlayerData.getByEntity(entity)
		
		if playerData then
			local player = playerData.player
			local realBody = playerData.realBody
			debugLog(player.name .. "'s real body died")
			
			-- Make a new body for the player, and give it to them
			local newBody = realBody.surface.create_entity{name="fake-player", position=realBody.position, force=realBody.force}
			playerData.realBody = newBody
			AvatarControl.loseAvatarControl(playerData.player, event.tick)
			
			-- Now kill them
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

-- Handles a player dying while controlling an avatar
function on_preplayer_died(event)
	local player = game.players[event.player_index]
	
	if player.character.name == "avatar" then
		AvatarControl.loseAvatarControl(player, 0)
		player.print{"Avatars-error-controlled-avatar-death"}
	end
end

script.on_event(defines.events.on_pre_player_died, on_preplayer_died)

-- Handler for the hotkey to disconnect from an avatar
function on_hotkey(event)
	local player = game.players[event.player_index]
	
	AvatarControl.loseAvatarControl(player, event.tick)
end

script.on_event("avatars_disconnect", on_hotkey)


-- Handler for when the player teleports to a different surface
function on_player_changed_surface(event)
	local player = game.players[event.player_index]
	local playerData = Storage.PlayerData.getOrCreate(player)
	
	-- If the player is controlling an avatar, then we need to fix the entity reference to that avatar
	-- Otherwise, it becomes invalid
	if player.character.name == "avatar" and playerData.currentAvatarData then
		debugLog("Re-referencing avatar")
		playerData.currentAvatarData.entity = player.character
	end
end

script.on_event(defines.events.on_player_changed_surface, on_player_changed_surface)


--~~~~~~~ Remote Calls ~~~~~~~--
--Mod Interfaces

-- This isn't needed any more, since the script_raised_built event exists, so please use that
-- Just keeping it in case someone is still using it
--remote.call("Avatars_avatar_placement", "addAvatar", arg)
remote.add_interface("Avatars_avatar_placement", {
	addAvatar = function(entity)
		if entity and entity.valid then
			if entity.name == "avatar" then
				Storage.Avatars.add(entity)
			end
		end
	end
})


--User Commands
remote.add_interface("Avatars", {
	--Used to force a swap back to the player's body
	-- /c remote.call("Avatars", "manual_swap_back")
	
	manual_swap_back = function()
		player = game.player
		if player.character.name ~= "player" then
			local playerData = Storage.PlayerData.getOrCreate(player)
			local avatarData = playerData.currentAvatarData
			
			if playerData.realBody then
				-- Give back the player's body
				player.character = playerData.realBody
				
				-- In strange waters here, this might not exist
				if avatarData then
					avatarData.entity.active = false
					avatarData.playerData = nil
				end
				
				-- Clear the table
				playerData.realBody = nil
				playerData.currentAvatarData = nil
				
				-- GUI clean up
				GUI.destroyAll(player)
			end
		else
			player.print{"avatar-remote-call-in-your-body"}
		end
	end,
	
	--LAST DITCH EFFORT
	--Only use this is your body was destroyed somehow and you can't reload a save (this will create a new body)
	-- /c remote.call("Avatars", "create_new_body")
	create_new_body = function()
		player = game.player
		if player.character.name ~= "player" then
			local playerData = Storage.PlayerData.getOrCreate(player)
			
			if playerData.realBody and playerData.realBody.valid then
				player.print{"avatar-remote-call-still-have-a-body"}
				return
			end
			
			local newBody = player.surface.create_entity{name="player", position=player.position, force=player.force}
			
			if newBody then
				-- Manually lose control
				player.character = newBody
				
				-- In strange waters here, this might not exist
				local avatarData = playerData.currentAvatarData
				if avatarData then
					avatarData.entity.active = false
					avatarData.playerData = nil
				end
				
				-- Clear the table
				playerData.realBody = nil
				playerData.currentAvatarData = nil
				
				-- GUI clean up
				GUI.destroyAll(player)
			end
		else
			player.print{"avatar-remote-call-in-your-body"}
		end
	end
})


--		DEBUG Things
-- Only initialized if the debug_mode setting is true
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
			local count = 0
			for _, avatar in ipairs(global.avatars) do
				count = count + 1
				debugLog(count .. ", " .. avatar.name .. ", " .. tostring(avatar.entity and avatar.entity.valid))
			end
		end
	})
end

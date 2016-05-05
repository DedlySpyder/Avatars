require "defines"
require "gui"
require "config"

--Dev notes
--GUI interfaces
--drawSelectionGUI(player, pageNumber), updateSelectionGUI(player, allPlayersBool) this bool is a flag for who to update, destroySelectionGUI(player)
--drawRenameGUI(player, name), updateRenameGUI(player, oldName, newName), destroyRenameGUI(player)
--drawRenameGUI(player, name), updateRenameGUI(player, oldName, newName), destroyRenameGUI(player)
--drawDisconnectGUI(player), destroyDisconnectGUI(player)
--destroyAllGUI(player)

--Check on entering or leaving a vehicle
function driving(event)
	local player = game.get_player(event.player_index)
	
	--Check for entering or leaving the Avatar Control Center
	if player.vehicle and player.vehicle.name == "avatar-control-center" then
		drawSelectionGUI(player, 1)
		debugLog("Getting in")
	else 
		destroySelectionGUI(player)
		destroyRenameGUI(player)
		debugLog("Getting out")
	end
end

script.on_event(defines.events.on_player_driving_changed_state, driving)

--Check on GUI click
function checkGUI(event)
	local element = event.element
	local elementName = element.name
	local player = game.get_player(event.player_index)
	debugLog("Clicked "..elementName)
	
	--Page forward button
	if (elementName == "pageForward") then
		local page = tonumber(player.gui.center.selectionFrame.pageNumber.caption)
		if (avatarCount(player) > page*table_avatars_per_page) then
			drawSelectionGUI(player, page+1)
			if (player.gui.center.changeNameFrame ~= nil and player.gui.center.changeNameFrame.valid) then
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
			if (player.gui.center.changeNameFrame ~= nil and player.gui.center.changeNameFrame.valid) then
				destroyRenameGUI(player, nil)
			end
		end
		return
	end
	
	--Other button
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
			gainAvatarControl(event, name)
		end
		
		--Submit button (to submite a rename)
		if (modButton == "sbmt") then
			changeAvatarNameSubmit(player)
		end
		
		--Cancel button (to cancel a rename)
		if (modButton == "cncl") then
			destroyRenameGUI(player)
		end
		
		--Exit button (to disconnect from the avatar)
		if (modButton == "exit") then
			loseAvatarControl(event, player)
		end
	end
end

--Counts the number of avatars in the same force as the player
function avatarCount(player)
	local totalAvatars = 0
	for _, avatar in ipairs(global.avatars) do
		if (avatar == nil) then break end
		if (avatar.avatarEntity.force.name == player.force.name) then
			totalAvatars = totalAvatars + 1
		end
	end
	return totalAvatars
end

--Submiting the name
function changeAvatarNameSubmit(player)
	local changeNameFrame = player.gui.center.changeNameFrame
	
	--Obtain the old name
	local oldName = changeNameFrame.currentNameFlow.currentName.caption
	
	--Make sure the text field is valid
	if (changeNameFrame.newNameField ~= nil and changeNameFrame.newNameField.valid) then
	
		--Make sure a name was entered
		if (changeNameFrame.newNameField.text ~= "") then
			--Obtain the new name
			local newName = changeNameFrame.newNameField.text
			local flag = false
			local renamedAvatar = nil
			for _, avatar in ipairs(global.avatars) do
				--If the new name matches any avatars, then break the loop and throw an error
				if (avatar.name == newName) then
					flag = false
					debugLog("Duplicate name found")
					break
				end
				--Catch the matching name but still check for duplicate names
				if (avatar.name == oldName) then
					flag = true
					renamedAvatar = avatar
					debugLog("Found the old name")
				end
			end
			
			--Final check and set
			if flag then
				renamedAvatar.name = newName
				updateRenameGUI(player, oldName, newName)
			else
				--Name in use
				player.print{"Avatars-error-name-in-use"}
				updateRenameGUI(player, oldName, nil)
				player.gui.center.changeNameFrame.newNameField.text = newName
			end
		else
			--Blank text field
			player.print{"Avatars-error-blank-name"}
			updateRenameGUI(player, oldName, nil)
		end
	end
end

--Give control of an avatar to a player
function gainAvatarControl(event, name)
	debugLog("Gaining control of "..name)
	
	local player = game.get_player(event.player_index)
	local playerData = getPlayerData(player) --{player=nil, realBody=nil, currentAvatar=nil, currentAvatarName=nil, lastBodySwap=nil}
		
    -- Don't bodyswap too often, Factorio hates it when you do that. -per YARM
    if (playerData.lastBodySwap ~= nil) and (playerData.lastBodySwap + 10 > event.tick) then return end
    playerData.lastBodySwap = event.tick
	
	--Players can only control an avatar from their real body
	if (player.character.name ~= "player") then
		player.print{"Avatars-error-only-control-from-real-body"}
		return
	end
	
	--Store the real body
	playerData.realBody = player.character
	
	--Find the avatar
	for _, avatar in ipairs(global.avatars) do
		if (avatar.name == name) then
			debugLog(avatar.name.." found")
			
			local owner = nil
			--Make sure no one else is controlling it
			for _, players in ipairs(global.avatarPlayerData) do
				if (players.currentAvatar == avatar.avatarEntity) then
					owner = players.player.name
					break
				end
			end
			
			if (owner ~= nil) then
				player.print{"Avatars-error-already-controlled", owner}
				return
			end
			--Give it to the player
			playerData.currentAvatar = avatar.avatarEntity
			playerData.currentAvatarName = avatar.name
			break
		end
	end
	
	--Final check
	if (playerData.realBody ~= nil) and (playerData.currentAvatar ~= nil) then
		debugLog("Final check")
		playerData.currentAvatar.active = true
		player.character = playerData.currentAvatar
	end
	
	--GUI clean up
	destroyAllGUI(player)
	drawDisconnectGUI(player)
end

--Take control from a player
function loseAvatarControl(event, player)
	debugLog("Going back to the body")
	
	local playerData = getPlayerData(player)
	
	-- Don't bodyswap too often, Factorio hates it when you do that. -per YARM
    if (playerData.lastBodySwap ~= nil) and (playerData.lastBodySwap + 10 > event.tick) then return end
    playerData.lastBodySwap = event.tick
	
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
	destroyDisconnectGUI(player)
	drawSelectionGUI(player, 1)
end

--Look up the player in global.avatarPlayerData, or create an entry for them
function getPlayerData(player)
	global.avatarPlayerData = doesPlayerTableExistOrCreate(global.avatarPlayerData)
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

script.on_event(defines.events.on_gui_click, checkGUI)

--Check on an entity being built
function entityBuilt(event)
	local entity = event.created_entity
		
	--Dummy fuel to avoid the error signal
	if (entity.name == "avatar-control-center") then
		entity.insert{name="coal", count=1}
		entity.operable = false
		return
	end
	
	--Add avatars to the table
	if (entity.name == "avatar") then
		global.avatars = doesAvatarTableExistOrCreate(global.avatars)
		
		local defaultStringLength = #default_avatar_name
		local lastNameInTable = nil
		
		--Find the last name that has a default name
		for _, avatar in ipairs(global.avatars) do
			local name = avatar.name
			local namePrefix = string.sub(name, 1, defaultStringLength)
			if (namePrefix == default_avatar_name) then lastNameInTable = name end --If a sort function is added, this will need to sort first
			debugLog(lastNameInTable)
		end

		--Find out if it is higher than the total number of avatars
		--This is caused when one is destroyed
		local currentIncrement = #global.avatars
		if (lastNameInTable ~= nil) then
			local lastIncrement = tonumber(string.sub(lastNameInTable, defaultStringLength+1, #lastNameInTable))
			debugLog(lastIncrement)
			--Determine the increment to use
			if (lastIncrement >= currentIncrement) then currentIncrement = lastIncrement + 1 end
		end
		
		--Inser the new avatar to the table
		table.insert(global.avatars, {avatarEntity=entity, name=default_avatar_name..currentIncrement})
		debugLog("new avatar: " .. #global.avatars .. ", " .. global.avatars[#global.avatars].name)
	end
end

script.on_event(defines.events.on_robot_built_entity, entityBuilt)
script.on_event(defines.events.on_built_entity, entityBuilt)

--Check on entity being destroyed or deconstructed
function entityDestroyed(event)
	local entity = event.entity
	
	if (entity.name == "avatar-control-center") then
		--Remove dummy fuel
		entity.clear_items_inside()
		
		--Check if a player was using it
		local playerDataTable = doesPlayerTableExistOrCreate(global.avatarPlayerData)
		if (playerDataTable ~= nil) then
			for _, playerData in ipairs(playerDataTable) do
				if (entity.passenger == playerData.realBody) then
					--Deactive the current avatar
					--The game will continue it's actions otherwise, which can cause a game crash
					if (playerData.currentAvatar ~= nil) then
						playerData.currentAvatar.active = false
						local player = playerData.player
						loseAvatarControl(event, player)
						destroyAllGUI(player)
						player.print{"Avatars-error-avatar-control-center-destroyed"}
					end
				end
			end
		end
		return
	end
	
	if (entity.name == "avatar") then
		local player = nil
		local playerDataTable = doesPlayerTableExistOrCreate(global.avatarPlayerData)
		
		--Check if a player was controlling the avatar
		if (playerDataTable ~= nil) then
			for _, playerData in ipairs(playerDataTable) do
				if (playerData.currentAvatar == entity) then
					--Stop a game over screen --Will need added functionality for 0.13 to support MP properly
					game.set_game_state{game_finished=false}
					player = playerData.player
					
					--Give back control of the player's body
					loseAvatarControl(event, player)
					player.print{"Avatars-error-controlled-avatar-death"}
				end
			end
		end
		
		--Remove the avatar from the global table
		for _, currentAvatar in ipairs(global.avatars) do
			if (currentAvatar.avatarEntity == entity) then
				local newFunction = function (arg) return arg.avatarEntity == entity end --Function that returns true or false if the entities match
				global.avatars = removeFromTable(newFunction, global.avatars)
				debugLog("deleted avatar: " .. #global.avatars .. ", " .. currentAvatar.name)
				
				--Will only be set if a player was in the avatar
				if (player ~= nil) then
					--They need the GUI if so
					drawSelectionGUI(player, 1)
				end
			end
		end
	end
end

--Removes an entity from the global table
--Works by adding everything except the old entry to a new table and overwritting the old table
function removeFromTable(func, avatarTable)
	if (avatarTable == nil) then return nil end
	local newTable = {}
	for _, row in ipairs(avatarTable) do
		if not func(row) then table.insert(newTable, row) end
	end
	return newTable
end

script.on_event(defines.events.on_preplayer_mined_item, entityDestroyed)
script.on_event(defines.events.on_robot_pre_mined, entityDestroyed)
script.on_event(defines.events.on_entity_died, entityDestroyed)

--Make sure global.avatarPlayerData exists
function doesPlayerTableExistOrCreate(checkTable)
	if checkTable == nil then
		return {player=nil, realBody=nil, currentAvatar=nil, lastBodySwap=nil}
	else
		return checkTable
	end
end

--Make sure global.avatars exists
function doesAvatarTableExistOrCreate(checkTable)
	if checkTable == nil then
		return {avatarEntity=nil,name=""}
	else
		return checkTable
	end
end

--DEBUG messages
function debugLog(message)
	if debug_mode then
		game.player.print(message)
	end
end 


--Remote Calls
--Sometimes remote calls don't want to work, not sure why
-- /c remote.call("Ava", "manualSwapBack")
remote.add_interface("Ava", {
	manualSwapBack = function()
		player = game.player
		local positionX = player.character.position.x
		local positionY = player.character.position.y
		
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
	end
})

--LAST DITCH EFFORT
--Only use this is your body was destroyed somehow and you can't reload a save (this will create a new body)
-- /c remote.call("Ava", "createNewBody")
remote.add_interface("Ava", {
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
			game.player.insert({name="avatar-control-center", count=2})
			game.player.insert({name="avatar", count=25})
		end
	end
})
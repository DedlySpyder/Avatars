require "defines"
require "gui"
local debug_mode = true --DEBUG

--table needs spaces added somehow & buttons!
function driving(event)
	local player = game.get_player(event.player_index)
	
	if player.vehicle and player.vehicle.name == "avatar-control-center" then
		updateGUI(player, 1)
		debugLog("getting in")
	else 
		destroyGUI(player)
		debugLog("getting out")
	end
end

function destroyGUI(player)
	if (player.gui.center.selectionFrame ~= nil) then
		player.gui.center.selectionFrame.destroy()
	end
	changeAvatarNameClose(player)
end

--UNNEEDED?
function drawGUI(player)
	
	
	--local numberList = numberFrame.add{type="frame", name="numberList", direction="vertical"}
	--local nameList = nameFrame.add{type="frame", name="nameList", direction="vertical"}
	--local locationList = locationFrame.add{type="frame", name="locationList", direction="vertical"}
	
	updateGUI(player, 1)
	
	
end

function updateGUI(player, pageNumber) --This needs to only show avatars in the same force
	local pageItems = 1
	if (pageNumber ~= 1) then
		debugLog("Adjusting pageNumber"..pageNumber)
		pageItems = ((pageNumber-1)*10)+1
	end
	
	if (selectionFrame ~= nil and selectionFrame.valid) then 
		selectionFrame.destroy() 
	end
		
	local position = player.position
	local positionString = "("..math.floor(position.x)..", "..math.floor(position.y)..")"
	selectionFrame = player.gui.center.add{type="frame", name="selectionFrame", direction="vertical", caption="Avatar Control Center "..positionString}
	--local tableHeader = selectionFrame.add{type="frame", name="header", direction="horizontal"}
	--tableHeader.add{type="label", name="headerNumber", caption="Avatar # |"}
	--tableHeader.add{type="label", name="headerName", caption=" Avatar Name |"}
	--tableHeader.add{type="label", name="headerLocaltion", caption=" Avatar Location"}
	
	avatarTable = selectionFrame.add{type="table", name="avatarTable", colspan=4}--, style="avatar_table"}
	
	numberFrame = avatarTable.add{type="frame", name="numberFrame", direction="vertical"}--, style="avatar_table_frame"}
	nameFrame = avatarTable.add{type="frame", name="nameFrame", direction="vertical"}--, style="avatar_table_frame"}
	locationFrame = avatarTable.add{type="frame", name="locationFrame", direction="vertical"}--, style="avatar_table_frame"}
	controlFrame = avatarTable.add{type="frame", name="controlFrame", direction="vertical"}
	
	numberFrame.add{type="label", caption="#", style="avatar_label_center"}
	numberFrame.add{type="label", caption="-", style="avatar_label_center"}
	nameFrame.add{type="label", caption="    Avatar Name    ", style="avatar_label_center"}
	nameFrame.add{type="label", caption="--------------------", style="avatar_label_center"}
	locationFrame.add{type="label", caption="Avatar Location", style="avatar_label_center"}
	locationFrame.add{type="label", caption="---------------", style="avatar_label_center"}
	controlFrame.add{type="label", caption="Control Avatar", style="avatar_label_center"}
	controlFrame.add{type="label", caption="--------------", style="avatar_label_center"}
		
	if (global.avatars ~= nil) then
		for row=pageItems,(pageItems+9),1 do
			local avatar = global.avatars[row]
			if (avatar == nil) then break end
			numberFrame.add{type="label", caption=row, style="avatar_label_center"}
			nameRow = nameFrame.add{type="flow", direction="horizontal"}
			nameRow.add{type="label", name=avatar.name, caption=avatar.name, style="avatar_label_center"}
			nameRow.add{type="button", name="avatar_rnam_"..avatar.name, style="avatar_button_rename"} --button name "rnam_"
			locationFrame.add{type="label", caption=printPosition(avatar), style="avatar_label_center"}
			controlFrame.add{type="button", name="avatar_ctrl_"..avatar.name, caption="Control", style="avatar_button_control"} -- button name "ctrl_"
		end
		if (#global.avatars > 10)then
			selectionFrame.add{type="button", name="pageBack", caption="<", style="avatar_button_change_page"}
			selectionFrame.add{type="label", name="pageNumber", caption=pageNumber, style="avatar_label_center"}
			selectionFrame.add{type="button", name="pageForward", caption=">", style="avatar_button_change_page"}
			selectionFrame.add{type="label", caption="  Total Avatars: "..#global.avatars}
		end
	end
end

function printPosition(avatar)
	local entity = avatar.avatarEntity
	local position = "(" ..math.floor(entity.position.x) ..", " ..math.floor(entity.position.y) ..")"
	return position
end

script.on_event(defines.events.on_player_driving_changed_state, driving)

--GUI checks
function checkGUI(event)
	local element = event.element
	local elementName = element.name
	local player = game.get_player(event.player_index)
	debugLog("Clicked "..elementName)
	
	if (elementName == "pageForward") then
		local page = tonumber(selectionFrame.pageNumber.caption)
		if (#global.avatars > page*10) then
			updateGUI(player, page+1)
		end
		return
	end
	
	if (elementName == "pageBack") then
		local page = tonumber(selectionFrame.pageNumber.caption)
		if (page > 1) then
			updateGUI(player, page-1)
		end
		return
	end
	
	local modSubString = string.sub(elementName, 1, 7)
	if (modSubString == "avatar_") then
		debugLog("Avatar Mod button press")
		local modButton = string.sub(elementName, 8, 11)
		debugLog("Button pushed: "..modButton)
		if (modButton == "rnam") then
			local name = string.sub(elementName, 13)
			changeAvatarName(player, name)
		end
		
		if (modButton == "ctrl") then
			local name = string.sub(elementName, 13)
			gainAvatarControl(event, name)
		end
		
		if (modButton == "sbmt") then
			changeAvatarNameSubmit(player)
		end
		
		if (modButton == "cncl") then
			changeAvatarNameClose(player)
		end
		
		if (modButton == "exit") then
			loseAvatarControl(event, player)
		end
	end
end

--Changing the name
function changeAvatarName(player, name)
	
	if (changeNameFrame ~= nil and changeNameFrame.valid) then
		changeNameFrame.destroy()
	end
	debugLog("Changing name of "..name)
	changeNameFrame = player.gui.center.add{type="frame", name="changeNameFrame", direction="vertical", caption="Change Avatar Name"}
	changeNameFrame.add{type="label", name="currentName", caption="Current Name: "..name}
	changeNameFrame.add{type="textfield", name="newNameField"}
	
	local buttonsFlow = changeNameFrame.add{type="flow", name="buttonsFlow"}
	buttonsFlow.add{type="button", name="avatar_sbmt", caption="Submit"}
	buttonsFlow.add{type="button", name="avatar_cncl", caption="Cancel"}
end

--Submiting the name
function changeAvatarNameSubmit(player)
	local oldName = string.sub(changeNameFrame.currentName.caption, 15)
	if (changeNameFrame.newNameField ~= nil) then
		if (changeNameFrame.newNameField.text ~= "") then
			local newName = changeNameFrame.newNameField.text
			for _, avatar in ipairs(global.avatars) do
				if (avatar.name == oldName) then
					avatar.name = newName
					break
				end
			end
			
			local page = tonumber(player.gui.center.selectionFrame.pageNumber.caption)
			updateGUI(player, page)
			changeAvatarName(player, oldName)
			changeNameFrame.newNameField.text = newName
			changeAvatarNameClose(player)
			return
		else
			game.player.print("Please enter a name.")
		end
	end
end

--Closing the name change box
function changeAvatarNameClose(player)
	if (player.gui.center.changeNameFrame ~= nil) then
		player.gui.center.changeNameFrame.destroy()
	end 
end

function gainAvatarControl(event, name)
	debugLog("Gaining control of "..name)
	
	local player = game.get_player(event.player_index)
	
	local playerData = getPlayerData(player) --{player=nil, realBody=nil, currentAvatar=nil, lastBodySwap=nil}
		

    -- Don't bodyswap too often, Factorio hates it when you do that. -per YARM
    if (playerData.lastBodySwap ~= nil) and (playerData.lastBodySwap + 10 > event.tick) then return end
    playerData.lastBodySwap = event.tick
	
	if (player.character.name ~= "player") then
		player.print("You can only control from your real body!")
		return
	end
	playerData.realBody = player.character
	
	
	for _, avatar in ipairs(global.avatars) do
		if (avatar.name == name) then
			debugLog(avatar.name.." found")
			playerData.currentAvatar = avatar.avatarEntity
			break
		end
	end
	
	if (playerData.realBody ~= nil) and (playerData.currentAvatar ~= nil) then
		debugLog("final check")
		playerData.currentAvatar.active = true
		player.character = playerData.currentAvatar
	end
	
	destroyGUI(player)
	cancelControlGui(player)
end

function cancelControlGui(player)
	player.gui.top.add{type="button", name="avatar_exit", caption="GTFO?"}
end

function loseAvatarControl(event, player)
	debugLog("Going back to my body")
	
	local playerData = getPlayerData(player)
	
	-- Don't bodyswap too often, Factorio hates it when you do that. -per YARM
    if (playerData.lastBodySwap ~= nil) and (playerData.lastBodySwap + 10 > event.tick) then return end
    playerData.lastBodySwap = event.tick
	
	player.character = playerData.realBody
	
	playerData.realBody = nil
	playerData.currentAvatar = nil
	player.gui.top.avatar_exit.destroy()
	updateGUI(player, 1)
end

--depreciated
function killPlayer(event, player)
	debugLog("Your body died.")
	
	local playerData = getPlayerData(player)
	local position = playerData.realBody.position
	--recreate the avatar?
	local currentAvatar = playerData.currentAvatar
	local currentAvatarPosition = currentAvatar.position
	local currentAvatarForce = currentAvatar.force
	
	local newAvatar = player.surface.create_entity{name="avatar", position=currentAvatarPosition, force=currentAvatarForce}
	
	for x, selectedAvatar in ipairs(global.avatars) do
		if (selectedAvatar.avatarEntity == playerData.currentAvatar) then
			debugLog("Replacing the avatar")
			transferInventory(selectedAvatar.avatarEntity, newAvatar)
			selectedAvatar.avatarEntity = newAvatar--WORKING?? (check the new ones inventory)
		end
	end
	playerData.currentAvatar.destroy()
	
	playerData.realBody = nil
	playerData.currentAvatar = nil
	player.gui.top.avatar_exit.destroy()
	
	player.character = player.surface.create_entity{name="player", position=position, force=player.force}
	player.character.damage(1000, player.force)
end

--depreciated
function transferInventory(fromEntity, toEntity)
	--local inventoryContents = fromEntity.get_inventory(inventory.player_main.get_contents())
	local inventoryContents = fromEntity.get_inventory(6).get_contents() --I have no idea what this returns ****************************
																		 --Or if I am even accessing the right inventory
	
	-- inventoryContents += [other inventories]?
	
	for _, item in ipairs(inventoryContents) do
		local success = toEntity.insert({name=item.name, count=item.count})
		debugLog(success)
	end
end

function getPlayerData(player)
	global.avatarPlayerData = doesPlayerTableExistOrCreate(global.avatarPlayerData)
	if (player == nil) then return end --?
	for _, playerData in ipairs(global.avatarPlayerData) do
		if (playerData.player == player) then
			debugLog(player.name.." was found in the table")
			return playerData
		end
	end
	
	debugLog(player.name.." was added to the table")
	local playerData = {player=player, realBody=nil, currentAvatar=nil, lastBodySwap=nil}
	table.insert(global.avatarPlayerData, playerData)
	debugLog("Players is PlayerData:"..#global.avatarPlayerData)
	return playerData
end

script.on_event(defines.events.on_gui_click, checkGUI)

function entityBuilt(event)
	local entity = event.created_entity
	
	if (entity.name == "avatar-control-center") then
		entity.insert{name="coal", count=1}
		entity.operable = false
		return
	end
	
	if (entity.name == "avatar") then
		global.avatars = doesAvatarTableExistOrCreate(global.avatars)
		
		table.insert(global.avatars, {avatarEntity=entity, name="Avatar #" ..#global.avatars})
		
		debugLog("new avatar: " .. #global.avatars .. ", " .. global.avatars[#global.avatars].name)
	end
end

script.on_event(defines.events.on_robot_built_entity, entityBuilt)
script.on_event(defines.events.on_built_entity, entityBuilt)

function entityDestroyed(event)
	local entity = event.entity
	
	if (entity.name == "avatar-control-center") then
		entity.clear_items_inside()
		for _, playerData in ipairs(global.avatarPlayerData) do
			if (entity.passenger == playerData.realBody) then
				playerData.currentAvatar.active = false
				loseAvatarControl(event, playerData.player)
			end
		end
		return
	end
	
	--depreciated
	if false then--(entity.name == "player") then
		local playerDataTable = doesPlayerTableExistOrCreate(global.avatarPlayerData)
		
		if (playerDataTable ~= nil) then
			for _, playerData in ipairs(playerDataTable) do
				if (playerData.realBody == entity) then
					local player = playerData.player
					killPlayer(event, player)
					return
				end
			end
		end
	end
	
	if (entity.name == "avatar") then
		local player = nil
		local playerDataTable = doesPlayerTableExistOrCreate(global.avatarPlayerData)
		
		if (playerDataTable ~= nil) then
			for _, playerData in ipairs(playerDataTable) do
				if (playerData.currentAvatar == entity) then
					game.set_game_state{game_finished=false}
					
					player = playerData.player
					loseAvatarControl(event, player)
				end
			end
		end
		
		for _, currentAvatar in ipairs(global.avatars) do
			if (currentAvatar.avatarEntity == entity) then
				local newFunction = function (arg) return arg.avatarEntity == entity end
				global.avatars = removeFromTable(newFunction, global.avatars)
				debugLog("deleted avatar: " .. #global.avatars .. ", " .. currentAvatar.name)
				if (player ~= nil) then
					updateGUI(player, 1)
				end
			end
		end
	end
end

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

function doesPlayerTableExistOrCreate(checkTable)
	if checkTable == nil then
		return {player=nil, realBody=nil, currentAvatar=nil, lastBodySwap=nil}
	else
		return checkTable
	end
end

function doesAvatarTableExistOrCreate(checkTable)
	if checkTable == nil then
		return {avatarEntity=nil,name=""}
	else
		return checkTable
	end
end

function debugLog(message)
	if debug_mode then
		game.player.print(message)
	end
end 


--Remote Calls
-- /c remote.call("avatar", "testing")
remote.add_interface("avatar", {
	testing = function()
		if debug_mode then
			game.player.insert{item="avatar-control-center", count=2}
			game.player.insert{item="avatar", count="25"}
		end
	end
})

--Searches in a small radius to find your body
-- /c remote.call("avatar", "findMyBody")
remote.add_interface("avatar", {
	findMyBody = function()
		--TODO, search for realBody, and switch back
	end
})

--LAST DITCH EFFORT
--Only use this is your body was destroyed and you can't go back with the aboe function
-- /c remote.call("avatar", "createNewBody")
remote.add_interface("avatar", {
	createNewBody = function()
		--TODO, create new body near current location and switch to it
	end
})
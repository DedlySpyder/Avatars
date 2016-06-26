--Selection GUI - The main table that displays and allows for renaming and control of avatars
--Draw Selection GUI
function drawSelectionGUI(player, pageNumber)
	--Create the frame variable
	local selectionFrame
	
	--Destroy old Selection GUI
	destroySelectionGUI(player)
	
	--Create the frame to hold everything
	selectionFrame = player.gui.center.add{type="frame", name="selectionFrame", direction="vertical", caption={"Avatars-table-header", printPosition(player)}}
	
	--Table to display items
	avatarTable = selectionFrame.add{type="table", name="avatarTable", colspan=4}
	
	--Columns in the table
	numberFrame = avatarTable.add{type="frame", name="numberFrame", direction="vertical"}
	nameFrame = avatarTable.add{type="frame", name="nameFrame", direction="vertical", style="avatar_table_avatar_name_frame"}
	locationFrame = avatarTable.add{type="frame", name="locationFrame", direction="vertical", style="avatar_table_avatar_location_frame"}
	controlFrame = avatarTable.add{type="frame", name="controlFrame", direction="vertical"}
	
	--Column headers
	numberFrame.add{type="label", caption="#", style="avatar_table_general"}
	numberFrame.add{type="label", caption="-", style="avatar_table_general"}
	nameFrame.add{type="label", caption={"Avatars-table-avatar-name-header"}, style="avatar_table_header_avatar_name"}
	nameFrame.add{type="label", caption="-------------------------------------", style="avatar_table_general"}
	locationFrame.add{type="label", caption={"Avatars-table-avatar-location-header"}, style="avatar_table_label_avatar_location"}
	locationFrame.add{type="label", caption="-----------------", style="avatar_table_label_avatar_location"}
	controlFrame.add{type="label", caption={"Avatars-table-control-header"}, style="avatar_table_general"}
	controlFrame.add{type="label", caption="--------------", style="avatar_table_general"}
	
	--Calculation for the first and last item to display
	local firstItem = 1
	if (pageNumber ~= 1) then
		debugLog("Adjusting page number "..pageNumber)
		firstItem = ((pageNumber-1)*table_avatars_per_page)+1
	end
	local lastItem = firstItem+(table_avatars_per_page-1)
	
	--Total avatars in the player's force
	local totalAvatars = 0
	
	if (global.avatars ~= nil) then
		local row = 1
		local itemsDisplayed = 0
		for _, avatar in ipairs(global.avatars) do
			if (avatar == nil) then break end
			--Make sure the avatar is in the same force
			local avatarEntity = avatar.avatarEntity
			if (avatarEntity ~= nil and avatarEntity.valid) then
				if (avatarEntity.force.name == player.force.name) then
					--Add it to the count
					totalAvatars = totalAvatars + 1
					--Make sure the avatar should be on this page, and that the page isn't full
					if (row >= firstItem) and (row <= lastItem) and (itemsDisplayed <= table_avatars_per_page) then
						numberFrame.add{type="label", caption=row, style="avatar_table_general"}
						nameRow = nameFrame.add{type="flow", direction="horizontal"}
						nameRow.add{type="label", name=avatar.name, caption=avatar.name, style="avatar_table_label_avatar_name"}
						nameRow.add{type="button", name="avatar_rnam_"..avatar.name, style="avatar_table_button_rename"} --button name "rnam_"
						locationFrame.add{type="label", caption=printPosition(avatarEntity), style="avatar_table_label_avatar_location"}
						controlFrame.add{type="button", name="avatar_ctrl_"..avatar.name, caption={"Avatars-table-control-button"}, style="avatar_table_button_control"} -- button name "ctrl_"
						
						itemsDisplayed = itemsDisplayed + 1
					end
				end
				row = row + 1
			end
		end
		
		--Footer
		local footerFlag = (totalAvatars > table_avatars_per_page)
		
		--Page Back
		if footerFlag then
			selectionFrame.add{type="button", name="pageBack", caption="<", style="avatar_table_button_change_page"}
		end
		
		--Page Number
		selectionFrame.add{type="label", name="pageNumber", caption=pageNumber, style="avatar_table_general"}
		
		--Page Forward
		if footerFlag then
			selectionFrame.add{type="button", name="pageForward", caption=">", style="avatar_table_button_change_page"}
		end
		
		--Avatar Total
		selectionFrame.add{type="label", caption={"Avatars-table-total-avatars", totalAvatars}, style="avatar_table_total_avatars"}
	end
end

--Creates a printable position
function printPosition(entity)
	local position = "(" ..math.floor(entity.position.x) ..", " ..math.floor(entity.position.y) ..")"
	return position
end

--Update Selection GUI for the current player
function updateSelectionGUI(player)
	--Find the current page number
	local pageNumber = tonumber(player.gui.center.selectionFrame.pageNumber.caption)
	
	--Redraw the GUI
	drawSelectionGUI(player, pageNumber)
end

--Update the Selection GUI for all players on this page
function updateSelectionGUIAll(pageNumber)
	for _, player in ipairs(game.players) do
		local playersSelectionFrame = player.gui.center.selectionFrame
		if (playersSelectionFrame ~= nil and playersSelectionFrame.valid) then
			local currentPageNumber = tonumber(playersSelectionFrame.pageNumber.caption)
			if (pageNumber == currentPageNumber) then
				debugLog("Updating Slection GUI of "..player.name)
				drawSelectionGUI(player, pageNumber)
			end
		end
	end
end

--Returns true or false if the Selection GUI is open
function verifySelectionGUI(player)
	if (player.gui.center.selectionFrame ~= nil and player.gui.center.selectionFrame.valid) then
		return true
	end
	return false
end

--Destroy Selection GUI
function destroySelectionGUI(player)
	if verifySelectionGUI(player) then 
		player.gui.center.selectionFrame.destroy()
	end
end

--Rename GUI -Rename an avatar
--Draw Rename GUI
function drawRenameGUI(player, name)
	--Destroy old Rename GUI
	destroyRenameGUI(player)
	debugLog("Changing name of "..name)
	
	--Rename Frame and labels
	local changeNameFrame = player.gui.center.add{type="frame", name="changeNameFrame", direction="vertical", caption={"Avatars-change-name-change-name"}}
	local currentNameFlow = changeNameFrame.add{type="flow", name="currentNameFlow", direction="horizontal"}
	currentNameFlow.add{type="label", name="currentNameLabel", caption={"Avatars-change-name-current-name"}}
	currentNameFlow.add{type="label", name="currentName", caption=name}
	changeNameFrame.add{type="textfield", name="newNameField"}
	
	--Buttons
	local buttonsFlow = changeNameFrame.add{type="flow", name="buttonsFlow"}
	buttonsFlow.add{type="button", name="avatar_sbmt", caption={"Avatars-submit-button"}}
	buttonsFlow.add{type="button", name="avatar_cncl", caption={"Avatars-cancel-button"}}
end

--Update Rename GUI
function updateRenameGUI(player, oldName, newName)
	--Check if a name change occured
	if (newName ~= nil) then
		--Update Selection GUI first, to maintain order
		if verifySelectionGUI(player) then
			updateSelectionGUIAll(tonumber(player.gui.center.selectionFrame.pageNumber.caption))
		end
		
		--Update Rename GUI for each player
		for _, players in ipairs(game.players) do
			local changeNameFrame = players.gui.center.changeNameFrame
			if (changeNameFrame ~= nil and changeNameFrame.valid) then
				--Perserve the text in the textfield
				local currentTextField = changeNameFrame.newNameField.text
				
				--Check for each player
				if (changeNameFrame.currentNameFlow.currentName.caption == oldName) then
					drawRenameGUI(players, newName)
				else
					local currentName = changeNameFrame.currentNameFlow.currentName.caption
					drawRenameGUI(players, currentName)
				end
				
				--Put back the text in the textfield
				players.gui.center.changeNameFrame.newNameField.text = currentTextField
			end
		end
	else
		--If not, update with the old name
		updateSelectionGUI(player)
		drawRenameGUI(player, oldName)
	end
end

--Returns true or false if the Rename GUI is open
function verifyRenameGUI(player)
	if (player.gui.center.changeNameFrame ~= nil and player.gui.center.changeNameFrame.valid) then
		return true
	end
	return false
end

--Destroy Rename GUI
function destroyRenameGUI(player)
	if verifyRenameGUI(player) then
		player.gui.center.changeNameFrame.destroy()
	end 
end

--Disconnect GUI - Disconnect from the controlled avatar
--Draw Disconnect GUI
function drawDisconnectGUI(player)
	local disconnect = player.gui.top.add{type="flow", name="avatarExit"}
	disconnect.add{type="button", name="avatar_exit", caption={"Avatars-button-disconnect"}}
end

--Destroy Disconnect GUI
function destroyDisconnectGUI(player)
	if (player.gui.top.avatarExit ~= nil and player.gui.top.avatarExit.valid) then
		player.gui.top.avatarExit.destroy()
	end 
end

--Avatar Remote Deployment Unit GUI
--Draw ARDU GUI
function drawARDUGUI(player, ARDU)
	--Destroy old ARDU GUI
	destroyARDUGUI(player)
	
	--Get the ARDU from the table
	local ARDUData = getARDUFromTable(ARDU)
	
	if (ARDUData ~= nil) then
		--Rename Frame and labels
		local ARDUGUI = player.gui.center.add{type="frame", name="avatarARDUFrame", direction="vertical", caption={"Avatars-ARDU-rename-header"}}
		local currentNameFlow = ARDUGUI.add{type="flow", name="currentNameFlow", direction="horizontal"}
		currentNameFlow.add{type="label", name="currentNameLabel", caption={"Avatars-ARDU-rename-current-name"}}
		currentNameFlow.add{type="label", name="currentName", caption=ARDUData.name, style="avatar_ARDU_current_name"}
		ARDUGUI.add{type="textfield", name="newNameField"}
		
		--Buttons
		local buttonsFlow = ARDUGUI.add{type="flow", name="buttonsFlow"}
		buttonsFlow.add{type="button", name="avatar_ARDU", caption={"Avatars-submit-button"}}
	else
		player.print{"Avatars-error-ARDU-not-found"}
	end
end

--Destroy ARDU GUI
function destroyARDUGUI(player)
	if (player.gui.center.avatarARDUFrame ~= nil and player.gui.center.avatarARDUFrame.valid) then
		player.gui.center.avatarARDUFrame.destroy()
	end 
end

--Destroys all GUI
function destroyAllGUI(player)
	destroySelectionGUI(player)
	destroyRenameGUI(player)
	destroyDisconnectGUI(player)
	destroyARDUGUI(player)
end
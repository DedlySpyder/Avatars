local Sort = require("sort")
local Storage = require "storage"
require("mod-gui")

-- The returned table by this file will contain all the GUI related functions
-- The main object will have the following for each GUI used by the mod (along with a few helper functions):
--		Selection
--		Rename
--		Disconnect
--		ARDU

local GUI = {}

--Creates a printable position
GUI.entityPositionString = function(entity)
	local position = "(" ..math.floor(entity.position.x) ..", " ..math.floor(entity.position.y) ..")"
	return position
end

--Destroys all GUI
GUI.destroyAll = function(player)
	GUI.Selection.destroy(player)
	GUI.Rename.destroy(player)
	GUI.Disconnect.destroy(player)
	GUI.ARDU.destroy(player)
end



--~~~~~~~  Selection GUI ~~~~~~~--
GUI.Selection = {}

--Selection GUI - The main table that displays and allows for renaming and control of avatars
--Draw Selection GUI
GUI.Selection.draw = function(player)
	debugLog("Drawing Selection GUI")
	
	--Determine the sort
	local sortValues
	if GUI.Selection.verify(player) then
		--Get the sort from the current selection GUI
		debugLog("Old Selection GUI found")
		sortValues = Sort.getCurrentState(player)
	else
		--Default sort values
		sortValues = {	name_ascending = true,
						name_descending = false,
						location_ascending = false,
						location_descending = false
					 }
	end
	
	--Destroy old Selection GUI
	GUI.Selection.destroy(player)
	
	--Obtain a sorted table to display
	local sortedTable = Sort.getSortedTable(sortValues, player)
	
	--Create the frame to hold everything
	local avatarSelectionFrame = player.gui.center.add{type="frame", name="avatarSelectionFrame", direction="vertical", caption={"Avatars-table-header", GUI.entityPositionString(player)}}
	
	--Total avatar count
	local totalEntries = 0
	
	--Fill in the GUI if there is data
	if sortedTable and #sortedTable > 0 then
		--Flow to align the header frames
		local headerFlow = avatarSelectionFrame.add{type="flow", name="headerFlow", direction="horizontal"}
		
		--Column header frames
		local nameHeader = headerFlow.add{type="frame", name="nameHeader", direction="vertical", style="avatar_table_name_header_frame"}
		local locationHeader = headerFlow.add{type="frame", name="locationHeader", direction="vertical", style="avatar_table_location_header_frame"}
		local renameHeader = headerFlow.add{type="frame", name="renameHeader", direction="vertical", style="avatar_table_rename_header_frame"}
		local controlHeader = headerFlow.add{type="frame", name="controlHeader", direction="vertical", style="avatar_table_control_header_frame"}
		
		--Header labels
		nameHeader.add{type="label", caption={"Avatars-table-avatar-name-header"}, style="avatar_table_header_avatar_name"}
		locationHeader.add{type="label", caption={"Avatars-table-avatar-location-header"}, style="avatar_table_general"}
		renameHeader.add{type="label", caption={"Avatars-table-rename-avatar-header"}, style="avatar_table_general"}
		controlHeader.add{type="label", caption={"Avatars-table-control-avatar-header"}, style="avatar_table_general"}
		
		--Create the "Asending" sort row
		local upperSortFlow = avatarSelectionFrame.add{type="flow", name="upperSortFlow", direction="horizontal"}
		upperSortFlow.add{type="label", caption={"Avatars-table-sort-prefix"}}
		upperSortFlow.add{	type="radiobutton", 
							name="avatar_sort_name_ascending", 
							caption={"Avatars-table-ascending"}, 
							tooltip={"Avatars-table-sort-ascending-names-tooltip"}, 
							state=sortValues.name_ascending, 
							style="avatar_table_name_sort_radiobutton"}
		upperSortFlow.add{	type="radiobutton", 
							name="avatar_sort_location_ascending", 
							caption={"Avatars-table-ascending"}, 
							tooltip={"Avatars-table-sort-ascending-location-tooltip"}, 
							state=sortValues.location_ascending}
		upperSortFlow.add{type="label", caption="", style="avatar_table_sort_trailing_null_label"}
		
		--Create the "Descending" sort row
		local lowerSortFlow = avatarSelectionFrame.add{type="flow", name="lowerSortFlow", direction="horizontal"}
		lowerSortFlow.add{type="label", caption="", style="avatar_table_sort_leading_null_label"}
		lowerSortFlow.add{	type="radiobutton", 
							name="avatar_sort_name_descending", 
							caption={"Avatars-table-descending"}, 
							tooltip={"Avatars-table-sort-descending-names-tooltip"}, 
							state=sortValues.name_descending, 
							style="avatar_table_name_sort_radiobutton"}
		lowerSortFlow.add{	type="radiobutton", 
							name="avatar_sort_location_descending", 
							caption={"Avatars-table-descending"}, 
							tooltip={"Avatars-table-sort-descending-location-tooltip"}, 
							state=sortValues.location_descending}
		lowerSortFlow.add{type="label", caption="", style="avatar_table_sort_trailing_null_label"}
		
		--Frame and scroll pane creation
		local tableFrame = avatarSelectionFrame.add{type="frame", name="tableFrame", direction="vertical"}
		local selectionScrollPane = tableFrame.add{type="scroll-pane", name="selectionScrollPane", direction="vertical", style="avatar_table_scroll_pane"}
		
		-- Iterate through the avatars (and ARDUs)
		for _, tableEntry in ipairs(sortedTable) do
			--if not avatar then break end --TODO - why did I have this?
			local entity = tableEntry.entity
			if entity and entity.valid then
				--Add it to the count
				totalEntries = totalEntries + 1
				

				--Create the row frame
				local row = selectionScrollPane.add{type="frame", direction="horizontal", style="avatar_table_row_frame"}
				
				local renameEnabled = true
				local controlButtonName = nil
				
				-- Check if the entry is an ARDU
				if tableEntry.currentIteration then
					renameEnabled = false
					controlButtonName = "avatar_ctrl_ardu_" .. tableEntry.name
				else
					controlButtonName = "avatar_ctrl_" .. tableEntry.name
				end
				
				--Fill in the row
				row.add{type = "label", name = tableEntry.name, caption = tableEntry.name, style = "avatar_table_label_avatar_name"}
				row.add{type = "label", caption = Sort.getDistance(player.position, entity.position), style = "avatar_table_label_avatar_location"}
				row.add{	type = "button",
							name = "avatar_rnam_" .. tableEntry.name,
							enabled = renameEnabled,
							caption = {"Avatars-table-rename-button"},
							tooltip = {"Avatars-table-rename-button-tooltip", tableEntry.name},
							style = "avatar_table_button"
				}
				row.add{type = "label", style = "avatar_table_label_gap"}
				row.add{	type = "button", 
							name = controlButtonName, 
							caption = {"Avatars-table-control-button"}, 
							tooltip = {"Avatars-table-control-button-tooltip", tableEntry.name}, 
							style = "avatar_table_button"
				}
			end
		end
	end
	
	--Footer 
	--Exit button
	avatarSelectionFrame.add{type="button", name="avatar_exit", caption={"Avatars-table-exit-button"}}
	--Avatar Total
	avatarSelectionFrame.add{type="label", caption={"Avatars-table-total-avatars", totalEntries}, style="avatar_table_total_avatars"}
end

--Update Selection GUI for the current player
GUI.Selection.update = function(player)
	--Redraw the GUI
	if GUI.Rename.verify then
		GUI.Selection.draw(player)
	end
end

--Update the Selection GUI for all players on this page
--TODO - wait, does this just draw it fresh for each player??
GUI.Selection.updateAllPlayers = function()
	for _, player in pairs(game.players) do
		GUI.Selection.draw(player)
	end
end

--Returns true or false if the Selection GUI is open
GUI.Selection.verify = function(player)
	if (player.gui.center.avatarSelectionFrame ~= nil and player.gui.center.avatarSelectionFrame.valid) then
		return true
	end
	return false
end

--Destroy Selection GUI
GUI.Selection.destroy = function(player)
	if GUI.Selection.verify(player) then 
		player.gui.center.avatarSelectionFrame.destroy()
		GUI.Rename.destroy(player)
	end
end

--Flip the sort radio buttons that were not checked
GUI.Selection.flipRadioButtons = function(player, modButton)
	if GUI.Selection.verify(player) then
		if (modButton ~= "name_ascending") then
			player.gui.center.avatarSelectionFrame.upperSortFlow.avatar_sort_name_ascending.state = false
		end
		
		if (modButton ~= "name_descending") then
			player.gui.center.avatarSelectionFrame.lowerSortFlow.avatar_sort_name_descending.state = false
		end
		
		if (modButton ~= "location_ascending") then
			player.gui.center.avatarSelectionFrame.upperSortFlow.avatar_sort_location_ascending.state = false
		end
		
		if (modButton ~= "location_descending") then
			player.gui.center.avatarSelectionFrame.lowerSortFlow.avatar_sort_location_descending.state = false
		end
	end
end



--~~~~~~~  Rename GUI ~~~~~~~--
GUI.Rename = {}

--Rename GUI -Rename an avatar
--Draw Rename GUI
GUI.Rename.draw = function(player, name)
	--Destroy old Rename GUI
	GUI.Rename.destroy(player)
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

--Update Rename GUI when the submit button has be pressed
GUI.Rename.updateOnSubmit = function(player, oldName, newName)
	--Check if a name change occured
	if (newName ~= nil) then
		--Update Selection GUI first, to maintain order
		if GUI.Selection.verify(player) then
			GUI.Selection.updateAllPlayers()
		end
		
		--Update Rename GUI for each player
		for _, players in pairs(game.players) do
			local changeNameFrame = players.gui.center.changeNameFrame
			if (changeNameFrame ~= nil and changeNameFrame.valid) then
				--Perserve the text in the textfield
				local currentTextField = changeNameFrame.newNameField.text
				
				--Check for each player
				if (changeNameFrame.currentNameFlow.currentName.caption == oldName) then
					GUI.Rename.draw(players, newName)
				else
					local currentName = changeNameFrame.currentNameFlow.currentName.caption
					GUI.Rename.draw(players, currentName)
				end
				
				--Put back the text in the textfield
				players.gui.center.changeNameFrame.newNameField.text = currentTextField
			end
		end
	else
		--If not, update with the old name
		GUI.Selection.update(player)
		GUI.Rename.draw(player, oldName)
	end
end

--Update the Rename GUI
GUI.Rename.update = function(player)
	--Update Selection GUI first, to maintain order
	GUI.Selection.update(player)
	
	if GUI.Rename.verify(player) then
		--Preserve the name and the text in the text box
		local currentName = player.gui.center.changeNameFrame.currentNameFlow.currentName.caption
		local textBoxData = player.gui.center.changeNameFrame.newNameField.text
		
		GUI.Rename.draw(player, currentName)
		
		--Replace the text in the text box
		player.gui.center.changeNameFrame.newNameField.text = textBoxData
	end
end

--Returns true or false if the Rename GUI is open
GUI.Rename.verify = function(player)
	if (player.gui.center.changeNameFrame ~= nil and player.gui.center.changeNameFrame.valid) then
		return true
	end
	return false
end

--Destroy Rename GUI
GUI.Rename.destroy = function(player)
	if GUI.Rename.verify(player) then
		player.gui.center.changeNameFrame.destroy()
	end 
end



--~~~~~~~  Disconnect GUI ~~~~~~~--
GUI.Disconnect = {}

--Disconnect GUI - Disconnect from the controlled avatar
--Draw Disconnect GUI
GUI.Disconnect.draw = function(player)
	if not GUI.Disconnect.verify(player) then
		mod_gui.get_button_flow(player).add{
			type="button",
			name="avatar_disc",
			tooltip={"Avatars-button-disconnect-tooltip", Storage.PlayerData.getOrCreate(player).currentAvatarData.name},
			caption={"Avatars-button-disconnect"}
		}
	end
end

--Destroy Disconnect GUI
GUI.Disconnect.destroy = function(player)
	if GUI.Disconnect.verify(player) then
		mod_gui.get_button_flow(player)["avatar_disc"].destroy()
	end 
end

--Verify Disconnect GUI
GUI.Disconnect.verify = function(player)
	if mod_gui.get_button_flow(player)["avatar_disc"] and mod_gui.get_button_flow(player)["avatar_disc"].valid then
		return true
	end
	return false
end



--~~~~~~~  Avatar Remote Deployment Unit (ARDU) GUI ~~~~~~~--
GUI.ARDU = {}

--Avatar Remote Deployment Unit GUI
--Draw ARDU GUI
GUI.ARDU.draw = function(player, ARDU)
	--Destroy old ARDU GUI
	GUI.ARDU.destroy(player)
	
	--Get the ARDU from the table
	local ARDUData = Storage.ARDU.getByEntity(ARDU)
	
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
GUI.ARDU.destroy = function(player)
	if (player.gui.center.avatarARDUFrame ~= nil and player.gui.center.avatarARDUFrame.valid) then
		player.gui.center.avatarARDUFrame.destroy()
	end 
end


GUI.Trigger = {}

--GUI Triggers

--Submiting the avatar name
GUI.Trigger.changeAvatarNameSubmit = function(player)
	local changeNameFrame = player.gui.center.changeNameFrame
	
	--Make sure the text field is valid
	if GUI.Rename.verify(player) then
	
		--Obtain the old name
		local oldName = changeNameFrame.currentNameFlow.currentName.caption
	
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
				debugLog("Renaming Avatar")
				renamedAvatar.name = newName
				GUI.Rename.updateOnSubmit(player, oldName, newName)
			else
				--Name in use
				player.print{"Avatars-error-name-in-use"}
				GUI.Rename.updateOnSubmit(player, oldName, nil)
				player.gui.center.changeNameFrame.newNameField.text = newName
			end
		else
			--Blank text field
			player.print{"Avatars-error-blank-name"}
			GUI.Rename.updateOnSubmit(player, oldName, nil)
		end
	end
end

--Submitting the ARDU rename
GUI.Trigger.changeARDUName = function(player)
	local ARDUGUI = player.gui.center.avatarARDUFrame
	
	if (ARDUGUI ~= nil and ARDUGUI.valid) then
		--Obtain the old name
		local oldName = ARDUGUI.currentNameFlow.currentName.caption
	
		--Make sure a name was entered
		if (ARDUGUI.newNameField.text ~= "") then
			--Obtain the new name
			local newName = ARDUGUI.newNameField.text
			local flag = false
			local renamedARDU = nil
			for _, currentARDU in ipairs(global.avatarARDUTable) do
				--If the new name matches any ARDUs, then break the loop and throw an error
				if (currentARDU.name == newName) then
					flag = false
					debugLog("Duplicate name found")
					break
				end
				--Catch the matching name but still check for duplicate names
				if (currentARDU.name == oldName) then
					flag = true
					renamedARDU = currentARDU
					debugLog("Found the old name")
				end
			end
			
			--Final check and set
			if flag then
				renamedARDU.name = newName
				GUI.ARDU.draw(player, renamedARDU.entity)
			else
				--Name in use
				player.print{"Avatars-error-name-in-use"}
			end
		else
			--Blank text field
			player.print{"Avatars-error-blank-name"}
		end
	end
end

return GUI

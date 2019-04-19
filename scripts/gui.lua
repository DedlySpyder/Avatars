require("mod-gui")

-- The returned table by this file will contain all the GUI related functions
-- The main object will have the following for each GUI used by the mod (along with a few helper functions):
--		Selection
--		Rename
--		Disconnect
--		ARDU

GUI = {}

-- Destroys all GUIs
--	@param player - a LuaPlayer object to clear all GUIs for
GUI.destroyAll = function(player)
	GUI.Selection.destroy(player)
	GUI.Rename.destroy(player)
	GUI.Disconnect.destroy(player)
	GUI.ARDU.destroy(player)
end



--~~~~~~~ Main flow ~~~~~~~--
-- This GUI is entirely invisible, but it is for the sorting of the Selection and Rename GUIs
-- This allows them to be freely updated in any order and still maintain their correct ordering

GUI.Main = {}

-- Create the Main flow
--	@param player - a LuaPlayer object
GUI.Main.draw = function(player)
	if not GUI.Main.verify(player) then
		local mainFlow = player.gui.center.add{type="flow", direction="horizontal", name="avatarMainFlow"}
		mainFlow.add{type="flow", direction="vertical", name="avatarSelectionFlow"}
		mainFlow.add{type="flow", direction="vertical", name="avatarRenameFlow"}
	end
end

-- Get or create the Rename flow if it doesn't exist
--	@param player - a LuaPlayer object
GUI.Main.getOrCreateSelectionFlow = function(player)
	GUI.Main.draw(player)
	return GUI.Main.getSelectionFlow(player)
end

-- Get the Selection flow (create it if it doesn't exist)
--	@param player - a LuaPlayer object
GUI.Main.getSelectionFlow = function(player)
	if GUI.Main.verify(player) then
		return player.gui.center.avatarMainFlow.avatarSelectionFlow
	end
end

-- Get or create the Rename flow if it doesn't exist
--	@param player - a LuaPlayer object
GUI.Main.getOrCreateRenameFlow = function(player)
	GUI.Main.draw(player)
	return GUI.Main.getRenameFlow(player)
end

-- Get the Rename flow (create it if it doesn't exist)
--	@param player - a LuaPlayer object
GUI.Main.getRenameFlow = function(player)
	if GUI.Main.verify(player) then
		return player.gui.center.avatarMainFlow.avatarRenameFlow
	end
end

-- Update all children of the Main flow
--	@param player - a LuaPlayer object
GUI.Main.update = function(player)
	GUI.Selection.update(player)
	GUI.Rename.update(player)
end

-- Destroy the Main flow (and all children)
--	@param player - a LuaPlayer object
GUI.Main.destroy = function(player)
	if GUI.Main.verify(player) then
		player.gui.center.avatarMainFlow.destroy()
	end
end

-- Shows whether the Main flow has been created or not
--	@param player - a LuaPlayer object
--	@return - true if the Main flow is open and valid, false otherwise
GUI.Main.verify = function(player)
	return player.gui.center.avatarMainFlow and player.gui.center.avatarMainFlow.valid
end


--~~~~~~~ Selection GUI ~~~~~~~--
-- This GUI is the main table that displays all avatars controllable by the player & ARDUs that do not have a spawned avatar
-- The player can rename or control any avatar
-- They can also spawn a new avatar from an ARDU

GUI.Selection = {}

-- Draw the Selection GUI
--	@param player - a LuaPlayer object
--	@param sortValues - the sort values for the table (optional, if it's nil then the default will be used)	
GUI.Selection.draw = function(player, sortValues)
	if not GUI.Selection.verify(player) then
		debugLog("Drawing Selection GUI")
		
		-- Determine the sort values and get a sorted table
		if not sortValues then sortValues = GUI.Selection.getSortValues(player) end
		local sortedTable = Sort.getSortedTable(sortValues, player)
		
		--Create the frame to hold everything
		local avatarSelectionFrame = GUI.Main.getOrCreateSelectionFlow(player).add{type="frame", name="avatarSelectionFrame", direction="vertical", caption={"Avatars-table-header", Util.entityPositionString(player.vehicle)}}
		
		-- Total avatar count
		local totalEntries = 0
		
		-- Fill in the GUI if there is data
		if sortedTable and #sortedTable > 0 then
			-- Flow to align the header frames
			local headerFlow = avatarSelectionFrame.add{type="flow", name="headerFlow", direction="horizontal"}
			
			-- Column header frames
			local nameHeader = headerFlow.add{type="frame", name="nameHeader", direction="vertical", style="avatar_table_name_header_frame"}
			local locationHeader = headerFlow.add{type="frame", name="locationHeader", direction="vertical", style="avatar_table_location_header_frame"}
			local renameHeader = headerFlow.add{type="frame", name="renameHeader", direction="vertical", style="avatar_table_rename_header_frame"}
			local controlHeader = headerFlow.add{type="frame", name="controlHeader", direction="vertical", style="avatar_table_control_header_frame"}
			
			-- Header labels
			nameHeader.add{type="label", caption={"Avatars-table-avatar-name-header"}, style="avatar_table_header_avatar_name"}
			locationHeader.add{type="label", caption={"Avatars-table-avatar-location-header"}, style="avatar_table_general"}
			renameHeader.add{type="label", caption={"Avatars-table-rename-avatar-header"}, style="avatar_table_general"}
			controlHeader.add{type="label", caption={"Avatars-table-control-avatar-header"}, style="avatar_table_general"}
			
			-- Create the "Asending" sort row
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
			
			-- Create the "Descending" sort row
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
			
			-- Frame and scroll pane creation
			local tableFrame = avatarSelectionFrame.add{type="frame", name="tableFrame", direction="vertical"}
			local selectionScrollPane = tableFrame.add{type="scroll-pane", name="selectionScrollPane", direction="vertical", style="avatar_table_scroll_pane"}
			
			local playerData = Storage.PlayerData.getOrCreate(player)
			local tick = game.tick
			
			-- Iterate through the avatars (and ARDUs)
			for _, tableEntry in ipairs(sortedTable) do
				local entity = tableEntry.entity
				if entity and entity.valid then
					-- Add it to the count
					totalEntries = totalEntries + 1
					
					-- Create the row frame
					local row = selectionScrollPane.add{type="frame", direction="horizontal", style="avatar_table_row_frame"}
					
					local entryNameLabelCaption = tableEntry.name
					local renameButtonEnabled = true
					local renameButtonTooltip = {"Avatars-table-rename-button-tooltip", tableEntry.name}
					local controlButtonEnabled = true
					local controlButtonTooltip = {"Avatars-table-control-button-tooltip", tableEntry.name}
					local controlButtonName = nil
					
					local controlError = nil
					
					-- Check if the entry is an ARDU
					if tableEntry.currentIteration then
						-- Data is an ARDU
						entryNameLabelCaption = {"Avatars-table-ardu-caption-suffix", entryNameLabelCaption}
						
						renameButtonEnabled = false
						renameButtonTooltip = {"Avatars-warning-cannot-rename-ARDU-here"}
						
						controlButtonEnabled, controlError = Deployment.canDeploy(tableEntry)
						
						controlButtonName = "avatar_ctrl_ardu_" .. tableEntry.name
					else
						controlButtonEnabled, controlError = AvatarControl.canGainControl(tableEntry, playerData, tick)
						controlButtonName = "avatar_ctrl_" .. tableEntry.name
					end
					
					if controlError then controlButtonTooltip = controlError end
					
					-- Fill in the row
					row.add{type = "label", name = tableEntry.name, caption = entryNameLabelCaption, style = "avatar_table_label_avatar_name"}
					row.add{type = "label", caption = Util.getDistance(player.vehicle.position, entity.position), style = "avatar_table_label_avatar_location"}
					row.add{	type = "button",
								name = "avatar_rnam_" .. tableEntry.name,
								enabled = renameButtonEnabled,
								caption = {"Avatars-table-rename-button"},
								tooltip = renameButtonTooltip,
								style = "avatar_table_button"
					}
					row.add{type = "label", style = "avatar_table_label_gap"}
					row.add{	type = "button",
								name = controlButtonName,
								enabled = controlButtonEnabled,
								caption = {"Avatars-table-control-button"},
								tooltip = controlButtonTooltip,
								style = "avatar_table_button"
					}
				end
			end
		end
		
		-- Footer 
		-- Exit button
		local refreshFlow = avatarSelectionFrame.add{type="flow", name="avatarSelectionFrameRefreshFlow", direction="horizontal"}
		refreshFlow.add{type="button", name="avatar_rfrh", caption={"Avatars-refresh-button"}}
		refreshFlow.add{type="label", name="avatarRefreshNeeded"}
		
		avatarSelectionFrame.add{type="button", name="avatar_exit", caption={"Avatars-table-exit-button"}}
		
		-- Avatar Total
		avatarSelectionFrame.add{type="label", caption={"Avatars-table-total-avatars", totalEntries}, style="avatar_table_total_avatars"}
	end
end

-- Get the sort values from this player's Selection GUI
--	@param player - a LuaPlayer object
--	@return - a table of each sort name -> it's current state
GUI.Selection.getSortValues = function(player)
	debugLog("Obtaining sort values")
	if GUI.Selection.verify(player) then
		-- Get the sort from the current selection GUI
		local selectionFrame = GUI.Main.getSelectionFlow(player).avatarSelectionFrame
		return	{	name_ascending = selectionFrame.upperSortFlow.avatar_sort_name_ascending.state,
					name_descending = selectionFrame.lowerSortFlow.avatar_sort_name_descending.state,
					location_ascending = selectionFrame.upperSortFlow.avatar_sort_location_ascending.state,
					location_descending = selectionFrame.lowerSortFlow.avatar_sort_location_descending.state,
				}
	else
		-- Default sort values
		return	{	name_ascending = true,
					name_descending = false,
					location_ascending = false,
					location_descending = false
				}
	end
end

-- Update Selection GUI for the given player
--	@param player - a LuaPlayer object
GUI.Selection.update = function(player)
	if GUI.Selection.verify(player) then
		local sortValues = GUI.Selection.getSortValues(player)
		GUI.Selection.destroy(player)
		GUI.Selection.draw(player, sortValues)
	end
end

-- Show that something changed with the Selection GUI, and that a refresh may be needed
-- This will show for all players in the given force
--	@param force - a LuaForce object (or nil if show the warning for everyone)
GUI.Selection.refreshNeeded = function(force)
	local players = game.players
	if force then players = force.players end

	for _, player in pairs(players) do
		if GUI.Selection.verify(player) then
			GUI.Main.getSelectionFlow(player).avatarSelectionFrame.avatarSelectionFrameRefreshFlow.avatarRefreshNeeded.caption = {"Avatars-warning-stale-data"}
		end
	end
end

-- Shows whether the Selection GUI is open or not
--	@param player - a LuaPlayer object
--	@return - true if the Selection GUI is open and valid, false otherwise
GUI.Selection.verify = function(player)
	local selectionFlow = GUI.Main.getSelectionFlow(player)
	return selectionFlow and selectionFlow.valid and selectionFlow.avatarSelectionFrame and selectionFlow.avatarSelectionFrame.valid
end

-- Destroy the Selection GUI
--	@param player - a LuaPlayer object
GUI.Selection.destroy = function(player)
	if GUI.Selection.verify(player) then
		GUI.Main.getSelectionFlow(player).avatarSelectionFrame.destroy()
	end
end

-- Handle radio button selection (set all states to false except the clicked one)
--	@param player - a LuaPlayer object
--	@param modButton - a string of the button that was clicked (trimming down to just the "[column]_[sort-type]")
GUI.Selection.flipRadioButtons = function(player, modButton)
	if GUI.Selection.verify(player) then
		local selectionFrame = GUI.Main.getSelectionFlow(player).avatarSelectionFrame
		
		if modButton ~= "name_ascending" then
			selectionFrame.upperSortFlow.avatar_sort_name_ascending.state = false
		end
		
		if modButton ~= "name_descending" then
			selectionFrame.lowerSortFlow.avatar_sort_name_descending.state = false
		end
		
		if modButton ~= "location_ascending" then
			selectionFrame.upperSortFlow.avatar_sort_location_ascending.state = false
		end
		
		if modButton ~= "location_descending" then
			selectionFrame.lowerSortFlow.avatar_sort_location_descending.state = false
		end
	end
end



--~~~~~~~ Rename GUI ~~~~~~~--
-- This GUI is used to rename avatars
GUI.Rename = {}

-- Draw the Rename GUI
--	@param player - a LuaPlayer object
--	@param name - the avatar's current name
GUI.Rename.draw = function(player, name)
	if not GUI.Rename.verify(player) then
		debugLog("Changing name of " .. name)
		
		-- Rename Frame and labels
		local avatarChangeNameFrame = GUI.Main.getOrCreateRenameFlow(player).add{type="frame", name="avatarChangeNameFrame", direction="vertical", caption={"Avatars-change-name-change-name"}}
		local currentNameFlow = avatarChangeNameFrame.add{type="flow", name="currentNameFlow", direction="horizontal"}
		currentNameFlow.add{type="label", name="currentNameLabel", caption={"Avatars-change-name-current-name"}}
		currentNameFlow.add{type="label", name="currentName", caption=name}
		
		avatarChangeNameFrame.add{type="textfield", name="newNameField"}.focus()
		
		-- Buttons
		local buttonsFlow = avatarChangeNameFrame.add{type="flow", name="buttonsFlow"}
		buttonsFlow.add{type="button", name="avatar_sbmt", caption={"Avatars-submit-button"}}
		buttonsFlow.add{type="button", name="avatar_cncl", caption={"Avatars-cancel-button"}}
		
		-- Warnings
		avatarChangeNameFrame.add{type="label", name="avatarRenameRefreshNeeded"}
		avatarChangeNameFrame.add{type="label", name="avatarRenameError"}
	end
end

-- Update the Rename GUI
--	@param player - a LuaPlayer object
GUI.Rename.update = function(player)
	if GUI.Rename.verify(player) then
		-- Preserve the name and the text in the text box
		local renameFlow = GUI.Main.getRenameFlow(player)
		local oldChangeNameFrame = renameFlow.avatarChangeNameFrame
		local currentName = oldChangeNameFrame.currentNameFlow.currentName.caption
		local textBoxData = oldChangeNameFrame.newNameField.text
		
		GUI.Rename.destroy(player)
		
		-- Only redraw the GUI if the name is still valid
		if Storage.Avatars.getByName(currentName) then
			GUI.Rename.draw(player, currentName)
			
			-- Replace the text in the text box
			renameFlow.avatarChangeNameFrame.newNameField.text = textBoxData
		else
			player.print{"Avatars-error-rename-avatar-doesnt-exist"}
		end
	end
end

-- Show that something changed with the Rename GUI, and that a refresh may be needed
-- This will show for all players (since, currently, the names pool is shared by forces)
GUI.Rename.refreshNeeded = function()
	for _, player in pairs(game.players) do
		if GUI.Rename.verify(player) then
			GUI.Main.getRenameFlow(player).avatarChangeNameFrame.avatarRenameRefreshNeeded.caption = {"Avatars-warning-stale-data"}
		end
	end
end

-- Display an error on the Rename GUI
--	@param player - a LuaPlayer object
--	@param err - the error message
GUI.Rename.error = function(player, err)
	if GUI.Rename.verify(player) then
		GUI.Main.getRenameFlow(player).avatarChangeNameFrame.avatarRenameError.caption = err
	end
end

-- Shows whether the Rename GUI is open or not
--	@param player - a LuaPlayer object
--	@return - true if the Rename GUI is open and valid, false otherwise
GUI.Rename.verify = function(player)
	local renameFlow = GUI.Main.getRenameFlow(player)
	return renameFlow and renameFlow.valid and renameFlow.avatarChangeNameFrame and renameFlow.avatarChangeNameFrame.valid
end

-- Destroy the Rename GUI
--	@param player - a LuaPlayer object
GUI.Rename.destroy = function(player)
	if GUI.Rename.verify(player) then
		GUI.Main.getRenameFlow(player).avatarChangeNameFrame.destroy()
	end 
end



--~~~~~~~ Disconnect GUI ~~~~~~~--
-- Disconnect button for stopping control of an avatar
GUI.Disconnect = {}

-- Draw Disconnect the GUI
--	@param player - a LuaPlayer object
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

-- Destroy the Disconnect GUI
--	@param player - a LuaPlayer object
GUI.Disconnect.destroy = function(player)
	if GUI.Disconnect.verify(player) then
		mod_gui.get_button_flow(player)["avatar_disc"].destroy()
	end 
end

-- Shows whether the Disconnect GUI is open or not
--	@param player - a LuaPlayer object
--	@return - true if the Rename GUI is open and valid, false otherwise
GUI.Disconnect.verify = function(player)
	return mod_gui.get_button_flow(player)["avatar_disc"] and mod_gui.get_button_flow(player)["avatar_disc"].valid
end



--~~~~~~~ Avatar Remote Deployment Unit (ARDU) GUI ~~~~~~~--
-- The GUI to rename an ARDU
GUI.ARDU = {}

-- Draw the ARDU GUI
-- This is binary GUI, nothing special is needed, either the player sees it when in the ARDU or not
--	@param player - a LuaPlayer object
--	@param ardu - a LuaEntity object of the ARDU
GUI.ARDU.draw = function(player, ardu)
	-- Destroy old ARDU GUI
	GUI.ARDU.destroy(player)
	
	-- Get the ARDU from the table
	local arduData = Storage.ARDU.getByEntity(ardu)
	
	if arduData then
		-- Rename Frame and labels
		local arduGui = player.gui.center.add{type="frame", name="avatarARDUFrame", direction="vertical", caption={"Avatars-ARDU-rename-header"}}
		local currentNameFlow = arduGui.add{type="flow", name="currentNameFlow", direction="horizontal"}
		currentNameFlow.add{type="label", name="currentNameLabel", caption={"Avatars-ARDU-rename-current-name"}}
		currentNameFlow.add{type="label", name="currentName", caption=arduData.name, style="avatar_ARDU_current_name"}
		
		arduGui.add{type="textfield", name="newNameField"}.focus()
		
		-- Buttons
		local buttonsFlow = arduGui.add{type="flow", name="buttonsFlow"}
		buttonsFlow.add{type="button", name="avatar_ARDU", caption={"Avatars-submit-button"}}
		buttonsFlow.add{type="button", name="avatar_exit", caption={"Avatars-table-exit-button"}}
	else
		player.print{"Avatars-error-ARDU-not-found"}
	end
end

-- Destroy the ARDU GUI
--	@param player - a LuaPlayer object
GUI.ARDU.destroy = function(player)
	if GUI.ARDU.verify(player) then
		player.gui.center.avatarARDUFrame.destroy()
	end 
end

-- Shows whether the ARDU GUI is open or not
--	@param player - a LuaPlayer object
--	@return - true if the ARDU GUI is open and valid, false otherwise
GUI.ARDU.verify = function(player)
	return player.gui.center.avatarARDUFrame and player.gui.center.avatarARDUFrame.valid
end



--~~~~~~~ GUI Refreshes ~~~~~~~--
-- Functions to aggregate the refresh warnings by action that caused it
GUI.Refresh = {}

GUI.Refresh.nameChange = function()
	GUI.Selection.refreshNeeded()
	GUI.Rename.refreshNeeded()
end

GUI.Refresh.avatarControlChanged = function(force)
	GUI.Selection.refreshNeeded(force)
end



--~~~~~~~ GUI Triggers ~~~~~~~--
GUI.Trigger = {}

-- Trigger for attempting to change an avatar name
--	@param player - a LuaPlayer object
GUI.Trigger.changeAvatarNameSubmit = function(player)
	-- Make sure the text field is valid
	if GUI.Rename.verify(player) then
		local renameFlow = GUI.Main.getRenameFlow(player)
		local avatarChangeNameFrame = renameFlow.avatarChangeNameFrame
	
		-- Obtain the old name
		local oldName = avatarChangeNameFrame.currentNameFlow.currentName.caption
	
		-- Make sure a new name was entered
		local newName = avatarChangeNameFrame.newNameField.text
		if newName ~= "" then
			local renamedAvatar = nil
			
			for _, avatar in ipairs(global.avatars) do
				-- If the new name matches any avatars, then break the loop and throw an error
				if avatar.name == newName then
					debugLog("Duplicate name found")
					player.print{"Avatars-error-name-in-use"}
					GUI.Rename.error(player, {"Avatars-error-name-in-use"})
					avatarChangeNameFrame.newNameField.focus()
					return
				end
				
				-- Catch the matching name but still check for duplicate names
				if avatar.name == oldName then
					renamedAvatar = avatar
					debugLog("Found the old name")
				end
			end
			
			-- Final check and set
			if renamedAvatar then
				debugLog("Renaming Avatar")
				renamedAvatar.name = newName
				
				GUI.Refresh.nameChange()
				
				GUI.Rename.destroy(player)
				GUI.Selection.update(player)
			else
				player.print{"Avatars-error-avatar-not-found"}
				GUI.Rename.error(player, {"Avatars-error-avatar-not-found"})
			end
		else
			-- Blank text field
			player.print{"Avatars-error-blank-name"}
			GUI.Rename.error(player, {"Avatars-error-blank-name"})
		end
	end
end

-- Trigger for attempting to change an ARDU name
--	@param player - a LuaPlayer object
GUI.Trigger.changeARDUName = function(player)
	if GUI.ARDU.verify(player) then
		local arduGui = player.gui.center.avatarARDUFrame
		
		-- Obtain the old name
		local oldName = arduGui.currentNameFlow.currentName.caption
	
		-- Make sure a name was entered
		local newName = arduGui.newNameField.text
		if newName ~= "" then
			local renamedARDU = nil
			
			for _, currentARDU in ipairs(global.avatarARDUTable) do
				-- If the new name matches any ARDUs, then break the loop and throw an error
				if (currentARDU.name == newName) then
					debugLog("Duplicate name found")
					player.print{"Avatars-error-name-in-use"}
					arduGui.newNameField.focus()
					return
				end
				
				-- Catch the matching name but still check for duplicate names
				if (currentARDU.name == oldName) then
					debugLog("Found the old name")
					renamedARDU = currentARDU
				end
			end
			
			-- Final check and set
			if renamedARDU then
				renamedARDU.name = newName
				GUI.Refresh.nameChange()
				GUI.ARDU.draw(player, renamedARDU.entity)
			else
				player.print{"Avatars-error-ARDU-not-found"}
			end
		else
			-- Blank text field
			player.print{"Avatars-error-blank-name"}
		end
	end
end

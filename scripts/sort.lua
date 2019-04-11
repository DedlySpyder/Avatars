local Sort = {}

Sort.getCurrentState = function(player)
	debugLog("Obtaining old sort values")
	local selectionFrame = player.gui.center.avatarSelectionFrame
	
	return {	name_ascending = selectionFrame.upperSortFlow.avatar_sort_name_ascending.state,
				name_descending = selectionFrame.lowerSortFlow.avatar_sort_name_descending.state,
				location_ascending = selectionFrame.upperSortFlow.avatar_sort_location_ascending.state,
				location_descending = selectionFrame.lowerSortFlow.avatar_sort_location_descending.state,
		   }
end

Sort.getSortedTable = function(sortValues, player)
	local position = player.position
	
	--Check the sort string
	if (global.avatars) then --TODO - yes this fucking exists now
		if (sortValues.name_ascending) then
			--Comapre the name strings
			local newFunction = function(a,b) return a.name < b.name end
			return Sort.getNewSortedTable(Sort.getFilteredTable(player), newFunction)
			
		elseif (sortValues.name_descending) then
			--Comapre the name strings
			local newFunction = function(a,b) return a.name > b.name end
			return Sort.getNewSortedTable(Sort.getFilteredTable(player), newFunction)
			
		elseif (sortValues.location_ascending) then
			--Compare the distances
			local newFunction = function(a,b) 
									local aDistance = Sort.getDistance(position, a.entity.position)
									local bDistance = Sort.getDistance(position, b.entity.position)
									return aDistance < bDistance
								end
			return Sort.getNewSortedTable(Sort.getFilteredTable(player), newFunction)
			
		elseif (sortValues.location_descending) then
			--Compare the distances
			local newFunction = function(a,b) 
									local aDistance = Sort.getDistance(position, a.entity.position)
									local bDistance = Sort.getDistance(position, b.entity.position)
									return aDistance > bDistance
								end
			return Sort.getNewSortedTable(Sort.getFilteredTable(player), newFunction)
			
		else
			return global.avatars
		end
	else
		return {}
	end
end

--Takes a table (list) and sorts it based on the function provided
Sort.getNewSortedTable = function(list, func)
	local changesMade
	local itemCount = #list
	
	--Repeat until there are no changes made
	repeat
		changesMade = false
		--The first item will never need comapred to nothing
		for i=2, itemCount do
			if func(list[i], list[i-1]) then
				--Swap the data
				local temp = list[i-1]
				list[i-1] = list[i]
				list[i] = temp
				
				--Set the flag
				changesMade = true
			end
		end
		itemCount = itemCount - 1
	until changesMade == false
	
	return list
end

--Find the distance of an avatar from the player
Sort.getDistance = function(startPosition, endPosition)
	local xDistance = startPosition.x - endPosition.x
	local yDistance = startPosition.y - endPosition.y
	
	--Find the total distance of the line
	local distance = math.sqrt((xDistance^2) + (yDistance^2))
	
	--Round the distance (found from http://lua-users.org/wiki/SimpleRound)
	local mult = 10^(1) --The power is the number of decimal places to round to
	return math.floor(distance * mult + 0.5) / mult
end

--Copies a table by value
--TODO - more general than sort though?
Sort.getFilteredTable = function(player)
	local force = player.force
	local filteredTable = {}
	
	-- Add all avatars for this player's force
	for _, data in ipairs(global.avatars) do
		if data.entity.force == force then
			table.insert(filteredTable, data)
		end
	end
	
	-- Add ARDU's that do not have spawned avatars for this player's force
	-- These are safe for all sort functions, because they have name and entity, just like avatars
	for _, data in ipairs(global.avatarARDUTable) do
		if not data.deployedAvatarData and data.entity.force == force then
			table.insert(filteredTable, data)
		end
	end
	
	return filteredTable
end

return Sort

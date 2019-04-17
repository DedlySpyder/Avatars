Sort = {}

-- Using the given sort values, create a sorted list of avatars/ARDUs
--	@param sortValues - a table of the sorting names, each to a boolean
--	@player player - a LuaPlayer object
--	@return - a sorted version of avatars to display
Sort.getSortedTable = function(sortValues, player)
	local position = player.position
	
	local sortFunction = nil
	
	-- Check the sort string
	if (sortValues.name_ascending) then
		-- Compare the name strings
		sortFunction = function(a,b) return a.name < b.name end
		
	elseif (sortValues.name_descending) then
		-- Compare the name strings
		sortFunction = function(a,b) return a.name > b.name end
		
	elseif (sortValues.location_ascending) then
		-- Compare the distances
		sortFunction = function(a,b) 
			local aDistance = Sort.getDistance(position, a.entity.position)
			local bDistance = Sort.getDistance(position, b.entity.position)
			return aDistance < bDistance
		end
		
	elseif (sortValues.location_descending) then
		-- Compare the distances
		sortFunction = function(a,b) 
			local aDistance = Sort.getDistance(position, a.entity.position)
			local bDistance = Sort.getDistance(position, b.entity.position)
			return aDistance > bDistance
		end
		
	else
		return Sort.getFilteredTable(player)
	end
	
	return Sort.getNewSortedTable(Sort.getFilteredTable(player), sortFunction)
end

-- Takes a table (list) and sorts it based on the function provided
--	@param list - an indexed table
--	@param func - a function to test if a sort needs to happen
--	@return - a sorted list
Sort.getNewSortedTable = function(list, func)
	local changesMade
	local itemCount = #list
	
	-- Repeat until there are no changes made
	repeat
		changesMade = false
		-- The first item will never need compared to nothing
		for i=2, itemCount do
			if func(list[i], list[i-1]) then
				-- Swap the data
				local temp = list[i-1]
				list[i-1] = list[i]
				list[i] = temp
				
				-- Set the flag
				changesMade = true
			end
		end
		itemCount = itemCount - 1
	until changesMade == false
	
	return list
end

-- Find the distance of an avatar from the player
--	@param startPosition - a position object of one entity
--	@param endPosition - a position object of another entity
--	@return - the distance between the two entities
Sort.getDistance = function(startPosition, endPosition)
	local xDistance = startPosition.x - endPosition.x
	local yDistance = startPosition.y - endPosition.y
	
	-- Find the total distance of the line
	local distance = math.sqrt((xDistance^2) + (yDistance^2))
	
	-- Round the distance (found from http://lua-users.org/wiki/SimpleRound)
	local mult = 10^(1) -- The power is the number of decimal places to round to
	return math.floor(distance * mult + 0.5) / mult
end

-- Get a filtered table for display in the Selection GUI
-- This table will contain both avatars and ARDUs that do not have a spawned avatar
-- This table will only be of entities that share a force with the given player
--	@param player - a LuaPlayer object
--	@return - a filtered table of avatar & ardu global table data
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

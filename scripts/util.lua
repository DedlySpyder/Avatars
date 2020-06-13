-- General functions that don't fit anywhere else
Util = {}

-- Left pad the given number with 0s
--	@param num - a number to format
--	@return - the number with left-padded zeros
Util.formatNumberForName = function(num)
	return string.format("%03d", num)
end

-- Find the distance of an avatar from the player
--	@param startPosition - a position object of one entity
--	@param endPosition - a position object of another entity
--	@return - the distance between the two entities
Util.getDistance = function(startPosition, endPosition)
	local xDistance = startPosition.x - endPosition.x
	local yDistance = startPosition.y - endPosition.y
	
	-- Find the total distance of the line
	local distance = math.sqrt((xDistance^2) + (yDistance^2))
	
	-- Round the distance (found from http://lua-users.org/wiki/SimpleRound)
	local mult = 10^(1) -- The power is the number of decimal places to round to
	return math.floor(distance * mult + 0.5) / mult
end

-- Creates a printable position
--	@param entity - a LuaEntity to get the string position for
--	@return - a string of "(x, y)"
Util.entityPositionString = function(entity)
	return "(" ..math.floor(entity.position.x) ..", " ..math.floor(entity.position.y) ..")"
end

Util.getActiveQuickBars = function(player)
	if player and player.valid then
		local quickBars = {}
		for screenIndex=1,4 do
			quickBars[screenIndex] = player.get_active_quick_bar_page(screenIndex)
		end
		return quickBars
	end
end

Util.setActiveQuickBars = function(player, quickBars)
	if quickBars and type(quickBars) == "table" and player and player.valid then
		for screenIndex, pageIndex in ipairs(quickBars) do
			player.set_active_quick_bar_page(screenIndex, pageIndex)
		end
	end
end


Util.printAll = function(message)
	for _, player in pairs(game.players) do
		if player.valid and player.connected then
			player.print(message)
		end
	end
end
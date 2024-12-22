Migrations = {}

Migrations.handle = function(data)
	if data.mod_changes.Avatars then
		local oldVersion = data.mod_changes.Avatars.old_version
		if oldVersion then
			if Migrations.versionCompare(oldVersion, "0.6.0") then
				log("Actually re-used an old save from 1.1???")
			end
		end
	end
end

-- Returns true if oldVersion is older than newVersion
Migrations.versionCompare = function(oldVersion, newVersion)
	_, _, oldMaj, oldMin, oldPat = string.find(oldVersion, "(%d+)%.(%d+)%.(%d+)")
	_, _, newMaj, newMin, newPat = string.find(newVersion, "(%d+)%.(%d+)%.(%d+)")
	
	local lt = function(o, n) return tonumber(o) < tonumber(n) end
	local gt = function(o, n) return tonumber(o) > tonumber(n) end
	
	if gt(oldMaj, newMaj) then return false
	elseif lt(oldMaj, newMaj) then return true end
	
	if gt(oldMin, newMin) then return false
	elseif lt(oldMin, newMin) then return true end
	
	if lt(oldPat, newPat) then return true end
	return false
end

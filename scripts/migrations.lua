local Migrations = {}

--Migration Scripts

--0.4.0 Migration
--rewrite - migrateTo_0_4_0
Migrations.to_0_4_0 = function()
	--Default avatar names need to have leading zeroes in order to sort correctly
	if global.avatars then
		for i, avatar in ipairs(global.avatars) do
			local nameSubString = string.sub(avatar.name, 1, #default_avatar_name)
			if (default_avatar_name == nameSubString) then
				local avatarNumber = string.format("%03d", tonumber(string.sub(avatar.name, #default_avatar_name+1, #avatar.name)))
				global.avatars[i].name = default_avatar_name..avatarNumber
			end
		end
	end
end

return Migrations

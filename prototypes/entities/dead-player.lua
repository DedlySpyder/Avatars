local deadPlayer = util.table.deepcopy(data.raw["player"]["player"])

deadPlayer.name = "dead-player"
deadPlayer.character_corpse = nil

data:extend ({ deadPlayer })
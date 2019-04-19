local fakePlayer = util.table.deepcopy(data.raw["player"]["player"])

fakePlayer.name = "fake-player"
fakePlayer.character_corpse = nil

data:extend ({ fakePlayer })
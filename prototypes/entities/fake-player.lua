local fakePlayer = util.table.deepcopy(data.raw["character"]["character"])

fakePlayer.name = "fake-player"
fakePlayer.character_corpse = nil

data:extend ({ fakePlayer })

local fakePlayer = util.table.deepcopy(data.raw["character"]["character"])

fakePlayer.name = "fake-player"
fakePlayer.character_corpse = nil
fakePlayer.hidden = true

data:extend ({ fakePlayer })

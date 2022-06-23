Compatibility = {}

Compatibility.run_all = function()
    Compatibility.space_exploration()
end

Compatibility.space_exploration = function()
    if script.active_mods["space-exploration"] then
        script.on_event(remote.call("space-exploration", "get_on_player_respawned_event"), function(event)
            local player = game.get_player(event.player_index)
            local playerData = Storage.PlayerData.getByPlayer(player)
            debugLog(serpent.line(playerData))
            if playerData and playerData.currentAvatarData then
                local oldCharacter = player.character
                AvatarControl.loseAvatarControl(player, 0, true)
                player.print{"Avatars-error-controlled-avatar-death"}
                oldCharacter.destroy()
            end
        end)
    end
end

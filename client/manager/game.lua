Ctz.CreateThread(function()
    local playerId = PlayerId()

    rm.Function.togglePvp(Config.TogglePvp, playerId)
    rm.Function.toggleNpcDrops(Config.ToggleNpcDrops, playerId)
    rm.Function.toggleNpcHealthRegeneration(Config.ToggleNpcHealthRegeneration, playerId)
    rm.Function.toggleDefaultWantedLevel(Config.ToggleDefaultWantedLevel, playerId)
    rm.Function.toggleDispatchService(Config.ToggleDispatchService, playerId)
    rm.Function.toggleScenarios(Config.ToggleScenarios)

    if Config.BigWater == true then
        local success = LoadWaterFromPath('z-framework', 'water.xml')
    end

    AddTextEntry('FE_THDR_GTAO', ("%s%s ~w~ | %s | %s/%s"):format(Config.Color.default, Config.ServerName, GetPlayerName(playerId), #GetActivePlayers(), GetConvar('sv_maxclients', '48')))

    for _, item in ipairs(Config.Esc) do
        AddTextEntry(item.Key, item.Label)
    end

    ReplaceHudColourWithRgba(116, Config.Color.rgba.r, Config.Color.rgba.g, Config.Color.rgba.b, Config.Color.rgba.a)
end)
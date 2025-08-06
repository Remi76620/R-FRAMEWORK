--- Spawn Player
--- @param x number X coordinate
--- @param y number Y coordinate
--- @param z number Z coordinate
--- @param h number Heading
local function spawnPlayer(x, y, z, h, firstConnection)
    repeat
        Ctz.Wait(100)
    until DoesEntityExist(PlayerPedId())

    rm.Function.setPlayerModel(PlayerId(), 'mp_m_freemode_01')
    rm.Function.setEntityCoords(PlayerPedId(), x, y, z, false, false, false)
    rm.Function.setEntityHeading(PlayerPedId(), h)
    rm.Function.loadingHide()

    if DoesEntityExist(PlayerPedId()) then
        SetPedDefaultComponentVariation(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), false)
        rm.Io.Trace('Player spawned successfully at coords: ' .. x .. ', ' .. y .. ', ' .. z)
        TriggerEvent('rm-framework:playerSpawned', x, y, z, h, firstConnection)
        TriggerServerEvent('rm-framework:playerSpawned', x, y, z, h, firstConnection)
    else
        rm.Io.Warn('Player failed to spawn at coords: ' .. x .. ', ' .. y .. ', ' .. z)
    end
end

rm.Event.Register('rm-spawn:spawnPlayer', function(x, y, z, h, firstConnection)
    spawnPlayer(x, y, z, h, firstConnection)

end)

Ctz.CreateThread(function()
    rm.Event.TriggerServer('rm-spawn:loadPlayer')
end)
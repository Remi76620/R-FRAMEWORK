RegisterCommand('addweapon', function(source, args, rawCommand)
    local player = rm.getPlayer(1)
    player.addWeapon('WEAPON_ASSAULTRIFLE', 100)
end)
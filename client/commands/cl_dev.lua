-- ========================================
-- RM-FRAMEWORK DEVELOPER COMMANDS CLIENT
-- ========================================

-- Variables pour les états des commandes
local noclipEnabled = false
local godModeEnabled = false
local invisibleEnabled = false

-- ========================================
-- COMMANDES DE VÉHICULES
-- ========================================

-- Event pour supprimer le véhicule
rm.Event.Register('rm-dev:deleteVehicle', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle ~= 0 then
        -- Si le joueur est dans un véhicule, le supprimer
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
    else
        -- Sinon, supprimer le véhicule le plus proche
        local coords = GetEntityCoords(playerPed)
        local closestVehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
        
        if closestVehicle ~= 0 then
            SetEntityAsMissionEntity(closestVehicle, true, true)
            DeleteVehicle(closestVehicle)
        end
    end
end)

-- Event pour spawn un véhicule
rm.Event.Register('rm-dev:spawnVehicle', function(vehicleModel)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    -- Demander le modèle
    if rm.Function.requestModel(vehicleModel) then
        -- Créer le véhicule
        local vehicle = CreateVehicle(GetHashKey(vehicleModel), coords.x, coords.y, coords.z, heading, true, false)
        
        -- Mettre le joueur dans le véhicule
        SetPedIntoVehicle(playerPed, vehicle, -1)
        
        -- Configurer le véhicule
        SetEntityAsNoLongerNeeded(vehicle)
        SetVehicleOnGroundProperly(vehicle)
        SetVehicleNumberPlateText(vehicle, "RM-DEV")
        
        -- Donner les clés (si système de clés implémenté)
        SetVehicleEngineOn(vehicle, true, true, false)
    end
end)

-- ========================================
-- COMMANDES DE TÉLÉPORTATION
-- ========================================

-- Event pour téléporter vers un joueur
rm.Event.Register('rm-dev:teleportToPlayer', function(targetId)
    local targetPed = GetPlayerPed(targetId)
    if targetPed ~= 0 then
        local coords = GetEntityCoords(targetPed)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    end
end)

-- Event pour téléporter vers des coordonnées
rm.Event.Register('rm-dev:teleportToCoords', function(x, y, z)
    SetEntityCoords(PlayerPedId(), x, y, z, false, false, false, true)
end)

-- Event pour téléporter vers le marqueur
rm.Event.Register('rm-dev:teleportToMarker', function()
    local waypoint = GetFirstBlipInfoId(8) -- Waypoint blip
    
    if not DoesBlipExist(waypoint) then
        return
    end
    
    local coords = GetBlipInfoIdCoord(waypoint)
    local success, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
    
    if success then
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, groundZ, false, false, false, true)
    else
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    end
end)

-- ========================================
-- COMMANDES D'ÉTAT DU JOUEUR
-- ========================================

-- Event pour basculer le noclip
rm.Event.Register('rm-dev:toggleNoclip', function()
    noclipEnabled = not noclipEnabled
    local playerPed = PlayerPedId()
    
    if noclipEnabled then
        -- Activer le noclip
        SetEntityInvincible(playerPed, true)
        SetEntityVisible(playerPed, false, false)
        SetEntityCollision(playerPed, false, false)
        FreezeEntityPosition(playerPed, true)
        SetPlayerInvincible(PlayerId(), true)
    else
        -- Désactiver le noclip
        SetEntityInvincible(playerPed, false)
        SetEntityVisible(playerPed, true, false)
        SetEntityCollision(playerPed, true, true)
        FreezeEntityPosition(playerPed, false)
        SetPlayerInvincible(PlayerId(), false)
    end
end)

-- Thread pour gérer le noclip
Citizen.CreateThread(function()
    while true do
        if noclipEnabled then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local speed = 2.0
            
            -- Contrôles de base
            if IsControlPressed(0, 21) then speed = 4.0 end -- Shift pour aller plus vite
            if IsControlPressed(0, 19) then speed = 0.5 end -- Alt pour aller plus lentement
            
            -- Mouvement
            if IsControlPressed(0, 32) then -- W
                local heading = GetEntityHeading(playerPed)
                local newCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, speed, 0.0)
                SetEntityCoords(playerPed, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
            end
            
            if IsControlPressed(0, 33) then -- S
                local newCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -speed, 0.0)
                SetEntityCoords(playerPed, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
            end
            
            if IsControlPressed(0, 34) then -- A
                local newCoords = GetOffsetFromEntityInWorldCoords(playerPed, -speed, 0.0, 0.0)
                SetEntityCoords(playerPed, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
            end
            
            if IsControlPressed(0, 35) then -- D
                local newCoords = GetOffsetFromEntityInWorldCoords(playerPed, speed, 0.0, 0.0)
                SetEntityCoords(playerPed, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
            end
            
            if IsControlPressed(0, 44) then -- Q (monter)
                SetEntityCoords(playerPed, coords.x, coords.y, coords.z + speed, false, false, false, true)
            end
            
            if IsControlPressed(0, 46) then -- E (descendre)
                SetEntityCoords(playerPed, coords.x, coords.y, coords.z - speed, false, false, false, true)
            end
        end
        
        Citizen.Wait(0)
    end
end)

-- Event pour basculer le god mode
rm.Event.Register('rm-dev:toggleGodMode', function()
    godModeEnabled = not godModeEnabled
    local playerPed = PlayerPedId()
    
    SetEntityInvincible(playerPed, godModeEnabled)
    SetPlayerInvincible(PlayerId(), godModeEnabled)
    
    if godModeEnabled then
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
        SetPedArmour(playerPed, 100)
    end
end)

-- Event pour basculer l'invisibilité
rm.Event.Register('rm-dev:toggleInvisible', function()
    invisibleEnabled = not invisibleEnabled
    local playerPed = PlayerPedId()
    
    SetEntityVisible(playerPed, not invisibleEnabled, false)
    
    -- Rendre le joueur invisible sur le radar aussi
    if invisibleEnabled then
        SetLocalPlayerVisibleLocally(true)
        SetPlayerInvisibleLocally(PlayerId(), true)
    else
        SetPlayerInvisibleLocally(PlayerId(), false)
    end
end)

-- ========================================
-- COMMANDES DE SANTÉ DU JOUEUR
-- ========================================

-- Event pour réanimer un joueur
rm.Event.Register('rm-dev:revivePlayer', function()
    local playerPed = PlayerPedId()
    
    -- Réanimer le joueur
    local coords = GetEntityCoords(playerPed)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
    
    -- Restaurer la santé et l'armure
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    SetPedArmour(playerPed, 0)
    
    -- Nettoyer les effets
    ClearPedBloodDamage(playerPed)
    ClearPedTasks(playerPed)
    ClearPedSecondaryTask(playerPed)
end)

-- Event pour soigner un joueur
rm.Event.Register('rm-dev:healPlayer', function()
    local playerPed = PlayerPedId()
    
    -- Restaurer la santé complète
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    
    -- Nettoyer les dégâts visuels
    ClearPedBloodDamage(playerPed)
end)

-- Event pour donner de l'armure
rm.Event.Register('rm-dev:giveArmor', function(amount)
    local playerPed = PlayerPedId()
    
    -- Donner l'armure
    SetPedArmour(playerPed, amount or 100)
end)

print("^2[RM-Framework] ^7Developer commands client loaded!")

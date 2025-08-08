-- ========================================
-- RM-FRAMEWORK DEVELOPER COMMANDS
-- ========================================

-- Fonction utilitaire pour vérifier les permissions de développement
local function hasDevPermissions(source)
    local player = rm.getPlayer(source)
    if not player then return false end
    
    local rankId = player.getRankId()
    return rankId == 'fonda' or rankId == 'admin' or rankId == 'dev'
end

-- Fonction utilitaire pour envoyer un message de chat
local function sendChatMessage(source, color, message)
    TriggerClientEvent('chat:addMessage', source, {
        color = color,
        multiline = true,
        args = {"RM-Framework", message}
    })
end

-- ========================================
-- COMMANDES DE VÉHICULES
-- ========================================

-- Commande /dv - Delete Vehicle
RegisterCommand('dv', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    TriggerClientEvent('rm-dev:deleteVehicle', source)
    sendChatMessage(source, {0, 255, 0}, "Véhicule supprimé")
    rm.Io.Trace("Vehicle deleted by " .. GetPlayerName(source))
end, false)

-- Commande /car - Spawn Vehicle  
RegisterCommand('car', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    if #args < 1 then
        sendChatMessage(source, {255, 255, 0}, "Usage: /car <modèle>")
        return
    end
    
    local vehicleModel = args[1]
    TriggerClientEvent('rm-dev:spawnVehicle', source, vehicleModel)
    sendChatMessage(source, {0, 255, 0}, "Véhicule '" .. vehicleModel .. "' spawn")
    rm.Io.Trace("Vehicle " .. vehicleModel .. " spawned by " .. GetPlayerName(source))
end, false)

-- ========================================
-- COMMANDES DE TÉLÉPORTATION
-- ========================================

-- Commande /tp - Teleport to player or coordinates
RegisterCommand('tp', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    if #args == 1 then
        -- Téléportation vers un joueur
        local targetId = tonumber(args[1])
        if not targetId then
            sendChatMessage(source, {255, 0, 0}, "Erreur: ID de joueur invalide")
            return
        end
        
        local targetPed = GetPlayerPed(targetId)
        if targetPed == 0 then
            sendChatMessage(source, {255, 0, 0}, "Erreur: Joueur non trouvé")
            return
        end
        
        TriggerClientEvent('rm-dev:teleportToPlayer', source, targetId)
        sendChatMessage(source, {0, 255, 0}, "Téléporté vers " .. GetPlayerName(targetId))
        rm.Io.Trace(GetPlayerName(source) .. " teleported to " .. GetPlayerName(targetId))
        
    elseif #args == 3 then
        -- Téléportation vers des coordonnées
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if not x or not y or not z then
            sendChatMessage(source, {255, 0, 0}, "Erreur: Coordonnées invalides")
            return
        end
        
        TriggerClientEvent('rm-dev:teleportToCoords', source, x, y, z)
        sendChatMessage(source, {0, 255, 0}, "Téléporté aux coordonnées " .. x .. ", " .. y .. ", " .. z)
        rm.Io.Trace(GetPlayerName(source) .. " teleported to coords " .. x .. ", " .. y .. ", " .. z)
        
    else
        sendChatMessage(source, {255, 255, 0}, "Usage: /tp <joueur_id> OU /tp <x> <y> <z>")
    end
end, false)

-- Commande /tpm - Teleport to Marker
RegisterCommand('tpm', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    TriggerClientEvent('rm-dev:teleportToMarker', source)
    sendChatMessage(source, {0, 255, 0}, "Téléportation vers le marqueur")
    rm.Io.Trace(GetPlayerName(source) .. " teleported to waypoint")
end, false)

-- ========================================
-- COMMANDES D'ÉTAT DU JOUEUR
-- ========================================

-- Commande /noclip - No Clip
RegisterCommand('noclip', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    TriggerClientEvent('rm-dev:toggleNoclip', source)
    sendChatMessage(source, {0, 255, 0}, "NoClip basculé")
    rm.Io.Trace(GetPlayerName(source) .. " toggled noclip")
end, false)

-- Commande /godmode - God Mode
RegisterCommand('godmode', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    TriggerClientEvent('rm-dev:toggleGodMode', source)
    sendChatMessage(source, {0, 255, 0}, "God Mode basculé")
    rm.Io.Trace(GetPlayerName(source) .. " toggled godmode")
end, false)

-- Commande /invisible - Invisible
RegisterCommand('invisible', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    TriggerClientEvent('rm-dev:toggleInvisible', source)
    sendChatMessage(source, {0, 255, 0}, "Invisibilité basculée")
    rm.Io.Trace(GetPlayerName(source) .. " toggled invisibility")
end, false)

-- ========================================
-- COMMANDES DE SANTÉ DU JOUEUR
-- ========================================

-- Commande /revive - Revive Player
RegisterCommand('revive', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    local targetId = source
    if #args >= 1 then
        targetId = tonumber(args[1])
        if not targetId or GetPlayerPed(targetId) == 0 then
            sendChatMessage(source, {255, 0, 0}, "Erreur: Joueur non trouvé")
            return
        end
    end
    
    TriggerClientEvent('rm-dev:revivePlayer', targetId)
    
    if targetId == source then
        sendChatMessage(source, {0, 255, 0}, "Vous avez été réanimé")
    else
        sendChatMessage(source, {0, 255, 0}, "Joueur " .. GetPlayerName(targetId) .. " réanimé")
        sendChatMessage(targetId, {0, 255, 0}, "Vous avez été réanimé par " .. GetPlayerName(source))
    end
    
    rm.Io.Trace(GetPlayerName(source) .. " revived " .. GetPlayerName(targetId))
end, false)

-- Commande /heal - Heal Player
RegisterCommand('heal', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    local targetId = source
    if #args >= 1 then
        targetId = tonumber(args[1])
        if not targetId or GetPlayerPed(targetId) == 0 then
            sendChatMessage(source, {255, 0, 0}, "Erreur: Joueur non trouvé")
            return
        end
    end
    
    TriggerClientEvent('rm-dev:healPlayer', targetId)
    
    if targetId == source then
        sendChatMessage(source, {0, 255, 0}, "Vous avez été soigné")
    else
        sendChatMessage(source, {0, 255, 0}, "Joueur " .. GetPlayerName(targetId) .. " soigné")
        sendChatMessage(targetId, {0, 255, 0}, "Vous avez été soigné par " .. GetPlayerName(source))
    end
    
    rm.Io.Trace(GetPlayerName(source) .. " healed " .. GetPlayerName(targetId))
end, false)

-- Commande /armor - Give Armor
RegisterCommand('armor', function(source, args, rawCommand)
    if source == 0 then return end
    
    if not hasDevPermissions(source) then
        sendChatMessage(source, {255, 0, 0}, "Erreur: Permissions insuffisantes")
        return
    end
    
    local targetId = source
    local armorAmount = 100
    
    if #args >= 1 then
        targetId = tonumber(args[1])
        if not targetId or GetPlayerPed(targetId) == 0 then
            sendChatMessage(source, {255, 0, 0}, "Erreur: Joueur non trouvé")
            return
        end
    end
    
    if #args >= 2 then
        armorAmount = tonumber(args[2])
        if not armorAmount or armorAmount < 0 or armorAmount > 100 then
            sendChatMessage(source, {255, 0, 0}, "Erreur: Quantité d'armure invalide (0-100)")
            return
        end
    end
    
    TriggerClientEvent('rm-dev:giveArmor', targetId, armorAmount)
    
    if targetId == source then
        sendChatMessage(source, {0, 255, 0}, "Armure donnée (" .. armorAmount .. "%)")
    else
        sendChatMessage(source, {0, 255, 0}, "Armure donnée à " .. GetPlayerName(targetId) .. " (" .. armorAmount .. "%)")
        sendChatMessage(targetId, {0, 255, 0}, "Armure reçue de " .. GetPlayerName(source) .. " (" .. armorAmount .. "%)")
    end
    
    rm.Io.Trace(GetPlayerName(source) .. " gave armor (" .. armorAmount .. "%) to " .. GetPlayerName(targetId))
end, false)

print("^2[RM-Framework] ^7Developer commands loaded!")

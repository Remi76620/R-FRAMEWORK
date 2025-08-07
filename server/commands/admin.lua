-- ========================================
-- RM-FRAMEWORK ADMIN COMMANDS
-- ========================================

-- Commande pour changer le rang d'un joueur
RegisterCommand('setrank', function(source, args, rawCommand)
    if source == 0 then return end -- Empêche l'exécution depuis la console serveur
    
    local player = rm.getPlayer(source)
    if not player then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Joueur non trouvé"}
        })
        return
    end
    
    -- Vérifier les permissions - Seuls fonda, admin ou dev peuvent changer les rangs
    local senderRank = rm.getRank(player.getRankId())
    if not senderRank then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Rang non trouvé"}
        })
        return
    end
    
    local senderRankId = player.getRankId()
    if senderRankId ~= 'fonda' and senderRankId ~= 'admin' and senderRankId ~= 'dev' then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Vous pas changer de rangs"}
        })
        return
    end
    
    -- Vérifier les arguments
    if #args < 2 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            multiline = true,
            args = {"RM-Framework", "Usage: /setrank <rmId> <rank_id>"}
        })
        return
    end
    
    local targetRmId = tonumber(args[1])
    local newRankId = args[2]
    
    if not targetRmId then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: rmId invalide"}
        })
        return
    end
    
    -- Vérifier si le rang existe
    local targetRank = rm.getRank(newRankId)
    if not targetRank then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Rang '" .. newRankId .. "' non trouvé"}
        })
        return
    end
    
    -- Vérifier la hiérarchie des rangs
    if senderRank and targetRank then
        if senderRank.getWeight() <= targetRank.getWeight() and senderRankId ~= 'fonda' then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"RM-Framework", "Erreur: Vous ne pouvez pas modifier un rang de poids égal ou supérieur"}
            })
            return
        end
    end
    
    -- Vérifier si le joueur existe en base de données
    MySQL.query('SELECT rmId, rankId FROM rm_players WHERE rmId = ?', {targetRmId}, function(result)
        if not result or #result == 0 then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"RM-Framework", "Erreur: Aucun joueur trouvé avec le rmId " .. targetRmId}
            })
            return
        end
        
        local oldRankId = result[1].rankId
        
        -- Mettre à jour en base de données
        MySQL.update('UPDATE rm_players SET rankId = ? WHERE rmId = ?', {newRankId, targetRmId}, function(affectedRows)
            if affectedRows > 0 then
                -- Mettre à jour le joueur en mémoire s'il est connecté
                local targetPlayer = nil
                for _, connectedPlayer in pairs(rm.Players) do
                    if connectedPlayer.getRmId() == targetRmId then
                        targetPlayer = connectedPlayer
                        connectedPlayer.setRankId(newRankId)
                        break
                    end
                end
                
                -- Messages de confirmation
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 255, 0},
                    multiline = true,
                    args = {"RM-Framework", "Rang du joueur rmId " .. targetRmId .. " changé de '" .. oldRankId .. "' vers '" .. newRankId .. "'"}
                })
                
                -- Notifier le joueur s'il est connecté
                if targetPlayer then
                    TriggerClientEvent('chat:addMessage', targetPlayer.getSource(), {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"RM-Framework", "Votre rang a été changé vers '" .. newRankId .. "' par " .. GetPlayerName(source)}
                    })
                end
                
                rm.Io.Trace("Rank changed for player rmId " .. targetRmId .. " from " .. oldRankId .. " to " .. newRankId .. " by " .. GetPlayerName(source))
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"RM-Framework", "Erreur: Impossible de mettre à jour le rang"}
                })
            end
        end)
    end)
end, false)

-- Commande pour se donner le rang fondateur (pour les tests)
RegisterCommand('setfonda', function(source, args, rawCommand)
    if source == 0 then return end
    
    local player = rm.getPlayer(source)
    if not player then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Joueur non trouvé"}
        })
        return
    end
    
    -- Vérifier si le rang fondateur existe
    local fondaRank = rm.getRank('fonda')
    if not fondaRank then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Rang 'fonda' non trouvé"}
        })
        return
    end
    
    -- Changer le rang
    local oldRankId = player.getRankId()
    player.setRankId('fonda')
    
    -- Sauvegarder en base de données
    MySQL.update('UPDATE `rm_players` SET `rankId` = ? WHERE `rmId` = ?', {'fonda', player.getRmId()})
    
    -- Message de confirmation
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = true,
        args = {"RM-Framework", "Votre rang a été changé vers 'fonda' (Fondateur)"}
    })
    
    rm.Io.Trace("Player " .. GetPlayerName(source) .. " set to fonda rank")
end, false)

-- Commande pour se retirer le rang fondateur (retourner en user)
RegisterCommand('unrank', function(source, args, rawCommand)
    if source == 0 then return end
    
    local player = rm.getPlayer(source)
    if not player then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Joueur non trouvé"}
        })
        return
    end
    
    -- Vérifier si le joueur est fondateur
    if player.getRankId() ~= 'fonda' then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            multiline = true,
            args = {"RM-Framework", "Vous n'êtes pas fondateur, pas besoin de vous unrank"}
        })
        return
    end
    
    -- Changer le rang vers user
    local oldRankId = player.getRankId()
    player.setRankId('user')
    
    -- Sauvegarder en base de données
    MySQL.update('UPDATE `rm_players` SET `rankId` = ? WHERE `rmId` = ?', {'user', player.getRmId()})
    
    -- Message de confirmation
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = true,
        args = {"RM-Framework", "Votre rang a été retiré, vous êtes maintenant 'user'"}
    })
    
    rm.Io.Trace("Player " .. GetPlayerName(source) .. " unranked from fonda to user")
end, false)

-- Commande pour voir son rang
RegisterCommand('myrank', function(source, args, rawCommand)
    if source == 0 then return end
    
    local player = rm.getPlayer(source)
    if not player then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Joueur non trouvé"}
        })
        return
    end
    
    local rankId = player.getRankId()
    local rank = rm.getRank(rankId)
    local rankLabel = rank and rank.getLabel() or "Inconnu"
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 255},
        multiline = true,
        args = {"RM-Framework", "Votre rang: " .. rankLabel .. " (" .. rankId .. ")"}
    })
end, false)

-- Commande pour lister tous les rangs
RegisterCommand('ranks', function(source, args, rawCommand)
    if source == 0 then return end
    
    local player = rm.getPlayer(source)
    if not player then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Joueur non trouvé"}
        })
        return
    end
    
    -- Vérifier les permissions - Seuls fonda, admin ou dev peuvent voir les rangs
    local senderRankId = player.getRankId()
    if senderRankId ~= 'fonda' and senderRankId ~= 'admin' and senderRankId ~= 'dev' then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Seuls les fonda, admin ou dev peuvent voir les rangs"}
        })
        return
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 255},
        multiline = true,
        args = {"RM-Framework", "Rangs disponibles:"}
    })
    
    for rankId, rankData in pairs(rm.Ranks) do
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "- " .. rankData.getLabel() .. " (" .. rankId .. ")"}
        })
    end
end, false)

-- Commande pour voir les permissions d'un rang
RegisterCommand('rankperms', function(source, args, rawCommand)
    if source == 0 then return end
    
    local player = rm.getPlayer(source)
    if not player then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Joueur non trouvé"}
        })
        return
    end
    
    -- Vérifier les permissions - Seuls fonda, admin ou dev peuvent voir les permissions
    local senderRankId = player.getRankId()
    if senderRankId ~= 'fonda' and senderRankId ~= 'admin' and senderRankId ~= 'dev' then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Seuls les fonda, admin ou dev peuvent voir les permissions"}
        })
        return
    end
    
    local targetRankId = args[1] or player.getRankId()
    local targetRank = rm.getRank(targetRankId)
    
    if not targetRank then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Rang '" .. targetRankId .. "' non trouvé"}
        })
        return
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 255},
        multiline = true,
        args = {"RM-Framework", "Permissions du rang " .. targetRank.getLabel() .. ":"}
    })
    
    local permissions = targetRank.getPermissions()
    if #permissions == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "Aucune permission"}
        })
    else
        for _, permission in ipairs(permissions) do
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 255},
                multiline = true,
                args = {"", "- " .. permission}
            })
        end
    end
end, false)

print("^2[RM-Framework] ^7Admin commands loaded!") 
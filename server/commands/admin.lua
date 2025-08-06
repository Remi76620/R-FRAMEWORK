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
    
    -- Vérifier les permissions
    local rank = rm.getRank(player.getRankId())
    if not rank or not rank.hasPermission('admin.accessRankManagerAndManageRank') then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Vous n'avez pas la permission de changer les rangs"}
        })
        return
    end
    
    -- Vérifier les arguments
    if #args < 2 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            multiline = true,
            args = {"RM-Framework", "Usage: /setrank <player_id> <rank_id>"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    local newRankId = args[2]
    
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: ID du joueur invalide"}
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
    
    -- Récupérer le joueur cible
    local targetPlayer = rm.getPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Joueur avec l'ID " .. targetId .. " non trouvé"}
        })
        return
    end
    
    -- Changer le rang
    local oldRankId = targetPlayer.getRankId()
    targetPlayer.setRankId(newRankId)
    
    -- Sauvegarder en base de données
    MySQL.update('UPDATE `rm_players` SET `rankId` = ? WHERE `rmId` = ?', {newRankId, targetPlayer.getRmId()})
    
    -- Messages de confirmation
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = true,
        args = {"RM-Framework", "Rang de " .. GetPlayerName(targetId) .. " changé de '" .. oldRankId .. "' vers '" .. newRankId .. "'"}
    })
    
    TriggerClientEvent('chat:addMessage', targetId, {
        color = {0, 255, 0},
        multiline = true,
        args = {"RM-Framework", "Votre rang a été changé vers '" .. newRankId .. "' par " .. GetPlayerName(source)}
    })
    
    rm.Io.Trace("Rank changed for player " .. GetPlayerName(targetId) .. " from " .. oldRankId .. " to " .. newRankId .. " by " .. GetPlayerName(source))
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
    
    -- Vérifier les permissions
    local rank = rm.getRank(player.getRankId())
    if not rank or not rank.hasPermission('admin.accessRankManagerAndManageRank') then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Vous n'avez pas la permission de voir les rangs"}
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
    
    -- Vérifier les permissions
    local rank = rm.getRank(player.getRankId())
    if not rank or not rank.hasPermission('admin.accessRankManagerAndManageRank') then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"RM-Framework", "Erreur: Vous n'avez pas la permission de voir les permissions"}
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
-- ========================================
-- RM-FRAMEWORK INITIALIZATION MANAGER
-- ========================================

print("^2[RM-Framework] ^7Initialization started...")

-- Fonction pour créer les rangs par défaut
function CreateDefaultRanks()
    MySQL.query('SELECT COUNT(*) as count FROM rm_ranks', {}, function(result)
        if result and result[1] and result[1].count == 0 then
            rm.Io.Trace("Aucun rang trouvé, création des rangs par défaut...")
            
            -- Création du rang Fondateur
            MySQL.insert('INSERT INTO `rm_ranks` (`position`, `id`, `label`, `weight`, `baseColor`) VALUES (?, ?, ?, ?, ?)', 
                {4, 'fonda', 'Fondateur', 90000000, '~r~'}, function(rankId)
                
                if rankId then
                    rm.Io.Trace("Rang Fondateur créé avec ID: " .. rankId)
                    
                    -- Ajout des permissions pour le fondateur
                    local founderPermissions = {
                        'admin.open', 'admin.vehdelete', 'admin.giveitem', 'admin.giveweapon',
                        'admin.kickplayer', 'admin.removeplayeritem', 'admin.removeplayerweapon',
                        'admin.vehspawn', 'admin.teleport', 'admin.ban', 'admin.unban',
                        'admin.banlist', 'admin.noclip', 'admin.report', 'admin.names',
                        'admin.blips', 'admin.tpwaypoint', 'admin.playerinv', 'admin.organisation',
                        'admin.openOrgaGrade', 'admin.moveOrgaPoint', 'admin.deleteOrga',
                        'admin.accessRankManagerAndManageRank', 'admin.createGroup',
                        'admin.deleteRank', 'admin.playerList', 'admin.deleteGrade',
                        'admin.createOrganisation'
                    }
                    
                    for _, permission in ipairs(founderPermissions) do
                        MySQL.insert('INSERT INTO `rm_ranks_permissions` (`rankId`, `permission`) VALUES (?, ?)', 
                            {'fonda', permission}, function(permId)
                            
                            if permId then
                                rm.Io.Trace("Permission " .. permission .. " ajoutée pour fonda")
                            else
                                rm.Io.Error("Failed to add permission " .. permission .. " for fonda")
                            end
                        end)
                    end
                else
                    rm.Io.Error("Failed to create Fondateur rank")
                end
            end)
            
            -- Création du rang Membre
            MySQL.insert('INSERT INTO `rm_ranks` (`position`, `id`, `label`, `weight`, `baseColor`) VALUES (?, ?, ?, ?, ?)', 
                {1, 'member', 'Membre', 0, '~m~'}, function(rankId)
                
                if rankId then
                    rm.Io.Trace("Rang Membre créé avec ID: " .. rankId)
                else
                    rm.Io.Error("Failed to create Membre rank")
                end
            end)
        else
            rm.Io.Trace("Rangs existants trouvés (" .. result[1].count .. " rangs)")
        end
    end)
end

-- Load all data from database on startup
CreateThread(function()
    -- Wait for MySQL to be ready
    Wait(1000)
    
    print("^2[RM-Framework] ^7Loading data from database...")
    
    -- Créer les rangs par défaut si nécessaire
    CreateDefaultRanks()
    Wait(500)
    
    -- Load ranks and permissions
    rm.loadRanks()
    Wait(500)
    rm.loadPermissions()
    Wait(500)
    
    -- Load bank accounts
    rm.loadBankAccounts()
    Wait(500)
    
    -- Load bans
    rm.loadBans()
    Wait(500)
    
    print("^2[RM-Framework] ^7All data loaded successfully!")
end)

-- Event to reload all data
rm.Event.Register('rm:reloadData', function()
    print("^2[RM-Framework] ^7Reloading all data...")
    
    -- Clear existing data
    rm.Ranks = {}
    rm.BankAccounts = {}
    rm.Bans = {}
    
    -- Reload all data
    rm.loadRanks()
    Wait(500)
    rm.loadPermissions()
    Wait(500)
    rm.loadBankAccounts()
    Wait(500)
    rm.loadBans()
    Wait(500)
    
    print("^2[RM-Framework] ^7All data reloaded successfully!")
end)

-- Event to check if player is banned on connection
rm.Event.Register('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    
    deferrals.defer()
    deferrals.update("Checking ban status...")
    
    if rm.isPlayerBanned(license) then
        local ban = rm.getBan(license)
        deferrals.done("Vous êtes banni. Raison: " .. ban.getReason() .. " | Modérateur: " .. ban.getModerator())
    else
        deferrals.done()
    end
end)

print("^2[RM-Framework] ^7Initialization manager loaded!") 
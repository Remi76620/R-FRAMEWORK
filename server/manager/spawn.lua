-- Fonction pour récupérer tous les identifiants d'un joueur
function GetAllPlayerIdentifiers(source)
    local identifiers = {}
    
    rm.Io.Trace("Récupération des identifiants pour source: " .. source)
    
    -- Récupérer tous les identifiants
    local allIdentifiers = GetPlayerIdentifiers(source)
    rm.Io.Trace("Tous les identifiants: " .. json.encode(allIdentifiers))
    
    for _, identifier in ipairs(allIdentifiers) do
        rm.Io.Trace("Traitement identifiant: " .. identifier)
        if string.find(identifier, "license:") then
            identifiers.license = identifier
            rm.Io.Trace("License trouvé: " .. identifier)
        elseif string.find(identifier, "steam:") then
            identifiers.steam = identifier
            rm.Io.Trace("Steam trouvé: " .. identifier)
        elseif string.find(identifier, "live:") then
            identifiers.live = identifier
            rm.Io.Trace("Live trouvé: " .. identifier)
        elseif string.find(identifier, "xbl:") then
            identifiers.xbl = identifier
            rm.Io.Trace("XBL trouvé: " .. identifier)
        elseif string.find(identifier, "discord:") then
            identifiers.discord = identifier:gsub("^discord:", "")
            rm.Io.Trace("Discord trouvé: " .. identifier)
        end
    end
    
    -- Récupérer l'IP
    identifiers.endpoint = tostring(GetPlayerEndpoint(source))
    rm.Io.Trace("Endpoint: " .. identifiers.endpoint)
    
    -- Valeurs par défaut si manquantes
    identifiers.license = identifiers.license or "license:unknown"
    identifiers.steam = identifiers.steam or "steam:unknown"
    identifiers.live = identifiers.live or "live:unknown"
    identifiers.xbl = identifiers.xbl or "xbl:unknown"
    identifiers.discord = identifiers.discord or "unknown"
    identifiers.endpoint = identifiers.endpoint or "unknown"
    
    rm.Io.Trace("Identifiants finaux: " .. json.encode(identifiers))
    return identifiers
end

-- Fonction pour créer les comptes bancaires d'un joueur
function CreatePlayerBankAccounts(rmId, license)
    rm.Io.Trace("Création des comptes bancaires pour rmId: " .. rmId)
    
    -- Compte principal (type 1)
    MySQL.insert('INSERT INTO `rm_bankaccounts` (`accountId`, `type`, `owner`, `label`, `pin`, `balance`, `state`) VALUES (?, ?, ?, ?, ?, ?, ?)', 
        {rmId, 1, license, "Compte Principal", 0000, 1000, 1}, function(accountId)
        
        if accountId then
            rm.Io.Trace("Compte principal créé avec ID: " .. accountId)
            
            -- Transaction initiale
            MySQL.insert('INSERT INTO `rm_bankaccounts_transaction` (`accountId`, `type`, `label`, `amount`) VALUES (?, ?, ?, ?)', 
                {rmId, 1, "Création du compte", 1000}, function(transactionId)
                
                if transactionId then
                    rm.Io.Trace("Transaction initiale créée avec ID: " .. transactionId)
                else
                    rm.Io.Error("Failed to create initial transaction for account: " .. rmId)
                end
            end)
        else
            rm.Io.Error("Failed to create main bank account for rmId: " .. rmId)
        end
    end)
    
    -- Compte épargne (type 2)
    MySQL.insert('INSERT INTO `rm_bankaccounts` (`accountId`, `type`, `owner`, `label`, `pin`, `balance`, `state`) VALUES (?, ?, ?, ?, ?, ?, ?)', 
        {rmId + 1000, 2, license, "Compte Épargne", 0000, 0, 1}, function(accountId)
        
        if accountId then
            rm.Io.Trace("Compte épargne créé avec ID: " .. accountId)
        else
            rm.Io.Error("Failed to create savings bank account for rmId: " .. rmId)
        end
    end)
end

-- Fonction pour vérifier et créer les comptes bancaires manquants
function CheckAndCreateBankAccounts(rmId, license)
    MySQL.query('SELECT * FROM `rm_bankaccounts` WHERE `owner` = ?', {license}, function(accounts)
        if not accounts or #accounts == 0 then
            rm.Io.Trace("Aucun compte bancaire trouvé pour " .. license .. ", création...")
            CreatePlayerBankAccounts(rmId, license)
        else
            rm.Io.Trace("Comptes bancaires existants trouvés pour " .. license .. " (" .. #accounts .. " comptes)")
        end
    end)
end

rm.Event.Register('rm-spawn:loadPlayer', function()
    local source = source
    local license = GetPlayerIdentifierByType(source, 'license')
    local isNewPlayer = false

    rm.Io.Trace("=== DEBUT LOAD PLAYER ===")
    rm.Io.Trace("Source: " .. source)
    rm.Io.Trace("License: " .. license)

    MySQL.single('SELECT * FROM `rm_players` WHERE `identifier` = ?', {license}, function(result)
        if result then
            rm.Io.Trace("Joueur existant trouvé avec rmId: " .. result.rmId)
            -- Récupération des identifiants
            MySQL.single('SELECT * FROM `rm_players_identifiers` WHERE `rmId` = ?', {result.rmId}, function(identifiers)
                -- Récupération de la position
                MySQL.single('SELECT * FROM `rm_players_positions` WHERE `rmId` = ?', {result.rmId}, function(position)
                    
                    -- Si pas d'identifiants, les créer
                    if not identifiers then
                        rm.Io.Trace("Pas d'identifiants trouvés, création...")
                        local currentIdentifiers = GetAllPlayerIdentifiers(source)
                        
                        MySQL.insert('INSERT INTO `rm_players_identifiers` (`rmId`, `license`, `steam`, `live`, `xbl`, `discord`, `endpoint`) VALUES (?, ?, ?, ?, ?, ?, ?)', 
                            {result.rmId, currentIdentifiers.license, currentIdentifiers.steam, currentIdentifiers.live, currentIdentifiers.xbl, currentIdentifiers.discord, currentIdentifiers.endpoint}, function(identifierId)
                            
                            if identifierId then
                                rm.Io.Trace("Identifiants créés avec ID: " .. identifierId)
                            else
                                rm.Io.Error("Failed to create identifiers for existing player")
                            end
                        end)
                        identifiers = { rmId = result.rmId }
                    end
                    
                    -- Si pas de position, la créer
                    if not position then
                        rm.Io.Trace("Pas de position trouvée, création...")
                        local defaultPosition = json.encode(Config.Start.spawn)
                        
                        MySQL.insert('INSERT INTO `rm_players_positions` (`rmId`, `position`) VALUES (?, ?)', 
                            {result.rmId, defaultPosition}, function(positionId)
                            
                            if positionId then
                                rm.Io.Trace("Position créée avec ID: " .. positionId)
                            else
                                rm.Io.Error("Failed to create position for existing player")
                            end
                        end)
                        position = { rmId = result.rmId, position = defaultPosition }
                    end
                    
                    -- Vérifier et créer les comptes bancaires si nécessaire
                    CheckAndCreateBankAccounts(result.rmId, license)
                    
            local playerData = {
                        rmId = result.rmId,
                        identifier = result.identifier,
                        rankId = result.rankId,
                        identity = result.identity,
                        cash = result.cash,
                        skin = result.skin,
                        outfits = result.outfits,
                        selectedOutfit = result.selectedOutfit,
                        accessories = result.accessories,
                        identifiers = identifiers or {},
                        position = position and json.decode(position.position) or Config.Start.spawn
            }

            rm.addPlayer(source, playerData)

                    -- Mise à jour des informations de base si nécessaire
            local playerInfo = {
                        identifier = license,
                        name = GetPlayerName(source)
                    }

                    if result.identifier ~= playerInfo.identifier then
                        MySQL.update('UPDATE `rm_players` SET `identifier` = ? WHERE `identifier` = ?', 
                            {playerInfo.identifier, result.identifier})
                    end

                    -- Mise à jour des identifiants si nécessaire
                    if identifiers and identifiers.rmId then
                        local currentIdentifiers = GetAllPlayerIdentifiers(source)

                        MySQL.update('UPDATE `rm_players_identifiers` SET `license` = ?, `steam` = ?, `live` = ?, `xbl` = ?, `discord` = ?, `endpoint` = ? WHERE `rmId` = ?', 
                            {currentIdentifiers.license, currentIdentifiers.steam, currentIdentifiers.live, currentIdentifiers.xbl, currentIdentifiers.discord, currentIdentifiers.endpoint, result.rmId})
                    end

                    -- Démarrer la sauvegarde automatique des positions
                    StartPositionAutoSave(source, result.rmId)

                    rm.Event.TriggerClient('rm-spawn:spawnPlayer', source, playerData.position.x, playerData.position.y, playerData.position.z, playerData.position.h, isNewPlayer)
                end)
            end)
        else
            isNewPlayer = true
            rm.Io.Trace("Nouveau joueur détecté, création en cours...")
            
            -- Récupérer tous les identifiants actuels du joueur
            local currentIdentifiers = GetAllPlayerIdentifiers(source)
            
            rm.Io.Trace("Creating new player with identifiers: " .. json.encode(currentIdentifiers))
            
            -- Fonction pour diviser le nom
            local function splitName(name)
                local parts = {}
                for part in name:gmatch("%S+") do
                    table.insert(parts, part)
                end
                return parts
            end
            
            local playerName = GetPlayerName(source)
            local nameParts = splitName(playerName)
            
            local defaultIdentity = json.encode({
                firstname = nameParts[1] or 'John',
                lastname = nameParts[2] or 'Doe',
                age = 25,
                sex = 'M'
            })
            
            local defaultSkin = json.encode({})
            local defaultOutfits = json.encode({})
            local defaultAccessories = json.encode({})
            local defaultPosition = json.encode(Config.Start.spawn)
            
            rm.Io.Trace("Insertion du joueur principal...")
            
            -- Insertion du joueur principal
            MySQL.insert('INSERT INTO `rm_players` (`identifier`, `rankId`, `identity`, `cash`, `skin`, `outfits`, `selectedOutfit`, `accessories`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', 
                {license, 'user', defaultIdentity, 0, defaultSkin, defaultOutfits, 'default', defaultAccessories}, function(rmId)
                
                if rmId then
                    rm.Io.Trace("Player created with rmId: " .. rmId)
                    
                    rm.Io.Trace("Insertion des identifiants...")
                    -- Insertion des identifiants actuels
                    MySQL.insert('INSERT INTO `rm_players_identifiers` (`rmId`, `license`, `steam`, `live`, `xbl`, `discord`, `endpoint`) VALUES (?, ?, ?, ?, ?, ?, ?)', 
                        {rmId, currentIdentifiers.license, currentIdentifiers.steam, currentIdentifiers.live, currentIdentifiers.xbl, currentIdentifiers.discord, currentIdentifiers.endpoint}, function(identifierId)
                        
                        if identifierId then
                            rm.Io.Trace("Identifiers inserted with ID: " .. identifierId)
                            rm.Io.Trace("License: " .. currentIdentifiers.license)
                            rm.Io.Trace("Steam: " .. currentIdentifiers.steam)
                            rm.Io.Trace("Live: " .. currentIdentifiers.live)
                            rm.Io.Trace("XBL: " .. currentIdentifiers.xbl)
                            rm.Io.Trace("Discord: " .. currentIdentifiers.discord)
                            rm.Io.Trace("Endpoint: " .. currentIdentifiers.endpoint)
                        else
                            rm.Io.Error("Failed to insert identifiers for rmId: " .. rmId)
                        end
                    end)
                    
                    rm.Io.Trace("Insertion de la position...")
                    -- Insertion de la position
                    MySQL.insert('INSERT INTO `rm_players_positions` (`rmId`, `position`) VALUES (?, ?)', 
                        {rmId, defaultPosition}, function(positionId)
                        
                        if positionId then
                            rm.Io.Trace("Position inserted with ID: " .. positionId)
                        else
                            rm.Io.Error("Failed to insert position for rmId: " .. rmId)
                        end
                    end)
                    
                    -- Création des comptes bancaires pour le nouveau joueur
                    CreatePlayerBankAccounts(rmId, license)
                    
                    rm.addPlayer(source, {
                        rmId = rmId,
                        identifier = license,
                        rankId = 'user',
                        identity = defaultIdentity,
                        cash = 0,
                        skin = defaultSkin,
                        outfits = defaultOutfits,
                        selectedOutfit = 'default',
                        accessories = defaultAccessories,
                        identifiers = currentIdentifiers,
                        position = Config.Start.spawn
                    })
                    
                    -- Démarrer la sauvegarde automatique des positions
                    StartPositionAutoSave(source, rmId)
                    
            rm.Event.TriggerClient('rm-spawn:spawnPlayer', source, Config.Start.spawn.x, Config.Start.spawn.y, Config.Start.spawn.z, Config.Start.spawn.h, isNewPlayer)
                else
                    rm.Io.Error("Failed to create player in database")
                end
            end)
        end

        TriggerClientEvent('rm-framework:playerLoaded', -1, isNewPlayer)
        TriggerEvent('rm-framework:playerLoaded')
        rm.Io.Trace("=== FIN LOAD PLAYER ===")
    end)
end)

-- Fonction pour créer un joueur de test avec vos identifiants
function CreateTestPlayer()
    local testLicense = "license:16945e7f0227cc4a1a8ae383ae8aa571f92b32ba"
    local testIdentity = json.encode({
        firstname = "Test",
        lastname = "Player",
        age = 25,
        sex = "M"
    })
    
    local testIdentifiers = {
        license = "license:16945e7f0227cc4a1a8ae383ae8aa571f92b32ba",
        steam = "steam:110000112c75272",
        live = "live:1055518528126665",
        xbl = "xbl:2535437230654876",
        discord = "854439133186490378",
        endpoint = "192.168.1.64"
    }
    
    local defaultSkin = json.encode({})
    local defaultOutfits = json.encode({})
    local defaultAccessories = json.encode({})
    local defaultPosition = json.encode(Config.Start.spawn)
    
    rm.Io.Trace("Creating test player with your identifiers...")
    
    MySQL.insert('INSERT INTO `rm_players` (`identifier`, `rankId`, `identity`, `cash`, `skin`, `outfits`, `selectedOutfit`, `accessories`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', 
        {testLicense, 'user', testIdentity, 1000, defaultSkin, defaultOutfits, 'default', defaultAccessories}, function(rmId)
        
        if rmId then
            rm.Io.Trace("Test player created with rmId: " .. rmId)
            
            -- Insertion des identifiants de test
            MySQL.insert('INSERT INTO `rm_players_identifiers` (`rmId`, `license`, `steam`, `live`, `xbl`, `discord`, `endpoint`) VALUES (?, ?, ?, ?, ?, ?, ?)', 
                {rmId, testIdentifiers.license, testIdentifiers.steam, testIdentifiers.live, testIdentifiers.xbl, testIdentifiers.discord, testIdentifiers.endpoint}, function(identifierId)
                
                if identifierId then
                    rm.Io.Trace("Test identifiers inserted with ID: " .. identifierId)
                    rm.Io.Trace("License: " .. testIdentifiers.license)
                    rm.Io.Trace("Steam: " .. testIdentifiers.steam)
                    rm.Io.Trace("Live: " .. testIdentifiers.live)
                    rm.Io.Trace("XBL: " .. testIdentifiers.xbl)
                    rm.Io.Trace("Discord: " .. testIdentifiers.discord)
                    rm.Io.Trace("Endpoint: " .. testIdentifiers.endpoint)
                else
                    rm.Io.Error("Failed to insert test identifiers")
                end
            end)
            
            -- Insertion de la position de test
            MySQL.insert('INSERT INTO `rm_players_positions` (`rmId`, `position`) VALUES (?, ?)', 
                {rmId, defaultPosition}, function(positionId)
                
                if positionId then
                    rm.Io.Trace("Test position inserted with ID: " .. positionId)
                else
                    rm.Io.Error("Failed to insert test position")
                end
            end)
            
            -- Création des comptes bancaires de test
            CreatePlayerBankAccounts(rmId, testLicense)
            
            rm.Io.Trace("Test player creation completed!")
        else
            rm.Io.Error("Failed to create test player")
        end
    end)
end

-- Event pour créer un joueur de test
rm.Event.Register('rm-framework:createTestPlayer', function()
    CreateTestPlayer()
end)

-- Fonction pour vérifier l'état des tables
function CheckTablesStatus()
    MySQL.query('SELECT COUNT(*) as count FROM `rm_players`', {}, function(playersResult)
        if playersResult and playersResult[1] then
            rm.Io.Trace("rm_players count: " .. playersResult[1].count)
        end
    end)
    
    MySQL.query('SELECT COUNT(*) as count FROM `rm_players_identifiers`', {}, function(identifiersResult)
        if identifiersResult and identifiersResult[1] then
            rm.Io.Trace("rm_players_identifiers count: " .. identifiersResult[1].count)
        end
    end)
    
    MySQL.query('SELECT COUNT(*) as count FROM `rm_players_positions`', {}, function(positionsResult)
        if positionsResult and positionsResult[1] then
            rm.Io.Trace("rm_players_positions count: " .. positionsResult[1].count)
        end
    end)
    
    MySQL.query('SELECT COUNT(*) as count FROM `rm_bankaccounts`', {}, function(bankResult)
        if bankResult and bankResult[1] then
            rm.Io.Trace("rm_bankaccounts count: " .. bankResult[1].count)
        end
    end)
    
    MySQL.query('SELECT COUNT(*) as count FROM `rm_bankaccounts_transaction`', {}, function(transactionResult)
        if transactionResult and transactionResult[1] then
            rm.Io.Trace("rm_bankaccounts_transaction count: " .. transactionResult[1].count)
        end
    end)
end

-- Event pour vérifier l'état des tables
rm.Event.Register('rm-framework:checkTables', function()
    CheckTablesStatus()
end)

-- Fonction pour sauvegarder automatiquement les positions
function StartPositionAutoSave(source, rmId)
    CreateThread(function()
        while true do
            Wait(30000) -- Sauvegarde toutes les 30 secondes
            
            if not GetPlayerName(source) then
                break -- Le joueur s'est déconnecté
            end
            
            local ped = GetPlayerPed(source)
            if ped and ped ~= 0 then
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                local position = json.encode({x = coords.x, y = coords.y, z = coords.z, h = heading})
                
                MySQL.update('UPDATE `rm_players_positions` SET `position` = ? WHERE `rmId` = ?', {position, rmId})
                rm.Io.Trace("Position auto-saved for player " .. GetPlayerName(source))
            end
        end
    end)
end

-- Fonction pour sauvegarder la position d'un joueur
function SavePlayerPosition(source, rmId)
    if not source or not rmId then return false end
    
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local position = json.encode({x = coords.x, y = coords.y, z = coords.z, h = heading})

    MySQL.update('UPDATE `rm_players_positions` SET `position` = ? WHERE `rmId` = ?', {position, rmId})
    rm.Io.Trace("Position saved for player " .. GetPlayerName(source))
    return true
end

AddEventHandler('playerDropped', function(reason)
    local source = source
    local player = rm.getPlayer(source)
    if not player then return end
    
    -- Sauvegarde finale de la position
    SavePlayerPosition(source, player.getRmId())
    
    -- Sauvegarde des données du joueur
    if player.updateData() then
        rm.removePlayer(source)
    end

    local identity = json.decode(player.getIdentity() or '{}')
    local message = ('Prénom: %s \n Nom: %s \n Rank: %s \n Cash: %s \n License: %s \n Raison: %s'):format(
        identity.firstname or 'Unknown', 
        identity.lastname or 'Unknown', 
        player.getRankId(), 
        player.getCash(), 
        player.getIdentifier(), 
        reason
    )
    rm.Function.sendDiscordLog(Config.Logs.Leave, 16711680, 'Déconnexion', message, 'RM-Framework')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, playerId in ipairs(GetPlayers()) do
            local player = rm.getPlayer(playerId)
            if player then
                -- Sauvegarde de la position
                SavePlayerPosition(playerId, player.getRmId())
                player.updateData()
            end
        end
    end
end)

-- Event pour sauvegarder manuellement la position
rm.Event.Register('rm-framework:savePosition', function()
    local source = source
    local player = rm.getPlayer(source)
    if player then
        SavePlayerPosition(source, player.getRmId())
    end
end)

rm.Event.Register('rm-framework:playerSpawned', function()
    local source = source
    local player = rm.getPlayer(source)
    if not player then return end
    -- Restauration des armes si nécessaire
    -- player.restoreWeapons()
end)   
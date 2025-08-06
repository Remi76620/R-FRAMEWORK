--- Player Class
--- @class rm.Player
rm.Players = {}

--- Create Player
--- @param source number The player's server ID.
--- @return table The player obj.
function rm.createPlayer(source, data)
    local player = {
        source = source,
        rmId = data.rmId,
        identifier = data.identifier or GetPlayerIdentifierByType(source, 'license'),
        rankId = data.rankId or "user",
        identity = data.identity or json.encode({firstname = "John", lastname = "Doe", age = 25, sex = "M"}),
        cash = data.cash or 0,
        skin = data.skin or json.encode({}),
        outfits = data.outfits or json.encode({}),
        selectedOutfit = data.selectedOutfit or "default",
        accessories = data.accessories or json.encode({}),
        identifiers = data.identifiers or {},
        position = data.position or Config.Start.spawn
    }

    --- Get RM ID of the player
    --- @return number RM ID of the player.
    function player.getRmId()
        return player.rmId
    end

    --- Get Identifier of the player
    --- @return string Identifier of the player.
    function player.getIdentifier()
        return player.identifier
    end

    --- Get Rank ID of the player
    --- @return string Rank ID of the player.
    function player.getRankId()
        return player.rankId
    end

    --- Set Rank ID of the player
    --- @param rankId string Rank ID of the player.
    --- @return boolean Return true if the rank is set.
    function player.setRankId(rankId)
        if type(rankId) ~= "string" then
            rm.Io.Error("Invalid 'rankId' argument. Expected string.")
            return false
        end
        player.rankId = rankId
        return true
    end

    --- Get Identity of the player
    --- @return string Identity JSON of the player.
    function player.getIdentity()
        return player.identity
    end

    --- Set Identity of the player
    --- @param identity string Identity JSON of the player.
    --- @return boolean Return true if the identity is set.
    function player.setIdentity(identity)
        if type(identity) ~= "string" then
            rm.Io.Error("Invalid 'identity' argument. Expected string.")
            return false
        end
        player.identity = identity
        return true
    end

    --- Get First Name of the player
    --- @return string Return FirstName of the player.
    function player.getFirstName()
        local identity = json.decode(player.identity) or {}
        return identity.firstname or "Unknown"
    end

    --- Set First Name of the player
    --- @param firstName string First Name of the player.
    --- @return boolean Return true if the first name is set.
    function player.setFirstName(firstName)
        if type(firstName) ~= "string" then
            rm.Io.Error("Invalid 'firstName' argument. Expected string.")
            return false
        end
        local identity = json.decode(player.identity) or {}
        identity.firstname = firstName
        player.identity = json.encode(identity)
        return true
    end

    --- Get Last Name of the player
    --- @return string Return LastName of the player.
    function player.getLastName()
        local identity = json.decode(player.identity) or {}
        return identity.lastname or "Unknown"
    end

    --- Set Last Name of the player
    --- @param lastName string Last Name of the player.
    --- @return boolean Return true if the last name is set.
    function player.setLastName(lastName)
        if type(lastName) ~= "string" then
            rm.Io.Error("Invalid 'lastName' argument. Expected string.")
            return false
        end
        local identity = json.decode(player.identity) or {}
        identity.lastname = lastName
        player.identity = json.encode(identity)
        return true
    end

    --- Get Age of the player
    --- @return number Return Age of the player.
    function player.getAge()
        local identity = json.decode(player.identity) or {}
        return identity.age or 25
    end

    --- Set Age of the player
    --- @param age number Age of the player.
    --- @return boolean Return true if the age is set.
    function player.setAge(age)
        if type(age) ~= "number" or age < 0 then
            rm.Io.Error("Invalid 'age' argument. Expected positive number.")
            return false
        end
        local identity = json.decode(player.identity) or {}
        identity.age = age
        player.identity = json.encode(identity)
        return true
    end

    --- Get Sex of the player
    --- @return string Return Sex of the player.
    function player.getSex()
        local identity = json.decode(player.identity) or {}
        return identity.sex or "M"
    end

    --- Set Sex of the player
    --- @param sex string Sex of the player.
    --- @return boolean Return true if sex is set.
    function player.setSex(sex)
        if sex ~= "M" and sex ~= "F" then
            rm.Io.Error("Invalid 'sex' argument. Expected 'M' or 'F'.")
            return false
        end
        local identity = json.decode(player.identity) or {}
        identity.sex = sex
        player.identity = json.encode(identity)
        return true
    end

    --- Get Cash of the player
    --- @return number Cash of the player.
    function player.getCash()
        return player.cash
    end

    --- Set Cash of the player
    --- @param cash number Cash of the player.
    --- @return boolean Return true if the cash is set.
    function player.setCash(cash)
        if type(cash) ~= "number" then
            rm.Io.Error("Invalid 'cash' argument. Expected number.")
            return false
        end
        player.cash = cash
        return true
    end

    --- Add Cash to the player
    --- @param amount number Amount to add to cash.
    --- @return boolean Return true if the cash is added.
    function player.addCash(amount)
        if type(amount) ~= "number" then
            rm.Io.Error("Invalid 'amount' argument. Expected number.")
            return false
        end
        player.cash = player.cash + amount
        return true
    end

    --- Remove Cash from the player
    --- @param amount number Amount to remove from cash.
    --- @return boolean Return true if the cash is removed.
    function player.removeCash(amount)
        if type(amount) ~= "number" then
            rm.Io.Error("Invalid 'amount' argument. Expected number.")
            return false
        end
        if player.cash >= amount then
            player.cash = player.cash - amount
            return true
        end
        return false
    end

    --- Get Skin of the player
    --- @return string Skin JSON of the player.
    function player.getSkin()
        return player.skin
    end

    --- Set Skin of the player
    --- @param skin string Skin JSON of the player.
    --- @return boolean Return true if the skin is set.
    function player.setSkin(skin)
        if type(skin) ~= "string" then
            rm.Io.Error("Invalid 'skin' argument. Expected string.")
            return false
        end
        player.skin = skin
        return true
    end

    --- Get Outfits of the player
    --- @return string Outfits JSON of the player.
    function player.getOutfits()
        return player.outfits
    end

    --- Set Outfits of the player
    --- @param outfits string Outfits JSON of the player.
    --- @return boolean Return true if the outfits are set.
    function player.setOutfits(outfits)
        if type(outfits) ~= "string" then
            rm.Io.Error("Invalid 'outfits' argument. Expected string.")
            return false
        end
        player.outfits = outfits
        return true
    end

    --- Get Selected Outfit of the player
    --- @return string Selected outfit of the player.
    function player.getSelectedOutfit()
        return player.selectedOutfit
    end

    --- Set Selected Outfit of the player
    --- @param outfit string Selected outfit of the player.
    --- @return boolean Return true if the selected outfit is set.
    function player.setSelectedOutfit(outfit)
        if type(outfit) ~= "string" then
            rm.Io.Error("Invalid 'outfit' argument. Expected string.")
            return false
        end
        player.selectedOutfit = outfit
        return true
    end

    --- Get Accessories of the player
    --- @return string Accessories JSON of the player.
    function player.getAccessories()
        return player.accessories
    end

    --- Set Accessories of the player
    --- @param accessories string Accessories JSON of the player.
    --- @return boolean Return true if the accessories are set.
    function player.setAccessories(accessories)
        if type(accessories) ~= "string" then
            rm.Io.Error("Invalid 'accessories' argument. Expected string.")
            return false
        end
        player.accessories = accessories
        return true
    end

    --- Get Identifiers of the player
    --- @return table Identifiers of the player.
    function player.getIdentifiers()
        return player.identifiers
    end

    --- Get specific identifier of the player
    --- @param type string Type of identifier (license, steam, live, xbl, discord, endpoint).
    --- @return string Identifier value.
    function player.getIdentifierByType(type)
        return player.identifiers[type] or ""
    end

    --- Set Identifiers of the player
    --- @param identifiers table Identifiers of the player.
    --- @return boolean Return true if the identifiers are set.
    function player.setIdentifiers(identifiers)
        if type(identifiers) ~= "table" then
            rm.Io.Error("Invalid 'identifiers' argument. Expected table.")
            return false
        end
        player.identifiers = identifiers
        return true
    end

    --- Get Position of the player
    --- @return table Position of the player.
    function player.getPosition()
        return player.position
    end

    --- Set Position of the player
    --- @param position table Position of the player.
    --- @return boolean Return true if the position is set.
    function player.setPosition(position)
        if type(position) ~= "table" then
            rm.Io.Error("Invalid 'position' argument. Expected table.")
            return false
        end
        player.position = position
        return true
    end

    --- Update Player Data in the Database
    --- @return boolean Return true if data is updated successfully.
    function player.updateData()
        local success, result = pcall(function()
            return MySQL.Sync.execute("UPDATE rm_players SET rankId = ?, identity = ?, cash = ?, skin = ?, outfits = ?, selectedOutfit = ?, accessories = ? WHERE identifier = ?", {
                player.rankId,
                player.identity,
                player.cash,
                player.skin,
                player.outfits,
                player.selectedOutfit,
                player.accessories,
                player.identifier
            })
        end)

        if success and result > 0 then
            rm.Io.Trace("Player data updated for " .. player.getFirstName() .. " " .. player.getLastName())
            return true
        else
            rm.Io.Warn("Player data not updated for " .. player.getFirstName() .. " " .. player.getLastName() .. ". Error: " .. tostring(result))
            return false
        end
    end

    --- Update Player Position in the Database
    --- @return boolean Return true if position is updated successfully.
    function player.updatePosition()
        local success, result = pcall(function()
            return MySQL.Sync.execute("UPDATE rm_players_positions SET position = ? WHERE rmId = ?", {
                json.encode(player.position),
                player.rmId
            })
        end)

        if success and result > 0 then
            rm.Io.Trace("Player position updated for " .. player.getFirstName() .. " " .. player.getLastName())
            return true
        else
            rm.Io.Warn("Player position not updated for " .. player.getFirstName() .. " " .. player.getLastName() .. ". Error: " .. tostring(result))
            return false
        end
    end

    --- Update Player Identifiers in the Database
    --- @return boolean Return true if identifiers are updated successfully.
    function player.updateIdentifiers()
        local success, result = pcall(function()
            return MySQL.Sync.execute("UPDATE rm_players_identifiers SET license = ?, steam = ?, live = ?, xbl = ?, discord = ?, endpoint = ? WHERE rmId = ?", {
                player.identifiers.license or "",
                player.identifiers.steam or "",
                player.identifiers.live or "",
                player.identifiers.xbl or "",
                player.identifiers.discord or "",
                player.identifiers.endpoint or "",
                player.rmId
            })
        end)

        if success and result > 0 then
            rm.Io.Trace("Player identifiers updated for " .. player.getFirstName() .. " " .. player.getLastName())
            return true
        else
            rm.Io.Warn("Player identifiers not updated for " .. player.getFirstName() .. " " .. player.getLastName() .. ". Error: " .. tostring(result))
            return false
        end
    end

    -- Message de trace après que toutes les méthodes soient définies
    rm.Io.Trace("Player created: " .. player.getFirstName() .. " " .. player.getLastName())

    return player
end

--- Add Player
--- @param source number The player's server ID.
--- @param data table The player's data.
--- @return boolean Return true if the player is added.
function rm.addPlayer(source, data)
    if rm.Players[source] then
        rm.Io.Warn("The player already exists.")
        return false
    end

    local player = rm.createPlayer(source, data)
    rm.Players[source] = player
    return true
end

--- Get Player
--- @param source number The player's server ID.
--- @return table Return the player.
function rm.getPlayer(source)
    return rm.Players[source]
end

--- Remove Player
--- @param source number The player's server ID.
function rm.removePlayer(source)
    if rm.Players[source] then
        rm.Players[source] = nil
        rm.Io.Trace("Player removed: " .. tostring(source))
    else
        rm.Io.Warn("Attempted to remove non-existent player: " .. tostring(source))
    end
end
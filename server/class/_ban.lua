--- Ban Class
--- @class rm.Ban
rm.Bans = {}

--- Create Ban
--- @param identifier string The player identifier.
--- @param data table The ban data.
--- @return table The ban obj.
function rm.createBan(identifier, data)
    local ban = {
        identifier = identifier,
        name = data.name or "Unknown",
        date = data.date or os.date("%Y-%m-%d"),
        time = data.time or "Permanent",
        reason = data.reason or "No reason specified",
        moderator = data.moderator or "System"
    }

    --- Get Ban Identifier
    --- @return string Ban identifier.
    function ban.getIdentifier()
        return ban.identifier
    end

    --- Get Ban Name
    --- @return string Ban name.
    function ban.getName()
        return ban.name
    end

    --- Set Ban Name
    --- @param name string Ban name.
    --- @return boolean Return true if name is set.
    function ban.setName(name)
        if type(name) ~= "string" then
            rm.Io.Error("Invalid 'name' argument. Expected string.")
            return false
        end
        ban.name = name
        return true
    end

    --- Get Ban Date
    --- @return string Ban date.
    function ban.getDate()
        return ban.date
    end

    --- Set Ban Date
    --- @param date string Ban date.
    --- @return boolean Return true if date is set.
    function ban.setDate(date)
        if type(date) ~= "string" then
            rm.Io.Error("Invalid 'date' argument. Expected string.")
            return false
        end
        ban.date = date
        return true
    end

    --- Get Ban Time
    --- @return string Ban time.
    function ban.getTime()
        return ban.time
    end

    --- Set Ban Time
    --- @param time string Ban time.
    --- @return boolean Return true if time is set.
    function ban.setTime(time)
        if type(time) ~= "string" then
            rm.Io.Error("Invalid 'time' argument. Expected string.")
            return false
        end
        ban.time = time
        return true
    end

    --- Get Ban Reason
    --- @return string Ban reason.
    function ban.getReason()
        return ban.reason
    end

    --- Set Ban Reason
    --- @param reason string Ban reason.
    --- @return boolean Return true if reason is set.
    function ban.setReason(reason)
        if type(reason) ~= "string" then
            rm.Io.Error("Invalid 'reason' argument. Expected string.")
            return false
        end
        ban.reason = reason
        return true
    end

    --- Get Ban Moderator
    --- @return string Ban moderator.
    function ban.getModerator()
        return ban.moderator
    end

    --- Set Ban Moderator
    --- @param moderator string Ban moderator.
    --- @return boolean Return true if moderator is set.
    function ban.setModerator(moderator)
        if type(moderator) ~= "string" then
            rm.Io.Error("Invalid 'moderator' argument. Expected string.")
            return false
        end
        ban.moderator = moderator
        return true
    end

    --- Check if Ban is Permanent
    --- @return boolean Return true if ban is permanent.
    function ban.isPermanent()
        return ban.time == "Permanent"
    end

    --- Check if Ban is Expired
    --- @return boolean Return true if ban is expired.
    function ban.isExpired()
        if ban.isPermanent() then
            return false
        end
        
        -- Parse ban time and check if expired
        local banTime = os.time({
            year = tonumber(string.sub(ban.date, 1, 4)),
            month = tonumber(string.sub(ban.date, 6, 7)),
            day = tonumber(string.sub(ban.date, 9, 10))
        })
        
        local currentTime = os.time()
        return currentTime > banTime
    end

    --- Update Ban in Database
    --- @return boolean Return true if ban is updated successfully.
    function ban.updateData()
        local success, result = pcall(function()
            return MySQL.Sync.execute("UPDATE rm_bans SET name = ?, date = ?, time = ?, reason = ?, moderator = ? WHERE identifier = ?", {
                ban.name,
                ban.date,
                ban.time,
                ban.reason,
                ban.moderator,
                ban.identifier
            })
        end)

        if success and result > 0 then
            rm.Io.Trace("Ban data updated for " .. ban.name)
            return true
        else
            rm.Io.Warn("Ban data not updated for " .. ban.name .. ". Error: " .. tostring(result))
            return false
        end
    end

    rm.Io.Trace("Ban created for: " .. ban.name)
    return ban
end

--- Add Ban
--- @param identifier string The player identifier.
--- @param data table The ban data.
--- @return boolean Return true if the ban is added.
function rm.addBan(identifier, data)
    if rm.Bans[identifier] then
        rm.Io.Warn("The ban already exists.")
        return false
    end

    local ban = rm.createBan(identifier, data)
    rm.Bans[identifier] = ban
    return true
end

--- Get Ban
--- @param identifier string The player identifier.
--- @return table Return the ban.
function rm.getBan(identifier)
    return rm.Bans[identifier]
end

--- Remove Ban
--- @param identifier string The player identifier.
function rm.removeBan(identifier)
    if rm.Bans[identifier] then
        rm.Bans[identifier] = nil
        rm.Io.Trace("Ban removed for: " .. tostring(identifier))
    else
        rm.Io.Warn("Attempted to remove non-existent ban: " .. tostring(identifier))
    end
end

--- Check if Player is Banned
--- @param identifier string The player identifier.
--- @return boolean Return true if player is banned.
function rm.isPlayerBanned(identifier)
    local ban = rm.getBan(identifier)
    if ban then
        return not ban.isExpired()
    end
    return false
end

--- Ban Player
--- @param identifier string The player identifier.
--- @param name string The player name.
--- @param reason string The ban reason.
--- @param moderator string The moderator name.
--- @param time string The ban duration (optional, default: "Permanent").
--- @return boolean Return true if player is banned.
function rm.banPlayer(identifier, name, reason, moderator, time)
    if type(identifier) ~= "string" or type(name) ~= "string" or type(reason) ~= "string" or type(moderator) ~= "string" then
        rm.Io.Error("Invalid ban arguments.")
        return false
    end

    local banData = {
        name = name,
        date = os.date("%Y-%m-%d"),
        time = time or "Permanent",
        reason = reason,
        moderator = moderator
    }

    local success, result = pcall(function()
        return MySQL.Sync.execute("INSERT INTO rm_bans (identifier, name, date, time, reason, moderator) VALUES (?, ?, ?, ?, ?, ?)", {
            identifier,
            banData.name,
            banData.date,
            banData.time,
            banData.reason,
            banData.moderator
        })
    end)

    if success and result > 0 then
        rm.addBan(identifier, banData)
        rm.Io.Trace("Player banned: " .. name)
        return true
    else
        rm.Io.Warn("Failed to ban player: " .. name)
        return false
    end
end

--- Unban Player
--- @param identifier string The player identifier.
--- @return boolean Return true if player is unbanned.
function rm.unbanPlayer(identifier)
    if type(identifier) ~= "string" then
        rm.Io.Error("Invalid identifier argument.")
        return false
    end

    local success, result = pcall(function()
        return MySQL.Sync.execute("DELETE FROM rm_bans WHERE identifier = ?", {identifier})
    end)

    if success and result > 0 then
        rm.removeBan(identifier)
        rm.Io.Trace("Player unbanned: " .. identifier)
        return true
    else
        rm.Io.Warn("Failed to unban player: " .. identifier)
        return false
    end
end

--- Load All Bans from Database
function rm.loadBans()
    MySQL.query('SELECT * FROM rm_bans', {}, function(bans)
        if bans then
            for _, banData in ipairs(bans) do
                rm.addBan(banData.identifier, {
                    name = banData.name,
                    date = banData.date,
                    time = banData.time,
                    reason = banData.reason,
                    moderator = banData.moderator
                })
            end
            rm.Io.Trace("Loaded " .. #bans .. " bans from database")
        else
            rm.Io.Error("Failed to load bans from database")
        end
    end)
end 
--- Rank Class
--- @class rm.Rank
rm.Ranks = {}

--- Create Rank
--- @param id string The rank ID.
--- @param data table The rank data.
--- @return table The rank obj.
function rm.createRank(id, data)
    local rank = {
        id = id,
        position = data.position or 0,
        label = data.label or "Unknown",
        weight = data.weight or 0,
        baseColor = data.baseColor or "~w~",
        permissions = {}
    }

    --- Get Rank ID
    --- @return string Rank ID.
    function rank.getId()
        return rank.id
    end

    --- Get Rank Position
    --- @return number Rank position.
    function rank.getPosition()
        return rank.position
    end

    --- Set Rank Position
    --- @param position number Rank position.
    --- @return boolean Return true if position is set.
    function rank.setPosition(position)
        if type(position) ~= "number" then
            rm.Io.Error("Invalid 'position' argument. Expected number.")
            return false
        end
        rank.position = position
        return true
    end

    --- Get Rank Label
    --- @return string Rank label.
    function rank.getLabel()
        return rank.label
    end

    --- Set Rank Label
    --- @param label string Rank label.
    --- @return boolean Return true if label is set.
    function rank.setLabel(label)
        if type(label) ~= "string" then
            rm.Io.Error("Invalid 'label' argument. Expected string.")
            return false
        end
        rank.label = label
        return true
    end

    --- Get Rank Weight
    --- @return number Rank weight.
    function rank.getWeight()
        return rank.weight
    end

    --- Set Rank Weight
    --- @param weight number Rank weight.
    --- @return boolean Return true if weight is set.
    function rank.setWeight(weight)
        if type(weight) ~= "number" then
            rm.Io.Error("Invalid 'weight' argument. Expected number.")
            return false
        end
        rank.weight = weight
        return true
    end

    --- Get Rank Base Color
    --- @return string Rank base color.
    function rank.getBaseColor()
        return rank.baseColor
    end

    --- Set Rank Base Color
    --- @param baseColor string Rank base color.
    --- @return boolean Return true if base color is set.
    function rank.setBaseColor(baseColor)
        if type(baseColor) ~= "string" then
            rm.Io.Error("Invalid 'baseColor' argument. Expected string.")
            return false
        end
        rank.baseColor = baseColor
        return true
    end

    --- Add Permission to Rank
    --- @param permission string Permission to add.
    --- @return boolean Return true if permission is added.
    function rank.addPermission(permission)
        if type(permission) ~= "string" then
            rm.Io.Error("Invalid 'permission' argument. Expected string.")
            return false
        end
        
        for _, perm in ipairs(rank.permissions) do
            if perm == permission then
                return false -- Permission already exists
            end
        end
        
        table.insert(rank.permissions, permission)
        return true
    end

    --- Remove Permission from Rank
    --- @param permission string Permission to remove.
    --- @return boolean Return true if permission is removed.
    function rank.removePermission(permission)
        if type(permission) ~= "string" then
            rm.Io.Error("Invalid 'permission' argument. Expected string.")
            return false
        end
        
        for i, perm in ipairs(rank.permissions) do
            if perm == permission then
                table.remove(rank.permissions, i)
                return true
            end
        end
        
        return false -- Permission not found
    end

    --- Check if Rank has Permission
    --- @param permission string Permission to check.
    --- @return boolean Return true if rank has permission.
    function rank.hasPermission(permission)
        if type(permission) ~= "string" then
            rm.Io.Error("Invalid 'permission' argument. Expected string.")
            return false
        end
        
        for _, perm in ipairs(rank.permissions) do
            if perm == permission then
                return true
            end
        end
        
        return false
    end

    --- Get All Permissions
    --- @return table Return all permissions.
    function rank.getPermissions()
        return rank.permissions
    end

    --- Update Rank in Database
    --- @return boolean Return true if rank is updated successfully.
    function rank.updateData()
        local success, result = pcall(function()
            return MySQL.Sync.execute("UPDATE rm_ranks SET position = ?, label = ?, weight = ?, baseColor = ? WHERE id = ?", {
                rank.position,
                rank.label,
                rank.weight,
                rank.baseColor,
                rank.id
            })
        end)

        if success and result > 0 then
            rm.Io.Trace("Rank data updated for " .. rank.label)
            return true
        else
            rm.Io.Warn("Rank data not updated for " .. rank.label .. ". Error: " .. tostring(result))
            return false
        end
    end

    rm.Io.Trace("Rank created: " .. rank.label)
    return rank
end

--- Add Rank
--- @param id string The rank ID.
--- @param data table The rank data.
--- @return boolean Return true if the rank is added.
function rm.addRank(id, data)
    if rm.Ranks[id] then
        rm.Io.Warn("The rank already exists.")
        return false
    end

    local rank = rm.createRank(id, data)
    rm.Ranks[id] = rank
    return true
end

--- Get Rank
--- @param id string The rank ID.
--- @return table Return the rank.
function rm.getRank(id)
    return rm.Ranks[id]
end

--- Remove Rank
--- @param id string The rank ID.
function rm.removeRank(id)
    if rm.Ranks[id] then
        rm.Ranks[id] = nil
        rm.Io.Trace("Rank removed: " .. tostring(id))
    else
        rm.Io.Warn("Attempted to remove non-existent rank: " .. tostring(id))
    end
end

--- Load All Ranks from Database
function rm.loadRanks()
    MySQL.query('SELECT * FROM rm_ranks', {}, function(ranks)
        if ranks then
            for _, rankData in ipairs(ranks) do
                rm.addRank(rankData.id, {
                    position = rankData.position,
                    label = rankData.label,
                    weight = rankData.weight,
                    baseColor = rankData.baseColor
                })
            end
            rm.Io.Trace("Loaded " .. #ranks .. " ranks from database")
        else
            rm.Io.Error("Failed to load ranks from database")
        end
    end)
end

--- Load All Permissions from Database
function rm.loadPermissions()
    MySQL.query('SELECT * FROM rm_ranks_permissions', {}, function(permissions)
        if permissions then
            for _, permData in ipairs(permissions) do
                local rank = rm.getRank(permData.rankId)
                if rank then
                    rank.addPermission(permData.permission)
                end
            end
            rm.Io.Trace("Loaded " .. #permissions .. " permissions from database")
        else
            rm.Io.Error("Failed to load permissions from database")
        end
    end)
end 
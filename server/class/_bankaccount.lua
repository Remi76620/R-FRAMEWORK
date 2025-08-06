--- Bank Account Class
--- @class rm.BankAccount
rm.BankAccounts = {}

--- Create Bank Account
--- @param accountId number The account ID.
--- @param data table The account data.
--- @return table The account obj.
function rm.createBankAccount(accountId, data)
    local account = {
        accountId = accountId,
        type = data.type or 1,
        owner = data.owner or "",
        label = data.label or "Compte Principal",
        pin = data.pin or 0000,
        balance = data.balance or 0,
        state = data.state or 1
    }

    --- Get Account ID
    --- @return number Account ID.
    function account.getAccountId()
        return account.accountId
    end

    --- Get Account Type
    --- @return number Account type.
    function account.getType()
        return account.type
    end

    --- Set Account Type
    --- @param type number Account type.
    --- @return boolean Return true if type is set.
    function account.setType(type)
        if type(type) ~= "number" then
            rm.Io.Error("Invalid 'type' argument. Expected number.")
            return false
        end
        account.type = type
        return true
    end

    --- Get Account Owner
    --- @return string Account owner.
    function account.getOwner()
        return account.owner
    end

    --- Set Account Owner
    --- @param owner string Account owner.
    --- @return boolean Return true if owner is set.
    function account.setOwner(owner)
        if type(owner) ~= "string" then
            rm.Io.Error("Invalid 'owner' argument. Expected string.")
            return false
        end
        account.owner = owner
        return true
    end

    --- Get Account Label
    --- @return string Account label.
    function account.getLabel()
        return account.label
    end

    --- Set Account Label
    --- @param label string Account label.
    --- @return boolean Return true if label is set.
    function account.setLabel(label)
        if type(label) ~= "string" then
            rm.Io.Error("Invalid 'label' argument. Expected string.")
            return false
        end
        account.label = label
        return true
    end

    --- Get Account PIN
    --- @return number Account PIN.
    function account.getPin()
        return account.pin
    end

    --- Set Account PIN
    --- @param pin number Account PIN.
    --- @return boolean Return true if PIN is set.
    function account.setPin(pin)
        if type(pin) ~= "number" then
            rm.Io.Error("Invalid 'pin' argument. Expected number.")
            return false
        end
        account.pin = pin
        return true
    end

    --- Get Account Balance
    --- @return number Account balance.
    function account.getBalance()
        return account.balance
    end

    --- Set Account Balance
    --- @param balance number Account balance.
    --- @return boolean Return true if balance is set.
    function account.setBalance(balance)
        if type(balance) ~= "number" then
            rm.Io.Error("Invalid 'balance' argument. Expected number.")
            return false
        end
        account.balance = balance
        return true
    end

    --- Add Money to Account
    --- @param amount number Amount to add.
    --- @return boolean Return true if money is added.
    function account.addMoney(amount)
        if type(amount) ~= "number" then
            rm.Io.Error("Invalid 'amount' argument. Expected number.")
            return false
        end
        account.balance = account.balance + amount
        return true
    end

    --- Remove Money from Account
    --- @param amount number Amount to remove.
    --- @return boolean Return true if money is removed.
    function account.removeMoney(amount)
        if type(amount) ~= "number" then
            rm.Io.Error("Invalid 'amount' argument. Expected number.")
            return false
        end
        if account.balance >= amount then
            account.balance = account.balance - amount
            return true
        end
        return false -- Insufficient funds
    end

    --- Get Account State
    --- @return number Account state.
    function account.getState()
        return account.state
    end

    --- Set Account State
    --- @param state number Account state.
    --- @return boolean Return true if state is set.
    function account.setState(state)
        if type(state) ~= "number" then
            rm.Io.Error("Invalid 'state' argument. Expected number.")
            return false
        end
        account.state = state
        return true
    end

    --- Check if Account is Active
    --- @return boolean Return true if account is active.
    function account.isActive()
        return account.state == 1
    end

    --- Add Transaction to Account
    --- @param type number Transaction type.
    --- @param label string Transaction label.
    --- @param amount number Transaction amount.
    --- @return boolean Return true if transaction is added.
    function account.addTransaction(type, label, amount)
        if type(type) ~= "number" or type(label) ~= "string" or type(amount) ~= "number" then
            rm.Io.Error("Invalid transaction arguments.")
            return false
        end

        local success, result = pcall(function()
            return MySQL.Sync.execute("INSERT INTO rm_bankaccounts_transaction (accountId, type, label, amount) VALUES (?, ?, ?, ?)", {
                account.accountId,
                type,
                label,
                amount
            })
        end)

        if success and result > 0 then
            rm.Io.Trace("Transaction added for account " .. account.accountId)
            return true
        else
            rm.Io.Warn("Failed to add transaction for account " .. account.accountId)
            return false
        end
    end

    --- Update Account in Database
    --- @return boolean Return true if account is updated successfully.
    function account.updateData()
        local success, result = pcall(function()
            return MySQL.Sync.execute("UPDATE rm_bankaccounts SET type = ?, owner = ?, label = ?, pin = ?, balance = ?, state = ? WHERE accountId = ?", {
                account.type,
                account.owner,
                account.label,
                account.pin,
                account.balance,
                account.state,
                account.accountId
            })
        end)

        if success and result > 0 then
            rm.Io.Trace("Bank account data updated for " .. account.label)
            return true
        else
            rm.Io.Warn("Bank account data not updated for " .. account.label .. ". Error: " .. tostring(result))
            return false
        end
    end

    rm.Io.Trace("Bank account created: " .. account.label)
    return account
end

--- Add Bank Account
--- @param accountId number The account ID.
--- @param data table The account data.
--- @return boolean Return true if the account is added.
function rm.addBankAccount(accountId, data)
    if rm.BankAccounts[accountId] then
        rm.Io.Warn("The bank account already exists.")
        return false
    end

    local account = rm.createBankAccount(accountId, data)
    rm.BankAccounts[accountId] = account
    return true
end

--- Get Bank Account
--- @param accountId number The account ID.
--- @return table Return the account.
function rm.getBankAccount(accountId)
    return rm.BankAccounts[accountId]
end

--- Remove Bank Account
--- @param accountId number The account ID.
function rm.removeBankAccount(accountId)
    if rm.BankAccounts[accountId] then
        rm.BankAccounts[accountId] = nil
        rm.Io.Trace("Bank account removed: " .. tostring(accountId))
    else
        rm.Io.Warn("Attempted to remove non-existent bank account: " .. tostring(accountId))
    end
end

--- Load All Bank Accounts from Database
function rm.loadBankAccounts()
    MySQL.query('SELECT * FROM rm_bankaccounts', {}, function(accounts)
        if accounts then
            for _, accountData in ipairs(accounts) do
                rm.addBankAccount(accountData.accountId, {
                    type = accountData.type,
                    owner = accountData.owner,
                    label = accountData.label,
                    pin = accountData.pin,
                    balance = accountData.balance,
                    state = accountData.state
                })
            end
            rm.Io.Trace("Loaded " .. #accounts .. " bank accounts from database")
        else
            rm.Io.Error("Failed to load bank accounts from database")
        end
    end)
end 
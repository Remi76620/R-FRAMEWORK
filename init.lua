--- RM-Framework
--- @class rm
--- @field IO table RM-Framework IO
--- @field Enums table RM-Framework Enums
--- @field Event table RM-Framework Event
--- @field Callback table RM-Framework Callback
--- @field Function table RM-Framework Function
--- @field Players table RM-Framework Players
--- @field Ranks table RM-Framework Ranks
--- @field BankAccounts table RM-Framework Bank Accounts
--- @field Bans table RM-Framework Bans
rm = {}

--- RM-Framework IO
--- @class rm.IO
--- @field Trace fun(message:string):void Trace message
--- @field Warn fun(message:string):void Warn message
--- @field Error fun(message:string):void Error message
--- @field Info fun(message:string):void Info message
--- @field Success fun(message:string):void Success message
rm.Io = rm.Io or {}

--- RM-Framework Enums
--- @class rm.Enums
--- @field Color table RM-Framework Color
rm.Enums = rm.Enums or {}

--- RM-Framework Event
--- @class rm.Event
--- @field Register fun(eventName:string, callback:function):void Register event
--- @field Trigger fun(eventName:string, ...):void Trigger event
--- @field TriggerServer fun(eventName:string, ...):void Trigger server event
--- @field TriggerClient fun(eventName:string, ...):void Trigger client event
rm.Event = rm.Event or {}

--- RM-Framework Function
--- @class rm.Function
--- @field requestModel fun(model:string):boolean Request model
--- @field setPlayerModel fun(player:number, model:string):boolean Set Player Model
--- @field setEntityCoords fun(entity:number, x:number, y:number, z:number, deadFlag:boolean, ragdollFlag:boolean, clearArea:boolean):boolean Set Entity Coordinates
--- @field setEntityHeading fun(entity:number, heading:number):boolean Set Entity Heading
--- @field loadingShow fun():void Show loading screen
--- @field loadingHide fun():void Hide loading screen
rm.Function = rm.Function or {}

--- RM-Framework Players
--- @class rm.Players
--- @field createPlayer fun(source:number, data:table):table Create player
--- @field addPlayer fun(source:number, data:table):boolean Add player
--- @field getPlayer fun(source:number):table Get player
--- @field removePlayer fun(source:number):void Remove player
rm.Players = rm.Players or {}

--- RM-Framework Ranks
--- @class rm.Ranks
--- @field createRank fun(id:string, data:table):table Create rank
--- @field addRank fun(id:string, data:table):boolean Add rank
--- @field getRank fun(id:string):table Get rank
--- @field removeRank fun(id:string):void Remove rank
--- @field loadRanks fun():void Load ranks from database
--- @field loadPermissions fun():void Load permissions from database
rm.Ranks = rm.Ranks or {}

--- RM-Framework Bank Accounts
--- @class rm.BankAccounts
--- @field createBankAccount fun(accountId:number, data:table):table Create bank account
--- @field addBankAccount fun(accountId:number, data:table):boolean Add bank account
--- @field getBankAccount fun(accountId:number):table Get bank account
--- @field removeBankAccount fun(accountId:number):void Remove bank account
--- @field loadBankAccounts fun():void Load bank accounts from database
rm.BankAccounts = rm.BankAccounts or {}

--- RM-Framework Bans
--- @class rm.Bans
--- @field createBan fun(identifier:string, data:table):table Create ban
--- @field addBan fun(identifier:string, data:table):boolean Add ban
--- @field getBan fun(identifier:string):table Get ban
--- @field removeBan fun(identifier:string):void Remove ban
--- @field isPlayerBanned fun(identifier:string):boolean Check if player is banned
--- @field banPlayer fun(identifier:string, name:string, reason:string, moderator:string, time:string):boolean Ban player
--- @field unbanPlayer fun(identifier:string):boolean Unban player
--- @field loadBans fun():void Load bans from database
rm.Bans = rm.Bans or {}

Ctz = Citizen
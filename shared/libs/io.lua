--- Format console messages with color
--- @vararg any Messages to format
local function formatConsoleMsg(...)
    local args = {...}
    local colorDefault = rm.Enums.Color["Default"]
    for i = 1, #args do
        if args[i] ~= nil then
            args[i] = ("%s%s%s"):format(colorDefault, args[i], colorDefault)
        end
    end
    return table.concat(args)
end

local LogLevels = {
    TRACE = {color = rm.Enums.Color["Purple"], prefix = "TRACE"},
    DEBUG = {color = rm.Enums.Color["Purple"], prefix = "DEBUG"},
    INFO = {color = rm.Enums.Color["Cyan"], prefix = "INFO"},
    WARN = {color = rm.Enums.Color["Yellow"], prefix = "WARN"},
    ERROR = {color = rm.Enums.Color["Red"], prefix = "ERROR"}
}

--- Log a message to the console
--- @param level string The log level
--- @vararg any Messages to log
local function log(level, ...)
    if level == "DEBUG" and not Config.Debug then return end

    local args = {...}
    local levelConfig = LogLevels[level]
    args[1] = ("[%s%s%s] %s"):format(levelConfig.color, levelConfig.prefix, rm.Enums.Color["Default"], args[1])
    print(formatConsoleMsg(table.unpack(args)))
end

function rm.Io.Trace(...) log("TRACE", ...) end
function rm.Io.Debug(...) log("DEBUG", ...) end
function rm.Io.Info(...) log("INFO", ...) end
function rm.Io.Warn(...) log("WARN", ...) end
function rm.Io.Error(...) log("ERROR", ...) end

Trace = rm.Io.Trace
Debug = rm.Io.Debug
Info = rm.Io.Info
Warn = rm.Io.Warn
Error = rm.Io.Error
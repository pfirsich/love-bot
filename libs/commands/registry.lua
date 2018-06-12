local registry = {}

local entries = {}

function registry.add(patterns, func, commandName, helpText)
    if type(patterns) ~= "table" then
        patterns = {patterns}
    end

    table.insert(entries, {
        patterns = patterns,
        func = func,
        commandName = commandName,
        helpText = helpText,
    })
end

function registry.processMessage(message)
    for _, entry in ipairs(entries) do
        for _, pattern in ipairs(entry.patterns) do
            local match = {message.content:match(pattern)}
            if #match > 0 then
                local response = entry.func(message, unpack(match))
                if response then
                    message.channel:send(response)
                end
                break
            end
        end
    end
end

local function entryCmp(a, b)
    if a.commandName == nil then
        return true
    elseif b.commandName == nil then
        return false
    else
        return a.commandName < b.commandName
    end
end

registry.add("^!help%s*.*", function()
    table.sort(entries, entryCmp)
    local ret = ""
    for _, entry in ipairs(entries) do
        if entry.commandName then
            ret = ret .. ("**%s**: %s\n"):format(entry.commandName, entry.helpText or "")
        end
    end
    return ret
end, "!help", "Display this help")

return registry
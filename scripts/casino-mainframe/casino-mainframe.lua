local CFG = {
    DEBUG="true",
    MONITOR_SIDE="right",
    MODEM_SIDE="top",
    HOSTNAME="Casino-MasterServer",
    PROTO={
        GET_MAINFRAME="Casino/mainframe/get",
        USER={
            NEW="Casino/user/new",
            INFO="Casino/user/info",
            TRANSACTION={
                GET="Casino/user/transaction/get",
                SUBTRACT="Casino/user/transaction/subtract",
                ADD="Casino/user/transaction/add"
            }
        }
    }
}

local function hostProto(proto)
    for k,v in pairs(proto) do
        if(type(v) == "table") then
            hostProto(v)
        else
            print("Now hosting ["..v.."]@["..CFG.HOSTNAME.."]")
            rednet.host(v, CFG.HOSTNAME)
        end
    end
end

local function getUserFromStorage(userId)
    if(userId == nil) then
        return nil
    end

    if(not fs.exists("users/"..userId..".dat")) then
        return nil
    end

    local userFile = fs.open("users/"..userId..".dat", "r")
    local user = textutils.unserialize(userFile.readAll())
    userFile.close()

    return user
end

--[[
    Userdata = {userId: number, name: string, currency: number}
]]
local function saveUserToStorage(userdata)
    local userFile = fs.open("users/"..userdata.userId..".dat", "w")
    userFile.write(textutils.serialize(userdata))
    userFile.close()
end

local function getHighestUserId()
    local highestId = 0
    for _,file in ipairs(fs.list("users")) do
        local userId = tonumber(string.match(file, "^%d+"))
        if(userId > highestId) then
            highestId = userId
        end
    end

    return highestId
end

local function startApi()
    local protocolHandlers = {}
    protocolHandlers[CFG.PROTO.GET_MAINFRAME] = function(sender, message)
        rednet.send(sender, os.getComputerID(), CFG.PROTO.GET_MAINFRAME)
    end

    protocolHandlers[CFG.PROTO.USER.NEW] = function(sender, message)
        local highestId = getHighestUserId()
        local newUserId = highestId + 1
        local newUser = {userId=newUserId, name="User"..newUserId, currency=250}
        print(textutils.serialize(newUser))
        saveUserToStorage(newUser)

        print("Created new user with id ["..newUserId.."]")

        rednet.send(sender, newUser, CFG.PROTO.USER.NEW)
    end

    protocolHandlers[CFG.PROTO.USER.INFO] = function(sender, message)
        local userId = message.userId
        local user = getUserFromStorage(userId)
        rednet.send(sender, user, CFG.PROTO.USER.INFO)
    end

    protocolHandlers[CFG.PROTO.USER.TRANSACTION.SUBTRACT] = function(sender, message)
        local userId = message.userId
        local amount = message.amount
        local user = getUserFromStorage(userId)

        if(user == nil) then
            rednet.send(sender, {error="User not found"}, CFG.PROTO.USER.TRANSACTION.SUBTRACT)
            return
        end

        if(user.currency < amount) then
            rednet.send(sender, {error="Insufficient funds"}, CFG.PROTO.USER.TRANSACTION.SUBTRACT)
            return
        end

        user.currency = user.currency - amount
        if(user.currency < 1) then
            user.currency = 1
        end
        saveUserToStorage(user)

        rednet.send(sender, user, CFG.PROTO.USER.TRANSACTION.SUBTRACT)
    end

    protocolHandlers[CFG.PROTO.USER.TRANSACTION.ADD] = function(sender, message)
        local userId = message.userId
        local amount = message.amount
        local user = getUserFromStorage(userId)

        if(user == nil) then
            rednet.send(sender, {error="User not found"}, CFG.PROTO.USER.TRANSACTION.ADD)
            return
        end

        user.currency = user.currency + amount
        saveUserToStorage(user)

        rednet.send(sender, user, CFG.PROTO.USER.TRANSACTION.ADD)
    end

    protocolHandlers[CFG.PROTO.USER.TRANSACTION.GET] = function(sender, message)
        local userId = message.userId
        local user = getUserFromStorage(userId)

        if(user == nil) then
            rednet.send(sender, {error="User not found"}, CFG.PROTO.USER.TRANSACTION.GET)
            return
        end

        rednet.send(sender, {currency=user.currency}, CFG.PROTO.USER.TRANSACTION.GET)
    end

    print("Starting Main Loop...")
    while(1==1) do
        local sender, message, protocol = rednet.receive()
        if(protocol ~= nil) then
            local handler = protocolHandlers[protocol]

            if(handler ~= nil) then
                local toPrint = "Handling ["..protocol.."] from ["..sender.."]"
                if(CFG.DEBUG == "true" and message ~= nil) then
                    toPrint = toPrint.." - "..textutils.serialize(message, {compact=true})
                end
                print(toPrint)
                handler(sender, message)
            else
                print("No handler found for protocol: " .. protocol)
            end
        end
    end
end

local function main()
    if(CFG.MONITOR_SIDE ~= nil) then
        local monitor = peripheral.wrap("right")
        monitor.setTextScale(0.5)
        term.redirect(monitor)
        term.clear()
        term.setCursorPos(1,1)
    end

    rednet.open(CFG.MODEM_SIDE)
    -- hostProto(CFG.PROTO)

    print("Starting API...")
    startApi()
end

main()

require("packet-handler/excavate")
require("packet-handler/tunnel")

local function handleFuel()
    local max = turtle.getFuelLimit()
    local current = turtle.getFuelLevel()

    if (current / max < 0.5) then
        turtle.refuel()
    end
end

local function handleForward(payload)
    handleFuel()

    if (payload == "forward") then
        turtle.forward()
    else
        for i = 1, tonumber(string.sub(payload, 9)) do
            turtle.forward()
        end
    end
end

local function handleRight(payload)
    handleFuel()

    if (payload == "right") then
        turtle.turnRight()
    else
        for i = 1, tonumber(string.sub(payload, 7)) do
            turtle.turnRight()
        end
    end
end

local function handleLeft(payload)
    handleFuel()

    if (payload == "left") then
        turtle.turnLeft()
    else
        for i = 1, tonumber(string.sub(payload, 6)) do
            turtle.turnLeft()
        end
    end
end

local function handleBack(payload)
    handleFuel()

    if (payload == "back") then
        turtle.back()
    else
        for i = 1, tonumber(string.sub(payload, 6)) do
            turtle.back()
        end
    end
end

local function handleUp(payload)
    handleFuel()

    if (payload == "up") then
        turtle.up()
    else
        for i = 1, tonumber(string.sub(payload, 4)) do
            turtle.up()
        end
    end
end

local function handleDown(payload)
    handleFuel()

    if (payload == "down") then
        turtle.down()
    else
        for i = 1, tonumber(string.sub(payload, 6)) do
            turtle.down()
        end
    end
end

local function handleRun(payload)
    parallel.waitForAny(function()
        shell.run(string.sub(payload, 5))
    end, function()
        while (1 == 1) do
            local _, packet = rednet.receive(PROTOCOL_NAME)
            if (packet.type == "BROADCAST" and packet.payload == "stop") then
                print("Stopped process")
                return
            end
        end
    end)
end

local function handleExcavate(payload)
    parallel.waitForAny(function()
        excavate(tonumber(string.sub(payload, 9)), false)
    end, function()
        while (1 == 1) do
            local _, packet = rednet.receive(PROTOCOL_NAME)
            if (packet.type == "BROADCAST" and packet.payload == "stop") then
                print("Stopped excavation")
                return
            end
        end
    end)
end

local function handleExcavateC(payload)
    parallel.waitForAny(function()
        excavate(tonumber(string.sub(payload, 10)), true)
    end, function()
        while (1 == 1) do
            local _, packet = rednet.receive(PROTOCOL_NAME)
            if (packet.type == "BROADCAST" and packet.payload == "stop") then
                print("Stopped excavation")
                return
            end
        end
    end)
end

local function handleTunnelUp(payload)
    parallel.waitForAny(function()
        tunnel(tonumber(string.sub(payload, 8)), false, true)
    end, function()
        while (1 == 1) do
            local _, packet = rednet.receive(PROTOCOL_NAME)
            if (packet.type == "BROADCAST" and packet.payload == "stop") then
                print("Stopped excavation")
                return
            end
        end
    end)
end

local function handleTunnel(payload)
    parallel.waitForAny(function()
        tunnel(tonumber(string.sub(payload, 7)), false, false)
    end, function()
        while (1 == 1) do
            local _, packet = rednet.receive(PROTOCOL_NAME)
            if (packet.type == "BROADCAST" and packet.payload == "stop") then
                print("Stopped excavation")
                return
            end
        end
    end)
end

local function handleReboot(payload)
    os.reboot()
end

local function handlePing(payload)
    send("PING", CLIENT_ID)
end

function handleBroadcast(payload)
    print("recv -> " .. payload)
    if (payload:find("^forward")) then
        handleForward(payload)
        return
    end

    if (payload:find("^back")) then
        handleBack(payload)
        return
    end

    if (payload:find("^left")) then
        handleLeft(payload)
        return
    end

    if (payload:find("^right")) then
        handleRight(payload)
        return
    end

    if (payload:find("^up") ~= nil) then
        handleUp(payload)
        return
    end

    if (payload:find("^down") ~= nil) then
        handleDown(payload)
        return
    end

    if (payload:find("^run") ~= nil) then
        handleRun(payload)
        return
    end

    if (payload:find("^excavatec") ~= nil) then
        handleExcavateC(payload)
        return
    end

    if (payload:find("^excavate") ~= nil) then
        handleExcavate(payload)
        return
    end

    if (payload:find("^tunnelup") ~= nil) then
        handleTunnelUp(payload)
        return
    end

    if (payload:find("^tunnel") ~= nil) then
        handleTunnel(payload)
        return
    end

    if (payload == "reboot") then
        handleReboot(payload)
        return
    end

    if (payload == "ping") then
        handlePing(payload)
        return
    end
end

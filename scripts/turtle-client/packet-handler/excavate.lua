local currentState
local relX = 0
local relY = 0
local relZ = 0
local lastX = 0
local lastY = 0
local lastZ = 0
local lastTurn = 0
local relTurn = 0

local function send(type, payload)
    local p = {}
    p.type = type
    p.payload = payload

    rednet.send(serverId, p, PROTOCOL_NAME)
end

local function setState(state)
    currentState = state
    print("Updated State to " .. currentState)
end

local function getFuelLevel()
    return turtle.getFuelLevel() / turtle.getFuelLimit()
end

local function forward()
    turtle.dig()
    turtle.forward()

    if(relTurn == 0) then
        relX = relX + 1
    elseif(relTurn == 1) then
        relZ = relZ + 1
    elseif(relTurn == 2) then
        relX = relX - 1
    elseif(relTurn == 3) then
        relZ = relZ - 1
    end
end

local function backward()
    turtle.back()

    if(relTurn == 0) then
        relX = relX - 1
    elseif(relTurn == 1) then
        relZ = relZ - 1
    elseif(relTurn == 2) then
        relX = relX + 1
    elseif(relTurn == 3) then
        relZ = relZ + 1
    end
end

local function up()
    if(turtle.detectUp()) then
        turtle.digUp()
    end
    turtle.up()
    relY = relY + 1
end

local function down()
    if(turtle.detectDown()) then
        turtle.digDown()
    end
    turtle.down()
    relY = relY - 1
end

local function turnLeft()
    turtle.turnLeft()
    relTurn = relTurn - 1

    if(relTurn < 0) then
        relTurn = 3
    end
end

local function turnRight()
    turtle.turnRight()
    relTurn = relTurn + 1

    if(relTurn > 3) then
        relTurn = 0
    end
end

local function moveToRel0()
    lastX = relX
    lastY = relY
    lastZ = relZ
    lastTurn = relTurn

    while(relY ~= 0) do
        if(relY > 0) then
            down()
        else
            up()
        end
    end

    if(relTurn ~= 0) then
        if(relTurn == 1) then
            turnLeft()
        elseif(relTurn == 2) then
            turnLeft()
            turnLeft()
        elseif(relTurn == 3) then
            turnRight()
        end
    end

    while(relX ~= 0) do
        if(relX > 0) then
            backward()
        else
            forward()
        end
    end

    turnRight()

    while(relZ ~= 0) do
        if(relZ > 0) then
            backward()
        else
            forward()
        end
    end

    turnLeft()

    return true
end

local function moveToLast()
    if(relTurn ~= 0) then
        if(relTurn == 1) then
            turnLeft()
        elseif(relTurn == 2) then
            turnLeft()
            turnLeft()
        elseif(relTurn == 3) then
            turnRight()
        end
    end

    if(relZ ~= lastZ) then
        turnRight()

        while(relZ ~= lastZ) do
            if(relZ > lastZ) then
                backward()
            else
                forward()
            end
            sleep(0)
        end

        turnLeft()
    end

    while(relX ~= lastX) do
        if(relX > lastX) then
            backward()
        else
            forward()
        end
        sleep(0)
    end

    while(relY ~= lastY) do
        if(relY > lastY) then
            down()
        else
            up()
        end
        sleep(0)
    end

    if(relTurn ~= lastTurn) then
        if(relTurn == 1) then
            turnLeft()
        elseif(relTurn == 2) then
            turnLeft()
            turnLeft()
        elseif(relTurn == 3) then
            turnRight()
        end
    end

    return true
end

local function handleIdle()
    setState(1)
end

local function excavateLayer(size)
    for i = 1, size do
        for j = 1, size do
            turtle.digDown()
            if(j ~= size) then
                forward()
            end
        end

        if(i ~= size) then
            if(i % 2 == 0) then
                turnLeft()
                forward()
                turnLeft()
            else
                turnRight()
                forward()
                turnRight()
            end
        else
            if(i % 2 ~= 0) then
                turnLeft()
                for j = 1, size - 1 do
                    forward()
                end
                turnLeft()
            else
                turnRight()
                for j = 1, size - 1 do
                    forward()
                end
                turnRight()
            end
        end

        sleep(0)
    end

    down()
end

local function needsDropoff()
    local blockedSlots = 0

    for i = 1, 16 do
        if(turtle.getItemCount(i) > 0) then
            blockedSlots = blockedSlots + 1
        end
    end

    return blockedSlots > 10
end

local function needRefuel()
    return getFuelLevel() < 0.2
end

local function handleExcavate(size)
    excavateLayer(size)

    if(needRefuel()) then
        setState(3)
        return
    end

    if(needsDropoff()) then
        setState(2)
        return
    end

    send("EXCAVATE_DEPTH", relY)
end

local function handleDropoff()
    moveToRel0()
    for i = 1, 10 do
        if(turtle.getItemCount(i) > 0) then
            turtle.select(i)
            turtle.dropUp()
        end
    end

    turtle.select(1)
    moveToLast()
    setState(1)
end

local function handleFuel()
    for i = 1, 16 do
        if(turtle.getItemCount(i) > 0 and getFuelLevel() < 0.5) then
            turtle.select(i)
            turtle.refuel()
        end
    end

    setState(1)
end

function excavate(size, continue)
    print("Excavating with size " .. tostring(size))

    -- States:
    --   -1 -> Finished
    --    0 -> Idle
    --    1 -> Excavating
    --    2 -> Dropoff
    --    3 -> Refueling
    currentState = 0
    relX = 0
    relY = 0
    relZ = 0

    if(continue) then
        while(not turtle.detectDown()) do
            down()
        end
    end

    while(currentState ~= -1) do
        if(currentState == 0) then
            handleIdle()
        elseif(currentState == 1) then
            handleExcavate(size)
        elseif(currentState == 2) then
            handleDropoff()
        elseif(currentState == 3) then
            handleFuel()
        end

        sleep(0)

        ::continue::
    end
end

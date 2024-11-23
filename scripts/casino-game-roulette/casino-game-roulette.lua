require("config")
require("views/default/view-utils")
require("views/default/error-screen")
require("views/default/idle-screen")
require("api/api")


local function getInventoryIn()
    return peripheral.wrap(CFG.CABLE.inventory_in)
end

local function getInventoryOut()
    return peripheral.wrap(CFG.CABLE.inventory_out)
end

local function getSpeaker()
    return peripheral.wrap(CFG.CABLE.speaker)
end

local function playInputSound(number)
    getSpeaker().playNote("hat", 1, 1)
    -- getSpeaker().playNote("hat", 1, (number/36)*12)
end

local function addNumberButton(number, x, y, onClick)
    local monitor = peripheral.wrap(CFG.CABLE.monitor_input)
    local toWrite = number

    if(tostring(number):len() == 1) then
        toWrite = " " .. number
    end

    monitor.setCursorPos(x, y)
    local backgroundColor = colors.red

    if(number % 2 == 0) then
        backgroundColor = colors.black
    end

    createButton({
        x=x,
        y=y,
        width=2,
        height=1,
        text=toWrite,
        action=onClick,
        foregroundColor=colors.white,
        backgroundColor=backgroundColor,
        monitor=CFG.CABLE.monitor_input,
        name="number_"..number
    })
end

local function renderPlayingBoard(S, onInput)
    local monitor = peripheral.wrap(CFG.CABLE.monitor_input)
    local lastTerm = term.redirect(monitor)
    monitor.setTextScale(1.5)
    term.setBackgroundColor(colors.orange)
    term.clear()

    term.setCursorPos(1, 1)

    local minX = 11
    local x = minX
    local y = 4

    clearButtons()

    createButton({
        x=minX,
        y=2,
        width=8,
        height=1,
        text="0",
        action=onInput,
        foregroundColor=colors.white,
        backgroundColor=colors.green,
        monitor=CFG.CABLE.monitor_input,
        name="number_0"
    })

    for i=1, 36 do
        addNumberButton(i, x, y, onInput)

        if(i % 3 == 0) then
            x = minX
            y = y + 2
        else
            x = x + 3
        end
    end

    local additionalButtonX = 2
    local additionalButtonY = 2
    local additionalButtons = {
        {label="1to18", name="1to18", backgroundColor=colors.green, foregroundColor=colors.white},
        {label="EVEN", name="even", backgroundColor=colors.green, foregroundColor=colors.white},
        {label="RED", name="red", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="BLACK", name="black", backgroundColor=colors.black, foregroundColor=colors.white},
        {label="ODD", name="odd", backgroundColor=colors.green, foregroundColor=colors.white},
        {label="19to36", name="19to36", backgroundColor=colors.green, foregroundColor=colors.white},
    }

    for _, button in ipairs(additionalButtons) do
        createButton({
            x=additionalButtonX,
            y=additionalButtonY,
            width=8,
            height=1,
            text=button.label,
            action=onInput,
            foregroundColor=button.foregroundColor,
            backgroundColor=button.backgroundColor,
            monitor=CFG.CABLE.monitor_input,
            name=button.name
        })
        additionalButtonY = additionalButtonY + 2
    end

    additionalButtonY = additionalButtonY - 2

    term.setCursorPos(2, additionalButtonY + 1)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.white)
    term.write("Bet: " .. S.totalBet)
    term.setCursorPos(2, additionalButtonY + 2)
    term.write(S.player.name)

    local chipsButtonX = 2
    local chipsButtonY = additionalButtonY + 4
    local chipsButtons = {
        {label="1", name="chip_1", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="5", name="chip_5", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="10", name="chip_10", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="25", name="chip_25", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="50", name="chip_50", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="100", name="chip_100", backgroundColor=colors.red, foregroundColor=colors.white},
    }
    local selectedChipsColor = colors.green

    for _, button in ipairs(chipsButtons) do
        local chipsColor = button.backgroundColor
        if(button.name == "chip_"..S.selectedChips) then
            chipsColor = selectedChipsColor
        end

        createButton({
            x=chipsButtonX,
            y=chipsButtonY,
            width=8,
            height=1,
            text=button.label,
            action=onInput,
            foregroundColor=button.foregroundColor,
            backgroundColor=chipsColor,
            monitor=CFG.CABLE.monitor_input,
            name=button.name
        })
        chipsButtonY = chipsButtonY + 2
    end

    renderButtons()

    term.redirect(lastTerm)
end

local function renderPlayerBets(S, x, y)
    term.setCursorPos(x, y)
    term.write("Bets")

    for userId, bets in pairs(S.bets) do
        term.setCursorPos(x, y + 2)
        term.write(userId)

        for number, amount in pairs(bets) do
            term.setCursorPos(x + 4, y + 2)
            term.write(number .. ": " .. amount)
            y = y + 1
        end
    end
end

local function renderPlayerTable(S, x, y, width, height)
    term.setCursorPos(x, y)
    term.write("Players")

    for _, player in pairs(S.players) do
        term.setCursorPos(x, y + 2)
        term.write(player.name .. " (" .. player.currency .. ")")
        y = y + 1
    end
end

local function renderBetsBoard(S, onInput)
    local monitor = peripheral.wrap(CFG.CABLE.monitor_bets)
    local lastTerm = term.redirect(monitor)
    monitor.setTextScale(1.5)
    local width, height = term.getSize()

    term.setBackgroundColor(colors.orange)
    term.clear()

    term.setCursorPos(1, 1)

    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 1)

    renderPlayerTable(S, 1, 1, 50, height)

    term.redirect(lastTerm)
end

local function main()
    local width, height = term.getSize()

    rednet.open(CFG.MODEM_SIDE)
    MAINFRAME_ID = getMainframeId()

    local totalBet = 0
    local bets = {}
    local players = {
        {userId= 65535, name="Player", currency=1000}
    }

    local currentPlayer = players[1]
    local selectedChips = 0

    while(1==1) do
        local currenState = {
            totalBet=totalBet,
            selectedChips=selectedChips,
            player=currentPlayer,
            players=players
        }

        renderPlayingBoard(currenState, function(button)
            print(button.name)

            if(button.name:match("^chip_")) then
                local chip = tonumber(button.name:sub(6))
                selectedChips = chip
            end

            if(button.name:match("^number_")) then
                local number = tonumber(button.name:sub(8))
                totalBet = totalBet + selectedChips

                if(not bets[currentPlayer.userId]) then
                    bets[currentPlayer.userId] = {}
                end

                bets[currentPlayer.userId][number] = (bets[currentPlayer.userId][number] or 0) + selectedChips
                print("Bet " .. currentPlayer.userId .. " " .. selectedChips .. "@" .. number .. "; total: " .. bets[currentPlayer.userId][number])
            end

            playInputSound(i)
        end)

        renderBetsBoard(currenState, function()
        
        end)

        listenToMonitorClick()
    end
end

main()

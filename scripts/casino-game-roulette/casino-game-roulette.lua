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

local function playErrorSound()
    getSpeaker().playNote("bass", 1, 1)
end

local function playFinishSound(number)
    getSpeaker().playNote("bell", 1, 1)
    -- getSpeaker().playNote("hat", 1, (number/36)*12)
end

local function addNumberButton(number, x, y, onClick, isSelected)
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

    if(isSelected) then
        backgroundColor = colors.yellow
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

    local filter = function(button)
        return button.monitor == CFG.CABLE.monitor_input
    end

    clearButtons(filter)

    local zeroColor = colors.green
    if(S.wonNr == 0) then
        zeroColor = colors.yellow
    end
    createButton({
        x=minX,
        y=2,
        width=8,
        height=1,
        text="0",
        action=onInput,
        foregroundColor=colors.white,
        backgroundColor=zeroColor,
        monitor=CFG.CABLE.monitor_input,
        name="number_0"
    })

    for i=1, 36 do
        addNumberButton(i, x, y, onInput, S.wonNr == i)

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
        --{label="1to18", name="1to18", backgroundColor=colors.green, foregroundColor=colors.white},
        --{label="EVEN", name="even", backgroundColor=colors.green, foregroundColor=colors.white},
        {label="RED", name="red", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="BLACK", name="black", backgroundColor=colors.black, foregroundColor=colors.white},
        --{label="ODD", name="odd", backgroundColor=colors.green, foregroundColor=colors.white},
        --{label="19to36", name="19to36", backgroundColor=colors.green, foregroundColor=colors.white},
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
        {label="1000", name="chip_1000", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="5000", name="chip_5000", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="10000", name="chip_10000", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="100000", name="chip_100000", backgroundColor=colors.red, foregroundColor=colors.white},
        {label="MAX", name="chipmax", backgroundColor=colors.red, foregroundColor=colors.white},
    }
    local selectedChipsColor = colors.green

    for _, button in ipairs(chipsButtons) do
        local chipsColor = button.backgroundColor
        if(button.name == "chip_"..S.selectedChips) then
            chipsColor = selectedChipsColor
        end

        if(button.name == "chipmax" and S.selectedChips == S.player.currency) then
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
        chipsButtonY = chipsButtonY + 1
    end

    renderButtons(filter)

    term.redirect(lastTerm)
end

local function renderPlayerBets(S, player, x, y, width, height)
    term.setCursorPos(x, y)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.white)
    if(S.player.userId == player.userId) then
        term.setTextColor(colors.green)
    end
    term.write(player.name)
    y = y + 1

    term.setCursorPos(x, y)
    term.write(player.currency)

    y = y + 2

    -- Render in a single column
    for i=0, 36 do
        local bet = (S.bets[player.userId] and S.bets[player.userId][i]) or 0

        if(bet > 0) then
            term.setCursorPos(x, y)
            term.setBackgroundColor(colors.orange)
            term.setTextColor(colors.white)
            term.write(i.." -> ".. math.floor(bet))
            y = y + 1
        end
    end
end

local function renderPlayerTable(S, x, y, width, height)
    term.setCursorPos(x, y)
    local widthPerPlayer = width / (CFG.GAME.MAX_PLAYERS + 1)

    for i, player in pairs(S.players) do
        renderPlayerBets(S, player, x + ((i - 1) * widthPerPlayer), y, widthPerPlayer, height)
    end
end

local function renderBetsBoard(S, onInput)
    local monitor = peripheral.wrap(CFG.CABLE.monitor_bets)
    local lastTerm = term.redirect(monitor)
    monitor.setTextScale(1.5)
    term.setBackgroundColor(colors.orange)
    term.clear()

    local width, height = term.getSize()
    local widthPerPlayer = width / (CFG.GAME.MAX_PLAYERS + 1)

    renderPlayerTable(S, 1, 1, 50, height)

    local filter = function(button)
        return button.monitor == CFG.CABLE.monitor_bets
    end

    clearButtons(filter)
    createButton({
        x=(widthPerPlayer * CFG.GAME.MAX_PLAYERS) + 1,
        y=height - 2,
        width=widthPerPlayer,
        height=3,
        text="Next",
        action=onInput,
        foregroundColor=colors.white,
        backgroundColor=colors.green,
        monitor=CFG.CABLE.monitor_bets,
        name="next"
    })
    renderButtons(filter)

    term.redirect(lastTerm)
end

local function getLoggedInPlayers()
    local players = {}

    for _, files in pairs(CFG.FILES) do
        if(fs.exists(files.LOGON)) then
            local file = fs.open(files.LOGON, "r")
            local data = textutils.unserialize(file.readAll())
            file.close()

            table.insert(players, data)
        end
    end

    return players
end

local function waitForPlayers()
    while(true) do
        local players = getLoggedInPlayers()
        if(#players == 0) then
            local monitor = peripheral.wrap(CFG.CABLE.monitor_bets)
            local lastTerm = term.redirect(monitor)
            showIdleScreen()
            monitor = peripheral.wrap(CFG.CABLE.monitor_input)
            term.redirect(monitor)
            showIdleScreen()
            monitor = peripheral.wrap(CFG.CABLE.monitor_wheel)
            term.redirect(monitor)
            term.setBackgroundColor(colors.green)
            term.clear()
            term.redirect(lastTerm)
        else
            local resolvedPlayers = {}

            for _, player in pairs(players) do
                if(player.userId) then
                    local fetchedInfo = user_infoForId(player.userId)

                    if(fetchedInfo ~= nil) then
                        table.insert(resolvedPlayers, fetchedInfo)
                    end
                end
            end

            if(#resolvedPlayers > 0) then
                return resolvedPlayers
            end
        end

        os.pullEvent("disk")
    end
end

local function drawNumberOnWheel(number)
    local monitor = peripheral.wrap(CFG.CABLE.monitor_wheel)
    local color = colors.black
    if(number % 2 == 0) then
        color = colors.red
    end

    if(number == 0) then
        color = colors.green
    end

    local width, height = monitor.getSize()
    monitor.setBackgroundColor(color)
    monitor.setTextScale(5)
    monitor.clear()
    monitor.setCursorPos(width / 2, (height / 2) + 1)
    monitor.write(number)
end

local function spinWheel()
    local wheel = {0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26}
    local speed = 0.01
    local steps = math.random(CFG.GAME.WHEEL_STEPS_MIN, CFG.GAME.WHEEL_STEPS_MAX)
    local currentOffset = math.random(1, #wheel)

    for i=1, steps do
        if(i > steps - 14) then
            speed = speed * 1.5
        end

        currentOffset = currentOffset + 1
        if(currentOffset > #wheel) then
            currentOffset = 1
        end

        drawNumberOnWheel(wheel[currentOffset])

        if(i ~= steps) then
            os.sleep(speed)
            playInputSound()
        end
    end

    playFinishSound()
    return wheel[currentOffset]
end

local getBetsWon = function(wonNr, bets)
    local playerWonAmount = {}

    for userId, playerBets in pairs(bets) do
        local playerWon = 0

        for number, amount in pairs(playerBets) do
            if(number == wonNr) then
                playerWon = playerWon + (amount * 36)
            end
        end

        if(playerWon > 0) then
            playerWonAmount[userId] = playerWon
        end
    end

    return playerWonAmount
end

local function runMainLoop()
    local width, height = term.getSize()
    local currentPlayerIndex = 1
    local currentPlayer = nil
    local totalBet = 0
    local bets = {}
    local betsWon = {}
    local selectedChips = 0
    local wonNr = -1
    local currentState
    local actions

    while(1==1) do
        local players = waitForPlayers()

        if(currentPlayer == nil) then
            currentPlayerIndex = 1
            currentPlayer = players[currentPlayerIndex]
            bets[currentPlayer.userId] = nil
            totalBet = 0
            selectedChips = 0
        end

        if(currentState) then
            actions = currentState.actions
        end

        if(actions) then
            if(actions.next) then
                currentPlayerIndex = currentPlayerIndex + 1
                if(currentPlayerIndex > #players) then
                    currentPlayerIndex = 1

                    for userId, number in pairs(bets) do
                        local totalToSubtract = 0
                        for number, amount in pairs(number) do
                            totalToSubtract = totalToSubtract + amount
                        end
                        transaction_Subtract(userId, totalToSubtract)
                    end

                    wonNr = spinWheel()
                    betsWon = getBetsWon(wonNr, bets)

                    for userId, amount in pairs(betsWon) do
                        transaction_Add(userId, amount)
                    end

                    print(textutils.serialise(betsWon))

                    bets = {}
                    players = waitForPlayers()
                end

                currentPlayer = players[currentPlayerIndex]
                bets[currentPlayer.userId] = nil
                totalBet = 0
                selectedChips = 0
            end
        end

        currentState = {
            bets=bets,
            totalBet=totalBet,
            selectedChips=selectedChips,
            player=currentPlayer,
            players=players,
            actions={
                next=false
            },
            wonNr=wonNr
        }

        renderPlayingBoard(
            currentState,
            function(button)
                wonNr = -1

                if(button.name:match("^chip_")) then
                    local chip = tonumber(button.name:sub(6))
                    selectedChips = chip
                end

                if(button.name == "chipmax") then
                    selectedChips = currentPlayer.currency - totalBet
                end

                if(button.name:match("^number_")) then
                    if(selectedChips == 0) then
                        playErrorSound()
                        return
                    end

                    local number = tonumber(button.name:sub(8))

                    if(totalBet + selectedChips > currentPlayer.currency) then
                        playErrorSound()
                        return
                    end

                    totalBet = totalBet + selectedChips

                    if(not bets[currentPlayer.userId]) then
                        bets[currentPlayer.userId] = {}
                    end

                    bets[currentPlayer.userId][number] = (bets[currentPlayer.userId][number] or 0) + selectedChips
                    print("Bet " .. currentPlayer.userId .. " " .. selectedChips .. "@" .. number .. "; total: " .. bets[currentPlayer.userId][number])
                end

                if(button.name == "red") then
                    if(totalBet + selectedChips > currentPlayer.currency) then
                        playErrorSound()
                        return
                    end

                    totalBet = totalBet + selectedChips
                    bets[currentPlayer.userId] = bets[currentPlayer.userId] or {}
                    for i=1, 36 do
                        if(i % 2 == 0) then
                            bets[currentPlayer.userId][i] = (bets[currentPlayer.userId][i] or 0) + selectedChips/18
                        end
                    end
                end

                if(button.name == "black") then
                    if(totalBet + selectedChips > currentPlayer.currency) then
                        playErrorSound()
                        return
                    end

                    totalBet = totalBet + selectedChips
                    bets[currentPlayer.userId] = bets[currentPlayer.userId] or {}
                    for i=1, 36 do
                        if(i % 2 == 1) then
                            bets[currentPlayer.userId][i] = (bets[currentPlayer.userId][i] or 0) + selectedChips/18
                        end
                    end
                end

                playInputSound(i)
            end
        )

        renderBetsBoard(
            currentState,
            function(button)
                if(button.name == "next") then
                    currentState.actions.next = true
                end
            end
        )

        parallel.waitForAny(
            function()
                listenToMonitorClick()
            end,
            function()
                os.pullEvent("disk_eject")
                currentPlayer = nil
            end,
            function()
                os.pullEvent("disk")
                currentPlayer = nil
            end
        )
    end
end

local function main()
    runMainLoop()
end

main()

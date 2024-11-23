local function printBackground()
    local width, height = term.getSize()

    for x=1, width do
        for y=1, height do
            term.setCursorPos(x, y)

            term.setBackgroundColor(colors.orange)

            term.write(" ")
        end
    end
end

function showPlayScreen(_GS, onError)
    local width, height = term.getSize()
    local result = nil

    result = transaction_Subtract(_GS.player.userId, _GS.currentBet)
    if(result.error ~= nil) then
        onError(result.error)
        return
    end

    local card = math.random(1, 13)
    local currentBet = _GS.currentBet
    local lost = false

    while(1==1) do
        local input = nil
        printBackground()
        term.setBackgroundColor(colors.orange)
        term.setTextColor(colors.white)

        clearButtons()
        -- the higher the difference to max or min the higher
        local higherMultiplier = 1.25 + (card - 1) * (2 - 1.25) / (13 - 1)
        local lowerMultiplier = 1.25 + (13 - card) * (2 - 1.25) / (13 - 1)

        if(lost == false) then
            createButton(2, height - 8, width - 2, 3, "Higher (x"..(math.floor(higherMultiplier*100)/100)..")", function()
                input = "higher"
            end, colors.white, colors.green)

            createButton(2, height - 4, width - 2, 3, "Lower (x"..(math.floor(lowerMultiplier * 100)/100)..")", function()
                input = "lower"
            end, colors.white, colors.red)

            createButton(2, height, width - 2, 1, "Stop", function()
                input = "stop"
            end, colors.white, colors.gray)
        else
            createButton(2, height - 4, width - 2, 3, "Quit", function()
                input = "quit"
            end, colors.white, colors.gray)
        end

        centerPrint(currentBet, 1, colors.white, colors.orange)
        centerPrint("Values are from 1-13", 2, colors.white, colors.orange)
        fullCenterPrint(card, colors.white, colors.orange)

        renderButtons()
        listenToMonitorClick()

        if(input ~= nil) then
            if(input == "stop") then
                transaction_Add(_GS.player.userId, currentBet)

                if(result.error ~= nil) then
                    onError(result.error)
                    return
                end
                return
            end

            if(input == "quit") then
                return
            end

            local oldCard = card
            card = math.random(1, 13);


            if(not lost and (input == "higher" and card >= oldCard) or (input == "lower" and card <= oldCard)) then
                local multiplier = higherMultiplier
                if(input == "lower") then
                    multiplier = lowerMultiplier
                end

                currentBet = math.ceil(currentBet * multiplier)
            else
                lost = true
            end
        end
    end
end
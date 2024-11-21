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
    local input = nil
    local currentBet = _GS.currentBet
    local lost = false

    while(1==1) do
        printBackground()
        term.setBackgroundColor(colors.orange)
        term.setTextColor(colors.white)

        clearButtons()

        if(lost == false) then
            createButton(2, height - 8, width - 2, 3, "Higher", function()
                input = "higher"
            end, colors.white, colors.green)

            createButton(2, height - 4, width - 2, 3, "Lower", function()
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
        centerPrint("Values are from 1-13: ", 2, colors.white, colors.orange)
        fullCenterPrint(card, colors.white, colors.orange)

        renderButtons()
        listenToMonitorClick()

        if(input ~= nil) then
            if(input == "stop") then
                transaction_Add(_GS.player.userId, currentBet * 2)

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


            if((input == "higher" and card >= oldCard) or (input == "lower" and card <= oldCard)) then
                currentBet = currentBet * 2
            else
                lost = true
            end
        end
    end
end
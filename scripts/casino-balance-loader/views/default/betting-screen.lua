--[[
    data = {currentBet: number, player: {name: string, currency: number}}
]]
function renderBettingScreen(data, onBetUpdated, onContinue, onQuit)
    local width, height = term.getSize()

    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.white)
    term.clear()

    clearButtons()
    -- Increase and decrease bet buttons
    createButton(term.getSize() - 2, 1, 1, 1, "+", function()
        onBetUpdated(data.currentBet + 10)
    end, colors.white, colors.green)

    createButton(term.getSize(), 1, 1, 1, "*", function()
        onBetUpdated(data.currentBet * 2)
    end, colors.white, colors.green)

    createButton(term.getSize() - 2, 2, 3, 1, "max", function()
        onBetUpdated(data.player.currency)
    end, colors.white, colors.green)

    createButton(1, 2, 3, 1, "min", function()
        onBetUpdated(CFG.GAME.MIN_BET)
    end, colors.white, colors.red)

    createButton(1, 1, 1, 1, "/", function()
        onBetUpdated(math.floor(data.currentBet / 2))
    end, colors.white, colors.red)

    createButton(3, 1, 1, 1, "-", function()
        onBetUpdated(data.currentBet - 10)
    end, colors.white, colors.red)

    centerPrint(data.currentBet, 1, colors.white, colors.orange)
    centerPrint(data.player.currency, 2, colors.gray, colors.orange)
    
    local btnWidth = width - 2
    createButton((width / 2) - (btnWidth / 2) + 1, height - 10, btnWidth, 5, "Continue", function()
        onContinue()
    end, colors.white, colors.green)


    createButton((width / 2) - (btnWidth / 2) + 1, height - 5, btnWidth, 5, "Quit", function()
        onQuit()
    end, colors.white, colors.red)
    renderButtons()

    term.setCursorPos(1, height)
    term.setBackgroundColor(colors.orange)
    term.write(data.player.name)
end
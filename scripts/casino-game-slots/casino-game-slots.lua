require("config")
require("views/default/view-utils")

local monitor

local function main()
    monitor = peripheral.wrap(CFG.MONITOR_SIDE)
    term.redirect(monitor)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.white)
    term.clear()

    local width, height = term.getSize()

    rednet.open(CFG.MODEM_SIDE)

    local state = redstone.getOutput(CFG.REDSTONE_SIDE)

    while(1==1) do
        local buttonColor = colors.green

        if(not state) then
            buttonColor = colors.red
        end

        clearButtons()
        createButton(
            2, 2,
            width - 2, height - 2,
            "OIDA",
            function()
                state = not state
                redstone.setOutput(CFG.REDSTONE_SIDE, state)
            end,
            colors.white,
            buttonColor
        )
        renderButtons()
        listenToMonitorClick()
    end
end

main()

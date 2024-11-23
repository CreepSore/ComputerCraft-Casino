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

local function playLoginSound()
    local speaker = getSpeaker()
    speaker.playSound("minecraft:block.note_block.pling", 1, 1)
end

local function playLogoutSound()
    local speaker = getSpeaker()
    speaker.playSound("minecraft:block.note_block.bass", 1, 1)
end

local function logonWrapper(logonCallback)
    showIdleScreen()
    if(not fs.exists("disk")) then
        os.pullEvent("disk")
    end

    if(not isLoggedIn()) then
        showErrorScreen("Not logged in")
        playLogoutSound()
        os.pullEvent("disk_eject")
        return
    end

    local player = user_info()
    playLoginSound()
    logonCallback(player)

    os.pullEvent("disk_eject")
end

local function getRainbowColor(index)
    local rainbowColors = {
        colors.red,
        colors.yellow,
        colors.lime,
        colors.green,
        colors.lightBlue,
        colors.blue,
        colors.purple,
        colors.magenta,
        colors.pink,
        colors.brown,
        colors.white,
        colors.lightGray,
        colors.gray,
        colors.cyan,
        colors.black
    }
    return rainbowColors[(index % #rainbowColors) + 1]
end

local function getBalanceInInventory()
    local inventory = getInventoryIn()
    local balance = 0

    for _, inventory in pairs(inventory.list()) do
        for key, item in pairs(CFG.mapping) do
            if(inventory.name == key) then
                balance = balance + (inventory.count * item.amount)
            end
        end
    end

    return balance
end

local function renderMenuScreen(player, onCashIn)
    term.setBackgroundColor(colors.orange)
    term.clear()

    term.setCursorPos(1, 1)
    term.write("Balance: " .. player.currency)

    term.setCursorPos(1, 3)

    local sorted = {}
    for _, item in pairs(CFG.mapping) do
        table.insert(sorted, item)
    end
    table.sort(sorted, function(a, b)
        return a.amount < b.amount
    end)

    for index, item in pairs(sorted) do
        term.setTextColor(getRainbowColor(index))
        print(item.name .. ": " .. item.amount)
    end

    term.setCursorPos(1, 3 + #sorted + 2)
    print("Inventory: " .. getBalanceInInventory())

    clearButtons()
    createButton(2, 3 + #sorted + 4, 0, -1, "Cash-In", function()
        onCashIn()
    end, colors.white, colors.green)

    renderButtons()
end

local function main()
    monitor = peripheral.wrap(CFG.CABLE.monitor)
    monitor.setTextScale(0.5)
    term.redirect(monitor)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.white)
    term.clear()

    local width, height = term.getSize()

    rednet.open(CFG.MODEM_SIDE)
    MAINFRAME_ID = getMainframeId()

    while true do
        parallel.waitForAny(function()
            logonWrapper(function(player)
                parallel.waitForAny(
                    function()
                        while(true) do
                            renderMenuScreen(player, function()
                                local inv = getInventoryIn()
                                local balance = getBalanceInInventory()
                                for slot, inventory in pairs(inv.list()) do
                                    if CFG.mapping[inventory.name] then
                                        inv.pushItems(CFG.CABLE.inventory_out, slot, inventory.count)
                                    end
                                end

                                local result = transaction_Add(player.userId, balance)
                                if(result ~= nil and result.error ~= nil) then
                                    showErrorScreen(result.error)
                                else
                                    player.currency = player.currency + balance
                                end
                            end)
                            os.sleep(0.1)
                        end
                    end,
                    function()
                        while(true) do
                            local event, button, xPos, yPos = os.pullEvent("monitor_touch")
                            handleMonitorClick(xPos, yPos)
                        end
                    end
                )
            end)
        end, function()
            os.pullEvent("disk_eject")
            playLogoutSound()
        end)
    end
end

main()

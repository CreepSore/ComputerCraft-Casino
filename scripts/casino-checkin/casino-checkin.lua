require("config")
require("/scripts/ui-lib/handlers/ui-handler")
require("/scripts/ui-lib/handlers/window-handler")
require("/scripts/ui-lib/elements/containers/panel")
require("/scripts/ui-lib/elements/containers/grid")
require("/scripts/ui-lib/elements/button")

local function getSpeaker()
    return peripheral.wrap(CFG.DEVICES.SPEAKER)
end

function playLoginSound()
    getSpeaker().playSound("minecraft:block.note_block.pling", 1, 1)
end

function playLogoutSound()
    getSpeaker().playSound("minecraft:block.note_block.bass", 1, 1)
end

function loadPlayerInfo()
    if(not fs.exists(CFG.FILES.LOGON)) then
        return nil
    end

    local file = fs.open(CFG.FILES.LOGON, "r")
    local data = textutils.unserialise(file.readAll())
    file.close()

    return data
end

function idleWindow(windowHandler)
    local panel = Panel:new({
        x=1,
        y=1,
        backgroundColor=colors.orange,
        dock="fill"
    })

    local labelHello = Text:new({
        text="Hello, please insert your card.",
        anchor="center",
        autosize=true
    })

    panel:addChild(labelHello)

    windowHandler:registerWindow("idle", panel)
end

function logonWindow(uiHandler, windowHandler)
    local panel = Panel:new({
        x=1,
        y=1,
        backgroundColor=colors.orange,
        dock="fill"
    })

    local labelWelcome = Text:new({
        y=-5,
        text="",
        anchor="center",
        maxWidth = 30,
        update=function(self)
            self:setText("Welcome " .. uiHandler.state.player.name .. "! Your balance is " .. uiHandler.state.player.currency .. "!")
        end
    })

    local labelInput = Text:new({
        text="Please deposit one Allthemodium ingot on the pedestal.",
        anchor="center",
        maxWidth = 30,
    })

    panel:addChild(labelWelcome)
    panel:addChild(labelInput)

    windowHandler:registerWindow("logon", panel)
end

function getItemFromPedestal()
    local pedestal = peripheral.wrap(CFG.DEVICES.IN_PEDESTAL)
    local item = pedestal.list()[1]

    if(item == nil) then
        return nil
    end

    return item
end

function movePedestalItemToOutput()
    local pedestal = peripheral.wrap(CFG.DEVICES.IN_PEDESTAL)

    pedestal.pushItems(CFG.DEVICES.OUT_INVENTORY, 1, 1, 1)
end

function triggerDropper()
    redstone.setOutput(CFG.DEVICES.DROPPER, true)
    sleep(0.5)
    redstone.setOutput(CFG.DEVICES.DROPPER, false)
end

function main()
    local uiHandler = UiHandler:new()
    local windowHandler = WindowHandler:new()

    idleWindow(windowHandler)
    logonWindow(uiHandler, windowHandler)

    uiHandler:setWindowHandler(windowHandler)
    uiHandler.monitor = peripheral.wrap(CFG.DEVICES.MONITOR)

    uiHandler.monitor.setTextScale(0.5)

    while(1==1) do
        uiHandler:render()
        uiHandler:render(true)

        os.pullEvent("disk")
        playLoginSound()
        windowHandler:setCurrentWindow("logon")
        uiHandler.state.player = loadPlayerInfo()
        uiHandler:update()
        uiHandler:render()
        uiHandler:render(true)

        while(1==1) do
            local item = getItemFromPedestal()
            if(item ~= nil and item.name == "allthemodium:allthemodium_ingot") then
                break
            end
            os.sleep(0.1)
        end

        movePedestalItemToOutput()
        playLoginSound()

        triggerDropper()

        os.pullEvent("disk_eject")
        playLogoutSound()
    end
end

main()

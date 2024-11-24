require("config")
require("views/default/view-utils")
require("views/default/idle-screen")
require("api/api")

local monitor
local musicStep = 1
local lastNote = 0

local function getSpeaker()
    return peripheral.wrap(CFG.DEVICES.speaker)
end

local function getPedestal1()
    return peripheral.wrap(CFG.DEVICES.infusionPedestal0)
end

local function getPedestal2()
    return peripheral.wrap(CFG.DEVICES.infusionPedestal1)
end

local function getPedestal3()
    return peripheral.wrap(CFG.DEVICES.infusionPedestal2)
end

local function playLoginSound()
    local speaker = getSpeaker()
    speaker.playSound("minecolonies:raid.desert.desert_raid", 1, 1)
end

local function playLogoutSound()
    local speaker = getSpeaker()
    speaker.playSound("stevescarts:gameover", 1, 1)
end

local function playWinMusic()
    getSpeaker().playSound("minecolonies:raid.desert.desert_raid_victory", 1, 1)
end

local function playMusic(reset)
    if(reset) then
        musicStep = 1
        lastNote = 0
    end

    if(os.clock() - lastNote < 0.15) then
        return
    end

    local speaker = getSpeaker()
    speaker.playNote("bell", 1, 5 + musicStep)

    lastNote = os.clock()
    musicStep = musicStep + 1
    if(musicStep > 4) then
        musicStep = 1
    end
end

local function logonWrapper(logonCallback)
    if(not fs.exists("disk")) then
        showIdleScreen()
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

local pedestalHasItem = {false, false, false}
local pedestalItemDetectionTime = {0, 0, 0}

local function cyclePedestals()
    infusionPedestal0 = getPedestal1()
    infusionPedestal1 = getPedestal2()
    infusionPedestal2 = getPedestal3()

    local item0 = infusionPedestal0.list()
    local item1 = infusionPedestal1.list()
    local item2 = infusionPedestal2.list()

    if(item0[1] ~= nil and not pedestalHasItem[1]) then
        pedestalHasItem[1] = true
        pedestalItemDetectionTime[1] = os.epoch()
    end

    if(item1[1] ~= nil and not pedestalHasItem[2]) then
        pedestalHasItem[2] = true
        pedestalItemDetectionTime[2] = os.epoch()
    end

    if(item2[1] ~= nil and not pedestalHasItem[3]) then
        pedestalHasItem[3] = true
        pedestalItemDetectionTime[3] = os.epoch()
    end

    if(not pedestalHasItem[1] or not pedestalHasItem[2] or not pedestalHasItem[3]) then
        return
    end

    local time = os.epoch()
    if(time - pedestalItemDetectionTime[1] < 1000 or time - pedestalItemDetectionTime[2] < 1000 or time - pedestalItemDetectionTime[3] < 1000) then
        return
    end

    infusionPedestal0.pushItems(CFG.DEVICES.recycleInventory, 1)
    infusionPedestal1.pushItems(CFG.DEVICES.recycleInventory, 1)
    infusionPedestal2.pushItems(CFG.DEVICES.recycleInventory, 1)
    pedestalHasItem = {false, false, false}
    pedestalItemDetectionTime = {0, 0, 0}
end

local function waitForPedestalItems()
    while(1==1) do
        infusionPedestal0 = getPedestal1()
        infusionPedestal1 = getPedestal2()
        infusionPedestal2 = getPedestal3()

        local item0 = infusionPedestal0.list()
        local item1 = infusionPedestal1.list()
        local item2 = infusionPedestal2.list()

        if(item0[1] ~= nil and item1[1] ~= nil and item2[1] ~= nil) then
            return
        end

        os.sleep(0.1)
    end
end

local function checkWin()
    infusionPedestal0 = getPedestal1()
    infusionPedestal1 = getPedestal2()
    infusionPedestal2 = getPedestal3()

    local item0 = infusionPedestal0.list()
    local item1 = infusionPedestal1.list()
    local item2 = infusionPedestal2.list()

    if(item0[1] == nil or item1[1] == nil or item2[1] == nil) then
        return false
    end

    if(item0[1].name == item1[1].name and item1[1].name == item2[1].name) then
        return true
    end

    return false
end

local function renderPlayerInfo(player, wonCredits)

end

local function main()
    monitor = peripheral.wrap(CFG.DEVICES.monitor)
    term.redirect(monitor)

    getSpeaker().stop()

    local bet = 10

    os.sleep(1)

    while(1==1) do
        monitor.setTextScale(0.5)

        parallel.waitForAny(
            function()
                logonWrapper(function(player)
                    local gameIsRunning = false

                    while(1==1) do
                        local leverIsPulled = redstone.getInput(CFG.LEVER_SIDE)

                        if(leverIsPulled) then
                            if(not gameIsRunning) then
                                local result = transaction_Subtract(player.userId, bet)

                                if(result ~= nil and result.error ~= nil) then
                                    showErrorScreen(result.error)
                                    playLogoutSound()
                                    os.pullEvent("disk_eject")
                                    return
                                end

                                playMusic(true)
                            else
                                playMusic(false)
                            end
                            gameIsRunning = true
                            cyclePedestals()
                        else
                            if(gameIsRunning) then
                                gameIsRunning = false
                                waitForPedestalItems()
                                waitForPedestalItems()
                                cyclePedestals()
                                waitForPedestalItems()

                                if(checkWin()) then
                                    playWinMusic()

                                    transaction_Add(player.userId, bet * 10)
                                else
                                    playLogoutSound()
                                end
                            end
                        end
                        os.sleep(0)
                    end
                end)
            end,
            function()
                os.pullEvent("disk_eject")
                playLogoutSound()
            end
        )
    end
end

main()

require("config")
require("views/default/view-utils")
require("views/default/betting-screen")
require("views/default/quit-screen")
require("views/default/idle-screen")
require("views/default/error-screen")
require("views/play-screen")
require("api/api")

local monitor
local buttons = {}

local _GS = nil

local function playWinMusic()
    local speaker = peripheral.wrap(CFG.SPEAKER_SIDE)
    speaker.playSound("minecraft:block.note_block.harp", 1, 12)
end

local function playLoseMusic()
    local speaker = peripheral.wrap(CFG.SPEAKER_SIDE)
    speaker.playSound("minecraft:block.note_block.bass", 1, 1)
end

local function playLoginMusic()
    local speaker = peripheral.wrap(CFG.SPEAKER_SIDE)
    speaker.playSound("minecraft:block.note_block.pling", 1, 1)
end

local function playContinueSound()
    local speaker = peripheral.wrap(CFG.SPEAKER_SIDE)
    speaker.playSound("minecraft:block.note_block.hat", 1, 1)
end

local function setBet(bet)
    if(bet > _GS.player.currency) then
        _GS.currentBet = _GS.player.currency
        playLoseMusic()
        return
    end

    if(bet < CFG.GAME.MIN_BET) then
        _GS.currentBet = CFG.GAME.MIN_BET
        playLoseMusic()
        return
    end

    _GS.currentBet = bet
    playContinueSound()
end

local function main()
    monitor = peripheral.wrap(CFG.MONITOR_SIDE)
    monitor.setTextScale(1)
    term.redirect(monitor)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.white)
    term.clear()

    local width, height = term.getSize()

    rednet.open(CFG.MODEM_SIDE)
    MAINFRAME_ID = getMainframeId()

    while true do
        _GS = {
            playing=false,
            currentBet=10,
            player=nil,
            quitting=false,
            continuing=false
        }

        parallel.waitForAny(function()
            showIdleScreen()

            if(not fs.exists("disk")) then
                os.pullEvent("disk")
            end

            if(not isLoggedIn()) then
                playLoseMusic()
                showErrorScreen("Not logged in")
                os.pullEvent("disk_eject")
                return
            end

            term.setBackgroundColor(colors.orange)
            term.clear()
            playLoginMusic()

            local continue = true
            while(1==1) do
                _GS.continuing = false
                _GS.quitting = false
                _GS.player = user_info()

                if(_GS.currentBet > _GS.player.currency) then
                    _GS.currentBet = _GS.player.currency
                    if(_GS.currentBet < CFG.GAME.MIN_BET) then
                        showErrorScreen("Balance too low")
                        os.pullEvent("disk_eject")
                        return
                    end
                end

                renderBettingScreen(
                    _GS,
                    function(bet) -- onBetUpdated
                        setBet(bet)
                    end,
                    function() -- onContinue
                        _GS.playing = true
                        _GS.continuing = true
                        playContinueSound()
                    end,
                    function() -- onQuit
                        _GS.quitting = true
                        _GS.playing = false
                        playLoseMusic()
                    end
                )
                listenToMonitorClick()

                if(_GS.quitting) then
                    break
                end

                if(_GS.playing and _GS.continuing) then
                    showPlayScreen(
                        _GS,
                        function()
                            renderErrorScreen(result.error)
                            listenToMonitorClick()
                            _GS.playing = false
                        end
                    )
                end
            end

            renderQuitScreen()
            os.pullEvent("disk_eject")
        end, function()
            os.pullEvent("disk_eject")
        end)
    end
end

main()

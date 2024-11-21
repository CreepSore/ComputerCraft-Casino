local cfg = {
    HOSTNAME_MASTERSERVER="Casino-MasterServer",
    PROTO_MAINFRAME_GET="Casino/mainframe/get",
    PROTO_USERINFO="Casino/user/info",
    PROTO_NEW_USER="Casino/user/new",
    MONITOR_SIDE="top",
    MODEM_SIDE="right",
    SPEAKER_SIDE="back",
    REDSTONE_SIDE="bottom",
    FILENAME_USERID="userid.dat",
    FILENAME_LOGON="logon.dat",
}

local loc = {
    GREETING="Welcome to the Casino!\nPlease insert your keycard!\n",
    CREATING_USER="Creating new user...\n",
    LOGGING_IN="Logging in...\n",
    SUCCESS="Successfully logged in. Good luck\n",
    FAILED_LOGON="Failed to log in. Please try again.\n",
    LOGGED_OUT="Successfully logged out.\n"
}

local MAINFRAME_ID

function tellerLoop()
    local speaker = peripheral.wrap(cfg.SPEAKER_SIDE)
    local width, height = term.getSize()
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)

    while(1==1) do
        if(cfg.REDSTONE_SIDE ~= nil) then
            redstone.setOutput(cfg.REDSTONE_SIDE, true)
        end
        speaker.playNote("bass", 1, 0)
        term.setBackgroundColor(colors.green)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(math.ceil(centerX - (string.len(loc.GREETING) / 2)), centerY)
        term.write(loc.GREETING)

        os.pullEvent("disk")

        term.clear()
        local action = handleLogon()

        if(cfg.SPEAKER_SIDE ~= nil) then
            if(action == 1) then
                speaker.playNote("bell", 1, 12)
            elseif(action == 2) then
                speaker.playNote("bell", 1, 0)
            end
        end

        if(cfg.REDSTONE_SIDE ~= nil) then
            redstone.setOutput(cfg.REDSTONE_SIDE, false)
        end

        os.sleep(3.5)
    end
end

function getMainframeId()
    rednet.broadcast({}, cfg.PROTO_MAINFRAME_GET)
    local senderId, mainframeId = rednet.receive(cfg.PROTO_MAINFRAME_GET)

    return senderId
end

function fetchUserData(userId)
    local serverId = MAINFRAME_ID

    local message = {userId=userId}
    rednet.send(serverId, message, cfg.PROTO_USERINFO)
    local userdata = nil
    repeat
        local senderId, fetchedData = rednet.receive(cfg.PROTO_USERINFO)
        userdata = fetchedData
    until(senderId == serverId)

    return userdata
end

function createNewUser()
    local serverId = MAINFRAME_ID

    rednet.send(serverId, {}, cfg.PROTO_NEW_USER)
    local newUser = nil
    repeat
        local senderId, newUserData = rednet.receive(cfg.PROTO_NEW_USER)
        newUser = newUserData
    until(senderId == serverId)

    return newUser
end

function handleLogout()
    local width, height = term.getSize()
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)

    fs.delete("disk/"..cfg.FILENAME_LOGON)

    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(math.ceil(centerX - (string.len(loc.LOGGED_OUT) / 2)), centerY)
    term.write(loc.LOGGED_OUT)
end

function handleLogon()
    if(fs.exists("disk/"..cfg.FILENAME_LOGON)) then
        handleLogout()
        return 2
    end

    if(not fs.exists("disk/" .. cfg.FILENAME_USERID)) then
        handleNewUser()
    end

    handleExistingUser()

    return 1
end

function handleNewUser()
    local width, height = term.getSize()
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)

    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.clear()

    term.setCursorPos(math.ceil(centerX - (string.len(loc.CREATING_USER) / 2)), centerY)
    term.write(loc.CREATING_USER)

    local newUser = createNewUser()

    local file = fs.open("disk/" .. cfg.FILENAME_USERID, "w")
    file.write(newUser.userId)
    file.close()
end

function handleExistingUser()
    local width, height = term.getSize()
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)

    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.clear()

    term.setCursorPos(math.ceil(centerX - (string.len(loc.CREATING_USER) / 2)), centerY)
    term.write(loc.CREATING_USER)

    local file = fs.open("disk/" .. cfg.FILENAME_USERID, "r")
    local userId = file.readAll()
    file.close()

    local userdata = fetchUserData(userId)

    if(userdata ~= nil) then
        term.setBackgroundColor(colors.green)
        term.setTextColor(colors.white)
        term.clear()
        local toPrint = loc.SUCCESS .. " " .. userdata.name
        term.setCursorPos(math.ceil(centerX - (string.len(toPrint) / 2)), centerY)
        term.write(toPrint)

        local file = fs.open("disk/" .. cfg.FILENAME_LOGON, "w")
        file.write(textutils.serialise(userdata))
        file.close()
    else
        term.setBackgroundColor(colors.red)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(math.ceil(centerX - (string.len(loc.FAILED_LOGON) / 2)), centerY)
        term.write(loc.FAILED_LOGON)
    end
end

function main()
    if(cfg.MONITOR_SIDE ~= nil) then
        term = peripheral.wrap(cfg.MONITOR_SIDE)
        term.setTextScale(0.5)
        term.clear()
        term.setCursorPos(1,1)
    end

    rednet.open(cfg.MODEM_SIDE)
    MAINFRAME_ID = getMainframeId()

    tellerLoop()
end

main()

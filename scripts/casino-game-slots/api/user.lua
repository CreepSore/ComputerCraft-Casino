function user_info()
    local userId = fs.open(CFG.FILES.USERID, "r").readAll()

    local serverId = MAINFRAME_ID

    local message = {userId=userId}
    rednet.send(serverId, message, CFG.PROTO.USER.INFO)
    local userdata = nil
    repeat
        local senderId, fetchedData = rednet.receive(CFG.PROTO.USER.INFO)
        userdata = fetchedData
    until(senderId == serverId)

    return userdata
end

function user_infoForId(userId)
    local serverId = MAINFRAME_ID

    local message = {userId=userId}
    rednet.send(serverId, message, CFG.PROTO.USER.INFO)
    local userdata = nil
    repeat
        local senderId, fetchedData = rednet.receive(CFG.PROTO.USER.INFO)
        userdata = fetchedData
    until(senderId == serverId)

    return userdata
end

function isLoggedIn()
    return fs.exists(CFG.FILES.LOGON)
end

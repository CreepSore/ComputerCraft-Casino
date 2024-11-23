function transaction_Add(userId, amount)
    local serverId = MAINFRAME_ID

    local message = {userId=userId, amount=amount}
    rednet.send(serverId, message, CFG.PROTO.USER.TRANSACTION.ADD)
    local userdata = nil
    repeat
        local senderId, fetchedData = rednet.receive(CFG.PROTO.USER.TRANSACTION.ADD)
        userdata = fetchedData
    until(senderId == serverId)

    return userdata
end

function transaction_Subtract(userId, amount)
    local serverId = MAINFRAME_ID

    local message = {userId=userId, amount=amount}
    rednet.send(serverId, message, CFG.PROTO.USER.TRANSACTION.SUBTRACT)
    local userdata = nil
    repeat
        local senderId, fetchedData = rednet.receive(CFG.PROTO.USER.TRANSACTION.SUBTRACT)
        userdata = fetchedData
    until(senderId == serverId)

    return userdata
end

require("api/transaction")
require("api/user")

function getMainframeId()
    rednet.broadcast({}, CFG.PROTO.GET_MAINFRAME)
    local senderId, mainframeId = rednet.receive(CFG.PROTO.GET_MAINFRAME)

    return senderId
end


MAINFRAME_ID = getMainframeId()
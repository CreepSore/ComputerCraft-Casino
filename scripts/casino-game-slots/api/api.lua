require("api/transaction")
require("api/user")

function getMainframeId()
    if(not rednet.isOpen(CFG.MODEM_SIDE)) then
        rednet.open(CFG.MODEM_SIDE)
    end

    rednet.broadcast({}, CFG.PROTO.GET_MAINFRAME)
    local senderId, mainframeId = rednet.receive(CFG.PROTO.GET_MAINFRAME)

    return senderId
end


MAINFRAME_ID = getMainframeId()

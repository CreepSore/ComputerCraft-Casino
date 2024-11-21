SERVER_ID = 2
HOSTNAME = "ehdes-cnc"
PROTOCOL_NAME = "turtle-cluster-control"
local MODEM_SIDE = "back"

require("packet-handler/packet-handler")

local function initRednet()
  rednet.open(MODEM_SIDE)
  rednet.host(PROTOCOL_NAME, HOSTNAME)
end

local function receiveAndProcess()
  local id, message = rednet.receive(PROCOTOL_NAME, 3)
  
  if id == nil then
    return false
  end
  
  handlePacket(id, message)
  return true
end

local function mainLoop()
  while(1==1) do
    if(not receiveAndProcess()) then
      sleep(0.5)
    end
  end
end

local function init()
  initRednet()
  print("Start listening...")
  
  parallel.waitForAll(
    function()
      os.pullEventRaw("terminate")
      rednet.close(MODEM_SIDE)
      print("Shutdown rednet")
    end,
    mainLoop
  )
end

init()

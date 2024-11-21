-- CONFIG
local CLIENT_ID = 0
local CLIENT_VERSION_MAJOR = 1
local CLIENT_VERSION_MINOR = 0
local SERVER_HOSTNAME = "ehdes-cnc"
local PROTOCOL_NAME = "turtle-cluster-control"
local MODEM_SIDE = "back"

-- GLOBALS
serverId = -1

local function initRednet()
  rednet.open(MODEM_SIDE)
  local newServerId = rednet.lookup(
    PROTOCOL_NAME,
    SERVER_HOSTNAME
  )
  
  serverId = newServerId
  
  if(serverId == nil or serverId == -1) then
    return false
  end
  
  serverId = newServerId
  
  return true
end

local function send(type, payload)
  local p = {}
  p.type = type
  p.payload = payload

  rednet.send(serverId, p, PROTOCOL_NAME)
end

local function sendHandshake()
  local p = {clientId = CLIENT_ID}

  send("HANDSHAKE", p)
end

local function afterConnect()
  sendHandshake()  

  while(1==1) do  
    local input = read()
    send("BROADCAST", input)
  end
end

local function init()
  while(initRednet() == false) do
    print("Failed to connect to server")
    sleep(1)
  end  

  print("Successfully connected to the server @ " .. serverId)
  afterConnect()  
end

init()


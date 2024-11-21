require("packet-handler/handshake-handler")
require("packet-handler/broadcast-handler")

function handlePacket(senderId, packet)
  if(packet.type == "HANDSHAKE") then
    handleHandshake(senderId, packet.payload)
    return    
  end

  if(packet.type == "BROADCAST") then
    handleBroadcast(sender, packet.payload)
    return
  end

  if(packet.type == "EXCAVATE_DEPTH") then
    print("Excavate Depth: " .. tostring(packet.payload))
    return
  end

  if(packet.type == "TUNNEL_LENGTH") then
    print("Tunnel length: " .. tostring(packet.payload))
    return
  end
end



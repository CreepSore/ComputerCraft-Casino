function handleHandshake(senderId, packet)
  print(
    "Received Handshake -> ["
    .. packet.clientId
    .. "]@["
    .. senderId
    .. "]"
  )
end

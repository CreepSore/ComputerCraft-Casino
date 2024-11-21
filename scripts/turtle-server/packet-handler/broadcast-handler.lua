function handleBroadcast(senderId, payload)
  print(
    "Broadcast -> [" .. tostring(payload) .. "]"
  )

  local p = {type="BROADCAST", payload=payload}

  rednet.broadcast(p, PROTOCOL_NAME)
end

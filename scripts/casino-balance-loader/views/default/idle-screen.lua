function showIdleScreen()
    local width, height = term.getSize()
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)

    term.setBackgroundColor(colors.orange)
    term.clear()

    local image = paintutils.loadImage("logo.nfp")
    if(image ~= nil) then
        local file = fs.open("logo.nfp", "r")
        local data = file.readAll()
        file.close()

        local width = 0
        local height = 0
        for line in data:gmatch("[^\n]+") do
            width = math.max(width, line:len())
            height = height + 1
        end

        paintutils.drawImage(image, centerX - math.floor(width / 2), centerY - math.floor(height / 2))
    end
end

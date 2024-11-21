function showIdleScreen()
    local width, height = term.getSize()
    local centerX = math.floor(width / 2)
    local centerY = math.floor(height / 2)

    term.setBackgroundColor(colors.orange)
    term.clear()

    local image = paintutils.loadImage("logo.nfp")

    paintutils.drawImage(image, centerX - 3, centerY - 5)
end

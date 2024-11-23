function createButton(x, y, width, height, text, action, foregroundColor, backgroundColor)
    local button = {
        x=x,
        y=y,
        width=width,
        height=height,
        text=text,
        action=action,
        foregroundColor=foregroundColor,
        backgroundColor=backgroundColor
    }

    local sW, sH = term.getSize()
    if(button.width == -1) then
        button.width = string.len(button.text) + 2
    end
    if(button.height == -1) then
        button.height = 3
    end

    if(button.width == 0) then
        button.width = sW - 2
    end

    if(button.height == 0) then
        button.height = sH - 2
    end

    table.insert(buttons, button)
end

function clearButtons()
    buttons = {}
end

function renderButtons()
    for _,button in ipairs(buttons) do
        term.setBackgroundColor(button.backgroundColor)
        term.setTextColor(button.foregroundColor)
        term.setCursorPos(button.x, button.y)
        for y=1, button.height do
            term.setCursorPos(button.x, button.y + y - 1)
            for x=1, button.width do
                term.write(" ")
            end
        end

        term.setCursorPos(button.x + math.floor(button.width / 2) - math.floor(string.len(button.text) / 2), button.y + math.floor(button.height / 2))
        term.write(button.text)
    end
end

function listenToMonitorClick()
    local event, button, xPos, yPos = os.pullEvent("monitor_touch")
    handleMonitorClick(xPos, yPos)
end

function handleMonitorClick(xPos, yPos)
    for _,button in ipairs(buttons) do
        if(xPos >= button.x and xPos < button.x + button.width and yPos >= button.y and yPos < button.y + button.height) then
            button.action()
        end
    end
end

function centerPrint(text, y, foregroundColor, backgroundColor)
    if(text == nil) then
        text = ""
    end

    if(backgroundColor == nil) then
        backgroundColor = colors.black
    end
    if(foregroundColor == nil) then
        foregroundColor = colors.white
    end

    term.setBackgroundColor(backgroundColor)
    term.setTextColor(foregroundColor)
    term.setCursorPos(math.floor((term.getSize() / 2) - ((string.len(text) / 2) - 1)), y)
    term.write(text)
end

function fullCenterPrint(text, foregroundColor, backgroundColor)
    if(text == nil) then
        text = ""
    end

    if(backgroundColor == nil) then
        backgroundColor = colors.black
    end
    if(foregroundColor == nil) then
        foregroundColor = colors.white
    end

    local sW, sH = term.getSize()

    term.setBackgroundColor(backgroundColor)
    term.setTextColor(foregroundColor)
    term.setCursorPos(math.floor((sW / 2) - ((string.len(text) / 2) - 1)), sH / 2)
    term.write(text)
end

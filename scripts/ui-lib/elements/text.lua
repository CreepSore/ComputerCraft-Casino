Text = {
    text = "",
    lines = nil,
    color = nil,
    x = 1,
    y = 1,
    width = 1,
    height = 1,
    maxWidth = 10
}

function Text:new(obj)
    o = {lines={}, color=colors.white}

    if(obj) then
        for key, value in pairs(obj) do
            o[key] = value
        end
    end

    setmetatable(o, self)
    self.__index = self

    -- Re-Set label to update geometry
    o:setText(o.text)

    return o
end

function Text:setText(text)
    self.text = text
    self.lines = {}

    local line = ""
    local largestLine = 0
    for word in string.gmatch(text, "%S+") do
        if(string.len(line) + string.len(word) + 1 > self.maxWidth) then
            table.insert(self.lines, line)
            line = ""
        end

        if(string.len(line) > 0) then
            line = line .. " "
        end

        line = line .. word

        if(string.len(line) > largestLine) then
            largestLine = string.len(line)
        end
    end

    if(line ~= "") then
        table.insert(self.lines, line)
        if(string.len(line) > largestLine) then
            largestLine = string.len(line)
        end
    end

    self.width = largestLine
    self.height = #self.lines
end

function Text:render()
    local x, y = ui_getRelativePosition(self)
    local width, height = ui_getElementSize(self)

    term.setTextColor(self.color)

    for i, line in ipairs(self.lines) do
        term.setCursorPos(x, y + i - 1)
        term.write(line)
    end
end

WindowHandler = {
    windows = nil,
    currentWindow = nil,
    backWindowStack = nil,
    forwardWindowStack = nil
}

function WindowHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function WindowHandler:registerWindow(name, panel)
    if(not self.windows) then
        self.windows = {}
    end

    self.windows[name] = panel

    if(self.currentWindow == nil) then
        self.currentWindow = panel
    end
end

function WindowHandler:setCurrentWindow(name)
    if(self.windows[name]) then
        self.currentWindow = self.windows[name]

        if(not self.backWindowStack) then
            self.backWindowStack = {}
        end

        table.insert(self.backWindowStack, WindowHandler:windowToName(self.currentWindow))
        self.forwardWindowStack = {}
    end
end

function WindowHandler:back()
    if(#self.backWindowStack > 1) then
        local window = table.remove(self.backWindowStack)
        table.insert(self.forwardWindowStack, window)
        self.currentWindow = self.backWindowStack[#self.backWindowStack]

        if(not self.forwardWindowStack) then
            self.forwardWindowStack = {}
        end

        table.insert(self.forwardWindowStack, window)
    end
end

function WindowHandler:forward()
    if(#self.forwardWindowStack > 0) then
        local window = table.remove(self.forwardWindowStack)
        table.insert(self.backWindowStack, window)
        self.currentWindow = self.forwardWindowStack[#self.forwardWindowStack]
    end
end

function WindowHandler:windowToName(window)
    for name, panel in pairs(self.windows) do
        if(panel == window) then
            return name
        end
    end
end

function WindowHandler:getCurrentWindow()
    return self.currentWindow
end

WindowHandler = {
    windows = nil,
    currentWindow = nil
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
    end
end

function WindowHandler:getCurrentWindow()
    return self.currentWindow
end

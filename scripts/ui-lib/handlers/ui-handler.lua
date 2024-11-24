UiHandler = {
    type="ui-handler",
    state = {},
    x=1,
    y=1,
    width=1,
    height=1,
    windowHandler = nil
}

function UiHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function UiHandler:panic(message)
    print(message)
end

function UiHandler:setChild(child)
    if(child == nil) then
        return
    end

    if(self.child == child) then
        return
    end

    if(self.child) then
        self.child.parent = nil
    end

    self.child = child
    self.child.parent = self

    if(self.child.monitor) then
        self.monitor = self.child.monitor
    end
end

function UiHandler:setMonitor(monitor)
    self.monitor = monitor

    if(self.child) then
        self.child.monitor = monitor
    end
end

function UiHandler:render()
    if(self.windowHandler) then
        self:setChild(self.windowHandler:getCurrentWindow())
    end

    local oldTerm = nil
    if(self.monitor) then
        local oldTerm = term.redirect(self.monitor)
    end

    self.width, self.height = term.getSize()

    self.width = self.width + 1
    self.height = self.height + 1

    if(self.child == nil) then
        self:panic("No child to render")
        return
    end

    self.child:render()

    if(self.monitor) then
        term.redirect(oldTerm)
    end
end

function UiHandler:onTouch(x, y, monitor)
    if(self.windowHandler) then
        self:setChild(self.windowHandler:getCurrentWindow())
    end

    if(self.monitor) then
        if(monitor ~= self.monitor) then
            return
        end
    end

    self.child:onTouch(x, y, monitor)
end

function UiHandler:onClick(x, y, button)
    if(self.windowHandler) then
        self:setChild(self.windowHandler:getCurrentWindow())
    end

    self.child:onClick(x, y, button)
end

function UiHandler:setWindowHandler(windowHandler)
    self.windowHandler = windowHandler
end

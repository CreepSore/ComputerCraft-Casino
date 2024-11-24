require("/scripts/ui-lib/logic/ui-utils")

Panel = {
    type = "panel",
    parent = nil,
    children = nil,
    width = 0,
    height = 0,
    x = 0,
    y = 0,
    dock = "none", -- none, fill,
    backgroundColor = nil, -- colors.*,
    margin = nil,
    anchor = "left",
    onRenderHandler = nil,
    onClickHandler = nil,
    onTouchHandler = nil,
    borderSize = 0,
    borderColor = nil
}

function Panel:new(obj)
    local o = {
        margin = {top=0, right=0, bottom=0, left=0}
    }

    if(obj) then
        for key, value in pairs(obj) do
            o[key] = value
        end
    end

    setmetatable(o, self)
    self.__index = self
    return o
end

function Panel:render()
    if(self.onRenderHandler) then
        if(self.onRenderHandler()) then
            return
        end
    end

    local x, y = ui_getRelativePosition(self)
    local width, height = ui_getElementSize(self)

    if(self.borderSize > 0 and self.borderColor ~= nil) then
        paintutils.drawFilledBox(
            x,
            y,
            x + width - 1,
            y + height - 1,
            self.borderColor
        )
    end

    if(self.backgroundColor) then
        paintutils.drawFilledBox(
            x + self.borderSize,
            y + self.borderSize,
            x + width - 1 - self.borderSize,
            y + height - 1- self.borderSize,
            self.backgroundColor
        )
    end

    if(self.children) then
        for i, child in ipairs(self.children) do
            child:render()
        end
    end
end

function Panel:addChild(child)
    if(child == self) then
        return
    end

    if(not self.children) then
        self.children = {}
    end

    table.insert(self.children, child)
    child.parent = self
end

function Panel:setMargin(top, right, bottom, left)
    self.margin = {
        top=top,
        right=right,
        bottom=bottom,
        left=left
    }
end

function Panel:onClick(x, y, button)
    if(self.onClickHandler) then
        if(self:onClickHandler(x, y, button)) then
            return
        end
    end

    if(self.children) then
        for i, child in ipairs(self.children) do
            if(child.onClick) then
                if ui_isPointInsideElement(x, y, child) then
                    child:onClick(x, y, button)
                end
            end
        end
    end
end

function Panel:onTouch(x, y, monitor)
    if(self.onTouchHandler) then
        if(self:onTouchHandler(x, y, monitor)) then
            return
        end
    end

    if(self.children) then
        for i, child in ipairs(self.children) do
            if(child.onTouch) then
                if ui_isPointInsideElement(x, y, child) then
                    child:onTouch(x, y, button)
                end
            end
        end
    end
end

function Panel:setOnClickHandler(handler)
    self.onClickHandler = handler
end

function Panel:setOnTouchHandler(handler)
    self.onTouchHandler = handler
end

function Panel:update()
    if(self.children) then
        for i, child in ipairs(self.children) do
            if(child.update) then
                child:update()
            end
        end
    end
end

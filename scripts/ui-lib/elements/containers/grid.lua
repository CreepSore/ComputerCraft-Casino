require("/scripts/ui-lib/logic/ui-utils")
require("/scripts/ui-lib/elements/containers/panel")

Grid = {
    type = "grid",
    parent = nil,
    children = nil,
    width = 0,
    height = 0,
    x = 1,
    y = 1,
    gap = 0,
    dock = "fill", -- none, fill,
    backgroundColor = nil, -- colors.*,
    margin = nil,
    anchor = "left",
    onRenderHandler = nil,
    onClickHandler = nil,
    onTouchHandler = nil,
    borderSize = 0,
    borderColor = nil,
    columnWidth = nil,
    rowHeight = nil,
    panels = nil
}

function Grid:resize(columns, rows)
    self.columns = columns
    self.rows = rows

    self.columnWidth = {}
    self.rowHeight = {}

    for i=1, columns do
        table.insert(self.columnWidth, 1/columns)
    end

    print(self.columnWidth[1])

    for i=1, rows do
        table.insert(self.rowHeight, 1/rows)
    end
end

function Grid:new(columns, rows, obj)
    o = {margin = {top=0, right=0, bottom=0, left=0}, children = {}}

    if(obj) then
        for key, value in pairs(obj) do
            o[key] = value
        end
    end

    setmetatable(o, self)
    self.__index = self
    o:resize(columns, rows)
    return o
end

function Grid:addChild(child)
    if(child == self) then
        return
    end

    if(not self.children) then
        self.children = {}
    end

    table.insert(self.children, child)
    child.parent = self
end

function Grid:createPanels()
    self.panels = {}

    local startX, startY = 1, 1
    local currentX, currentY = startX, startY
    for y = 1, self.rows do
        local height = self:getRowHeight(y)

        if(y < self.rows) then
            height = height - self.gap
        end

        for x = 1, self.columns do
            local width = self:getColumnWidth(x)

            if(x < self.columns) then
                width = width - self.gap
            end

            local panel = Panel:new({
                x = currentX,
                y = currentY,
                width = width,
                height = height,
                backgroundColor = nil,
                borderSize = nil,
                borderColor = nil,
                dock="none",
                parent=self
            })

            table.insert(self.panels, panel)
            currentX = currentX + width + self.gap
        end

        currentX = startX
        currentY = currentY + height + self.gap
    end

    self:addChildrenToPanel()
end

function Grid:addChildrenToPanel()
    for i, panel in ipairs(self.panels) do
        local child = self.children[i]

        if(child) then
            child.dock = "fill"
            panel:addChild(child)
        end
    end
end

function Grid:setColumnWidth(columnNo, width)
    self.columnWidth[columnNo] = width
end

function Grid:getColumnWidth(columnNo)
    local width = ui_getElementSize(self)

    return math.floor(width * self.columnWidth[columnNo])
end

function Grid:setRowHeight(rowNo, height)
    self.rowHeight[rowNo] = height
end

function Grid:getRowHeight(rowNo)
    local _, height = ui_getElementSize(self)
    return math.floor(height * self.rowHeight[rowNo])
end

function Grid:render()
    if(self.onRenderHandler) then
        if(self.onRenderHandler()) then
            return
        end
    end

    local x, y = ui_getRelativePosition(self)
    local width, height = ui_getElementSize(self)

    self.width = width
    self.height = height

    self:createPanels()

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

    if(self.panels) then
        for i, panel in ipairs(self.panels) do
            panel:render()
        end
    end
end

function Grid:setMargin(top, right, bottom, left)
    self.margin = {
        top=top,
        right=right,
        bottom=bottom,
        left=left
    }
end

function Grid:onClick(x, y, button)
    if(self.onClickHandler) then
        if(self:onClickHandler(x, y, button)) then
            return
        end
    end

    if(self.panels) then
        for i, panel in ipairs(self.panels) do
            if(panel.onClick) then
                if ui_isPointInsideElement(x, y, panel) then
                    panel:onClick(x, y, button)
                end
            end
        end
    end
end

function Grid:onTouch(x, y, monitor)
    if(self.onTouchHandler) then
        if(self:onTouchHandler(x, y, monitor)) then
            return
        end
    end

    if(self.panels) then
        for i, panel in ipairs(self.panels) do
            if(panel.onTouch) then
                if ui_isPointInsideElement(x, y, panel) then
                    panel:onTouch(x, y, button)
                end
            end
        end
    end
end

function Grid:setOnClickHandler(handler)
    self.onClickHandler = handler
end

function Grid:setOnTouchHandler(handler)
    self.onTouchHandler = handler
end

function Grid:update()
    if(self.panels) then
        for i, panel in ipairs(self.panels) do
            if(panel.update) then
                panel:update()
            end
        end
    end
end

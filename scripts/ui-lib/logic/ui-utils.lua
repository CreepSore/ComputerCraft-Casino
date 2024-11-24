---@return number, number
function ui_getRelativePosition(element)
    local x = element.x
    local y = element.y
    local width, height = ui_getElementSize(element)

    if(element.parent ~= nil) then
        local parentWidth, parentHeight = ui_getElementSize(element.parent)
        local parentX, parentY = ui_getRelativePosition(element.parent)

        if(element.anchor == "right") then
            x = parentWidth - x - width

            if(element.margin) then
                x = x + element.margin.left
            end
        elseif(element.anchor == "bottom") then
            y = parentHeight - y - height

            if(element.margin) then
                y = y + element.margin.top
            end
        elseif(element.anchor == "center") then
            x = math.ceil((parentWidth - width) / 2) + x
            y = math.ceil((parentHeight - height) / 2) + y
        end

        x = x + parentX
        y = y + parentY
    end

    if(element.margin) then
        x = x + element.margin.left
        y = y + element.margin.top
    end
    return x, y
end

---@return number, number
function ui_getElementSize(element)
    if(element.dock == "fill" and element.parent) then
        local parentWidth, parentHeight = ui_getElementSize(element.parent)

        if(element.margin) then
            parentWidth = parentWidth - element.margin.left - element.margin.right
            parentHeight = parentHeight - element.margin.top - element.margin.bottom
        end

        return parentWidth, parentHeight
    end

    return element.width, element.height
end

---@return boolean
function ui_isPointInsideElement(x, y, element)
    local elementX, elementY = ui_getRelativePosition(element)
    local elementWidth, elementHeight = ui_getElementSize(element)

    if(x >= elementX and x <= elementX + elementWidth - 1 and y >= elementY and y <= elementY + elementHeight - 1) then
        return true
    end

    return false
end

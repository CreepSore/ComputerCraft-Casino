require("/scripts/ui-lib/elements/text")

Button = {}

function Button:new(panelOptions, buttonOptions)
    local panel = Panel:new(panelOptions)
    if(buttonOptions and buttonOptions.onClickHandler) then
        panel.onClickHandler = buttonOptions.onClickHandler
    end

    if(buttonOptions and buttonOptions.onTouchHandler) then
        panel.onTouchHandler = buttonOptions.onTouchHandler
    end

    local textElement = Text:new({
        text = buttonOptions.text,
        color = colors.white,
        x = 0,
        y = 0,
        width = panel.width,
        height = panel.height,
        anchor = "center",
        maxWidth = buttonOptions.maxWidth
    })

    panel:addChild(textElement)

    if(buttonOptions.autosize) then
        panel.width = textElement.width + 2
        panel.height = textElement.height + 2
    end

    return panel
end



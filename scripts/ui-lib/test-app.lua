require("/scripts/ui-lib/handlers/ui-handler")
require("/scripts/ui-lib/handlers/window-handler")
require("/scripts/ui-lib/elements/containers/panel")
require("/scripts/ui-lib/elements/containers/grid")
require("/scripts/ui-lib/elements/button")

function createPanel(color)
    return Button:new({
        x = 1,
        y = 1,
        width = 10,
        height = 10,
        backgroundColor = color,
        dock="fill"
    }, {
        text="OIDA",
        textColor=colors.white,
        onClickHandler=function()
            print("Clicked")
        end
    })
end

function Window(windowHandler)
    local panel = Panel:new({
        x = 1,
        y = 1,
        dock="fill",
    })

    local panel2 = Panel:new({
        x = 1,
        y = 1,
        backgroundColor = colors.orange,
        dock="fill"
    })

    local panel3 = Panel:new({
        x = 1,
        y = 1,
        backgroundColor = colors.orange,
        dock="fill"
    })

    local green = createPanel(colors.green)
    local red = createPanel(colors.red)
    local blue = createPanel(colors.blue)
    local yellow = createPanel(colors.yellow)

    local grid = Grid:new(1, 2, {
        x = 1,
        y = 1,
        dock="fill",
    })

    grid:setRowHeight(1, 0.6)
    grid:setRowHeight(2, 0.4)

    local grid2 = Grid:new(4, 1, {
        x = 1,
        y = 1,
        dock="fill",
    })

    grid2:addChild(green)
    grid2:addChild(red)
    grid2:addChild(blue)
    grid2:addChild(yellow)

    grid:addChild(panel2)
    grid:addChild(grid2)

    panel:addChild(grid)

    windowHandler:registerWindow("window", panel)
end

function main()
    local uiHandler = UiHandler:new()
    local windowHandler = WindowHandler:new()

    Window(windowHandler)

    uiHandler:setWindowHandler(windowHandler)
    uiHandler:render()

    parallel.waitForAny(
        function()
            os.pullEvent("key")
        end,
        function()
            while(1==1) do
                --uiHandler:render()
                local event, button, x, y = os.pullEvent("mouse_click")
                uiHandler:onClick(x, y, button)
            end
        end
    )
end

main()

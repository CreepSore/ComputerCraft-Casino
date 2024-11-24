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
        backgroundColor = colors.blue,
        dock="fill",
    })

    local panel2 = Panel:new({
        x = 1,
        y = 1,
        width = 20,
        height = 20,
        backgroundColor = colors.yellow,
        anchor="center"
    })

    local green = createPanel(colors.green)
    local red = createPanel(colors.red)

    local grid = Grid:new(2, 1, {
        x = 1,
        y = 1,
        gap = 1,
        dock="fill",
        margin={top=1, right=1, bottom=1, left=1}
    })
    grid:addChild(green)
    grid:addChild(red)

    panel2:addChild(grid)
    panel:addChild(panel2)

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

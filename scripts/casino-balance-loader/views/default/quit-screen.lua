function renderQuitScreen()
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.clear()

    centerPrint("Please remove", 5, colors.white, colors.red)
    centerPrint("your disk", 6, colors.white, colors.red)
end

function showErrorScreen(error)
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.clear()

    centerPrint(error, 5, colors.white, colors.red)
end
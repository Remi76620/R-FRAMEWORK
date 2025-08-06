--- Loading Hide
function rm.Function.loadingHide()
    if IsLoadingPromptBeingDisplayed() then
        RemoveLoadingPrompt()
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        rm.Io.Trace('(rm.Functions.loadingHide) Loading hidden')
        return true
    end
end
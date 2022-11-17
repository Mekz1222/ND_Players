local display = false
selected = 0

function findPedById(id)
    for _, info in pairs(linedUp) do
        if info.character == id then
            return info.ped
        end
    end
end

-- TriggerServerEvent("ND:setCharacterOnline", data.id)
-- TriggerServerEvent("ND:deleteCharacter", data.id)
RegisterNUICallback("action", function(data)
    if data.action == "new" then
        TriggerServerEvent("ND_CharactersV2:createCharacter", data)
    elseif data.action == "delete" then
        local ped = findPedById(selected)
        DeletePed(ped)
        -- TriggerServerEvent("ND:deleteCharacter", selected)
    elseif data.action == "play" then
        print("Action", "play as character")
    end
end)

-- when a character is clicked on and selected.
RegisterNUICallback("select", function(data)
    for i = 1, #peds do
        if peds[i] == linedUp[data.lineup].ped then
            playBoardAnim(peds[i], 'loop_raised')
        else
            playBoardAnim(peds[i], 'loop')
        end
    end
    selected = linedUp[data.lineup].character
end)

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(1000)
    init()
end)

AddEventHandler("playerSpawned", function()
    -- init()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    cleanUp()
    DestroyAllCams(true)
end)

RegisterCommand(Config.frameworkCommand, function()
    display = not display
    SetNuiFocus(display, display)
    LeaveCursorMode()
    SendNUIMessage({
        type = "display",
        status = display
    })
end, false)
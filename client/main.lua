local display = false
selected = 0

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
        if findPedById(selected) then
            print("Action", "play as character", selected)
            local soundId = GetSoundId()
            PlaySoundFrontend(soundId, "BASE_JUMP_PASSED", "HUD_AWARDS", true)
            ReleaseSoundId(soundId)
            playOutro(findPedById(selected))
        end
    end
end)

-- when a character is clicked on and selected.
RegisterNUICallback("select", function(data)
    if selected == linedUp[data.lineup].character then return end
    for i = 1, #peds do
        if peds[i] == linedUp[data.lineup].ped then
            local soundId = GetSoundId()
            PlaySoundFrontend(soundId, "SELECT", "HUD_FREEMODE_SOUNDSET", true)
            ReleaseSoundId(soundId)
            playRaiseBoard(peds[i])
        elseif peds[i] == findPedById(selected) then
            playLowerBoard(peds[i])
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
    cleanup()
    DestroyAllCams(true)
end)

RegisterCommand(Config.frameworkCommand, function()
    display = not display
    SetNuiFocus(display, display)
    SendNUIMessage({
        type = "display",
        status = display
    })
end, false)
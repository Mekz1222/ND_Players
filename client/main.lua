NDCore = exports["ND_Core"]:GetCoreObject()
local display = false
selected = 0

-- TriggerServerEvent("ND:setCharacterOnline", data.id)
-- TriggerServerEvent("ND:deleteCharacter", data.id)
RegisterNUICallback('action', function(data, cb)
    cb(1)
    if data.action == 'new' then
        DoScreenFadeOut(1000)
        Wait(1000)
        CreateThread(function()
            cleanup()
            DestroyAllCams(true)
        end)
        local ped = PlayerPedId()
        SetEntityCoords(ped, 402.84, -996.83, -100.00)
        SetEntityHeading(182.28)
        FreezeEntityPosition(ped, false)
        Wait(1000)
        DoScreenFadeIn(1000)

        local config = {
            ped = true,
            headBlend = true,
            faceFeatures = true,
            headOverlays = true,
            components = true,
            props = true,
            tattoos = false
        }
        exports["fivem-appearance"]:startPlayerCustomization(function(appearance)
            if appearance then
                TriggerServerEvent("ND_CharactersV2:createCharacter", data)
                local ped = PlayerPedId()
                local clothing = {
                    model = GetEntityModel(ped),
                    tattoos = exports["fivem-appearance"]:getPedTattoos(ped),
                    appearance = exports["fivem-appearance"]:getPedAppearance(ped)
                }
                DoScreenFadeOut(1000)
                Wait(1000)
                local character = NDCore.Functions.GetSelectedCharacter()
                SendNUIMessage({
                    type = "map",
                    status = true,
                    markers = Config.spawns,
                    job = character.job
                })
                SetNuiFocus(true, true)
                Wait(4000)
                TriggerServerEvent("ND:updateClothes", clothing)
            else
                init()
            end
        end, config)
    elseif data.action == 'delete' then
        local ped = findPedById(selected)
        DeletePed(ped)
        -- TriggerServerEvent("ND:deleteCharacter", selected)
    elseif data.action == 'play' then
        if findPedById(selected) then
            TriggerServerEvent("ND:setCharacterOnline", selected)
            print('Action', 'play as character', selected)
            local soundId = GetSoundId()
            PlaySoundFrontend(soundId, 'BASE_JUMP_PASSED', 'HUD_AWARDS', true)
            ReleaseSoundId(soundId)
            local character = NDCore.Functions.GetSelectedCharacter()
            CreateThread(function()
                Wait(4000)
                SendNUIMessage({
                    type = "map",
                    status = true,
                    markers = Config.spawns,
                    job = character.job
                })
            end)
            playOutro(findPedById(selected))
            SetNuiFocus(true, true)
        end
    end
end)

-- when a character is clicked on and selected.
RegisterNUICallback('select', function(data, cb)
    cb(1)
    if selected == linedUp[data.lineup].character then return end
    for i = 1, #peds do
        if peds[i] == linedUp[data.lineup].ped then
            local soundId = GetSoundId()
            PlaySoundFrontend(soundId, 'SELECT', 'HUD_FREEMODE_SOUNDSET', true)
            ReleaseSoundId(soundId)
            playRaiseBoard(peds[i])
        elseif peds[i] == findPedById(selected) then
            playLowerBoard(peds[i])
        end
    end
    selected = linedUp[data.lineup].character
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(1000)
    init()
end)

AddEventHandler('playerSpawned', function()
    --init()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    cleanup()
    DestroyAllCams(true)
end)

RegisterNUICallback("spawn", function(data)
    cleanup()
    local coords = Config.spawns[data.type] and Config.spawns[data.type][data.id+1] and Config.spawns[data.type][data.id+1].coords
    print(coords)
    if not coords then return end
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    Wait(2500)
    FreezeEntityPosition(ped, false)
    Wait(1500)
    DoScreenFadeIn(1000)
end)
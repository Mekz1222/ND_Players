local cam = nil
local interiorPos = vec3(399.9, -998.7, -100.0)
local interior = GetInteriorAtCoordsWithType(interiorPos.x, interiorPos.y, interiorPos.z, 'v_mugshot')

peds = {}
boards = {}
lineups = {
    vector4(409.29, -997.26, -99.00, 261.20),
    vector4(409.25, -998.08, -99.00, 266.71),
    vector4(409.22, -998.94, -99.00, 269.97),
    vector4(409.20, -999.73, -99.00, 274.27)
}
linedUp = {}

function genderAnim(ped)
    if IsPedMale(ped) then
        return 'male'
    end
    return 'female'
end

function findPedById(id)
    for _, info in pairs(linedUp) do
        if info.character == id then
            return info.ped
        end
    end
end

function init()
    DoScreenFadeOut(0)

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    PinInteriorInMemory(interior)
    repeat Wait(0) until IsInteriorReady(interior)
    SetEntityCoords(ped, 417.27, -998.65, -99.40, false, false, false, false)

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'display',
        status = true
    })
    display = true

    CreateThread(function()
        cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 37.0, false, 2)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
        ShakeCam(cam, 'HAND_SHAKE', 0.1)
        SetCamCoord(cam, 416.4084, -998.3806, -99.24789)
        SetCamRot(cam, 0.878834, -0.022102, 90.0173, 2)
        PointCamAtCoord(cam, 409.08, -998.47, -99.0)

        while display do
            DisableAllControlActions(0)
            ThefeedHideThisFrame()
            HideHudAndRadarThisFrame()
            Wait(0)
        end
    end)

    lib.callback('ND_CharactersV2:getCharacters', false, function(characters)
        local lineup = 0
        linedUp = {}
        for _, character in pairs(characters) do
            if next(character.data.clothing) then
                lineup += 1
                if lineup > #lineups then break end
                RequestModel(character.data.clothing.model)
                repeat Wait(0) until HasModelLoaded(character.data.clothing.model)
                local dummyPed = CreatePed(26, character.data.clothing.model, lineups[lineup].x, lineups[lineup].y, lineups[lineup].z, lineups[lineup].w, false, false)
                exports['fivem-appearance']:setPedTattoos(dummyPed, character.data.clothing.tattoos)
                exports['fivem-appearance']:setPedAppearance(dummyPed, character.data.clothing.appearance)
                peds[#peds + 1] = dummyPed
                createBoard(dummyPed)
                playReactAnim(dummyPed)
                linedUp[lineup] = {
                    character = character.id,
                    ped = dummyPed
                }
            end
        end
        Wait(1100)
        DoScreenFadeIn(1000)
        playLightSound()
        Wait(4500)
        for i = 1, #peds do
            ClearPedTasks(peds[i])
            playBoardAnim(peds[i], 'loop')
        end
        SendNUIMessage({
            type = 'lineup',
            amount = lineup
        })
    end)
end

function startChangeAppearence()
    exports['fivem-appearance']:startPlayerCustomization(function(appearance)
        if appearance then
            local ped = PlayerPedId()
            local clothing = {
                model = GetEntityModel(ped),
                tattoos = exports['fivem-appearance']:getPedTattoos(ped),
                appearance = exports['fivem-appearance']:getPedAppearance(ped)
            }
            Wait(1500)
            TriggerServerEvent('ND:updateClothing', clothing)
            return true
        end
        return false
    end, {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        tattoos = false
    })
end

function playLightSound()
    local soundId = GetSoundId()
    repeat RequestScriptAudioBank('DLC_GTAO/MUGSHOT_ROOM', false) until RequestScriptAudioBank('DLC_GTAO/MUGSHOT_ROOM', false)
    PlaySoundFrontend(soundId, 'Lights_On', 'GTAO_MUGSHOT_ROOM_SOUNDS', true)
    ReleaseSoundId(soundId)
end

function playReactAnim(ped)
    local animDict = ('mp_character_creation@lineup@%s_a'):format(genderAnim(ped))

    RequestAnimDict(animDict)
    repeat Wait(0) until HasAnimDictLoaded(animDict)

    TaskPlayAnim(ped, animDict, 'react_light', 8.0, 0.0, -1, 0.0, 0, false, false, false)
end

-- Set player clothes by character, this will be used when the player selects a character to play on.
function setCharacterClothes(character)
    if not character.clothing or next(character.clothing) == nil then
        changeAppearence = true
    else
        changeAppearence = false
        exports['fivem-appearance']:setPlayerModel(character.clothing.model)
        local ped = PlayerPedId()
        exports['fivem-appearance']:setPedTattoos(ped, character.clothing.tattoos)
        exports['fivem-appearance']:setPedAppearance(ped, character.clothing.appearance)
    end
end

function playRaiseBoard(ped)
    local animDict = ('mp_character_creation@lineup@%s_a'):format(genderAnim(ped))
    TaskPlayAnim(ped, animDict, 'low_to_high', 8.0, -8.0, -1, 0.0, 0, false, false, false)
    Wait(1500)
    TaskPlayAnim(ped, animDict, 'loop_raised', 8.0, -8.0, -1, 0.0, 0, false, false, false)
end

function playLowerBoard(ped)
    local animDict = ('mp_character_creation@lineup@%s_a'):format(genderAnim(ped))
    TaskPlayAnim(ped, animDict, 'high_to_low', 8.0, -8.0, -1, 0.0, 0, false, false, false)
    Wait(1500)
    TaskPlayAnim(ped, animDict, 'loop', 8.0, -8.0, -1, 0.0, 0, false, false, false)
end

function playOutro(ped)
    local animDict = ('mp_character_creation@lineup@%s_a'):format(genderAnim(ped))
    StopEntityAnim(ped, 'loop_raised', animDict, 0)
    TaskPlayAnim(ped, animDict, 'outro', 8.0, 0.0, -1, 0.0, 0, false, false, false)
    Wait(6500)
    DoScreenFadeOut(1000)
    repeat Wait(0) until IsScreenFadedOut()
    cleanup()
    DoScreenFadeIn(1000)
end

-- Spawn board model.
function createBoard(ped)
    RequestModel(`prop_police_id_board`)
    repeat Wait(0) until HasModelLoaded(`prop_police_id_board`)

    local key = #boards + 1
    boards[key] = {}
    boards[key].board = CreateObject(`prop_police_id_board`, 0.0, 0.0, 0.0, false, true, false)
    AttachEntityToEntity(boards[key].board, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(`prop_police_id_board`)
end

-- Play board animation on ped.
function playBoardAnim(ped, type)
    local animDict = ('mp_character_creation@lineup@%s_a'):format(genderAnim(ped))

    RequestAnimDict(animDict)
    repeat Wait(0) until HasAnimDictLoaded(animDict)

    TaskPlayAnim(ped, animDict, type, 50.0, 8.0, -1, 1, 0.0, false, false, false)
end

-- delete all peds and boards, set camera back to gameplay.
function cleanup()
    for i = 1, #boards do
        SetEntityAsMissionEntity(boards[i].board, true, true)
        DeleteObject(boards[i].board)
    end
    for i = 1, #peds do
        DeletePed(peds[i])
    end
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'display',
        status = false
    })
    display = false
    SetCamActive(cam, false)
    RenderScriptCams(false, false, 0, true, true)
    DestroyAllCams(true)
    ReleaseNamedScriptAudioBank('Mugshot_Character_Creator')
    RemoveAnimDict('mp_character_creation@lineup@male_a')
    RemoveAnimDict('mp_character_creation@lineup@female_a')
    UnpinInterior(interior)
end
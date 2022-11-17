function init()
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, 417.27, -998.65, -99.40, false, false, false, false)

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "display",
        status = true
    })

    CreateThread(function()
        DoScreenFadeOut(0)

        cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 39.4, false, 2)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
        SetCamCoord(cam, 416.359955, -998.358643, -99.115492)
        SetCamRot(cam, 0.144769, 0.0, 89.702049, 2)
        PointCamAtCoord(cam, 409.08, -998.47, -99.0)
    end)

    lib.callback("ND_CharactersV2:getCharacters", false, function(characters)
        local lineup = 1
        for player, character in pairs(characters) do
            if character.clothing and next(character.clothing) ~= nil then
                --if lineup > 1 then break end -- testing
                if lineup > #lineups then break end
                print(character.firstName, character.lastName)
                repeat Wait(0) until HasModelLoaded(character.clothing.model)
                local dummyPed = CreatePed(2, character.clothing.model, lineups[lineup].x, lineups[lineup].y, lineups[lineup].z, lineups[lineup].w, false, false)
                lineup += 1
                exports["fivem-appearance"]:setPedTattoos(dummyPed, character.clothing.tattoos)
                exports["fivem-appearance"]:setPedAppearance(dummyPed, character.clothing.appearance)
                peds[#peds + 1] = dummyPed

                createBoard(dummyPed)
                playReactAnim(dummyPed)
            end
        end
        Wait(1000)
        DoScreenFadeIn(1000)
        playLightSound()
        Wait(5000)
        for i = 1, #peds do
            ClearPedTasks(peds[i])
            playBoardAnim(peds[i])
        end
    end)
end

function startChangeAppearence()
    exports["fivem-appearance"]:startPlayerCustomization(function(appearance)
        if appearance then
            local ped = PlayerPedId()
            local clothing = {
                model = GetEntityModel(ped),
                tattoos = exports["fivem-appearance"]:getPedTattoos(ped),
                appearance = exports["fivem-appearance"]:getPedAppearance(ped)
            }
            Wait(1500)
            TriggerServerEvent("ND:updateClothes", clothing)
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
    local audio = RequestScriptAudioBank("Mugshot_Character_Creator", false)
    repeat Wait(0) until audio
    PlaySoundFrontend(soundId, 'Lights_On', 'GTAO_MUGSHOT_ROOM_SOUNDS', true)
    ReleaseSoundId(soundId)
    ---@diagnostic disable-next-line: redundant-parameter
    ReleaseScriptAudioBank('Mugshot_Character_Creator')
end

function playReactAnim(ped)
    if IsPedMale(ped) then
        TaskPlayAnim(ped, "mp_character_creation@lineup@male_a", "react_light", 8.0, 0.0, -1, 0, 0, false, false, false)
    else
        TaskPlayAnim(ped, "mp_character_creation@lineup@female_a", "react_light", 8.0, 0.0, -1, 0, 0, false, false, false)
    end
end

-- Set player clothes by character, this will be used when the player selects a character to play on.
function setCharacterClothes(character)
    if not character.clothing or next(character.clothing) == nil then
        changeAppearence = true
    else
        changeAppearence = false
        exports["fivem-appearance"]:setPlayerModel(character.clothing.model)
        local ped = PlayerPedId()
        exports["fivem-appearance"]:setPedTattoos(ped, character.clothing.tattoos)
        exports["fivem-appearance"]:setPedAppearance(ped, character.clothing.appearance)
    end
end

-- Spawn board model.
function createBoard(ped)
    RequestModel(`prop_police_id_text`)
    RequestModel(`prop_police_id_board`)
    repeat Wait(0) until HasModelLoaded(`prop_police_id_text`) and HasModelLoaded(`prop_police_id_board`)

    local key = #boards + 1
    boards[key] = {}
    boards[key].board = CreateObject(`prop_police_id_board`, 0.0, 0.0, 0.0, true, true, false)
    boards[key].overlay = CreateObject(`prop_police_id_text`, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(boards[key].overlay, boards[key].board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    AttachEntityToEntity(boards[key].board, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

    SetModelAsNoLongerNeeded(`prop_police_id_board`)
    SetModelAsNoLongerNeeded(`prop_police_id_text`)
end

-- Play holding up board animation on ped.
function playBoardAnim(ped)
    local animDict = "mp_character_creation@lineup@female_a"

    if IsPedMale(ped) then
        animDict = "mp_character_creation@lineup@male_a"
    end

    RequestAnimDict(animDict)
    repeat Wait(0) until HasAnimDictLoaded(animDict)

    TaskPlayAnim(ped, animDict, 'loop_raised', 50.0, 8.0, -1, 49, 0.0, false, false, false)
    RemoveAnimDict(animDict)
end

-- delete all peds and baords.
function cleanUp()
    for i = 1, #boards do
        DeleteObject(boards[i].board)
        DeleteObject(boards[i].overlay)
    end
    for i = 1, #peds do
        DeletePed(peds[i])
    end
end
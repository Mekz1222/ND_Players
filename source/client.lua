local test = false
local cam = nil

RegisterCommand("switch", function()
    test = not test
    SetNuiFocus(test, test)
    SendNUIMessage({
        type = "display",
        status = test
    })
end, false)

local function init()
    CreateThread(function()
        DoScreenFadeOut(0)
        NetworkStartSoloTutorialSession()
        repeat Wait(0) until not NetworkIsTutorialSessionChangePending()

        cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 39.4, false, 2)

        SetCamActive(cam, true)
        SetCamCoord(cam, 416.359955, -998.358643, -99.115492)
        --local pedCoords = GetEntityCoords(PlayerPedId())
        --PointCamAtCoord(cam, pedCoords.x, pedCoords.y, pedCoords.z)
        SetCamRot(cam, 0.144769, 0.0, 89.702049, 2)
        RenderScriptCams(true, false, 0, true, true)
    end)
end

AddEventHandler('onPlayerSpawned', function()
    init()
end)

RegisterNUICallback("action", function(data)
    if data.action == "new" then
        print("Action", "create new character")
    elseif data.action == "delete" then
        print("Action", "delete this character")
    elseif data.action == "left" then
        print("Action", "view character to the left")
    elseif data.action == "right" then
        print("Action", "view character to the right")
    end
end)

function createBoard()
    RequestModel(`prop_police_id_text`)
    RequestModel(`prop_police_id_board`)
    repeat Wait(0) until HasModelLoaded(`prop_police_id_text`) and HasModelLoaded(`prop_police_id_board`)

    board = CreateObject(`prop_police_id_board`, 0.0, 0.0, 0.0, true, true, false)
    overlay = CreateObject(`prop_police_id_text`, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(overlay, board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(`prop_police_id_text`)
    SetModelAsNoLongerNeeded(`prop_police_id_board`)
    AttachEntityToEntity(board, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
end

local function playBoardAnim()
    local animDict = 'mp_character_creation@lineup@male_a'
    RequestAnimDict(animDict)
    repeat Wait(0) until HasAnimDictLoaded(animDict)

    TaskPlayAnim(PlayerPedId(), animDict, 'loop_raised', 8.0, 8.0, -1, 49, 0.0, false, false, false)
    RemoveAnimDict(animDict)
end

RegisterCommand('cam', function()
    StartPlayerTeleport(PlayerId(), 409.02, -998.47, -99, 269.71, false, true, false)
    repeat Wait(0) until not IsPlayerTeleportActive()

    cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 39.4, false, 2)

    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    local pedCoords = GetEntityCoords(PlayerPedId())

    SetCamCoord(cam, 416.359955, -998.358643, -99.115492)
    SetCamRot(cam, 0.144769, 0.0, 89.702049, 2)
    PointCamAtCoord(cam, pedCoords.x, pedCoords.y, pedCoords.z)
end, false)

RegisterCommand('stopcam', function()
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, false)
    ClearPedTasksImmediately(PlayerPedId())
    cam = nil
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    DeleteObject(board)
    DeleteObject(overlay)
    DestroyAllCams(true)
    ClearPedTasksImmediately(PlayerPedId())
end)
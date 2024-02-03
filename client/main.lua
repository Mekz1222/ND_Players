local spawns = require "data.spawns"
local camera = require "modules.camera.client"
local creator = require "modules.creator.client"
local selector = require "modules.selector.client"

local function teleport(ped, coords, withVehicle)
    DoScreenFadeOut(500)
    Wait(500)
    FreezeEntityPosition(ped, true)
    
    lib.hideTextUI()
    StartPlayerTeleport(cache.playerId, coords.x, coords.y, coords.z, coords.w, withVehicle, true, true)
    while IsPlayerTeleportActive() or not HasCollisionLoadedAroundEntity(ped) do Wait(10) end
end

local function init(ped)
    teleport(ped, vec3(417.27, -998.65, -99.40), false)

    CreateThread(function()
        selector:start()
    end)

    camera:create()
end

AddEventHandler("onResourceStart", function(resourceName)
    if cache.resource ~= resourceName then return end
    Wait(1000)
    init(cache.ped)
end)

AddEventHandler("playerSpawned", function()
    Wait(500)
    init(cache.ped)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end
    camera:delete()
    selector:stop()
end)

RegisterNUICallback("spawn", function(data)
    camera:delete()
    selector:stop()

    local coords = spawns?[data.type]?[data.id+1]?.coords
    if not coords then return end

    local player = NDCore.getPlayer()
    if not player then return end

    local clothing = player.metadata.clothing
    exports["fivem-appearance"]:setPlayerModel(clothing.model)

    local ped = PlayerPedId()
    exports["fivem-appearance"]:setPedAppearance(ped, clothing.appearance)

    teleport(ped, coords, false)
    FreezeEntityPosition(ped, false)
    Wait(500)
    DoScreenFadeIn(500)
end)

RegisterNUICallback("select", function(data)
    local line = selector.linedUp[data.lineup]
    if selector.selected == line.character then return end
    
    for i=1, #selector.peds do
        local ped = selector.peds[i]

        if ped == line.ped then
            local soundId = GetSoundId()
            PlaySoundFrontend(soundId, "SELECT", "HUD_FREEMODE_SOUNDSET", true)
            ReleaseSoundId(soundId)

            lib.requestAnimDict("amb@world_human_hang_out_street@female_arms_crossed@idle_a")
            TaskPlayAnim(ped, "amb@world_human_hang_out_street@female_arms_crossed@idle_a", "idle_a", 4.0, 4.0, -1, 49, -1, false, false, false)
            
            SetEntityAlpha(ped, 255, false)
        elseif IsEntityPlayingAnim(ped, "amb@world_human_hang_out_street@female_arms_crossed@idle_a", "idle_a", 3) then
            SetEntityAlpha(ped, 200, false)
            StopAnimTask(ped, "amb@world_human_hang_out_street@female_arms_crossed@idle_a", "idle_a", 2.0)
        end

    end

    selector.selected = line.character
end)

local function createNewCharacter()
    
end

local function deleteCharacter()
    local ped = selector:findPedById(selector.selected)
    -- probaby add comfirm screen here.
    
    if ped and DoesEntityExist(ped) then
        DeletePed(ped)
    end
    TriggerServerEvent("ND:deleteCharacter", selector.selected)
end

local function playAsCharacter()
    selector:select()
    SetNuiFocus(true, true)

    local player = NDCore.getPlayer()
    SendNUIMessage({
        type = "map",
        status = true,
        markers = spawns,
        job = player.job
    })

    DoScreenFadeIn(0)
end

RegisterNUICallback("action", function(data)
    if data.action == "new" then
        createNewCharacter()
    elseif data.action == "delete" then
        deleteCharacter()
    elseif data.action == "play" then
        playAsCharacter()
    end
end)

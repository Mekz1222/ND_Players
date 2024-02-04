local spawns = require "data.spawns"
local camera = require "modules.camera.client"
local creator = require "modules.creator.client"
local selector = require "modules.selector.client"
local config = require "data.configuration"

local function teleport(ped, coords, withVehicle)
    DoScreenFadeOut(500)
    Wait(500)
    FreezeEntityPosition(ped, true)
    
    lib.hideTextUI()
    StartPlayerTeleport(cache.playerId, coords.x, coords.y, coords.z, coords.w, withVehicle, true, true)
    while IsPlayerTeleportActive() or not HasCollisionLoadedAroundEntity(ped) do Wait(10) end
end

local function init(ped)
    TriggerServerEvent("ND_Players:updateBucket", true)
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
    TriggerServerEvent("ND_Players:updateBucket", false)
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
    if not selector.characterAmount or selector.characterAmount >= (config.characterLimit or 4) then
        return lib.notify({
            label = "Max character amount reached",
            position = "top"
        })
    end

    local year, month, day = GetLocalTime()

    if month < 10 then
        month = "0" .. month
    end

    if day < 10 then
        day = "0" .. day
    end

    local input = lib.inputDialog("Create a new character", {
        {
            type = "input",
            label = "First name",
            placeholder = "John",
            required = true,
            min = 3,
            max = 16
        },
        {
            type = "input",
            label = "Last name",
            placeholder = "Doe",
            required = true,
            min = 3,
            max = 16
        },
        {
            type = "date",
            label = "Date of birth",
            icon = {"far", "calendar"},
            format = "DD/MM/YYYY",
            min = ("%s/%s/%s"):format(day, month, year-100),
            max = ("%s/%s/%s"):format(day, month, year-18),
            default = ("%s/%s/%s"):format(day, month, year-25),
            required = true,
            returnString = true
        },
        {
            type = "select",
            label = "Gender",
            options = {
                { label = "Male", value = "male" },
                { label = "Female", value = "female" }
            },
            default = "male",
            required = true
        }
    })

    if not input then return end

    teleport(cache.ped, vec4(402.84, -996.83, -100.00, 182.28))
    camera:delete()
    selector:stop()
    
    creator:start(input, function()
        Wait(1000)
        init(cache.ped)
    end)
end

local function deleteCharacter()
    if not selector.selected then
        return lib.notify({
            title = "Select a character to delete",
            position = "top"
        })
    end

    local alert = lib.alertDialog({
        header = "Delete character?",
        content = ("Are you sure you want to permanantly delete the character by id [%s] this action is irreversible."):format(selector.selected),
        centered = true,
        cancel = true
    })

    if alert ~= "confirm" then return end
    SendNUIMessage({ type = "deleteCharacter" })

    local ped = selector:findPedById(selector.selected)

    if ped and DoesEntityExist(ped) then
        DeletePed(ped)
    end

    TriggerServerEvent("ND_Players:delete", selector.selected)
end

local function playAsCharacter()
    if not selector.selected then
        return lib.notify({
            title = "Select or create a character to play",
            position = "top"
        })
    end

    SendNUIMessage({ type = "selector" })

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
    TriggerServerEvent("ND_Players:updateBucket", false)
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

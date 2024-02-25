local creator = {}
local spawns = require("data.spawns")
local spawnCallbacks = {}

local function manageSpawn(access, cb)
    spawnCallbacks[#spawnCallbacks+1] = {
        access = access,
        cb = cb
    }
end

exports("manageSpawn", manageSpawn)

manageSpawn("DEFAULT", function(player)
    local location = player.metadata?.location
    if not location then return end
    return {
        name = "Last location",
        coords = vec4(location.x, location.y, location.z, location.w),
        image = "last_location.png"
    }
end)

function creator:openMap(player)
    local spawnLocations = lib.table.deepclone(spawns)
    for i=1, #spawnCallbacks do
        local item = spawnCallbacks[i]
        local access = spawnLocations[item.access]
        if not access then goto next end

        local value = item.cb(player)
        if value then
            access[#access+1] = value
        end

        ::next::
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "map",
        status = true,
        markers = spawnLocations,
        job = player.job
    })
end

function creator:start(input, exitCallback)
    local ped = cache.ped

    if input[4] == "male" and GetEntityModel(ped) ~= `mp_m_freemode_01` then
        exports["fivem-appearance"]:setPlayerModel("mp_m_freemode_01")
    elseif input[4] == "female" and GetEntityModel(ped) ~= `mp_f_freemode_01` then
        exports["fivem-appearance"]:setPlayerModel("mp_f_freemode_01")
    end
    Wait(500)

    local function customize(appearance)
        if not appearance then
            return exitCallback and exitCallback()
        end

        DoScreenFadeOut(300)
        Wait(200)

        local player = lib.callback.await("ND_Players:new", false, input, appearance)
        self:openMap(player)
        
        Wait(150)
        DoScreenFadeIn(0)
        TriggerServerEvent("ND_Players:updateBucket", false)
    end
    
    exports["fivem-appearance"]:startPlayerCustomization(customize, {
        ped = false,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        tattoos = false
    })

    DoScreenFadeIn(500)
end

return creator

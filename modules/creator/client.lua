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
    local location = player and player.position or false
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

    self.spawns = spawnLocations

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "map",
        status = true,
        markers = spawnLocations,
        job = player and player.job and player.job.name or nil
    })
end

function creator:start(input)
    local ped = cache.ped
    Wait(500)

    DoScreenFadeOut(300)
    Wait(200)

    local success, player = lib.callback.await("ND_Players:new", false, input)
    self:openMap(player)
    
    Wait(150)
    DoScreenFadeIn(0)
    TriggerServerEvent("ND_Players:updateBucket", false)
    
    DoScreenFadeIn(500)

    
    DoScreenFadeIn(500)
end

return creator

local creator = {}
local spawns = require("data.spawns")

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
        TriggerServerEvent("ND_Players:new", input, appearance)
        
        Wait(200)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "map",
            status = true,
            markers = spawns
        })
        
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

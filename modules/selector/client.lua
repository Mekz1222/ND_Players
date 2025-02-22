local selector = {
    peds = {},
    linedUp = {},
    selected = nil
}

local lineups = {
    vector4(409.29, -997.26, -99.00, 261.20),
    vector4(409.25, -998.08, -99.00, 266.71),
    vector4(409.22, -998.94, -99.00, 269.97),
    vector4(409.20, -999.73, -99.00, 274.27)
}

local function playLightSound()
    local soundId = GetSoundId()
    repeat RequestScriptAudioBank("DLC_GTAO/MUGSHOT_ROOM", false) until RequestScriptAudioBank("DLC_GTAO/MUGSHOT_ROOM", false)
    PlaySoundFrontend(soundId, "Lights_On", "GTAO_MUGSHOT_ROOM_SOUNDS", true)
    ReleaseSoundId(soundId)
end

local function genderAnim(ped)
    return IsPedMale(ped) and "male" or "female"
end

local function createSelectPed(skin, location)
    if not skin then return end

    local model = skin.model
    lib.requestModel(model)
    
    local dummyPed = CreatePed(26, model, location.x, location.y, location.z, location.w, false, false)
    exports["illenium-appearance"]:setPedAppearance(dummyPed, skin.clothing)
    SetEntityAlpha(dummyPed, 200, false)

    return dummyPed
end

function selector:stop()
    self.enabled = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "selector",
        status = false
    })

    for i=1, #self.peds do
        local ped = self.peds[i]
        if DoesEntityExist(ped) then
            DeletePed(ped)
        end
    end

    self.peds = {}
    self.linedUp = {}
    self.selected = nil
end

function selector:start()
    self.peds = {}
    self.linedUp = {}
    self.selected = nil
    
    lib.callback("ND_Players:fetchCharacters", false, function(characters)
        local lineup = 0
        self.linedUp = {}

        for _, character in pairs(characters) do
            lineup += 1
            if lineup > #lineups then break end
            
            local location = lineups[lineup]
            local dummyPed = createSelectPed(character.skin, location)

            self.peds[#self.peds+1] = dummyPed
            self.linedUp[lineup] = {
                character = character.citizenid,
                ped = dummyPed
            }
        end

        self.characterAmount = lineup

        Wait(1000)
        DoScreenFadeIn(1000)
        playLightSound()

        SendNUIMessage({
            type = "lineup",
            amount = lineup
        })
    end)

    self.enabled = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "selector",
        status = true
    })

    while self.enabled do
        DisableAllControlActions(0)
        ThefeedHideThisFrame()
        HideHudAndRadarThisFrame()
        Wait(0)
    end
end

function selector:findPedById(id)
    for i=1, #self.linedUp do
        local info = self.linedUp[i]
        if info.character == id then
            return info.ped
        end
    end
end

function selector:select()
    local ped = self:findPedById(selector.selected)
    if not ped then return end

    TriggerServerEvent("ND_Players:select", selector.selected)

    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, "BASE_JUMP_PASSED", "HUD_AWARDS", true)
    ReleaseSoundId(soundId)
    
    local animDict = ("mp_character_creation@lineup@%s_a"):format(genderAnim(ped))
    lib.requestAnimDict(animDict)
    TaskPlayAnim(ped, animDict, "outro", 8.0, 0.0, -1, 0.0, 0, false, false, false)
    Wait(6300)
    DoScreenFadeOut(1000)
end


return selector

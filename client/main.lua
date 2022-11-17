lineups = {
    vector4(409.29, -997.26, -99.00, 261.20),
    vector4(409.25, -998.08, -99.00, 266.71),
    vector4(409.22, -998.94, -99.00, 269.97),
    vector4(409.20, -999.73, -99.00, 274.27)
}
peds = {}
boards = {}

local test = false
RegisterCommand("switch", function()
    test = not test
    SetNuiFocus(test, test)
    SendNUIMessage({
        type = "display",
        status = test
    })
end, false)

-- TriggerServerEvent("ND:setCharacterOnline", data.id)
-- TriggerServerEvent("ND:deleteCharacter", data.id)
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

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    Wait(2000)
    init()
end)

AddEventHandler("playerSpawned", function()
    init()
end)

lib.callback("ND_CharactersV2:getCharacters", false, function(characters)
    local lineup = 1
    for player, character in pairs(characters) do
        if character.clothing and next(character.clothing) ~= nil then
            if lineup > 1 then break end -- testing
            -- if lineup > #lineups then break end
            print(character.firstName, character.lastName)
            while not HasModelLoaded(character.clothing.model) do
                RequestModel(character.clothing.model)
                Wait(100)
            end
            local ped = CreatePed(2, character.clothing.model, lineups[lineup].x, lineups[lineup].y, lineups[lineup].z, lineups[lineup].w, false, false)
            lineup = lineup + 1
            exports["fivem-appearance"]:setPedTattoos(ped, character.clothing.tattoos)
            exports["fivem-appearance"]:setPedAppearance(ped, character.clothing.appearance)
            peds[#peds+1] = ped

            createBoard(ped)
            playBoardAnim(ped)
            PrepBoard()
            Wait(250)
            MakeBoard(character.firstName, character.lastName, character.dob)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    cleanUp()
    
    DestroyAllCams(true)
    ClearPedTasksImmediately(PlayerPedId())
end)
RegisterNetEvent("ND_CharactersV2:createCharacter", function()
    local source = source
    NDCore.Functions.CreateCharacter(source, data.firstName, data.lastName, data.dob, data.gender, "", "CIV")
end)

lib.callback.register("ND_CharactersV2:getCharacters", function(source)
    return NDCore.Functions.GetPlayerCharacters(source)
end)
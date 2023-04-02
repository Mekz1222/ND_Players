NDCore = exports["ND_Core"]:GetCoreObject()

RegisterNetEvent("ND_CharactersV2:createCharacter", function(data)
    local source = source
    NDCore.Functions.CreateCharacter(source, data.firstName, data.lastName, data.dob, data.gender, function(characterId)
        NDCore.Functions.SetActiveCharacter(source, characterId)
    end)
end)

lib.callback.register("ND_CharactersV2:getCharacters", function(source)
    return NDCore.Functions.GetPlayerCharacters(source)
end)
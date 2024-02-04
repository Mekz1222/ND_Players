local config = lib.load("data.configuration") or {
    characterLimit = 4,
    startingMoney = {
        cash = 2500,
        bank = 8000
    }
}

NDCore.enableMultiCharacter(true)

RegisterNetEvent("ND_Players:delete", function(characterId)
    local src = source
    local player = NDCore.fetchCharacter(characterId, src)
    return player and player.delete()
end)

RegisterNetEvent("ND_Players:select", function(id)
    local src = source
    NDCore.setActiveCharacter(src, tonumber(id))
end)

RegisterNetEvent("ND_Players:new", function(data, clothing)
    local src = source
    local count = 0
    local characters = NDCore.fetchAllCharacters(src)

    for _, __ in pairs(characters) do
        count += 1
    end

    if not data or count >= config.characterLimit then return end

    local player = NDCore.newCharacter(src, {
        firstname = data[1],
        lastname = data[2],
        dob = data[3],
        gender = data[4],
        cash = config.startingMoney.cash,
        bank = config.startingMoney.bank,
        metadata = {
            clothing = clothing or {}
        }
    })

    NDCore.setActiveCharacter(src, player.id)
end)

lib.callback.register("ND_Players:fetchCharacters", function(source)
    return NDCore.fetchAllCharacters(source)
end)

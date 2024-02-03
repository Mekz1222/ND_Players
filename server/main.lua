local config = lib.load("data.configuration") or {
    characterLimit = 4,
    startingMoney = {
        cash = 2500,
        bank = 8000
    }
}

NDCore.enableMultiCharacter(true)

RegisterNetEvent("ND_Players:select", function(id)
    local src = source
    NDCore.setActiveCharacter(src, tonumber(id))
end)

RegisterNetEvent("ND_Players:new", function(data)
    local src = source
    local count = 0
    local characters = NDCore.fetchAllCharacters(src)

    for _, __ in pairs(characters) do
        count += 1
    end

    if count >= config.characterLimit then return end

    local player = NDCore.newCharacter(src, {
        firstname = data.firstName,
        lastname = data.lastName,
        dob = data.dob,
        gender = data.gender,
        cash = config.startingMoney.cash,
        bank = config.startingMoney.bank,
    })

    NDCore.setActiveCharacter(src, tonumber(id))
end)

lib.callback.register("ND_Players:fetchCharacters", function(source)
    return NDCore.fetchAllCharacters(source)
end)

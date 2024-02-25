
local startingItems = lib.load("data.items")

local config = lib.load("data.configuration") or {
    characterLimit = 4,
    startingMoney = {
        cash = 2500,
        bank = 8000
    }
}

NDCore.enableMultiCharacter(true)

RegisterNetEvent("ND_Players:updateBucket", function(update)
    local src = source
    SetPlayerRoutingBucket(src, update and src or 0)
end)

RegisterNetEvent("ND_Players:delete", function(characterId)
    local src = source
    local player = NDCore.fetchCharacter(characterId, src)
    return player and player.delete()
end)

RegisterNetEvent("ND_Players:select", function(id)
    local src = source
    NDCore.setActiveCharacter(src, tonumber(id))
end)

lib.callback.register("ND_Players:new", function(src, data, clothing)
    local count = 0
    local characters = NDCore.fetchAllCharacters(src)

    for _, __ in pairs(characters) do
        count += 1
    end

    if not data or count >= config.characterLimit then return end

    local inventory = {}
    for slot=1, #startingItems do
        local item = startingItems[slot]
        inventory[slot] = {
            name = item[1],
            count = item[2],
            slot = slot
        }
    end

    local player = NDCore.newCharacter(src, {
        firstname = data[1],
        lastname = data[2],
        dob = data[3],
        gender = data[4],
        cash = config.startingMoney.cash,
        bank = config.startingMoney.bank,
        inventory = inventory,
        metadata = {
            clothing = clothing or {}
        }
    })

    return NDCore.setActiveCharacter(src, player.id)
end)

lib.callback.register("ND_Players:fetchCharacters", function(source)
    return NDCore.fetchAllCharacters(source)
end)

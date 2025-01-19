local startingItems = lib.load("data.items")

local config = lib.load("data.configuration") or {
    characterLimit = 4,
    startingMoney = {
        cash = 200,
        bank = 1500
    }
}

config.salaries = lib.load("data.salaries") or {}

NDCore.enableMultiCharacter(true)

lib.callback.register("ND_Players:updateBucketAndUnload", function(src, update)
    SetPlayerRoutingBucket(src, update and src or 0)

    if update then
        local player = NDCore.getPlayer()
        return player and player.unload()
    end
end)

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

local function getSalary(player)
    if not player or not player.job then return end
    
    local job = player.job:lower()
    for name, info in pairs(config.salaries) do
        if info.enabled and name:lower() == job then
            return info
        end
    end
end

CreateThread(function()
    local payChecks = false
    for _, salary in pairs(config.salaries) do
        if salary.enabled then
            payChecks = true
            break
        end
    end

    local lastSalaryPayouts = {}
    while payChecks do
        Wait(60000)

        local time = os.time()
        for _, player in pairs(NDCore.getPlayers()) do
            local salaryInfo = getSalary(player) or config.salaries["default"] or config.salaries["DEFAULT"]
            local src = player.source
            local lastPayout = lastSalaryPayouts[src]

            if not lastPayout then
                lastSalaryPayouts[src] = time -- this will make it to where it won't pay the player until next interval which will prevent pay if switching characters everytime.
            elseif salaryInfo and (not lastPayout or time-lastPayout > salaryInfo.interval*60) then                
                local salary = salaryInfo.amount or 100
                player.addMoney("bank", salary, "Salary")
                player.notify({
                    title = "Salary",
                    description = ("Received $%d."):format(salary),
                    type = "success",
                    icon = "sack-dollar"
                })
                lastSalaryPayouts[src] = time
            end

        end
    end
end)

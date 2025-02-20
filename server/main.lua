local config = lib.load("data.configuration") or {
    characterLimit = 4
}


local function fetchPlayerSkin(citizenId)
    return MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = 1', {citizenId})
  end
  
  local function fetchAllPlayerEntities(license2, license)
    local chars = {}
    local result = MySQL.query.await('SELECT * FROM players WHERE license = ? OR license = ?', {license, license2})
  
    for i = 1, #result do
      local skinData = fetchPlayerSkin(result[i].citizenid)
      local charinfo = json.decode(result[i].charinfo)
      chars[i] = {
        citizenid = '',
        name = '',
        cid = 0,
        metadata = {}
      }
      chars[i].citizenid = result[i].citizenid
      chars[i].name = charinfo.firstname .. ' ' .. charinfo.lastname
      chars[i].cid = charinfo.cid
      chars[i].metadata = {
        { key = "job", value = json.decode(result[i].job).label .. ' (' .. json.decode(result[i].job).grade.name .. ')' },
        { key = "nationality", value = charinfo.nationality },
        { key = "bank", value = lib.math.groupdigits(json.decode(result[i].money).bank) },
        { key = "cash", value = lib.math.groupdigits(json.decode(result[i].money).cash) },
        { key = "birthdate", value = charinfo.birthdate },
        { key = "gender", value = charinfo.gender == 0 and 'Male' or 'Female' },
      }
      chars[i].skin = {
        clothing = json.decode(skinData.skin),
        model = skinData.model
      }
      chars[i].position = json.decode(result[i].position)
    end
  
    return chars
  end

lib.callback.register("ND_Players:updateBucketAndUnload", function(src, update)
    SetPlayerRoutingBucket(src, update and src or 0)

    if update then
        local player = exports.qbx_core:GetPlayer(src)
        return player and exports.qbx_core:Logout(src)
    end
end)

RegisterNetEvent("ND_Players:updateBucket", function(update)
    local src = source
    SetPlayerRoutingBucket(src, update and src or 0)
end)

RegisterNetEvent("ND_Players:delete", function(characterId)
    return characterId and exports.qbx_core:DeleteCharacter(characterId)
end)

RegisterNetEvent("ND_Players:select", function(id)
    local src = source
    exports.qbx_core:Login(src, id)
end)

lib.callback.register("ND_Players:new", function(src, data, clothing)
    local newData = {}

    newData.charinfo = {
        firstname = data[1],
        lastname = data[2],
        gender = data[4],
        birthdate = data[3],
    }

    return exports.qbx_core:Login(src, nil, newData), newData
end)

lib.callback.register('ND_Players:fetchSkin', function(source, citizenid)
    local Ped = MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ?', {citizenid})
    local PlayerData = MySQL.single.await('SELECT * FROM players WHERE citizenid = ?', {citizenid})
    if not Ped or not PlayerData then return end
    Charinfo = json.decode(PlayerData.charinfo)
    return Ped.skin, joaat(Ped.model), Charinfo.gender
end)

lib.callback.register("ND_Players:fetchCharacters", function(source)
    local license2, license = GetPlayerIdentifierByType(source, 'license2'), GetPlayerIdentifierByType(source, 'license')
    
    return fetchAllPlayerEntities(license2, license)
end)
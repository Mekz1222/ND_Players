local test = false
RegisterCommand("switch", function(source, args, rawCommand)
    test = not test
    SetNuiFocus(test, test)
    SendNUIMessage({
        type = "display",
        status = test
    })
end, false)

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
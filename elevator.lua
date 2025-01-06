local elevatorMarker = 22 -- MarkerTypeChevronUpx3
local interactionDistance = 1.5 -- Distance to interact with the marker

-- Main thread
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000 -- Default sleep time

        for _, elevator in ipairs(Config.Elevators) do
            for _, floor in ipairs(elevator.floors) do
                local distance = #(playerCoords - floor.coords)

                -- Draw the marker
                if distance < 20.0 then
                    sleep = 0 -- Reduce sleep for better marker updates
                    DrawMarker(
                        elevatorMarker,
                        floor.coords.x, floor.coords.y, floor.coords.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        1.0, 1.0, 1.0,
                        255, 255, 0, 100,
                        false, false, 2, false, nil, nil, false
                    )
                end

                -- Check interaction
                if distance < interactionDistance then
                    sleep = 0 -- Reduce sleep for interaction updates
                    ShowHelpNotification("Press ~INPUT_CONTEXT~ to use the elevator")

                    if IsControlJustPressed(0, 38) then -- 38 is the default key for E
                        OpenElevatorMenu(playerPed, elevator.floors)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Elevator menu
function OpenElevatorMenu(playerPed, floors)
    local elements = {}

    for _, floor in ipairs(floors) do
        table.insert(elements, {label = floor.label, value = floor.coords})
    end

    -- Simple menu replacement
    local selectedFloor = ShowSimpleMenu(elements)

    if selectedFloor then
        TeleportToFloor(playerPed, selectedFloor)
    end
end

-- Simulated simple menu (since no NativeUI is used)
function ShowSimpleMenu(elements)
    local selected = nil

    for i, element in ipairs(elements) do
        print(string.format("%d: %s", i, element.label))
    end

    print("Enter the floor number:")
    local input = tonumber(GetUserInput())

    if input and elements[input] then
        selected = elements[input].value
    end

    return selected
end

-- Teleport function
function TeleportToFloor(playerPed, coords)
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
    SetEntityHeading(playerPed, 0.0) -- Reset heading for consistency
end

-- Helper: Show help notification
function ShowHelpNotification(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

AddEventHandler('onResourceStart', function (resourceName)
    if resourceName == GetCurrentResourceName() then
        ExecuteCommand('sets tags "LNWK Elevators"')
    end
end)

-- Helper: Simulate user input (stand-in for NativeUI input)
function GetUserInput()
    AddTextEntry('FMMC_KEY_TIP1', "Enter a number:")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 10)

    while UpdateOnscreenKeyboard() == 0 do
        Wait(0)
    end

    if GetOnscreenKeyboardResult() then
        return GetOnscreenKeyboardResult()
    end

    return nil
end

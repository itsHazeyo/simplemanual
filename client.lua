-- Switch and tables to store manual transmission states for each vehicle
local  mtEnabled = false
local automaticMode, sportMode = {}, {}

-- you can change this command to anything
RegisterCommand("mt", function()
    mtEnabled = not mtEnabled -- Toggle the value between true and false
    if mtEnabled==true then
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 255},
            multiline = true,
            args = { GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)))),
                     "Manual Mode enabled"
                   }
        })
    end
    if mtEnabled==false then
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 255},
            multiline = true,
            args = { GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)))), 
                     "Manual Mode disabled"
                    }
        })
    end
end)


Citizen.CreateThread(function()
    while true do 
        Wait(0)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        --I did this for controller players hold Right D-Pad and tap the E-brake to toggle, 'H' and 'Spacebar' on keyboards
        if GetPedInVehicleSeat(vehicle, -1)==playerPed and IsControlPressed(0, 74) and IsControlJustReleased(0, 76) then 
            ExecuteCommand("mt")
        end   
        if GetPedInVehicleSeat(vehicle, -1)==playerPed and DoesEntityExist(vehicle) and not IsEntityDead(vehicle) and mtEnabled==true and not sportMode[vehicle] then
            local modelFlags = GetVehicleHandlingInt(vehicle, 'CCarHandlingData', 'strAdvancedFlags')
            if not automaticMode[vehicle] then 
                automaticMode[vehicle] = modelFlags
            end
            local hexRepresentation
            if modelFlags then
                hexRepresentation = string.format('%X', modelFlags)
            else
                hexRepresentation = "0000C00"
            end
            local hexTable = {}
            for char in hexRepresentation:gmatch('.') do
                table.insert(hexTable, char)
            end      
            -- Modify the third value from the right to 'C'
            if #hexTable >= 3 then
                hexTable[#hexTable - 2] = 'C'
            end     
            -- Join the characters back into a string
            hexRepresentation = table.concat(hexTable)
            local mtModelFlags = tonumber(hexRepresentation, 16)
            SetVehicleHandlingInt(vehicle, 'CCarHandlingData', 'strAdvancedFlags', mtModelFlags)
            sportMode[vehicle] = mtModelFlags
        end
        if GetPedInVehicleSeat(vehicle, -1)==playerPed and DoesEntityExist(vehicle) and not IsEntityDead(vehicle) and mtEnabled==false and sportMode[vehicle] and automaticMode[vehicle] then
            SetVehicleHandlingInt(vehicle, 'CCarHandlingData', 'strAdvancedFlags', automaticMode[vehicle])
            local flagsOne, flagsTwo = table.clear(automaticMode), table.clear(sportMode)
        end
        if mtEnabled and GetPedInVehicleSeat(vehicle, -1)==playerPed then 
            DisableControlAction(0, 73, true)--Shift down 
            DisableControlAction(0, 80, true)--Shift up
        else
            EnableControlAction(0, 73, true)
            EnableControlAction(0, 80, true)
        end
    end
end)
function table.clear(t)
    for k in pairs(t) do
        t[k] = nil
    end
end
local QBCore = exports['qb-core']:GetCoreObject()
local ped = nil

CreateThread(function()
    local model = Config.PedLocation.model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end
    
    ped = CreatePed(4, model, Config.PedLocation.coords.x, Config.PedLocation.coords.y, Config.PedLocation.coords.z - 1.0, Config.PedLocation.coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'pay_vehicle_tax',
            label = Config.Locale.pay_vehicle_tax, -- Pay Vehicle Tax
            icon = 'fas fa-money-bill',
            onSelect = function()
                TriggerServerEvent('ms_vehicletax:server:getVehicleList')
            end
        }
    })
end)

-- 显示车辆列表
-- Show Vehicle List
RegisterNetEvent('ms_vehicletax:client:showVehicleList', function(vehicles)
    local options = {}
    
    if Config.Debug then
        print('^9[MySword]VehTex: ^2Total Vehcles: ' .. #vehicles)
    end
    
    for _, vehicle in pairs(vehicles) do
        local tax = Config.VehicleTax[vehicle.vehicle] or Config.VehicleTax.default
        local vehicleName = QBCore.Shared.Vehicles[vehicle.vehicle] and QBCore.Shared.Vehicles[vehicle.vehicle].name or vehicle.vehicle
        
        if Config.Debug then
            print('^9[MySword]VehTex: ^2Vehicle: ' .. vehicleName .. ' Tax: ' .. tax)
        end
        
        table.insert(options, {
            title = vehicleName,
            description = ('Plate: %s\nTax: $%s\nDays Left: %d days'):format(
                vehicle.plate, 
                tax,
                vehicle.daysLeft
            ),
            icon = 'fas fa-car',
            iconColor = '#3498db',
            onSelect = function()
                TriggerServerEvent('ms_vehicletax:server:payTax', vehicle.id, tax)
            end
        })
    end

    lib.registerContext({
        id = 'vehicle_tax_menu',
        title = Config.Locale.chose_vehicle_to_pay,
        options = options
    })

    lib.showContext('vehicle_tax_menu')
end)

-- 显示税费警告
-- Show Tax Warning
RegisterNetEvent('ms_vehicletax:client:showTaxWarning', function(data)
    local vehicleName = QBCore.Shared.Vehicles[data.vehicle] and QBCore.Shared.Vehicles[data.vehicle].name or data.vehicle
    
    lib.alertDialog({
        header = Config.Locale.tax_warning_title,
        content = ('Your vehicle %s (Plate: %s) is about to be seized!\n\nDays left: %d hours\n\nPlease pay the vehicle tax immediately!'):format(
            vehicleName,
            data.plate,
            data.hoursLeft
        ),
        centered = true,
        type = 'warning',
        size = 'lg'
    })
end)


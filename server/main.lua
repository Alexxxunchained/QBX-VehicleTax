local QBCore = exports['qb-core']:GetCoreObject()

-- 定时检查缴税状态函数
local function CheckVehicleTaxStatus()
    if Config.Debug then
        print('^9[MySword]VehTax: ^2Checking all player vehicle tax status...')
    end

    local currentTime = os.time()
    local result = MySQL.query.await('SELECT * FROM player_vehicles')
    
    for _, vehicle in pairs(result) do
        if vehicle.last_payment then
            local daysSincePayment = (currentTime - vehicle.last_payment) / (24 * 60 * 60)
            local daysLeft = Config.TaxDueTime - daysSincePayment
            
            -- 如果剩余时间少于1天则发送缴税警告 ↓
            -- 我不确定单判断小于等于1的话是否可行，因为在第一次简单测试的时候，发现车辆在1天的时候没有发送缴税警告，但当我加上了大于0的时候就正常了，我也不懂是为什么
            -- Send tax warning if less than 1 day left
            if daysLeft <= 1 and daysLeft > 0 then
                local owner = QBCore.Functions.GetPlayerByCitizenId(vehicle.citizenid)
                -- 如果玩家在线则发送缴税警告
                -- Send tax warning if player is online
                if owner then
                    if Config.Debug then
                        print(('^9[MySword]VehTax: ^2Sending tax warning to player %s for vehicle %s'):format(vehicle.citizenid, vehicle.plate))
                    end
                    
                    TriggerClientEvent('ms_vehicletax:client:showTaxWarning', owner.PlayerData.source, {
                        vehicle = vehicle.vehicle,
                        plate = vehicle.plate,
                        hoursLeft = math.floor(daysLeft * 24)
                    })
                end
            end
        end
    end
end

-- 我知道这样写很蠢，但你就说有没有用吧
CreateThread(function()
    while true do
        CheckVehicleTaxStatus()
        -- Debug模式下每分钟检查一次，正常模式下每30分钟call一次
        -- Debug mode checks every 1 minute, production version checks every 30 minutes
        Wait(Config.WarningInterval)
    end
end)

-- 获取玩家车辆列表
-- Get Player Vehicle List
RegisterNetEvent('ms_vehicletax:server:getVehicleList', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Config.Debug then
        print('^9[MySword]VehTax: ^2Getting vehicle list for player ID: ' .. Player.PlayerData.citizenid)
    end

    local result = MySQL.query.await('SELECT id, vehicle, plate, last_payment FROM player_vehicles WHERE citizenid = ?', {
        Player.PlayerData.citizenid
    })

    if Config.Debug then
        print('^9[MySword]VehTax: ^2Querying ' .. #result .. ' vehicles')
    end

    -- 检查和更新车辆缴税状态
    -- Check and update vehicle tax status
    local currentTime = os.time()
    local vehicles = {}
    
    for _, vehicle in pairs(result) do
        -- 如果是新车，或者应交税款的时间数据为空，则设置为当前时间（保险机制，目前来看运行正常）
        -- If it's a new vehicle or the tax due time data is empty, set it to the current time (insurance mechanism, works fine so far)
        if not vehicle.last_payment then
            MySQL.update('UPDATE player_vehicles SET last_payment = ? WHERE id = ?', {
                currentTime,
                vehicle.id
            })
            vehicle.last_payment = currentTime
            if Config.Debug then
                print('^9[MySword]VehTax: ^2New vehicle ' .. vehicle.plate .. ' set initial tax time')
            end
        end

        local daysSincePayment = (currentTime - vehicle.last_payment) / (24 * 60 * 60)
        
        if daysSincePayment >= Config.TaxDueTime then
            if Config.Debug then
                print('^9[MySword]VehTax: ^2Vehicle ' .. vehicle.plate .. ' not paid on time, deleting')
            end
            MySQL.query('DELETE FROM player_vehicles WHERE id = ?', {vehicle.id})
        else
            table.insert(vehicles, {
                id = vehicle.id,
                vehicle = vehicle.vehicle,
                plate = vehicle.plate,
                last_payment = vehicle.last_payment,
                daysLeft = math.ceil(Config.TaxDueTime - daysSincePayment)
            })
            if Config.Debug then
                print('^9[MySword]VehTax: ^2Adding vehicle to list: ' .. vehicle.vehicle .. ' Plate: ' .. vehicle.plate .. ' Days Left: ' .. math.ceil(Config.TaxDueTime - daysSincePayment))
            end
        end
    end

    TriggerClientEvent('ms_vehicletax:client:showVehicleList', src, vehicles)
end)

-- 处理缴税
-- Handle Tax Payment
RegisterNetEvent('ms_vehicletax:server:payTax', function(vehicleId, taxAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.money.cash >= taxAmount then
        Player.Functions.RemoveMoney('cash', taxAmount)
        MySQL.update('UPDATE player_vehicles SET last_payment = ? WHERE id = ?', {
            os.time(),
            vehicleId
        })
        TriggerClientEvent('ox_lib:notify', src, {
            title = Config.Locale.success_title,
            description = Config.Locale.success_content,
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = Config.Locale.error_title,
            description = Config.Locale.error_content,
            type = 'error'
        })
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

end)
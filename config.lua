Config = {}

Config.Debug = false

-- NPC位置配置
-- NPC Location
Config.PedLocation = {
    coords = vector4(227.27, -793.27, 30.65, 209.97),
    model = 'a_m_m_business_01'
}

-- 车辆税费配置
-- Vehicle Tax List
Config.VehicleTax = {
    default = 1000, -- 若载具未在此列表中，则使用此默认税款 If the vehicle is not in this list, use this default tax
    adder = 2000,
    t20 = 1500,
}

-- 调试模式下使用3分钟，正常模式下使用7天
-- Debug mode uses 3 minutes, normal mode uses 7 days so keep debug mode is false unless u are testing this in local (3mins could wipe out all players vehs)
Config.TaxDueTime = Config.Debug and (3/1440) or 7  -- 3/1440 = 3分钟

-- 警告检查间隔（毫秒）
-- Warning Check Interval (milliseconds)
Config.WarningInterval = Config.Debug and 60000 or 1800000  -- Debug模式1分钟检查一次，正常30分钟检查一次 (Debug mode checks every 1 minute, normal mode checks every 30 minutes)

Config.Locale = {
    pay_vehicle_tax = 'Vehicle Tax',
    chose_vehicle_to_pay = 'Choose a vehicle to pay tax for',
    tax_warning_title = '⚠️Vehicle Tax Warning⚠️',
    tax_warning_content = 'Your vehicle %s (Plate: %s) is about to be seized!\n\nDays left: %d hours\n\nPlease pay the vehicle tax immediately!',
    success_title = 'Success',
    success_content = 'Successfully paid vehicle tax',
    error_title = 'Error',
    error_content = 'Cash is not enough',
}

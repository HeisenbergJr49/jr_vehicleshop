ESX = exports["es_extended"]:getSharedObject()

-- Initialize database on resource start
MySQL.ready(function()
    print('[jr_vehicleshop] Database connection established')
    
    -- Check if tables exist, create if not
    MySQL.query([[ 
        CREATE TABLE IF NOT EXISTS `jr_vehicleshop_purchases` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(60) NOT NULL,
            `vehicle_model` varchar(50) NOT NULL,
            `vehicle_name` varchar(100) NOT NULL,
            `price` int(11) NOT NULL,
            `purchase_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `shop_name` varchar(100) NOT NULL,
            PRIMARY KEY (`id`),
            KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    
    MySQL.query([[ 
        CREATE TABLE IF NOT EXISTS `jr_vehicleshop_stock` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `vehicle_model` varchar(50) NOT NULL,
            `available` tinyint(1) NOT NULL DEFAULT 1,
            `stock_count` int(11) NOT NULL DEFAULT -1,
            `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `vehicle_model` (`vehicle_model`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    
    -- Initialize stock for all vehicles
    for i = 1, #Config.Vehicles do
        local vehicle = Config.Vehicles[i]
        MySQL.insert('INSERT IGNORE INTO jr_vehicleshop_stock (vehicle_model, available, stock_count) VALUES (?, ?, ?)', {
            vehicle.model,
            vehicle.available and 1 or 0,
            -1
        })
    end
    
    print('[jr_vehicleshop] Database tables initialized')
end)

-- Get available vehicles
ESX.RegisterServerCallback('jr_vehicleshop:getVehicles', function(source, cb)
    local vehicles = {}
    
    -- Get stock information from database
    MySQL.query('SELECT vehicle_model, available, stock_count FROM jr_vehicleshop_stock', {}, function(stockData)
        local stockMap = {}
        for i = 1, #stockData do
            stockMap[stockData[i].vehicle_model] = {
                available = stockData[i].available == 1,
                stock = stockData[i].stock_count
            }
        end
        
        -- Merge with config data
        for i = 1, #Config.Vehicles do
            local vehicle = Config.Vehicles[i]
            local stockInfo = stockMap[vehicle.model]
            
            table.insert(vehicles, {
                model = vehicle.model,
                name = vehicle.name,
                brand = vehicle.brand,
                price = vehicle.price,
                category = vehicle.category,
                image = vehicle.image,
                stats = vehicle.stats,
                available = stockInfo and stockInfo.available or vehicle.available,
                stock = stockInfo and stockInfo.stock or -1
            })
        end
        
        cb(vehicles)
    end)
end)

-- Get player money
ESX.RegisterServerCallback('jr_vehicleshop:getPlayerMoney', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        cb(xPlayer.getMoney())
    else
        cb(0)
    end
end)

-- Purchase vehicle
RegisterNetEvent('jr_vehicleshop:purchaseVehicle', function(vehicleModel, shopName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then
        return
    end
    
    -- Find vehicle in config
    local vehicleData = nil
    for i = 1, #Config.Vehicles do
        if Config.Vehicles[i].model == vehicleModel then
            vehicleData = Config.Vehicles[i]
            break
        end
    end
    
    if not vehicleData then
        TriggerClientEvent('esx:showNotification', src, _U('invalid_vehicle'))
        return
    end
    
    -- Check if vehicle is available
    MySQL.scalar('SELECT available FROM jr_vehicleshop_stock WHERE vehicle_model = ?', {vehicleModel}, function(available)
        if not available or available == 0 then
            TriggerClientEvent('esx:showNotification', src, _U('vehicle_not_available'))
            return
        end
        
        -- Check if player has enough money
        local playerMoney = xPlayer.getMoney()
        if playerMoney < vehicleData.price then
            TriggerClientEvent('esx:showNotification', src, _U('not_enough_money'))
            return
        end
        
        -- Remove money from player
        xPlayer.removeMoney(vehicleData.price)
        
        -- Generate unique plate
        local plate = GenerateRandomPlate()
        
        -- Create vehicle properties
        local vehicleProps = {
            model = GetHashKey(vehicleModel),
            plate = plate,
            plateIndex = 0,
            bodyHealth = 1000.0,
            engineHealth = 1000.0,
            tankHealth = 1000.0,
            fuelLevel = 100.0,
            dirtLevel = 0.0,
            color1 = 0,
            color2 = 0,
            pearlescentColor = 0,
            wheelColor = 0,
            wheels = 0,
            windowTint = 0,
            xenonColor = 255,
            customPrimaryColor = {0, 0, 0},
            customSecondaryColor = {0, 0, 0},
            neonEnabled = {false, false, false, false},
            neonColor = {255, 0, 255},
            extras = {},
            tyreSmokeColor = {255, 255, 255},
            modSpoilers = -1,
            modFrontBumper = -1,
            modRearBumper = -1,
            modSideSkirt = -1,
            modExhaust = -1,
            modFrame = -1,
            modGrille = -1,
            modHood = -1,
            modFender = -1,
            modRightFender = -1,
            modRoof = -1,
            modEngine = -1,
            modBrakes = -1,
            modTransmission = -1,
            modHorns = -1,
            modSuspension = -1,
            modArmor = -1,
            modTurbo = false,
            modSmokeEnabled = false,
            modXenon = false,
            windows = {},
            doors = {}
        }
        
        -- Insert into owned_vehicles
        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, stored) VALUES (?, ?, ?, ?, ?, ?)', {
            xPlayer.identifier,
            plate,
            json.encode(vehicleProps),
            'car',
            nil,
            1
        }, function(insertId)
            if insertId then
                -- Log purchase
                MySQL.insert('INSERT INTO jr_vehicleshop_purchases (identifier, vehicle_model, vehicle_name, price, shop_name) VALUES (?, ?, ?, ?, ?)', {
                    xPlayer.identifier,
                    vehicleModel,
                    vehicleData.name,
                    vehicleData.price,
                    shopName
                })
                
                -- Send Discord webhook
                if Config.Webhook.enabled and Config.Webhook.url ~= '' then
                    SendWebhookMessage(xPlayer.getName(), vehicleData.name, vehicleData.price, shopName)
                end
                
                -- Notify player
                TriggerClientEvent('esx:showNotification', src, _U('vehicle_purchased'))
                TriggerClientEvent('esx:showNotification', src, _U('vehicle_spawned'))
                TriggerClientEvent('jr_vehicleshop:purchaseComplete', src)
            else
                -- Refund money if database insert failed
                xPlayer.addMoney(vehicleData.price)
                TriggerClientEvent('esx:showNotification', src, 'Database error, money refunded.')
            end
        end)
    end)
end)

-- Generate random plate
function GenerateRandomPlate()
    local plate = ""
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    for i = 1, 8 do
        local rand = math.random(#chars)
        plate = plate .. string.sub(chars, rand, rand)
    end
    
    -- Check if plate already exists
    MySQL.scalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate}, function(existingPlate)
        if existingPlate then
            return GenerateRandomPlate() -- Generate new plate if exists
        end
    end)
    
    return plate
end

-- Send Discord webhook
function SendWebhookMessage(playerName, vehicleName, price, shopName)
    local content = {
        {
            ["color"] = Config.Webhook.color,
            ["title"] = Config.Webhook.title,
            ["description"] = string.format("**%s** hat ein Fahrzeug gekauft!\n\n**Fahrzeug:** %s\n**Preis:** $%s\n**Shop:** %s\n**Datum:** %s", 
                playerName, 
                vehicleName, 
                ESX.Math.GroupDigits(price), 
                shopName,
                os.date('%d.%m.%Y %H:%M:%S')
            ),
            ["footer"] = {
                ["text"] = "Jr Vehicle Shop System",
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }
    }
    
    PerformHttpRequest(Config.Webhook.url, function(err, text, headers) end, 'POST', json.encode({username = "Vehicle Shop", embeds = content}), { ['Content-Type'] = 'application/json' })
end

-- Admin commands (if you want to add them later)
ESX.RegisterCommand('vehicleshop', 'admin', function(xPlayer, args, showError)
    local action = args.action
    
    if action == 'reload' then
        TriggerEvent('jr_vehicleshop:reload')
        xPlayer.showNotification('Vehicle shop reloaded!')
    elseif action == 'stock' then
        local model = args.model
        local available = args.available == 'true'
        
        MySQL.update('UPDATE jr_vehicleshop_stock SET available = ? WHERE vehicle_model = ?', {available and 1 or 0, model}, function(affectedRows)
            if affectedRows > 0 then
                xPlayer.showNotification(string.format('Stock updated for %s: %s', model, available and 'Available' or 'Unavailable'))
            else
                xPlayer.showNotification('Vehicle not found in stock!')
            end
        end)
    end
end, false, {help = 'Vehicle shop admin commands', validate = true, arguments = {
    {name = 'action', help = 'reload/stock', type = 'string'},
    {name = 'model', help = 'Vehicle model (for stock command)', type = 'string'},
    {name = 'available', help = 'true/false (for stock command)', type = 'string'}
}})

print('[jr_vehicleshop] Server script loaded successfully')
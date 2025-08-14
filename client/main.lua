ESX = exports["es_extended"]:getSharedObject()

-- Local variables
local isInShop = false
local currentShop = nil
local shopMenu = false
local testDriveVehicle = nil
local testDriveTimer = 0
local originalCoords = nil
local blips = {}
local vehiclePreview = nil
local previewCam = nil

-- Initialize
Citizen.CreateThread(function()
    -- Create shop blips
    for i = 1, #Config.Shops do
        local shop = Config.Shops[i]
        local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
        
        SetBlipSprite(blip, shop.blip.sprite)
        SetBlipDisplay(blip, shop.blip.display)
        SetBlipScale(blip, shop.blip.scale)
        SetBlipColour(blip, shop.blip.color)
        SetBlipAsShortRange(blip, true)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shop.name)
        EndTextCommandSetBlipName(blip)
        
        table.insert(blips, blip)
    end
    
    print('[jr_vehicleshop] Client script loaded - ' .. #Config.Shops .. ' shops initialized')
end)

-- Main thread for shop detection and markers
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000
        local nearShop = false
        
        for i = 1, #Config.Shops do
            local shop = Config.Shops[i]
            local distance = #(playerCoords - shop.coords)
            
            if distance < 50.0 then
                sleep = 0
                
                -- Draw marker
                if distance < 10.0 then
                    DrawMarker(
                        shop.marker.type,
                        shop.coords.x, shop.coords.y, shop.coords.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        shop.marker.size.x, shop.marker.size.y, shop.marker.size.z,
                        shop.marker.color.r, shop.marker.color.g, shop.marker.color.b, shop.marker.color.a,
                        false, true, 2, false, nil, nil, false
                    )
                end
                
                -- Check if player is in range to interact
                if distance < 3.0 then
                    nearShop = true
                    currentShop = shop
                    
                    -- Show help text
                    ESX.ShowHelpNotification(_U('press_e_shop'))
                    
                    -- Check for interaction
                    if IsControlJustReleased(0, 38) and not shopMenu then -- E key
                        OpenVehicleShop(shop)
                    end
                end
            end
        end
        
        -- Update shop status
        if not nearShop then
            currentShop = nil
        end
        
        Citizen.Wait(sleep)
    end
end)

-- Test drive timer thread
Citizen.CreateThread(function()
    while true do
        if testDriveTimer > 0 then
            testDriveTimer = testDriveTimer - 1
            
            -- Show remaining time
            ESX.ShowNotification(_U('test_drive') .. ' - ' .. testDriveTimer .. 's', false, false, 1)
            
            if testDriveTimer <= 0 then
                EndTestDrive()
            end
        end
        
        Citizen.Wait(1000)
    end
end)

-- Open vehicle shop
function OpenVehicleShop(shop)
    if shopMenu then return end
    
    shopMenu = true
    isInShop = true
    
    -- Get vehicle data from server
    ESX.TriggerServerCallback('jr_vehicleshop:getVehicles', function(vehicles)
        ESX.TriggerServerCallback('jr_vehicleshop:getPlayerMoney', function(money)
            -- Organize vehicles by category
            local categories = {}
            for i = 1, #Config.VehicleCategories do
                local category = Config.VehicleCategories[i]
                categories[category.name] = {
                    label = Config.Locale == 'de' and category.label or category.labelEN,
                    vehicles = {}
                }
            end
            
            for i = 1, #vehicles do
                local vehicle = vehicles[i]
                if categories[vehicle.category] then
                    table.insert(categories[vehicle.category].vehicles, vehicle)
                end
            end
            
            -- Send data to NUI
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = 'openShop',
                shopName = shop.name,
                categories = categories,
                playerMoney = money,
                locale = Config.Locale,
                translations = Config.Locales[Config.Locale]
            })
        end)
    end)
end

-- Close vehicle shop
function CloseVehicleShop()
    shopMenu = false
    isInShop = false
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'closeShop'
    })
    
    -- Clean up preview
    if vehiclePreview then
        DeleteVehicle(vehiclePreview)
        vehiclePreview = nil
    end
    
    if previewCam then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(previewCam, false)
        previewCam = nil
    end
end

-- Preview vehicle
function PreviewVehicle(model)
    -- Delete existing preview
    if vehiclePreview then
        DeleteVehicle(vehiclePreview)
    end
    
    if previewCam then
        DestroyCam(previewCam, false)
    end
    
    local playerPed = PlayerPedId()
    local spawnCoords = currentShop.spawnPoint.coords
    local spawnHeading = currentShop.spawnPoint.heading
    
    -- Load model
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end
    
    -- Spawn preview vehicle
    vehiclePreview = CreateVehicle(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, false, false)
    SetEntityAsMissionEntity(vehiclePreview, true, true)
    SetVehicleOnGroundProperly(vehiclePreview)
    SetVehicleDoorsLocked(vehiclePreview, 2)
    SetEntityAlpha(vehiclePreview, 200, false)
    
    -- Create camera
    previewCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    local camCoords = spawnCoords + vector3(5.0, 5.0, 2.0)
    SetCamCoord(previewCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(previewCam, vehiclePreview, 0.0, 0.0, 0.0, true)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, true, 1000, true, true)
    
    SetModelAsNoLongerNeeded(hash)
end

-- Start test drive
function StartTestDrive(model)
    if testDriveVehicle then
        return
    end
    
    local playerPed = PlayerPedId()
    originalCoords = GetEntityCoords(playerPed)
    local spawnCoords = currentShop.spawnPoint.coords
    local spawnHeading = currentShop.spawnPoint.heading
    
    -- Load model
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end
    
    -- Spawn test drive vehicle
    testDriveVehicle = CreateVehicle(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, true, false)
    SetEntityAsMissionEntity(testDriveVehicle, true, true)
    SetVehicleOnGroundProperly(testDriveVehicle)
    
    -- Set vehicle properties
    SetVehicleFuelLevel(testDriveVehicle, Config.TestDrive.fuelLevel + 0.0)
    SetVehicleEngineOn(testDriveVehicle, true, true, false)
    
    -- Put player in vehicle
    TaskWarpPedIntoVehicle(playerPed, testDriveVehicle, -1)
    
    -- Start timer
    testDriveTimer = Config.TestDrive.duration
    
    -- Close shop menu
    CloseVehicleShop()
    
    -- Notify player
    ESX.ShowNotification(_U('test_drive_started', testDriveTimer))
    
    SetModelAsNoLongerNeeded(hash)
end

-- End test drive
function EndTestDrive()
    if not testDriveVehicle then
        return
    end
    
    local playerPed = PlayerPedId()
    
    -- Remove player from vehicle
    TaskLeaveVehicle(playerPed, testDriveVehicle, 0)
    
    -- Wait a bit then delete vehicle
    Citizen.Wait(2000)
    DeleteVehicle(testDriveVehicle)
    testDriveVehicle = nil
    testDriveTimer = 0
    
    -- Teleport player back to shop
    if originalCoords then
        SetEntityCoords(playerPed, originalCoords.x, originalCoords.y, originalCoords.z)
        originalCoords = nil
    end
    
    ESX.ShowNotification(_U('test_drive_ended'))
end

-- Purchase vehicle
function PurchaseVehicle(model)
    if not currentShop then
        return
    end
    
    TriggerServerEvent('jr_vehicleshop:purchaseVehicle', model, currentShop.name)
end

-- NUI Callbacks
RegisterNUICallback('closeShop', function(data, cb)
    CloseVehicleShop()
    cb('ok')
end)

RegisterNUICallback('previewVehicle', function(data, cb)
    PreviewVehicle(data.model)
    cb('ok')
end)

RegisterNUICallback('testDrive', function(data, cb)
    if Config.TestDrive.enabled then
        StartTestDrive(data.model)
    else
        ESX.ShowNotification('Test drive is not available')
    end
    cb('ok')
end)

RegisterNUICallback('purchaseVehicle', function(data, cb)
    PurchaseVehicle(data.model)
    cb('ok')
end)

-- Server events
RegisterNetEvent('jr_vehicleshop:purchaseComplete', function()
    CloseVehicleShop()
end)

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Delete preview vehicle
    if vehiclePreview then
        DeleteVehicle(vehiclePreview)
    end
    
    -- Delete test drive vehicle
    if testDriveVehicle then
        DeleteVehicle(testDriveVehicle)
    end
    
    -- Destroy camera
    if previewCam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(previewCam, false)
    end
    
    -- Remove blips
    for i = 1, #blips do
        RemoveBlip(blips[i])
    end
    
    -- Close NUI
    SetNuiFocus(false, false)
end)
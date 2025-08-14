Config = {}

-- Language Settings
Config.Locale = 'de' -- 'de' or 'en'

-- Shop Settings
Config.Shops = {
    {
        name = 'Premium Motors',
        coords = vector3(-56.79, -1096.67, 26.42),
        heading = 25.0,
        blip = {
            sprite = 326,
            color = 2,
            scale = 0.8,
            display = 4
        },
        marker = {
            type = 1,
            size = vector3(2.0, 2.0, 1.0),
            color = {r = 0, g = 255, b = 0, a = 100}
        },
        spawnPoint = {
            coords = vector3(-44.17, -1097.40, 26.42),
            heading = 115.0
        }
    },
    {
        name = 'Luxury Autos',
        coords = vector3(-1255.6, -361.16, 36.91),
        heading = 115.0,
        blip = {
            sprite = 326,
            color = 2,
            scale = 0.8,
            display = 4
        },
        marker = {
            type = 1,
            size = vector3(2.0, 2.0, 1.0),
            color = {r = 0, g = 255, b = 0, a = 100}
        },
        spawnPoint = {
            coords = vector3(-1244.27, -349.63, 36.91),
            heading = 115.0
        }
    }
}

-- Vehicle Categories
Config.VehicleCategories = {
    {
        name = 'compacts',
        label = 'Kompaktwagen',
        labelEN = 'Compact Cars'
    },
    {
        name = 'sedans',
        label = 'Limousinen',
        labelEN = 'Sedans'
    },
    {
        name = 'suvs',
        label = 'SUVs',
        labelEN = 'SUVs'
    },
    {
        name = 'sports',
        label = 'Sportwagen',
        labelEN = 'Sports Cars'
    },
    {
        name = 'super',
        label = 'Supersportwagen',
        labelEN = 'Super Sports'
    },
    {
        name = 'motorcycles',
        label = 'Motorräder',
        labelEN = 'Motorcycles'
    }
}

-- Vehicle Catalog
Config.Vehicles = {
    -- Compact Cars
    {
        model = 'blista',
        name = 'Dinka Blista',
        brand = 'Dinka',
        price = 15000,
        category = 'compacts',
        image = 'blista.jpg',
        stats = {
            speed = 65,
            acceleration = 45,
            braking = 50,
            handling = 70
        },
        available = true
    },
    {
        model = 'dilettante',
        name = 'Karin Dilettante',
        brand = 'Karin',
        price = 18000,
        category = 'compacts',
        image = 'dilettante.jpg',
        stats = {
            speed = 60,
            acceleration = 40,
            braking = 55,
            handling = 75
        },
        available = true
    },
    
    -- Sedans
    {
        model = 'fugitive',
        name = 'Cheval Fugitive',
        brand = 'Cheval',
        price = 35000,
        category = 'sedans',
        image = 'fugitive.jpg',
        stats = {
            speed = 75,
            acceleration = 60,
            braking = 65,
            handling = 70
        },
        available = true
    },
    {
        model = 'intruder',
        name = 'Karin Intruder',
        brand = 'Karin',
        price = 32000,
        category = 'sedans',
        image = 'intruder.jpg',
        stats = {
            speed = 72,
            acceleration = 58,
            braking = 62,
            handling = 68
        },
        available = true
    },
    
    -- SUVs
    {
        model = 'baller',
        name = 'Gallivanter Baller',
        brand = 'Gallivanter',
        price = 85000,
        category = 'suvs',
        image = 'baller.jpg',
        stats = {
            speed = 70,
            acceleration = 55,
            braking = 70,
            handling = 60
        },
        available = true
    },
    {
        model = 'cavalcade',
        name = 'Albany Cavalcade',
        brand = 'Albany',
        price = 75000,
        category = 'suvs',
        image = 'cavalcade.jpg',
        stats = {
            speed = 68,
            acceleration = 52,
            braking = 68,
            handling = 58
        },
        available = true
    },
    
    -- Sports Cars
    {
        model = 'banshee',
        name = 'Bravado Banshee',
        brand = 'Bravado',
        price = 150000,
        category = 'sports',
        image = 'banshee.jpg',
        stats = {
            speed = 90,
            acceleration = 85,
            braking = 75,
            handling = 80
        },
        available = true
    },
    {
        model = 'carbonizzare',
        name = 'Grotti Carbonizzare',
        brand = 'Grotti',
        price = 195000,
        category = 'sports',
        image = 'carbonizzare.jpg',
        stats = {
            speed = 88,
            acceleration = 82,
            braking = 78,
            handling = 85
        },
        available = true
    },
    
    -- Super Sports
    {
        model = 'adder',
        name = 'Truffade Adder',
        brand = 'Truffade',
        price = 1200000,
        category = 'super',
        image = 'adder.jpg',
        stats = {
            speed = 100,
            acceleration = 95,
            braking = 85,
            handling = 90
        },
        available = true
    },
    {
        model = 'entityxf',
        name = 'Överflöd Entity XF',
        brand = 'Överflöd',
        price = 850000,
        category = 'super',
        image = 'entityxf.jpg',
        stats = {
            speed = 98,
            acceleration = 92,
            braking = 82,
            handling = 88
        },
        available = true
    },
    
    -- Motorcycles
    {
        model = 'akuma',
        name = 'Dinka Akuma',
        brand = 'Dinka',
        price = 45000,
        category = 'motorcycles',
        image = 'akuma.jpg',
        stats = {
            speed = 85,
            acceleration = 88,
            braking = 60,
            handling = 92
        },
        available = true
    },
    {
        model = 'bati',
        name = 'Pegassi Bati 801',
        brand = 'Pegassi',
        price = 55000,
        category = 'motorcycles',
        image = 'bati.jpg',
        stats = {
            speed = 88,
            acceleration = 90,
            braking = 65,
            handling = 95
        },
        available = true
    }
}

-- Test Drive Settings
Config.TestDrive = {
    enabled = true,
    duration = 60, -- seconds
    fuelLevel = 100
}

-- Discord Webhook
Config.Webhook = {
    enabled = true,
    url = '', -- Add your Discord webhook URL here
    color = 65280, -- Green color
    title = 'Jr Vehicle Shop'
}

-- Locales
Config.Locales = {
    de = {
        -- UI
        ['vehicle_shop'] = 'Fahrzeughandel',
        ['welcome'] = 'Willkommen bei %s',
        ['browse_vehicles'] = 'Fahrzeuge durchsuchen',
        ['vehicle_details'] = 'Fahrzeugdetails',
        ['purchase_vehicle'] = 'Fahrzeug kaufen',
        ['test_drive'] = 'Probefahrt',
        ['price'] = 'Preis: $%s',
        ['not_enough_money'] = 'Du hast nicht genug Geld!',
        ['vehicle_purchased'] = 'Fahrzeug erfolgreich gekauft!',
        ['test_drive_started'] = 'Probefahrt gestartet. Du hast %s Sekunden.',
        ['test_drive_ended'] = 'Probefahrt beendet.',
        ['vehicle_spawned'] = 'Dein Fahrzeug wurde in der Garage gespawnt.',
        ['close'] = 'Schließen',
        ['buy'] = 'Kaufen',
        ['back'] = 'Zurück',
        
        -- Stats
        ['speed'] = 'Geschwindigkeit',
        ['acceleration'] = 'Beschleunigung',
        ['braking'] = 'Bremsen',
        ['handling'] = 'Handling',
        
        -- Markers
        ['press_e_shop'] = 'Drücke ~INPUT_CONTEXT~ um den Fahrzeughandel zu öffnen',
        
        -- Notifications
        ['invalid_vehicle'] = 'Ungültiges Fahrzeug!',
        ['vehicle_not_available'] = 'Dieses Fahrzeug ist derzeit nicht verfügbar.',
        ['purchase_cancelled'] = 'Kauf abgebrochen.',
    },
    en = {
        -- UI
        ['vehicle_shop'] = 'Vehicle Shop',
        ['welcome'] = 'Welcome to %s',
        ['browse_vehicles'] = 'Browse Vehicles',
        ['vehicle_details'] = 'Vehicle Details',
        ['purchase_vehicle'] = 'Purchase Vehicle',
        ['test_drive'] = 'Test Drive',
        ['price'] = 'Price: $%s',
        ['not_enough_money'] = 'You don\'t have enough money!',
        ['vehicle_purchased'] = 'Vehicle purchased successfully!',
        ['test_drive_started'] = 'Test drive started. You have %s seconds.',
        ['test_drive_ended'] = 'Test drive ended.',
        ['vehicle_spawned'] = 'Your vehicle has been spawned in the garage.',
        ['close'] = 'Close',
        ['buy'] = 'Buy',
        ['back'] = 'Back',
        
        -- Stats
        ['speed'] = 'Speed',
        ['acceleration'] = 'Acceleration',
        ['braking'] = 'Braking',
        ['handling'] = 'Handling',
        
        -- Markers
        ['press_e_shop'] = 'Press ~INPUT_CONTEXT~ to open the vehicle shop',
        
        -- Notifications
        ['invalid_vehicle'] = 'Invalid vehicle!',
        ['vehicle_not_available'] = 'This vehicle is currently not available.',
        ['purchase_cancelled'] = 'Purchase cancelled.',
    }
}

function _U(str, ...)
    if Config.Locales[Config.Locale] and Config.Locales[Config.Locale][str] then
        return string.format(Config.Locales[Config.Locale][str], ...)
    else
        return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
    end
end
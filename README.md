# Jr Vehicle Shop

A modern vehicle shop system for ESX Framework with a sleek NUI interface, inspired by jr_vehicleleasing but designed for direct vehicle purchases.

## Features

- ✅ **Modern ESX Integration** - Uses latest es_extended imports structure
- ✅ **Responsive NUI Interface** - Beautiful, modern web-based interface
- ✅ **Vehicle Categories** - Organized by Compacts, Sedans, SUVs, Sports, Super, Motorcycles
- ✅ **Test Drive System** - Try before you buy with configurable time limits
- ✅ **Vehicle Preview** - 3D camera preview system for vehicles
- ✅ **Database Integration** - MySQL integration with purchase logging and stock management
- ✅ **Discord Webhooks** - Automatic logging of purchases to Discord
- ✅ **Multi-language Support** - German and English translations included
- ✅ **Admin Commands** - In-game commands for stock management
- ✅ **Secure Transactions** - Proper money validation and transaction handling
- ✅ **Multiple Shop Locations** - Configurable shop locations with blips and markers

## Installation

1. **Download & Extract**
   ```bash
   cd resources
   git clone https://github.com/HeisenbergJr49/jr_vehicleshop.git
   ```

2. **Database Setup**
   Execute the SQL file in your database:
   ```bash
   mysql -u your_username -p your_database < jr_vehicleshop/sql/jr_vehicleshop.sql
   ```

3. **Configuration**
   - Edit `config.lua` to customize:
     - Shop locations
     - Vehicle catalog and prices
     - Discord webhook URL
     - Language settings
     - Test drive settings

4. **Add to Server Config**
   Add to your `server.cfg`:
   ```
   ensure jr_vehicleshop
   ```

5. **Dependencies**
   Make sure you have these resources:
   - `es_extended` (latest version)
   - `oxmysql`

## Configuration

### Shop Locations
Edit the `Config.Shops` table in `config.lua`:
```lua
Config.Shops = {
    {
        name = 'Premium Motors',
        coords = vector3(-56.79, -1096.67, 26.42),
        heading = 25.0,
        -- ... more settings
    }
}
```

### Vehicle Catalog
Add/modify vehicles in the `Config.Vehicles` table:
```lua
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
}
```

### Discord Webhook
Set your Discord webhook URL in `config.lua`:
```lua
Config.Webhook = {
    enabled = true,
    url = 'YOUR_DISCORD_WEBHOOK_URL_HERE',
    color = 65280,
    title = 'Jr Vehicle Shop'
}
```

## Admin Commands

- `/vehicleshop reload` - Reload the vehicle shop
- `/vehicleshop stock [model] [true/false]` - Set vehicle availability

## Vehicle Images

Place vehicle images in the `html/images/` directory. Supported formats:
- `.jpg`
- `.png` 
- `.webp`

Image naming should match the vehicle model name (e.g., `adder.jpg` for the Adder).

## Customization

### Adding New Categories
1. Add to `Config.VehicleCategories` in `config.lua`
2. Add vehicles with the new category name
3. The NUI will automatically display the new category

### Styling
Modify `html/style.css` to customize:
- Colors and gradients
- Animations
- Layout and spacing
- Responsive breakpoints

### Translations
Add new languages in `Config.Locales`:
```lua
Config.Locales = {
    de = { ... },
    en = { ... },
    fr = {
        ['vehicle_shop'] = 'Magasin de Véhicules',
        -- ... more translations
    }
}
```

## API

### Client Events
```lua
-- Trigger to open shop (if needed programmatically)
TriggerEvent('jr_vehicleshop:openShop', shopData)

-- Purchase complete event
RegisterNetEvent('jr_vehicleshop:purchaseComplete')
```

### Server Events
```lua
-- Purchase vehicle
TriggerServerEvent('jr_vehicleshop:purchaseVehicle', vehicleModel, shopName)
```

### Server Callbacks
```lua
-- Get available vehicles
ESX.TriggerServerCallback('jr_vehicleshop:getVehicles', function(vehicles) end)

-- Get player money
ESX.TriggerServerCallback('jr_vehicleshop:getPlayerMoney', function(money) end)
```

## Database Schema

The script creates these tables:
- `jr_vehicleshop_purchases` - Purchase history
- `jr_vehicleshop_stock` - Vehicle availability

## Troubleshooting

### Common Issues

1. **NUI not showing**
   - Check browser console for errors
   - Ensure all HTML/CSS/JS files are present
   - Verify `ui_page` in fxmanifest.lua

2. **Database errors**
   - Check MySQL connection
   - Verify oxmysql is running
   - Execute SQL file manually

3. **Vehicles not spawning**
   - Check vehicle models exist
   - Verify spawn points are valid
   - Check ESX owned_vehicles table

4. **Purchase not working**
   - Check player money
   - Verify vehicle availability
   - Check server console for errors

## Support

For support and updates:
- GitHub: [HeisenbergJr49/jr_vehicleshop](https://github.com/HeisenbergJr49/jr_vehicleshop)
- Discord: HeisenbergJr49

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Credits

- ESX Framework team
- FiveM community
- Inspired by jr_vehicleleasing design
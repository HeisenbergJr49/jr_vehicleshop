-- Jr Vehicle Shop Database Schema
-- This script creates necessary tables and modifications for the vehicle shop

-- Create vehicle shop tables if they don't exist
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

-- Create vehicle availability tracking
CREATE TABLE IF NOT EXISTS `jr_vehicleshop_stock` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `vehicle_model` varchar(50) NOT NULL,
    `available` tinyint(1) NOT NULL DEFAULT 1,
    `stock_count` int(11) NOT NULL DEFAULT -1,
    `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `vehicle_model` (`vehicle_model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert initial stock data for all vehicles
INSERT IGNORE INTO `jr_vehicleshop_stock` (`vehicle_model`, `available`, `stock_count`) VALUES
    ('blista', 1, -1),
    ('dilettante', 1, -1),
    ('fugitive', 1, -1),
    ('intruder', 1, -1),
    ('baller', 1, -1),
    ('cavalcade', 1, -1),
    ('banshee', 1, -1),
    ('carbonizzare', 1, -1),
    ('adder', 1, -1),
    ('entityxf', 1, -1),
    ('akuma', 1, -1),
    ('bati', 1, -1);

-- Note: This script assumes you already have the standard ESX owned_vehicles table
-- If you need to create it, uncomment the following:

/*
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
    `owner` varchar(60) NOT NULL,
    `plate` varchar(12) NOT NULL,
    `vehicle` longtext,
    `type` varchar(20) NOT NULL DEFAULT 'car',
    `job` varchar(20) DEFAULT NULL,
    `stored` tinyint(1) NOT NULL DEFAULT 0,
    `parking` varchar(60) DEFAULT NULL,
    `pound` int(1) DEFAULT NULL,
    PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
*/
#!/bin/bash

# Jr Vehicle Shop Installation Script
# This script helps with the installation of the Jr Vehicle Shop resource

echo "================================================"
echo "        Jr Vehicle Shop Installation"
echo "================================================"

# Check if running as root (for MySQL operations)
if [[ $EUID -eq 0 ]]; then
   echo "Don't run this script as root for safety reasons."
   exit 1
fi

echo "1. Checking dependencies..."

# Check if mysql command is available
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL client not found. Please install MySQL client."
    echo "   Ubuntu/Debian: sudo apt-get install mysql-client"
    echo "   CentOS/RHEL: sudo yum install mysql"
    exit 1
fi

echo "✅ MySQL client found"

# Check if the required directories exist
if [ ! -d "sql" ]; then
    echo "❌ SQL directory not found. Make sure you're in the jr_vehicleshop directory."
    exit 1
fi

echo "✅ Required files found"

echo ""
echo "2. Database Setup"
echo "Please provide your MySQL credentials:"

read -p "MySQL Host (default: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "MySQL Database Name: " DB_NAME
if [ -z "$DB_NAME" ]; then
    echo "❌ Database name is required!"
    exit 1
fi

read -p "MySQL Username: " DB_USER
if [ -z "$DB_USER" ]; then
    echo "❌ Username is required!"
    exit 1
fi

read -s -p "MySQL Password: " DB_PASS
echo ""

echo ""
echo "3. Installing database schema..."

# Execute SQL file
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < sql/jr_vehicleshop.sql

if [ $? -eq 0 ]; then
    echo "✅ Database schema installed successfully!"
else
    echo "❌ Database installation failed. Please check your credentials and try again."
    exit 1
fi

echo ""
echo "4. Configuration Setup"

# Check if config.lua exists
if [ ! -f "config.lua" ]; then
    echo "❌ config.lua not found!"
    exit 1
fi

echo "✅ Configuration file found"

# Prompt for Discord webhook
echo ""
read -p "Do you want to configure Discord webhooks? (y/n): " SETUP_WEBHOOK
if [[ $SETUP_WEBHOOK =~ ^[Yy]$ ]]; then
    read -p "Enter your Discord Webhook URL: " WEBHOOK_URL
    if [ ! -z "$WEBHOOK_URL" ]; then
        # Update config.lua with webhook URL (basic sed replacement)
        sed -i "s|url = '',|url = '$WEBHOOK_URL',|g" config.lua
        echo "✅ Discord webhook configured"
    fi
fi

echo ""
echo "5. Final Steps"
echo ""
echo "✅ Installation completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Add 'ensure jr_vehicleshop' to your server.cfg"
echo "   2. Configure shop locations in config.lua"
echo "   3. Add vehicle images to html/images/ directory"
echo "   4. Customize vehicle catalog in config.lua"
echo "   5. Restart your FiveM server"
echo ""
echo "📖 Documentation: Check README.md for detailed configuration"
echo ""
echo "🎮 Admin Commands:"
echo "   /vehicleshop reload - Reload the vehicle shop"
echo "   /vehicleshop stock [model] [true/false] - Set vehicle availability"
echo ""
echo "🎉 Enjoy your new vehicle shop!"
echo "================================================"
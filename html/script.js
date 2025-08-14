// Global variables
let currentVehicles = [];
let selectedCategory = null;
let playerMoney = 0;
let currentVehicle = null;
let translations = {};

// DOM Elements
const container = document.getElementById('container');
const shopTitle = document.getElementById('shopTitle');
const playerMoneyEl = document.getElementById('playerMoney');
const categoriesEl = document.getElementById('categories');
const vehicleGrid = document.getElementById('vehicleGrid');
const vehicleModal = document.getElementById('vehicleModal');
const confirmModal = document.getElementById('confirmModal');
const loadingScreen = document.getElementById('loadingScreen');

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    // Close buttons
    document.getElementById('closeBtn').addEventListener('click', closeShop);
    document.getElementById('modalCloseBtn').addEventListener('click', closeVehicleModal);
    
    // Modal buttons
    document.getElementById('testDriveBtn').addEventListener('click', testDriveVehicle);
    document.getElementById('purchaseBtn').addEventListener('click', showPurchaseConfirm);
    document.getElementById('confirmPurchaseBtn').addEventListener('click', purchaseVehicle);
    document.getElementById('cancelPurchaseBtn').addEventListener('click', closePurchaseConfirm);
    
    // ESC key handler
    document.addEventListener('keyup', function(event) {
        if (event.key === 'Escape') {
            if (!confirmModal.classList.contains('hidden')) {
                closePurchaseConfirm();
            } else if (!vehicleModal.classList.contains('hidden')) {
                closeVehicleModal();
            } else {
                closeShop();
            }
        }
    });
});

// NUI Message Handler
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openShop':
            openShop(data);
            break;
        case 'closeShop':
            closeShop();
            break;
    }
});

// Open shop
function openShop(data) {
    translations = data.translations || {};
    playerMoney = data.playerMoney || 0;
    
    // Update UI elements
    shopTitle.textContent = data.shopName || 'Jr Vehicle Shop';
    updatePlayerMoney();
    translateElements();
    
    // Load categories and vehicles
    loadCategories(data.categories);
    
    // Show container
    container.classList.remove('hidden');
    loadingScreen.classList.add('hidden');
}

// Close shop
function closeShop() {
    container.classList.add('hidden');
    closeVehicleModal();
    closePurchaseConfirm();
    
    // Send close event to game
    fetch(`https://${GetParentResourceName()}/closeShop`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// Load categories
function loadCategories(categories) {
    categoriesEl.innerHTML = '';
    currentVehicles = [];
    
    Object.keys(categories).forEach((categoryName, index) => {
        const category = categories[categoryName];
        const categoryEl = document.createElement('div');
        categoryEl.className = 'category-item';
        categoryEl.innerHTML = `
            <div class="category-name">${category.label}</div>
            <div class="category-count">${category.vehicles.length} vehicles</div>
        `;
        
        categoryEl.addEventListener('click', () => selectCategory(categoryName, category, categoryEl));
        categoriesEl.appendChild(categoryEl);
        
        // Select first category by default
        if (index === 0) {
            selectCategory(categoryName, category, categoryEl);
        }
        
        // Add vehicles to current vehicles array
        currentVehicles = [...currentVehicles, ...category.vehicles];
    });
}

// Select category
function selectCategory(categoryName, category, element) {
    // Update active state
    document.querySelectorAll('.category-item').forEach(el => el.classList.remove('active'));
    element.classList.add('active');
    
    selectedCategory = categoryName;
    loadVehicles(category.vehicles);
}

// Load vehicles
function loadVehicles(vehicles) {
    vehicleGrid.innerHTML = '';
    
    vehicles.forEach((vehicle, index) => {
        const vehicleEl = document.createElement('div');
        vehicleEl.className = `vehicle-card ${!vehicle.available ? 'unavailable' : ''}`;
        
        // Format price
        const formattedPrice = formatMoney(vehicle.price);
        
        vehicleEl.innerHTML = `
            <div class="vehicle-image">
                <img src="images/${vehicle.image}" alt="${vehicle.name}" onerror="this.src='images/placeholder.png'">
                ${!vehicle.available ? '<div class="unavailable-overlay">Not Available</div>' : ''}
            </div>
            <div class="vehicle-info">
                <div class="vehicle-brand">${vehicle.brand}</div>
                <div class="vehicle-name">${vehicle.name}</div>
                <div class="vehicle-price">${formattedPrice}</div>
                <div class="vehicle-stats-mini">
                    <div class="stat-mini">
                        <div class="stat-mini-label">${translations.speed || 'Speed'}</div>
                        <div class="stat-mini-value">${vehicle.stats.speed}</div>
                    </div>
                    <div class="stat-mini">
                        <div class="stat-mini-label">${translations.handling || 'Handling'}</div>
                        <div class="stat-mini-value">${vehicle.stats.handling}</div>
                    </div>
                </div>
            </div>
        `;
        
        if (vehicle.available) {
            vehicleEl.addEventListener('click', () => showVehicleDetails(vehicle));
        }
        
        // Animate appearance
        vehicleEl.style.animationDelay = `${index * 0.1}s`;
        vehicleGrid.appendChild(vehicleEl);
    });
}

// Show vehicle details
function showVehicleDetails(vehicle) {
    currentVehicle = vehicle;
    
    // Update modal content
    document.getElementById('modalVehicleName').textContent = vehicle.name;
    document.getElementById('modalVehicleBrand').textContent = vehicle.brand;
    document.getElementById('modalVehiclePrice').textContent = formatMoney(vehicle.price);
    document.getElementById('modalVehicleImage').src = `images/${vehicle.image}`;
    
    // Update stats
    updateStatBar('speed', vehicle.stats.speed);
    updateStatBar('acceleration', vehicle.stats.acceleration);
    updateStatBar('braking', vehicle.stats.braking);
    updateStatBar('handling', vehicle.stats.handling);
    
    // Show modal
    vehicleModal.classList.remove('hidden');
    
    // Preview vehicle
    previewVehicle(vehicle.model);
}

// Update stat bar
function updateStatBar(statName, value) {
    const bar = document.getElementById(`${statName}Bar`);
    const valueEl = document.getElementById(`${statName}Value`);
    
    if (bar && valueEl) {
        bar.style.width = `${value}%`;
        valueEl.textContent = value;
    }
}

// Close vehicle modal
function closeVehicleModal() {
    vehicleModal.classList.add('hidden');
    currentVehicle = null;
}

// Test drive vehicle
function testDriveVehicle() {
    if (!currentVehicle) return;
    
    fetch(`https://${GetParentResourceName()}/testDrive`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model: currentVehicle.model })
    });
}

// Show purchase confirmation
function showPurchaseConfirm() {
    if (!currentVehicle) return;
    
    // Check if player has enough money
    if (playerMoney < currentVehicle.price) {
        showNotification(translations.not_enough_money || 'You don\'t have enough money!', 'error');
        return;
    }
    
    // Update confirmation modal
    document.getElementById('confirmVehicleName').textContent = currentVehicle.name;
    document.getElementById('confirmPrice').textContent = formatMoney(currentVehicle.price);
    
    confirmModal.classList.remove('hidden');
}

// Close purchase confirmation
function closePurchaseConfirm() {
    confirmModal.classList.add('hidden');
}

// Purchase vehicle
function purchaseVehicle() {
    if (!currentVehicle) return;
    
    fetch(`https://${GetParentResourceName()}/purchaseVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model: currentVehicle.model })
    });
    
    closePurchaseConfirm();
    closeVehicleModal();
}

// Preview vehicle
function previewVehicle(model) {
    fetch(`https://${GetParentResourceName()}/previewVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model: model })
    });
}

// Update player money display
function updatePlayerMoney() {
    playerMoneyEl.textContent = formatMoney(playerMoney);
}

// Format money
function formatMoney(amount) {
    return '$' + amount.toLocaleString();
}

// Translate elements
function translateElements() {
    document.querySelectorAll('[data-translate]').forEach(element => {
        const key = element.getAttribute('data-translate');
        if (translations[key]) {
            element.textContent = translations[key];
        }
    });
}

// Show notification (simple implementation)
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    // Style notification
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        background: ${type === 'error' ? 'rgba(255, 0, 0, 0.9)' : 'rgba(0, 255, 136, 0.9)'};
        color: white;
        border-radius: 8px;
        font-weight: 600;
        z-index: 10000;
        animation: slideIn 0.3s ease;
        max-width: 300px;
    `;
    
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

// Get parent resource name
function GetParentResourceName() {
    return window.location.hostname === '' ? 'jr_vehicleshop' : window.GetParentResourceName();
}

// Utility function for smooth scrolling
function smoothScroll(element, to, duration) {
    const start = element.scrollTop;
    const change = to - start;
    const startTime = performance.now();

    function animateScroll(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = elapsed / duration;

        if (progress < 1) {
            element.scrollTop = start + change * easeInOutQuad(progress);
            requestAnimationFrame(animateScroll);
        } else {
            element.scrollTop = to;
        }
    }

    requestAnimationFrame(animateScroll);
}

function easeInOutQuad(t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
}

// Handle image loading errors
document.addEventListener('error', function(e) {
    if (e.target.tagName === 'IMG') {
        e.target.src = 'images/placeholder.png';
    }
}, true);

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);
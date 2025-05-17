// Sample menu data
const menuItems = [
    {
        id: 1,
        name: "Spicy Chicken Burger",
        description: "Juicy chicken patty with spicy mayo, lettuce, and cheese",
        price: 1299,
        image: "jpg/burger.jpg"
    },
    {
        id: 2,
        name: "Margherita Pizza",
        description: "Classic pizza with tomato sauce, mozzarella, and basil",
        price: 2199,
        image: "jpg/pizza1.jpg"
    },
    {
        id: 3,
        name: "Lemon Meringue Pie",
        description: "Tangy lemon filling with fluffy meringue topping",
        price: 1699,
        image: "jpg/StockCake-Lemon meringue pie_1724530442.jpg"
    },
    {
        id: 4,
        name: "Grilled Salmon",
        description: "Fresh salmon fillet with lemon butter sauce",
        price: 1599,
        image: "jpg/salmon.jpg"
    }
];

// DOM Elements
const menuContainer = document.getElementById('menu-items');
const orderList = document.getElementById('order-list');
const searchInput = document.getElementById('search-input');
const searchBtn = document.getElementById('search-btn');
const searchError = document.getElementById('search-error');
const privacyLink = document.getElementById('privacy-link');
const placeOrderBtn = document.getElementById('place-order-btn');

// Initialize the page
document.addEventListener('DOMContentLoaded', () => {
    renderMenu(menuItems);
    setupEventListeners();
    renderOrderList();
});

// Render menu items
function renderMenu(items) {
    menuContainer.innerHTML = '';
    
    if (items.length === 0) {
        menuContainer.innerHTML = '<p class="center">No items found. Please try a different search.</p>';
        return;
    }
    
    items.forEach(item => {
        const menuItem = document.createElement('div');
        menuItem.className = 'menu-item';
        menuItem.innerHTML = `
            <img src="${item.image}" alt="${item.name}">
            <div class="item-content">
                <h3>${item.name}</h3>
                <p>${item.description}</p>
                <span class="price">Rs.${item.price.toFixed(2)}</span>
                <button class="order-btn" data-id="${item.id}">Add to Cart</button>
                <div class="order-confirmation" id="confirmation-${item.id}"></div>
            </div>
        `;
        menuContainer.appendChild(menuItem);
    });
}

// Setup event listeners
function setupEventListeners() {
    // Search functionality
    searchBtn.addEventListener('click', handleSearch);
    searchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') handleSearch();
    });
    
    // Add to cart buttons (using event delegation)
    menuContainer.addEventListener('click', (e) => {
        if (e.target.classList.contains('order-btn')) {
            const itemId = parseInt(e.target.getAttribute('data-id'));
            const item = menuItems.find(i => i.id === itemId);
            addToCart(item);
        }
    });
    
    // Place order button
    if (placeOrderBtn) {
        placeOrderBtn.addEventListener('click', () => {
            const cart = JSON.parse(localStorage.getItem('foodiehub-cart')) || [];
            if (cart.length > 0) {
                alert('Your order has been placed successfully!');
                localStorage.removeItem('foodiehub-cart');
                renderOrderList();
            }
        });
    }
    
    // Privacy policy link
    privacyLink.addEventListener('click', (e) => {
        e.preventDefault();
        alert('Privacy policy will be displayed here. This is a demo.');
    });
    
    // Contact form
    const contactForm = document.getElementById('contact-form');
    if (contactForm) {
        contactForm.addEventListener('submit', (e) => {
            e.preventDefault();
            alert('Thank you for your message! We will get back to you soon.');
            contactForm.reset();
        });
    }
}

// Handle search functionality
function handleSearch() {
    const searchTerm = searchInput.value.trim();
    
    if (searchTerm === '') {
        searchError.textContent = 'Please enter a search term';
        searchError.style.display = 'block';
        renderMenu(menuItems);
        return;
    }
    
    searchError.style.display = 'none';
    const filteredItems = menuItems.filter(item => 
        item.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
        item.description.toLowerCase().includes(searchTerm.toLowerCase())
    );
    
    renderMenu(filteredItems);
}

// Add item to cart
function addToCart(item) {
    // Show confirmation message
    const confirmation = document.getElementById(`confirmation-${item.id}`);
    confirmation.textContent = `${item.name} added to your cart!`;
    confirmation.style.display = 'block';
    
    // Hide confirmation after 3 seconds
    setTimeout(() => {
        confirmation.style.display = 'none';
    }, 3000);
    
    // Update cart in localStorage
    let cart = JSON.parse(localStorage.getItem('foodiehub-cart')) || [];
    cart.push(item);
    localStorage.setItem('foodiehub-cart', JSON.stringify(cart));
    
    renderOrderList();
}

// Render order list (cart)
function renderOrderList() {
    const cart = JSON.parse(localStorage.getItem('foodiehub-cart')) || [];
    
    if (cart.length === 0) {
        orderList.innerHTML = '<p class="center">Your cart is empty. Add items from our delicious menu!</p>';
        placeOrderBtn.style.display = 'none';
        return;
    }
    
    let html = '<ul>';
    let total = 0;
    
    cart.forEach((item, index) => {
        html += `
            <li>
                <span>${item.name} - Rs.${item.price.toFixed(2)}</span>
                <button class="remove-btn" data-index="${index}">Remove</button>
            </li>
        `;
        total += item.price;
    });
    
    html += `</ul><div class="order-total"><strong>Total: Rs.${total.toFixed(2)}</strong></div>`;
    orderList.innerHTML = html;
    placeOrderBtn.style.display = 'block';
    
    // Add event listeners to remove buttons
    document.querySelectorAll('.remove-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const index = parseInt(e.target.getAttribute('data-index'));
            removeFromCart(index);
        });
    });
}

// Remove item from cart
function removeFromCart(index) {
    let cart = JSON.parse(localStorage.getItem('foodiehub-cart')) || [];
    cart.splice(index, 1);
    localStorage.setItem('foodiehub-cart', JSON.stringify(cart));
    renderOrderList();
}

// Scroll to menu function
function scrollToMenu() {
    document.getElementById('menu').scrollIntoView({ behavior: 'smooth' });
}

// Liquid button effect for contact form
document.addEventListener('DOMContentLoaded', function() {
    const contactBtn = document.querySelector('#contact-form .btn');
    if (contactBtn) {
        contactBtn.addEventListener('mousemove', (e) => {
            const rect = contactBtn.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            contactBtn.style.setProperty('--x', `${x}px`);
            contactBtn.style.setProperty('--y', `${y}px`);
        });
    }
});
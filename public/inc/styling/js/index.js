// Products in the store. | name, price, stock, image, product name
let items = [
    ["sandwich", 41, 99, 'https://image.flaticon.com/icons/svg/3123/3123770.svg', "Sandwich"],
    ["pizza", 68, 99, 'https://image.flaticon.com/icons/svg/3123/3123770.svg', "Pizza"],
    ["bread", 10, 99, 'https://image.flaticon.com/icons/svg/3123/3123770.svg', "Brød"],
    ["apple", 20, 99, 'https://image.flaticon.com/icons/svg/3123/3123770.svg', "Æble"],
    ["hotdog", 30, 99, 'https://image.flaticon.com/icons/svg/3123/3123770.svg', "Hotdog"],
    ["burger", 40, 99, 'https://image.flaticon.com/icons/svg/3123/3123770.svg', "Burger"],
    ["cake", 50, 99, 'https://image.flaticon.com/icons/svg/3123/3123770.svg', "Kage"]
];

let cartItemsElement, cartPricingElement;
let cart = []; // Cart array to store everything in the cart. | name, amount
let ownerTab = [0, false, 0, 0]; // Store information variable. | ownerid, forSale, forSalePrice, storeid
let userID = -1; // Store user id.

// Add product to cart.
function addProduct(product){
    let wasAlreadyAdded = false; // Set wasAlreadyAdded to false.
    for(item of cart) { // Loop through each item in the cart array.
        if(product == item[0]) { // If the item of the cart array is the same as the product we're trying to add.
            wasAlreadyAdded = true; // Set wasAlreadyAdded to true.
            for(prod of items) { // Loop through each item of the items array.
                if (prod[0] == product) { // If the item of the items array is the same as the product we're trying to add.
                    if (prod[2] > item[1]) { // If the products stock is greater than the requested amount.
                        item[1]++; // Added 1 to the item in the cart.
                    }
                }
            }
        }
    }

    if(!wasAlreadyAdded) { // If the product wasn't already in the cart.
        for(prod of items) { // Loop through each item of the items array.
            if (prod[0] == product) { // If the item of the items array is the same as the product we're trying to add.
                if (prod[2] > 1) { // If the products stock is greater than the requested amount.
                    cart.push([product, 1]); // Insert product to the cart array.
                }
            }
        }
    }
    updateCartList(); // Update cart list.
}

// Remove product from cart array.
function removeProduct(product) {
    for(item of cart) { // Loop through each item in the cart array.
        if(product == item[0]) { //If the product is the same as the current item of the cart array.
            if(item[1] > 1) { // If there's more than 1 product in the cart currently.
                item[1]--; // Remove 1 from the cart
            } else { // Else
                cart.pop(item); // Remove the item from the cart.
            }
        }
    }
    updateCartList(); // Update cart list.
}

// Function to update the cart list
function updateCartList(){
    if (cartItemsElement != null) { // If the cartItemsElement ain't undefined.
        cartItemsElement.innerHTML = ""; // Set cartItemsElements html to "".
        cartPricingElement.innerHTML = ""; // Set cartPricingElement html to "".
    }

    cartItemsElement = document.createElement('div'); // Create a new div element.
    cartPricingElement = document.createElement('div'); // Create a new div element.

    for(item of cart) { // Loop through each item of the cart array.
        cartItemsElement.innerHTML += `<p class="cartItem"><span class="cartItemAmount">${item[1]}x</span> ${item[0]}</p>`; // Add html to the cartItemsElement.
        for(product of items) { // Loop through each item of the items array.
            if(product[0] == item[0]) { // If the productname is the same as the current item of the items array loop.
                let fullItemPrice = item[1] * product[1]; // Get the full price of the product.
                cartPricingElement.innerHTML += `<p>${fullItemPrice} DKK</p>`; // Set the cartPricingElement html to the full price.
            }
        }
    }

    let fullPrice = 0; // Set fullprice to 0
    for(item of cart) { // Loop through each item of the cart array.
        for(product of items) { // Loop through each item of the items array.
            if(product[0] == item[0]) { // If the product name is the same as the current item of the cart array loop.
                fullPrice = fullPrice + (item[1] * product[1]); // Set the full price of the cart.
            }
        }
    }
    cartPricingElement.innerHTML += `<p>Total: ${fullPrice} DKK</p>`; // Set the cartPricingElement html to the full price.

    document.getElementById('addCartItemsHere').appendChild(cartItemsElement); // Add cartItemsElement to below addCartItemsHere.
    document.getElementById('addCartItemPricesHere').appendChild(cartPricingElement); // Add cartPricingElement to below addCartItemPricesHere.
}

// Add event handler for the click event on the purchaseButton button.
document.getElementById('purchaseButton').addEventListener('click', () => {
    document.getElementById("swoop").style.display = "none"; // Set the display to none.
    for(item of cart) { // Loop through each item of the cart array.
        $.post('http://swoopfoodmarket/purchase', JSON.stringify({ // post the product information to swoopfoodmarket/purchase
            'product': item[0],
            'amount': item[1],
            'storeID': ownerTab[3]
        }));
    }
    cart = []; // Empty the cart.
    $.post('http://swoopfoodmarket/closeUI', JSON.stringify({})); // Close the ui.
});

// Add event handler for the keyup event.
window.addEventListener('keyup', (e) => {
    if(e.key == "Esc" || e.key == "Escape") { // If the key was ESC.
        document.getElementById("swoop").style.display = "none"; // Set the display to none.
        cart = []; // Empty the cart.
        $.post('http://swoopfoodmarket/closeUI', JSON.stringify({})); // Close the ui.
    }
});

// Function to update the owner tab.
function updateOwnerTab(){
    if(ownerTab[1]) { // If the store is for sale.
        document.getElementById('forSale').innerHTML = `<h3>This store is for sale | price: ${ownerTab[2]} </h3><div id="buyStoreButton" onclick="buyStore();">Buy store</div><div class="floatFixer"></div>`; // Set the forSale html.
    } else { // Else.
        if (userID != -1 && userID == ownerTab[0]) { // If the userId aint -1 and the userid is equal to the stores ownerid.
            document.getElementById('forSale').style.display = "none"; // Set the foresale display to none.
            document.getElementById('notForSale').style.display = "block"; // Set the notforsale display to block.
        } else { // Else.
            document.getElementById('forSale').innerHTML = "<h3>This store ain't for sale.</h3>"; // Set the forsale html.
        }
    }
}

// Function to buy the store.
function buyStore(){
    if(ownerTab[1]) { // If the store is for sale.
        document.getElementById("swoop").style.display = "none"; // Set the swoop display to none
        cart = []; // Empty the cart.
        $.post('http://swoopfoodmarket/purchaseStore', JSON.stringify({ // Post the storeid to swoopfoodmarket/purchaseStore.
            'storeID': ownerTab[3]
        }));
    }
}

// Add event handler for the message event.
window.addEventListener('message', function(event){
    ownerTab = [0, false, 0]; // Reset the store information.
    let data = event.data; // Save the event data to the data variable.
    if(data.enabled) { // If data.enabled is true.
        document.getElementById("swoop").style.display = "block"; // Set swoop display to block.
        ownerTab = [data.ownerID, data.isForSale, data.forSalePrice, data.storeID]; // Set the store information.
        userID = data.playerID; // Set the userid.

        // Save the product information.
        items = [
            ["sandwich", data.priceSandwich, data.stockSandwich, 'https://image.flaticon.com/icons/svg/3123/3123770.svg', "Sandwich"],
            ["pizza", data.pricePizza, data.stockPizza, 'https://image.flaticon.com/icons/svg/2912/2912288.svg', "Pizza"],
            ["bread", data.priceBread, data.stockBread, 'https://image.flaticon.com/icons/svg/3142/3142672.svg', "Brød"],
            ["apple", data.priceApple, data.stockApple, 'https://image.flaticon.com/icons/svg/3143/3143649.svg', "Æble"],
            ["hotdog", data.priceHotdog, data.stockHotdog, 'https://image.flaticon.com/icons/svg/3126/3126350.svg', "Hotdog"],
            ["burger", data.priceBurger, data.stockBurger, 'https://image.flaticon.com/icons/svg/3200/3200143.svg', "Burger"],
            ["cake", data.priceCake, data.stockCake, 'https://image.flaticon.com/icons/svg/3135/3135157.svg', "Kage"]
        ];
        // --
        showProducts(); // Generate the products.
        updateOwnerTab(); // Update the owner tab.
    }
});

// Function to generate the products.
function showProducts(){
    document.getElementById('products').innerHTML = ""; // Remove any previous products.
    for(product of items) { // Loop through each product of the item arrays.
        let elem = document.createElement('div'); // Create a new div element.
        elem.classList = "productTab"; // Set the elements classes.
        // Set the elements html.
        elem.innerHTML = 
        `
        <div class="productHead">
            <p class="productName">${product[4]}</p>
            <div class="productRemoveFromCart" onclick="removeProduct('${product[0]}');">-</div>
            <div class="productAddToCart" onclick="addProduct('${product[0]}');">+</div>
            <div class="floatFixer"></div>
        </div>
        <div class="productBody">
            <img src="${product[3]}" alt="Product picture">
        </div>
        <div class="productFoot">
            <p class="productStock">Stock: ${product[2]}</p>
            <p class="productPrice">${product[1]} DKK</p>
            <div class="floatFixer"></div>
        </div>
        `;
        document.getElementById('products').appendChild(elem); // Add the element below products.
    }
}

// Add event handler for the click event on viewCartPage.
document.getElementById('viewCartPage').addEventListener('click', () => {
    document.getElementById('viewCartPage').classList = "activePage"; // Set the classes to 'activePage'.
    document.getElementById('cartBody').style.display = "block"; // Set the display to block.

    document.getElementById('viewOwnerPage').classList = ""; // Set the classes to ''.
    document.getElementById('ownerBody').style.display = "none"; // Set the display to none.
});

// Add event handler for the click event on viewOwnerPage.
document.getElementById('viewOwnerPage').addEventListener('click', () => {
    document.getElementById('viewOwnerPage').classList = "activePage"; // Set the classes to 'activePage'.
    document.getElementById('ownerBody').style.display = "block"; // Set the display to block.

    document.getElementById('viewCartPage').classList = ""; // Set the classes to ''.
    document.getElementById('cartBody').style.display = "none"; // Set the display to none.
});

// Function to buy stock.
function buyStock(product) {
    let requestedStock = document.getElementById(`buyStockField${product}`).value; // Get the value of the stock input field.
    
    document.getElementById("swoop").style.display = "none"; // Set the display to none.
    cart = []; // Empty the cart.
    $.post('http://swoopfoodmarket/ownerPurchaseStock', JSON.stringify({ // Post the stock information to swoopfoodmarket/ownerPurchaseStock.
        'storeID': ownerTab[3],
        'amount': requestedStock,
        'product': product
    }));
}

// Function to change price of a product
function setPrice(product) {
    let requestedPrice = document.getElementById(`setPriceField${product}`).value; // Get the value of the price input field.
    
    document.getElementById("swoop").style.display = "none"; // Set the display to none.
    cart = []; // Empty the cart.
    $.post('http://swoopfoodmarket/ownerChangePrice', JSON.stringify({ // Post the price information to swoopfoodmarket/ownerChangePrice
        'storeID': ownerTab[3],
        'newPrice': requestedPrice,
        'product': product
    }));
}

// Function to take cash from register
function takeCash() {
    document.getElementById("swoop").style.display = "none"; // Set display to none.
    cart = []; // Empty the cart.
    $.post('http://swoopfoodmarket/takeCashFromRegister', JSON.stringify({ // Post the store information to swoopfoodmarket/takeCashFromRegister
        'storeID': ownerTab[3]
    }));
}
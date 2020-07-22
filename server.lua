local proxy = module("vrp", "lib/Proxy")
vRP = proxy.getInterface("vRP")

-- || Discord webhook for logging activity to dicord.
local discordHook = ""

-- || Vars
local numberOfStores = 20

-- || Default product cost & weight (will change when swoopfoodmarket:getStoreInformation gets called) | product name, item name, default product price, product weight.
local items = {
    {"sandwich", "sandwich", 41, 0.6},
    {"pizza", "pizza", 68, 1.5},
    {"bread", "bread", 10, 0.5},
    {"apple", "apple", 20, 0.2},
    {"hotdog", "hotdog", 30, 0.3},
    {"burger", "burger", 40, 0.5},
    {"cake", "cake", 50, 0.4}
}

-- || Stock prices || item, cost per item.
local stockPrices = {
    {"Sandwich", 12},
    {"Pizza", 25},
    {"Bread", 6},
    {"Apple", 2},
    {"Hotdog", 10},
    {"Burger", 15},
    {"Cake", 22}
}

-- || Get the product information about the specific store.
RegisterServerEvent("swoopfoodmarket:getStoreInformation")
AddEventHandler("swoopfoodmarket:getStoreInformation", function(storeID)
    local _source = source
    local userID = vRP.getUserId({_source}) -- || Gets the users id.
    if storeID ~= nil and storeID > 0 and storeID <= numberOfStores then -- || If the storeid exists & is valid.
        exports.ghmattimysql:execute("SELECT * FROM foodmarkets WHERE marketID = @marketID LIMIT 1", { ['@marketID'] = storeID }, function(result) -- || Get the specific stores information.
            if result[1] ~= nil then -- || If the store was found.
                -- || Set storeOwner to 0 if its undefined.
                local storeOwner = result[1].ownerID
                if storeOwner == nil then storeOwner = 0 end
                
                -- || Set the specific prices for the specific store.
                items = {
                    {"sandwich", "sandwich", result[1].priceSandwich, 0.6},
                    {"pizza", "pizza", result[1].pricePizza, 1.5},
                    {"bread", "bread", result[1].priceBread, 0.5},
                    {"apple", "apple", result[1].priceApple, 0.2},
                    {"hotdog", "hotdog", result[1].priceHotdog, 0.3},
                    {"burger", "burger", result[1].priceBurger, 0.5},
                    {"cake", "cake", result[1].priceCake, 0.4}
                }
                -- || Send the store information to the client.
                TriggerClientEvent("swoopfoodmarket:returnStoreInformation", _source, userID, storeID, storeOwner, result[1].forSale, result[1].forSalePrice, result[1].priceSandwich, result[1].pricePizza, result[1].priceBread, result[1].priceApple, result[1].priceHotdog, result[1].priceBurger, result[1].priceCake, result[1].stockSandwich, result[1].stockPizza, result[1].stockBread, result[1].stockApple, result[1].stockHotdog, result[1].stockBurger, result[1].stockCake)
            end
        end)
    end
end)

-- || Let the player purchase the specific product from the specific store.
RegisterServerEvent("swoopfoodmarket:attemptPurchase")
AddEventHandler("swoopfoodmarket:attemptPurchase", function(product, amount, storeID)
    local _source = source
	local userID = vRP.getUserId({_source}) -- || Gets the users id.
    for key,value in pairs(items) do -- || Loop through each item in the items array.
        if value[1] == product and storeID ~= nil then -- || If the productname matches the current item in the item array.
            if (vRP.getInventoryWeight({userID}) + (value[4] * amount)) <= vRP.getInventoryMaxWeight({userID}) then -- || Check if there's space enough in the players inventory.
                exports.ghmattimysql:execute("SELECT * FROM foodmarkets WHERE marketID = @marketID LIMIT 1", { ['@marketID'] = storeID }, function(result) -- || Get the specific stores information.
                    if result[1] ~= nil then -- || If the store was found.
                        
                        -- || Get the products price & stock.
                        local storePrice = result[1].priceSandwich
                        local stockLeft = 15
                        if product == "sandwich" then
                            stockLeft = result[1].stockSandwich
                            storePrice = result[1].priceSandwich
                        elseif product == "pizza" then
                            stockLeft = result[1].stockPizza
                            storePrice = result[1].pricePizza
                        elseif product == "bread" then
                            stockLeft = result[1].stockBread
                            storePrice = result[1].priceBread
                        elseif product == "apple" then
                            stockLeft = result[1].stockApple
                            storePrice = result[1].priceApple
                        elseif product == "hotdog" then
                            stockLeft = result[1].stockHotdog
                            storePrice = result[1].priceHotdog
                        elseif product == "burger" then
                            stockLeft = result[1].stockBurger
                            storePrice = result[1].priceBurger
                        elseif product == "cake" then
                            stockLeft = result[1].stockCake
                            storePrice = result[1].priceCake
                        end

                        if stockLeft >= amount then -- || If the amount is less than the stock amount.
                            if vRP.tryFullPayment({userID, amount * storePrice}) then -- || Try to sell the player the product.
                                vRP.giveInventoryItem({userID, value[2], amount, false}) -- || If the payment went through, give the player the items.
                                exports.ghmattimysql:execute("UPDATE foodmarkets SET cashRegister = @newCashRegister WHERE marketID = @storeID", { ['@newCashRegister'] = tonumber(result[1].cashRegister + (amount * storePrice)), ['@storeID'] = tonumber(storeID) }, function(result) -- || Add the payment to the cash register.
                                    
                                    -- || Get the stock amount after the purchase & set the correct sql query for the specific product.
                                    local newStockAmount = stockLeft - amount
                                    local updateQuery = "UPDATE foodmarkets SET stockSandwich = @newStockAmount WHERE marketID = @storeID"
                                    if product == "sandwich" then
                                        updateQuery = "UPDATE foodmarkets SET stockSandwich = @newStockAmount WHERE marketID = @storeID"
                                    elseif product == "pizza" then
                                        updateQuery = "UPDATE foodmarkets SET stockPizza = @newStockAmount WHERE marketID = @storeID"
                                    elseif product == "bread" then
                                        updateQuery = "UPDATE foodmarkets SET stockBread = @newStockAmount WHERE marketID = @storeID"
                                    elseif product == "apple" then
                                        updateQuery = "UPDATE foodmarkets SET stockApple = @newStockAmount WHERE marketID = @storeID"
                                    elseif product == "hotdog" then
                                        updateQuery = "UPDATE foodmarkets SET stockHotdog = @newStockAmount WHERE marketID = @storeID"
                                    elseif product == "burger" then
                                        updateQuery = "UPDATE foodmarkets SET stockBurger = @newStockAmount WHERE marketID = @storeID"
                                    elseif product == "cake" then
                                        updateQuery = "UPDATE foodmarkets SET stockCake = @newStockAmount WHERE marketID = @storeID"
                                    end
                                    
                                    -- || Update the specific store with the new stock amount
                                    exports.ghmattimysql:execute(updateQuery, { ['@newStockAmount'] = tonumber(newStockAmount), ['@storeID'] = tonumber(storeID) }, function(result)
                                        if amount == 1 then
                                            TriggerClientEvent("notifyPlayer", _source, "Bought ~g~" .. amount .. " " .. product .. "~w~ for ~g~" .. (amount * storePrice) .. " DKK~w~")
                                        else
                                            TriggerClientEvent("notifyPlayer", _source, "Bought ~g~" .. amount .. " " .. product .. "s~w~ for ~g~" .. (amount * storePrice) .. " DKK~w~")
                                        end
                                    end)
                                end)
                            else
                                TriggerClientEvent("notifyPlayer", _source, "Not enough money") -- || Notify the player that they didn't have enough money.
                            end
                        else
                            TriggerClientEvent("notifyPlayer", _source, "Not enough in stock") -- || Notify the player that there wasn't enough stock available in the store.
                        end
                    end
                end)
            else
                TriggerClientEvent("notifyPlayer", _source, "Not enough space in inventory") -- || Notify the player that they didnt have space enough in their inventories.
            end
        end
    end
end)

-- || Let the player buy the specific store. | only allowed if the specific store is for sale.
RegisterServerEvent("swoopfoodmarket:attemptStorePurchase")
AddEventHandler("swoopfoodmarket:attemptStorePurchase", function(storeID)
    local _source = source
	local userID = vRP.getUserId({_source}) -- || Gets the user id.
    if storeID ~= nil and storeID > 0 and storeID <= numberOfStores then -- || If the storeid is valid.
        exports.ghmattimysql:execute("SELECT forSale, forSalePrice FROM foodmarkets WHERE marketID = @marketID LIMIT 1", { ['@marketID'] = storeID }, function(result) -- || Get the sale information from the specific store.
            if result[1] ~= nil then -- || If the store was found.
                if result[1].forSale then -- || If the store is for sale.
                    vRP.request({_source, "Do you want to buy the store? | Price: " .. result[1].forSalePrice, 10, function(target,ok) -- || Ask the player if he wants to purchase the store.
                        if ok then -- || If the player answer was yes.
                            if vRP.tryFullPayment({userID, result[1].forSalePrice}) then -- || Try to sell the player the specific store.
                                exports.ghmattimysql:execute("UPDATE foodmarkets SET ownerID = @userID, forSale = 0, forSalePrice = 0 WHERE marketID = @marketID", { ['@userID'] = userID, ['marketID'] = storeID }, function(result) -- || If the payment went through, set the new owner to the userid & forSale to false.
                                    TriggerClientEvent("notifyPlayer", _source, "You bought the store") -- || Notify the player that they've bought the store.
                                    -- || Log the store purchase in discord.
                                    local dname = "[DU] Spiller købte butik"
                                    local dmessage = "```\nID: " .. userID .. 
                                                        "\nButik: " .. storeID .. "\n```"
                                    PerformHttpRequest(discordHook, function(err, text, headers) end, 'POST', json.encode({username = dname, content = dmessage}), { ['Content-Type'] = 'application/json' })
                                end)
                            else
                                TriggerClientEvent("notifyPlayer", _source, "Not enough money") -- || Notify the player that they didn't have enough money.
                            end
                        end
                    end})
                end
            end
        end)
    end
end)

-- || Let player purchase more stock of a specific product to the specific store | only allowed if the player is the store owner.
RegisterServerEvent("swoopfoodmarket:attemptPurchaseMoreStock")
AddEventHandler("swoopfoodmarket:attemptPurchaseMoreStock", function(storeID, product, amount)
    local _source = source
    local userID = vRP.getUserId({_source}) -- || Get the users id.
    
    if storeID ~= nil and product ~= nil and amount ~= nil and tonumber(amount) > 0 then -- || If all the required variables is valid.
        for key,value in pairs(stockPrices) do -- || Loop through each item in the stockPrices array
            if value[1] == product then -- || If the productname is equal to the current item in the stockPrices array.
                vRP.request({_source, "Do you want to add " .. amount .. " " .. product .. " to the warehouse | Price: " .. (amount * value[2]) .. "(" .. value[2] .. " DKK pr stk)", 10, function(target,ok) -- || Ask the player if they want to purchase more stock of the specific product.
                    if ok then -- || If the players answer was yes.
                        if vRP.tryFullPayment({userID, (amount * value[2])}) then -- || Try to sell the player the specific stock.
                            exports.ghmattimysql:execute("SELECT * FROM foodmarkets WHERE marketID = @marketID LIMIT 1", { ['@marketID'] = storeID }, function(result) -- || Get the stores information.
                                if result[1] ~= nil then -- || If the store was found.
                                    
                                    -- || Get the stock amount of the specific product & set the correct sql query for the specific product.
                                    local updateQuery = "UPDATE foodmarkets SET stockSandwich = @newStockAmount WHERE marketID = @storeID AND ownerID = @userID"
                                    local stockLeft = 0
                                    
                                    if product == "Sandwich" then
                                        stockLeft = result[1].stockSandwich
                                        updateQuery = "UPDATE foodmarkets SET stockSandwich = @newStockAmount WHERE marketID = @storeID AND ownerID = @userID"
                                    elseif product == "pizza" then
                                        stockLeft = result[1].stockPizza
                                        updateQuery = "UPDATE foodmarkets SET stockPizza = @newStockAmount WHERE marketID = @storeID AND ownerID = @userID"
                                    elseif product == "bread" then
                                        stockLeft = result[1].stockBread
                                        updateQuery = "UPDATE foodmarkets SET stockBread = @newStockAmount WHERE marketID = @storeID AND ownerID = @userID"
                                    elseif product == "Apple" then
                                        stockLeft = result[1].stockApple
                                        updateQuery = "UPDATE foodmarkets SET stockApple = @newStockAmount WHERE marketID = @storeID AND ownerID = @userID"
                                    elseif product == "Hotdog" then
                                        stockLeft = result[1].stockHotdog
                                        updateQuery = "UPDATE foodmarkets SET stockHotdog = @newStockAmount WHERE marketID = @storeID AND ownerID = @userID"
                                    elseif product == "Burger" then
                                        stockLeft = result[1].stockBurger
                                        updateQuery = "UPDATE foodmarkets SET stockBurger = @newStockAmount WHERE marketID = @storeID AND ownerID = @userID"
                                    elseif product == "Cake" then
                                        stockLeft = result[1].stockCake
                                        updateQuery = "UPDATE foodmarkets SET stockCake = @newStockAmount WHERE marketID = @storeID AND ownerID = @userID"
                                    end
                                    
                                    exports.ghmattimysql:execute(updateQuery, { ['@newStockAmount'] = tonumber(stockLeft + amount), ['@storeID'] = tonumber(storeID), ['@userID'] = userID }, function(res) -- || Update the store amount of the specific product in the specific store to the new stock amount.
                                        TriggerClientEvent("notifyPlayer", _source, "Added " .. amount .. " " .. product .. " to the warehouse") -- || Notify the player that they bought the stock.
                                        
                                        -- || Log the purchase to discord.
                                        local dname = "[DU] Spiller købte produkter til butik"
                                        local dmessage = "```\nID: " .. userID .. 
                                                            "\nButik: " .. storeID .. 
                                                            "\nProdukt: " .. product .. 
                                                            "\nMængde: " .. amount .. 
                                                            "\nPris: " .. (amount * value[2]) .. "\n```"
                                        PerformHttpRequest(discordHook, function(err, text, headers) end, 'POST', json.encode({username = dname, content = dmessage}), { ['Content-Type'] = 'application/json' })
                                    end)
                                end
                            end)
                        else
                            TriggerClientEvent("notifyPlayer", _source, "Not enough money") -- || Notify the player that they didn't have enough money.
                        end
                    end
                end})
            end
        end
    end
end)

-- || Let the player change the specific products price at the specific store. | only allowed if the player is the owner of the store.
RegisterServerEvent("swoopfoodmarket:attemptChangeProductPrice")
AddEventHandler("swoopfoodmarket:attemptChangeProductPrice", function(storeID, product, newPrice)
    local _source = source
    local userID = vRP.getUserId({_source}) -- || Get the users id.
    
    if storeID ~= nil and product ~= nil and newPrice ~= nil and tonumber(newPrice) > 0 then -- || Check if the required variables is valid.
        vRP.request({_source, "Do you want to change the price of " .. product .. " to " .. newPrice .. " dkk", 10, function(target,ok) -- || Ask the player if he wants to change the products price.
            if ok then -- || If the players answer was yes.
                exports.ghmattimysql:execute("SELECT * FROM foodmarkets WHERE marketID = @marketID LIMIT 1", { ['@marketID'] = storeID }, function(result) -- || Get the stores information.
                    if result[1] ~= nil then -- ||If the store was found.
                        
                        -- || Get the stock amount of the specific product & set the correct sql query for the specific product.
                        local updateQuery = "UPDATE foodmarkets SET priceSandwich = @newPrice WHERE marketID = @storeID AND ownerID = @userID"
                        local stockLeft = 0
                        
                        if product == "Sandwich" then
                            stockLeft = result[1].stockSandwich
                            updateQuery = "UPDATE foodmarkets SET priceSandwich = @newPrice WHERE marketID = @storeID AND ownerID = @userID"
                        elseif product == "pizza" then
                            stockLeft = result[1].stockPizza
                            updateQuery = "UPDATE foodmarkets SET pricePizza = @newPrice WHERE marketID = @storeID AND ownerID = @userID"
                        elseif product == "bread" then
                            stockLeft = result[1].stockBread
                            updateQuery = "UPDATE foodmarkets SET priceBread = @newPrice WHERE marketID = @storeID AND ownerID = @userID"
                        elseif product == "Apple" then
                            stockLeft = result[1].stockApple
                            updateQuery = "UPDATE foodmarkets SET priceApple = @newPrice WHERE marketID = @storeID AND ownerID = @userID"
                        elseif product == "Hotdog" then
                            stockLeft = result[1].stockHotdog
                            updateQuery = "UPDATE foodmarkets SET priceHotdog = @newPrice WHERE marketID = @storeID AND ownerID = @userID"
                        elseif product == "Burger" then
                            stockLeft = result[1].stockBurger
                            updateQuery = "UPDATE foodmarkets SET priceBurger = @newPrice WHERE marketID = @storeID AND ownerID = @userID"
                        elseif product == "Cake" then
                            stockLeft = result[1].stockCake
                            updateQuery = "UPDATE foodmarkets SET priceCake = @newPrice WHERE marketID = @storeID AND ownerID = @userID"
                        end
                        
                        exports.ghmattimysql:execute(updateQuery, { ['@newPrice'] = tonumber(newPrice), ['@storeID'] = tonumber(storeID), ['@userID'] = userID }, function(res) -- || Set the new price for the specific product in the specific store.
                            TriggerClientEvent("notifyPlayer", _source, "Changed price of " .. product .. " to " .. newPrice .. " dkk") -- || Notify the player that the price was changed.
                            
                            -- || Log  to discord that the price was changed.
                            local dname = "[DU] Spiller ændrede pris på produkt"
                            local dmessage = "```\nID: " .. userID .. 
                                                "\nButik: " .. storeID .. 
                                                "\nProdukt: " .. product .. 
                                                "\nPris: " .. newPrice .. "\n```"
                            PerformHttpRequest(discordHook, function(err, text, headers) end, 'POST', json.encode({username = dname, content = dmessage}), { ['Content-Type'] = 'application/json' })
                        end)
                    end
                end)
            end
        end})
    end
end)

-- || Let the player take the profits from the specific store. | only allowed if the player is the owner of the store.
RegisterServerEvent("swoopfoodmarket:attemptTakeCashFromRegister")
AddEventHandler("swoopfoodmarket:attemptTakeCashFromRegister", function(storeID)
    local _source = source
    local userID = vRP.getUserId({_source}) -- || Get the users id.
    
    if storeID ~= nil then -- || If the storeid ain't undefined.
        exports.ghmattimysql:execute("SELECT ownerID, cashRegister FROM foodmarkets WHERE marketID = @storeID", { ['@storeID'] = tonumber(storeID) }, function(res) -- || Get the owner id & the cashRegister from the specific store.
            if res[1] ~= nil then -- || If the store was found.
                if res[1].ownerID == userID then -- || If the ownerid of the store matches the userid.
                    local currentlyInCashRegister = res[1].cashRegister -- Get the cash from the register
                    vRP.request({_source, "Do you want to take your profits from the cash register (" .. currentlyInCashRegister .. " dkk)", 10, function(target,ok) -- || Ask the player if they want to take the cash from the register.
                        if ok then -- || If the players answer was yes.
                            exports.ghmattimysql:execute("UPDATE foodmarkets SET cashRegister = 0 WHERE marketID = @storeID AND ownerID = @userID", { ['@storeID'] = tonumber(storeID), ['@userID'] = tonumber(userID) }, function(res) -- || Set the cash register to 0 for the specific store.
                                vRP.giveMoney({userID, currentlyInCashRegister}) -- || Give the cash to the player.
                            
                                -- || Log to discord that the player took the cash.
                                local dname = "[DU] Spiller tog penge fra kassen"
                                local dmessage = "```\nID: " .. userID .. 
                                                    "\nButik: " .. storeID .. 
                                                    "\nMængde: " .. currentlyInCashRegister .. "\n```"
                                PerformHttpRequest(discordHook, function(err, text, headers) end, 'POST', json.encode({username = dname, content = dmessage}), { ['Content-Type'] = 'application/json' })
                            end)
                        end
                    end})
                end
            end
        end)
    end
end)
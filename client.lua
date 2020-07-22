-- || Food markets | marketid, x, y, z
local foodMarkets = {
    {1, -47.522762298584,-1756.85717773438,29.4210109710693},
    {2, 25.7454013824463,-1345.26232910156,29.4970207214355},
    {3, 1135.57678222656,-981.78125,46.4157981872559},
    {4, 1163.53820800781,-323.541320800781,69.2050552368164},
    {5, 374.190032958984,327.506713867188,103.566368103027},
    {6, 2555.35766601563,382.16845703125,108.622947692871},
    {7, 2676.76733398438,3281.57788085938,55.2411231994629},
    {8, 1960.50793457031,3741.84008789063,32.3437385559082},
    {9, 1393.23828125,3605.171875,34.9809303283691},
    {10, 1166.18151855469,2709.35327148438,38.15771484375},
    {11, 547.987609863281,2669.7568359375,42.1565132141113},
    {12, 1698.30737304688,4924.37939453125,42.0636749267578},
    {13, 1729.54443359375,6415.76513671875,35.0372200012207},
    {14, -3243.9013671875,1001.40405273438,12.8307056427002},
    {15, -2967.8818359375,390.78662109375,15.0433149337769},
    {16, -3041.17456054688,585.166198730469,7.90893363952637},
    {17, -1820.55725097656,792.770568847656,138.113250732422},
    {18, -1486.76574707031,-379.553985595703,40.163387298584},
    {19, -1223.18127441406,-907.385681152344,12.3263463973999},
    {20, -707.408996582031,-913.681701660156,19.2155857086182}
}

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false,false) -- || Set the nui focus to false. (so the player can move)
    cb('ok')
end)

RegisterNUICallback('purchase', function(data, cb)
    TriggerServerEvent('swoopfoodmarket:attemptPurchase', data.product, data.amount, data.storeID) -- || Attempt the purchase the specific product.
    cb('ok')
end)

RegisterNUICallback('purchaseStore', function(data, cb)
    SetNuiFocus(false,false) -- || Set the nui focus to false. (so the player can move)
    TriggerServerEvent('swoopfoodmarket:attemptStorePurchase', data.storeID) -- || Attempt to purchase the specific store.
    cb('ok')
end)

RegisterNUICallback('ownerPurchaseStock', function(data, cb)
    SetNuiFocus(false,false) -- || Set the nui focus to false. (so the player can move)
    TriggerServerEvent('swoopfoodmarket:attemptPurchaseMoreStock', data.storeID, data.product, data.amount) -- || Attempt to purchase extra stock of the specific product.
    cb('ok')
end)

RegisterNUICallback('ownerChangePrice', function(data, cb)
    SetNuiFocus(false,false) -- || Set the nui focus to false. (so the player can move)
    TriggerServerEvent('swoopfoodmarket:attemptChangeProductPrice', data.storeID, data.product, data.newPrice) -- || Attempt to change the products price.
    cb('ok')
end)

RegisterNUICallback('takeCashFromRegister', function(data, cb)
    SetNuiFocus(false,false) -- || Set the nui focus to false. (so the player can move)
    TriggerServerEvent('swoopfoodmarket:attemptTakeCashFromRegister', data.storeID) -- || Attempt to take the cash from the store.
    cb('ok')
end)

RegisterNetEvent("notifyPlayer")
AddEventHandler("notifyPlayer", function(msg)
    notification(msg) -- || Notify the player with the specific message
end)

RegisterNetEvent("swoopfoodmarket:returnStoreInformation")
AddEventHandler("swoopfoodmarket:returnStoreInformation", function(userID, storeID, storeOwnerID, forSale, forSalePrice, sandwichPrice, pizzaPrice, breadPrice, applePrice, hotdogPrice, burgerPrice, cakePrice, sandwichStock, pizzaStock, breadStock, appleStock, hotdogStock, burgerStock, cakeStock)
    -- || Send nui message with the stores information.
    SendNUIMessage({
        enabled = true,
        storeID = storeID,
        playerID = userID,
        ownerID = storeOwnerID,
        isForSale = forSale,
        forSalePrice = forSalePrice,

        priceSandwich = sandwichPrice,
        pricePizza = pizzaPrice,
        priceBread = breadPrice,
        priceApple = applePrice,
        priceHotdog = hotdogPrice,
        priceBurger = burgerPrice,
        priceCake = cakePrice,

        stockSandwich = sandwichStock,
        stockPizza = pizzaStock,
        stockBread = breadStock,
        stockApple = appleStock,
        stockHotdog = hotdogStock,
        stockBurger = burgerStock,
        stockCake = cakeStock
    })
    SetNuiFocus(true,true) -- || Set nui focus to true. (so the player cant move)
end)


Citizen.CreateThread(function ()
	while true do
        Citizen.Wait(0)
        
        local playerPos = GetEntityCoords(GetPlayerPed(-1)) -- || Get the players current position.
        for key,value in pairs(foodMarkets) do -- || Loop through each market in the foodMarkets array.
            if GetDistanceBetweenCoords(playerPos, value[2],value[3],value[4], true) < 1.5 then -- || If the players distance to the market is less than 1.5.
                
                DrawText3Ds(value[2],value[3],value[4], "Klik ~g~E~s~ for at købe mad") -- || Draw text on the players screen.
                if IsControlJustReleased(1, 51) then -- || If E was pressed
                    TriggerServerEvent('swoopfoodmarket:getStoreInformation', value[1]) -- || Get the stores information.
                end
            end
        end
	end
end)


-- || Draw text on players screen (3d text)
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

-- || Notify the player with a message
function notification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(true, false)
end
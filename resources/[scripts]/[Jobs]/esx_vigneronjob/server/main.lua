
ESX = nil
local PlayersTransforming  = {}
local PlayersSelling       = {}
local PlayersHarvesting = {}
local vine = 1
local jus = 1
local grand_cru = 1
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
	TriggerEvent('ddx_service:activateService', 'vigne', Config.MaxInService)
end

TriggerEvent('ddx_phone:registerNumber', 'vigne', _U('vigneron_client'), true, true)
TriggerEvent('ddx_society:registerSociety', 'vigne', 'Vigneron', 'society_vigne', 'society_vigne', 'society_vigne', {type = 'private'})
local function Harvest(source, zone)
	if PlayersHarvesting[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if zone == "RaisinFarm" then
			local itemQuantity = xPlayer.getInventoryItem('raisin').count
			if itemQuantity >= 100 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_place'))
				return
			else
				SetTimeout(1200, function()
					xPlayer.addInventoryItem('raisin', 1)
					Harvest(source, zone)
				end)
			end
		end
	end
end

RegisterServerEvent('ddx_vigneronjob:startHarvest')
AddEventHandler('ddx_vigneronjob:startHarvest', function(zone)
	local _source = source
  	
	PlayersHarvesting[_source]=true
	TriggerClientEvent('esx:showNotification', _source, _U('tabac_taken'))  
	Harvest(_source,zone)
end)


RegisterServerEvent('ddx_vigneronjob:stopHarvest')
AddEventHandler('ddx_vigneronjob:stopHarvest', function()
	local _source = source
	PlayersHarvesting[_source] = false
end)


local function Transform(source, zone)

	if PlayersTransforming[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if zone == "TraitementVin" then
			local itemQuantity = xPlayer.getInventoryItem('raisin').count
			
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_raisin'))
				return
			else
				local rand = math.random(0,100)
				if (rand >= 98) then
					SetTimeout(1200, function()
						xPlayer.removeInventoryItem('raisin', 2)
						xPlayer.addInventoryItem('grand_cru', 1)
						TriggerClientEvent('esx:showNotification', source, _U('grand_cru'))
						Transform(source, zone)
					end)
				else
					SetTimeout(1200, function()
						xPlayer.removeInventoryItem('raisin', 2)
						xPlayer.addInventoryItem('vine', 1)
				
						Transform(source, zone)
					end)
				end
			end
		elseif zone == "TraitementJus" then
			local itemQuantity = xPlayer.getInventoryItem('raisin').count
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_raisin'))
				return
			else
				SetTimeout(1200, function()
					xPlayer.removeInventoryItem('raisin', 2)
					xPlayer.addInventoryItem('jus_raisin', 1)
		  
					Transform(source, zone)	  
				end)
			end
		end
	end	
end

RegisterServerEvent('ddx_vigneronjob:startTransform')
AddEventHandler('ddx_vigneronjob:startTransform', function(zone)
	local _source = source
		PlayersTransforming[_source]=true
		TriggerClientEvent('esx:showNotification', _source, _U('transforming_in_progress')) 
		Transform(_source,zone)
end)

RegisterServerEvent('ddx_vigneronjob:stopTransform')
AddEventHandler('ddx_vigneronjob:stopTransform', function()

	local _source = source
	PlayersTransforming[_source] = false
end)

local function Sell(source, zone)

	if PlayersSelling[source] == true then
		local xPlayer  = ESX.GetPlayerFromId(source)
		local nombreVin = xPlayer.getInventoryItem('vine').count
		local nombreJus = xPlayer.getInventoryItem('jus_raisin').count
		
		if zone == 'SellFarm' then
			if xPlayer.getInventoryItem('vine').count <= 0 then
				vine = 0
			else
				vine = 1
			end
			
			if xPlayer.getInventoryItem('jus_raisin').count <= 0 then
				jus = 0
			else
				jus = 1
			end
		
			if vine == 0 and jus == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_product_sale'))
				return
			elseif xPlayer.getInventoryItem('vine').count <= 0 and jus == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_vin_sale'))
				vine = 0
				return
			elseif xPlayer.getInventoryItem('jus_raisin').count <= 0 and vine == 0then
				TriggerClientEvent('esx:showNotification', source, _U('no_jus_sale'))
				jus = 0
				return
			else
				if (jus == 1) then
					SetTimeout(1100, function()
						local argent = math.random(30,40) --100 ITEMS
						local argentTotal = argent * nombreJus
						local money = math.random(10,14) --100 ITEMS
						local moneyTotal = money * nombreJus
						xPlayer.removeInventoryItem('jus_raisin', nombreJus)
						local societyAccount = nil

						TriggerEvent('ddx_addonaccount:getSharedAccount', 'society_vigne', function(account)
							societyAccount = account
						end)
						if societyAccount ~= nil then
							xPlayer.addMoney(argentTotal)
							societyAccount.addMoney(moneyTotal)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. argentTotal)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. moneyTotal)
						end
						Sell(source,zone)
					end)
				elseif (vine == 1) then
					SetTimeout(1100, function()
						local argent = math.random(30,40) --100 ITEMS
						local argentTotal = argent * nombreVin
						local money = math.random(10,14) --100 ITEMS
						local moneyTotal = money * nombreVin
						xPlayer.removeInventoryItem('vine', nombreVin)
						local societyAccount = nil

						TriggerEvent('ddx_addonaccount:getSharedAccount', 'society_vigne', function(account)
							societyAccount = account
						end)
						if societyAccount ~= nil then
							xPlayer.addMoney(argentTotal)
							societyAccount.addMoney(moneyTotal)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. argentTotal)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. moneyTotal)
						end
						Sell(source,zone)
					end)
				end
				
			end
		end
	end
end

local function Sell2(source, zone)

	if PlayersSelling[source] == true then
		local xPlayer  = ESX.GetPlayerFromId(source)
		local nombreGrandCru = xPlayer.getInventoryItem('grand_cru').count
		
		if zone == 'SellFarm2' then
			if xPlayer.getInventoryItem('grand_cru').count <= 0 then
				grand_cru = 0
			else
				grand_cru = 1
			end
			
		
			if grand_cru == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_product_sale'))
				return
			elseif xPlayer.getInventoryItem('grand_cru').count <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_product_sale'))
				grand_cru = 0
				return
			else
				if (grand_cru == 1) then
					SetTimeout(1100, function()
						local argent = math.random(30,40)
						local argentTotal = argent * nombreGrandCru
						local money = math.random(5,10)
						local moneyTotal = money * nombreGrandCru
						xPlayer.removeInventoryItem('grand_cru', nombreGrandCru)
						local societyAccount = nil
					
						TriggerEvent('ddx_addonaccount:getSharedAccount', 'society_vigne', function(account)
							societyAccount = account
						end)
						if societyAccount ~= nil then
							xPlayer.addMoney(argentTotal)
							societyAccount.addMoney(moneyTotal)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. argentTotal)
							TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. moneyTotal)		
						end
						Sell2(source,zone)
					end)
				end
				
			end
		end
	end
end

RegisterServerEvent('ddx_vigneronjob:startSell')
AddEventHandler('ddx_vigneronjob:startSell', function(zone)

	local _source = source
	
		PlayersSelling[_source]=true
		TriggerClientEvent('esx:showNotification', _source, _U('sale_in_prog'))
		Sell(_source, zone)

end)

AddEventHandler('ddx_vigneronjob:startSell', function(zone)

	local _source = source
		PlayersSelling[_source]=true
		TriggerClientEvent('esx:showNotification', _source, _U('sale_in_prog'))
		Sell2(_source, zone)

end)

RegisterServerEvent('ddx_vigneronjob:stopSell')
AddEventHandler('ddx_vigneronjob:stopSell', function()

	local _source = source
		TriggerClientEvent('esx:showNotification', _source, 'Vous pouvez ~g~vendre')
		PlayersSelling[_source]=true

end)

RegisterServerEvent('ddx_vigneronjob:getStockItem')
AddEventHandler('ddx_vigneronjob:getStockItem', function(itemName, count)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('ddx_addoninventory:getSharedInventory', 'society_vigne', function(inventory)

		local item = inventory.getItem(itemName)

		if item.count >= count then
			inventory.removeItem(itemName, count)
			xPlayer.addInventoryItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. count .. ' ' .. item.label)

	end)

end)

ESX.RegisterServerCallback('ddx_vigneronjob:getStockItems', function(source, cb)

	TriggerEvent('ddx_addoninventory:getSharedInventory', 'society_vigne', function(inventory)
		cb(inventory.items)
	end)

end)

RegisterServerEvent('ddx_vigneronjob:putStockItems')
AddEventHandler('ddx_vigneronjob:putStockItems', function(itemName, count)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('ddx_addoninventory:getSharedInventory', 'society_vigne', function(inventory)

		local item = inventory.getItem(itemName)

		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('added') .. count .. ' ' .. item.label)

	end)
end)

ESX.RegisterServerCallback('ddx_vigneronjob:getPlayerInventory', function(source, cb)

	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory

	cb({
		items      = items
	})

end)


ESX.RegisterUsableItem('jus_raisin', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('jus_raisin', 1)

	TriggerClientEvent('ddx_status:add', source, 'hunger', 40000)
	TriggerClientEvent('ddx_status:add', source, 'thirst', 120000)
	TriggerClientEvent('ddx_basicneeds:onDrink', source)
	TriggerClientEvent('esx:showNotification', source, _U('used_jus'))

end)

ESX.RegisterUsableItem('grand_cru', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('grand_cru', 1)

	TriggerClientEvent('ddx_status:add', source, 'drunk', 400000)
	TriggerClientEvent('ddx_basicneeds:onDrink', source)
	TriggerClientEvent('esx:showNotification', source, _U('used_grand_cru'))

end)

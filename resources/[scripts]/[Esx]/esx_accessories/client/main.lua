ESX = nil



local HasAlreadyEnteredMarker = false

local LastZone = nil



local CurrentAction = nil

local CurrentActionMsg = ''

local CurrentActionData = {}



local isDead = false



Citizen.CreateThread(function()

	while ESX == nil do

		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

		Citizen.Wait(10)

	end

end)



function OpenShopMenu(accessory)

	local _accessory = string.lower(accessory)

	local restrict = {}



	restrict = { _accessory .. '_1', _accessory .. '_2' }

	

	TriggerEvent('ddx_skin:openRestrictedMenu', function(data, menu)

		menu.close()



		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {

			title = _U('valid_purchase'),

			elements = {

				{label = _U('no'), value = 'no'},

				{label = _U('yes'), rightlabel = {ESX.Math.GroupDigits(Config.Price)}, value = 'yes'}

			}

		}, function(data, menu)

			menu.close()



			if data.current.value == 'yes' then

				ESX.TriggerServerCallback('ddx_accessories:checkMoney', function(hasEnoughMoney)

					if hasEnoughMoney then

						TriggerServerEvent('ddx_accessories:pay')

						TriggerEvent('skinchanger:getSkin', function(skin)

							TriggerServerEvent('ddx_accessories:save', skin, accessory)

						end)

					else

						TriggerEvent('ddx_skin:getLastSkin', function(skin)

							TriggerEvent('skinchanger:loadSkin', skin)

						end)

						ESX.ShowNotification(_U('not_enough_money'))

					end

				end)

			end



			if data.current.value == 'no' then

				local player = PlayerPedId()

				TriggerEvent('ddx_skin:getLastSkin', function(skin)

					TriggerEvent('skinchanger:loadSkin', skin)

				end)

				if accessory == "Ears" then

					ClearPedProp(player, 2)

				elseif accessory == "Mask" then

					SetPedComponentVariation(player, 1, 0 ,0, 2)

				elseif accessory == "Helmet" then

					ClearPedProp(player, 0)

				elseif accessory == "Glasses" then

					SetPedPropIndex(player, 1, -1, 0, 0)

				end

			end



			CurrentAction = 'shop_menu'

			CurrentActionMsg = _U('press_access')

			CurrentActionData = {}

		end, function(data, menu)

			CurrentAction = 'shop_menu'

			CurrentActionMsg = _U('press_access')

			CurrentActionData = {}

		end)

	end, function(data, menu)

		CurrentAction = 'shop_menu'

		CurrentActionMsg = _U('press_access')

		CurrentActionData = {}

	end, restrict)

end



AddEventHandler('playerSpawned', function()

	isDead = false

end)



AddEventHandler('esx:onPlayerDeath', function()

	isDead = true

end)



AddEventHandler('ddx_accessories:hasEnteredMarker', function(zone)

	CurrentAction = 'shop_menu'

	CurrentActionMsg = _U('press_access')

	CurrentActionData = { accessory = zone }

end)



AddEventHandler('ddx_accessories:hasExitedMarker', function(zone)

	ESX.UI.Menu.CloseAll()

	CurrentAction = nil

end)



-- Create Blips --

Citizen.CreateThread(function()

	for k, v in pairs(Config.ShopsBlips) do

		for i = 1, #v.Pos, 1 do

			local blip = AddBlipForCoord(v.Pos[i])



			SetBlipSprite(blip, v.Blip.sprite)

			SetBlipDisplay(blip, 4)

			SetBlipScale(blip, 0.8)

			SetBlipAsShortRange(blip, true)



			BeginTextCommandSetBlipName("STRING")

			AddTextComponentSubstringPlayerName("Magasin de Masque")

			EndTextCommandSetBlipName(blip)

		end

	end

end)



-- Display markers

Citizen.CreateThread(function()

	while true do

		Citizen.Wait(0)

		local coords = GetEntityCoords(PlayerPedId())

		for k, v in pairs(Config.Zones) do

			for i = 1, #v.Pos, 1 do

				if GetDistanceBetweenCoords(coords, v.Pos[i], true) < Config.DrawDistance then

					DrawMarker(29, v.Pos[i], vector3(0.0, 0.0, 0.0), vector3(0.0, 180.0, 0.0), vector3(0.5, 0.5, 0.5), 0, 255, 0, 100, true, false, 2, false)

				end

			end

		end

	end

end)



Citizen.CreateThread(function()

	while true do

		Citizen.Wait(200)

		local coords = GetEntityCoords(PlayerPedId())

		local isInMarker = false

		local currentZone = nil



		for k,v in pairs(Config.Zones) do

			for i = 1, #v.Pos, 1 do

				if GetDistanceBetweenCoords(coords, v.Pos[i], true) < Config.Size.x then

					isInMarker = true

					currentZone = k

				end

			end

		end



		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then

			HasAlreadyEnteredMarker = true

			LastZone = currentZone

			TriggerEvent('ddx_accessories:hasEnteredMarker', currentZone)

		end



		if not isInMarker and HasAlreadyEnteredMarker then

			HasAlreadyEnteredMarker = false

			TriggerEvent('ddx_accessories:hasExitedMarker', LastZone)

		end

	end

end)



-- Key controls

Citizen.CreateThread(function()

	while true do

		Citizen.Wait(0)

		

		if CurrentAction ~= nil then

			ESX.ShowHelpNotification(CurrentActionMsg)



			if IsControlJustReleased(0, 38) and CurrentActionData.accessory then

				OpenShopMenu(CurrentActionData.accessory)

				CurrentAction = nil

			end

		elseif CurrentAction == nil then

			Citizen.Wait(500)

		end

	end

end)
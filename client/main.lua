local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

dataLoaded = false

ESX = nil
blip = nil

gangName	= nil
rankName	= nil
salary		= 0
isBoss		= false

BlipSprite  = 176
BlipDisplay = 4
BlipScale   = 1.4
BlipColour  = 49

blipPos					= nil
weaponLOC 				= nil
itemLOC					= nil
bossLOC					= nil
moneyLOC				= nil
vehicleSpawnLOC			= nil
vehicleSpawnH			= nil
vehicleDeleteLOC		= nil
vehicleSpawnerLOC		= nil
vehicle 				= nil
vehiclePrimaryColor 	= 0
vehicleSecondaryColor 	= 0

checkStarted			= false
closeToArea				= false
HasAlreadyEnteredMarker	= false
LastPart				= nil
CurrentAction			= nil
CurrentActionMsg		= nil
lastTime				= 0

IsHandcuffed      		= false
IsDragged               = false
CopPed                  = 0

Citizen.CreateThread(function()
	
	Wait(6000)
	
	while ESX == nil do
		TriggerEvent('bib:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
    end
	
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	
	loadPlayerData()
	
end)

RegisterNetEvent('gang:reload')
AddEventHandler('gang:reload', function()
	loadPlayerData()
end)

RegisterNetEvent('gang:stop')
AddEventHandler('gang:stop', function()
	gangName = nil
	RemoveBlip(blip)
	TriggerEvent('CUI:loadGangData', 'Family', 'Bi Family')
end)

function loadPlayerData()

	ESX.TriggerServerCallback('gang:getPlayerGangData', function(result)
	
		if result == nil then
			dataLoaded = true
			TriggerEvent('CUI:loadGangData', 'Family', 'Bi Family')
		else
			gangName = result.gang_name
			rankName = result.rank_name
			salary = result.salary
			isBoss = result.is_boss
			dataLoaded = true
			
			ESX.TriggerServerCallback('gang:GetGangData', function(result)
			
				if result then
			
					v = json.decode(result[1].data)
			
					blip = AddBlipForCoord(v.Blip.x, v.Blip.y, v.Blip.z)

					SetBlipSprite (blip, BlipSprite)
					SetBlipDisplay(blip, BlipDisplay)
					SetBlipScale  (blip, BlipScale)
					SetBlipColour (blip, BlipColour)
					SetBlipAsShortRange(blip, false)

					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(gangName)
					EndTextCommandSetBlipName(blip)
					
					blipPos					= v.Blip
					weaponLOC 				= v.Weapon
					itemLOC 				= v.Items
					bossLOC 				= v.Boss
					moneyLOC 				= v.Money
					vehicleSpawnLOC			= {
						x = v.VehicleSpawnLocation.x,
						y = v.VehicleSpawnLocation.y,
						z = v.VehicleSpawnLocation.z
					}
					vehicleSpawnH			= v.VehicleSpawnLocation.h
					vehicleDeleteLOC		= v.VehicleDestroyer
					vehicleSpawnerLOC		= v.VehicleSpawner
					
					startThread()
					startActionMenuThread()
					TriggerEvent('CUI:loadGangData', gangName, rankName)
				
				end
			
			end, gangName)
			
			TriggerEvent('esx_vehicleshop:gangUpdate',isBoss, gangName)
			
		end
		
	end)
	
end

function startThread()

	Citizen.CreateThread(function()
		while gangName ~= nil do
			local playerPed = GetPlayerPed(-1)
			local coords    = GetEntityCoords(playerPed)
			if GetDistanceBetweenCoords(coords,  blipPos.x,  blipPos.y,  blipPos.z,  true) < Config.DrawDistance then
				DrawMarker(1, weaponLOC.x, weaponLOC.y, weaponLOC.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 0, 0 , 255, 100, false, true, 2, false, false, false, false)
				DrawMarker(1, itemLOC.x, itemLOC.y, itemLOC.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 0, 0 , 255, 100, false, true, 2, false, false, false, false)
				DrawMarker(36, vehicleSpawnerLOC.x, vehicleSpawnerLOC.y, vehicleSpawnerLOC.z + 1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 255, 255, 0, 100, false, true, 2, false, false, false, false)
				DrawMarker(1, vehicleDeleteLOC.x, vehicleDeleteLOC.y, vehicleDeleteLOC.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x * 2, Config.MarkerSize.y * 2, Config.MarkerSize.z, 255, 0, 0, 100, false, true, 2, false, false, false, false)
				if isBoss then
					DrawMarker(32, bossLOC.x, bossLOC.y, bossLOC.z + 1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 200, 200, 200, 100, false, true, 2, false, false, false, false)
					DrawMarker(29, moneyLOC.x, moneyLOC.y, moneyLOC.z + 1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 0, 255, 0, 100, false, true, 2, false, false, false, false)
				end
				closeToArea = true
				if not checkStarted then
					startCheck()
				end
				Wait(0)
			elseif GetDistanceBetweenCoords(coords,  blipPos.x,  blipPos.y,  blipPos.z,  true) > 500.0 then
				closeToArea = false
				Wait(1000)
			else
				closeToArea = false
				Wait(10)
			end
		
		end
	end)

end

function startActionMenuThread()

	Citizen.CreateThread(function()
		while gangName ~= nil do
			if IsControlPressed(0,  Keys['F9']) and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'gang_actions') and (GetGameTimer() - lastTime) > 150 then
				OpenGangActionsMenu()
				lastTime = GetGameTimer()
			end
			Wait(0)
		end
	end)

end

function OpenGangActionsMenu()

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'gang_actions',
		{
			title    = _U('actions'),
			align    = 'top-left',
			elements = {
				{label = _U('search'),        	value = 'body_search'},
				{label = _U('handcuff'),    	value = 'handcuff'},
				{label = _U('drag'),      		value = 'drag'},
				{label = _U('put_in_vehicle'),  value = 'put_in_vehicle'},
				{label = _U('out_the_vehicle'), value = 'out_the_vehicle'},
			},
		},
		function(data, menu)
		
			local player, distance = ESX.Game.GetClosestPlayer()
			if distance ~= -1 and distance <= 3.0 then

				if data.current.value == 'body_search' then
					OpenBodySearchMenu(player)
				end

				if data.current.value == 'handcuff' then
					TriggerServerEvent('gang:handcuff', GetPlayerServerId(player))
				end

				if data.current.value == 'drag' then
					TriggerServerEvent('gang:drag', GetPlayerServerId(player))
				end

				if data.current.value == 'put_in_vehicle' then
					TriggerServerEvent('gang:putInVehicle', GetPlayerServerId(player))
				end

				if data.current.value == 'out_the_vehicle' then
					  TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(player))
				end
			
			else
				ESX.ShowNotification(_U('no_players_nearby'))
			end

		end,
		function(data, menu)
			menu.close()
		end
	)

end


function OpenBodySearchMenu(player)

	ESX.TriggerServerCallback('gang:getOtherPlayerData', function(data)

		local elements = {}

		local blackMoney = 0

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' then
				blackMoney = data.accounts[i].money
				break
			end
		end

		table.insert(elements, {
			label          = _U('black_money') .. blackMoney,
			value          = 'black_money',
			itemType       = 'item_account',
			amount         = blackMoney
		})

		table.insert(elements, {label = '--- '.._U('arms')..' ---', value = nil})

		for i=1, #data.weapons, 1 do
			table.insert(elements, {
				label          = ESX.GetWeaponLabel(data.weapons[i].name),
				value          = data.weapons[i].name,
				itemType       = 'item_weapon',
				amount         = data.ammo,
			})
		end

		table.insert(elements, {label = '--- '.._U('inventory_label')..' ---', value = nil})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(elements, {
					label          = data.inventory[i].count .. 'x ' .. data.inventory[i].label,
					value          = data.inventory[i].name,
					itemType       = 'item_standard',
					amount         = data.inventory[i].count,
				})
			end
		end


		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'body_search',
			{
				title    = _U('search'),
				align    = 'top-left',
				elements = elements,
			},
			function(data, menu)

				local itemType = data.current.itemType
				local itemName = data.current.value
				local amount   = data.current.amount

				if data.current.value ~= nil then

					TriggerServerEvent('gang:confiscatePlayerItem', GetPlayerServerId(player), itemType, itemName, amount)
					OpenBodySearchMenu(player)

				end

			end,
			function(data, menu)
				menu.close()
			end
		)
	end, GetPlayerServerId(player))

end



function startCheck()
	Citizen.CreateThread(function()
		checkStarted = true
		while closeToArea and gangName ~= nil do
			Wait(0)

			local playerPed      = GetPlayerPed(-1)
			local coords         = GetEntityCoords(playerPed)
			local isInMarker     = false
			local currentStation = nil
			local currentPart    = nil
			local currentPartNum = nil
			if isBoss and GetDistanceBetweenCoords(coords,  weaponLOC.x,  weaponLOC.y,  weaponLOC.z,  true) < Config.MarkerSize.x then
				isInMarker     = true
				currentPart    = 'weapon'
			end
			if GetDistanceBetweenCoords(coords,  itemLOC.x,  itemLOC.y,  itemLOC.z,  true) < Config.MarkerSize.x then
				isInMarker     = true
				currentPart    = 'item'
			end
			if GetDistanceBetweenCoords(coords,  vehicleSpawnerLOC.x,  vehicleSpawnerLOC.y,  vehicleSpawnerLOC.z,  true) < Config.MarkerSize.x then
				isInMarker     = true
				currentPart    = 'spawner'
			end
			if GetDistanceBetweenCoords(coords,  vehicleDeleteLOC.x,  vehicleDeleteLOC.y,  vehicleDeleteLOC.z,  true) < (Config.MarkerSize.x * 2) then
				isInMarker     = true
				currentPart    = 'delete'
			end
			if isBoss and GetDistanceBetweenCoords(coords,  moneyLOC.x,  moneyLOC.y,  moneyLOC.z,  true) < Config.MarkerSize.x then
				isInMarker     = true
				currentPart    = 'money'
			end
			if isBoss and GetDistanceBetweenCoords(coords,  bossLOC.x,  bossLOC.y,  bossLOC.z,  true) < Config.MarkerSize.x then
				isInMarker     = true
				currentPart    = 'boss'
			end

			if isInMarker and not HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = true
				LastPart = currentPart
				TriggerEvent('gang:hasEnteredMarker', currentPart)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('gang:hasExitedMarker', LastPart)
			end
			
		end
		checkStarted = false
		
	end)
end

AddEventHandler('gang:hasEnteredMarker', function(part)

	if part == 'weapon' then
		CurrentAction     = 'menu_weapon'
		CurrentActionMsg  = _U('weapons_message')
	elseif part == 'item' then
		CurrentAction     = 'menu_item'
		CurrentActionMsg  = _U('items_message')
	elseif part == 'spawner' then
		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = _U('vehicle_message')
	elseif part == 'delete' then
	
		local playerPed = GetPlayerPed(-1)
		if IsPedInAnyVehicle(playerPed,  false) then

			local vehicle = GetVehiclePedIsIn(playerPed, false)
			
			if GetPedInVehicleSeat(vehicle, -1) == playerPed then

				if DoesEntityExist(vehicle) then
					CurrentAction     = 'delete_vehicle'
					CurrentActionMsg  = _U('delete_message')
				end
			
			end
		end
	elseif part == 'money' then
		CurrentAction     = 'menu_money'
		CurrentActionMsg  = _U('money_message')
	elseif part == 'boss' then
		CurrentAction     = 'menu_boss'
		CurrentActionMsg  = _U('boss_message')
	end
	
	startCheckActivateThread()

end)

AddEventHandler('gang:hasExitedMarker', function( part)
  ESX.UI.Menu.CloseAll()
  CurrentAction = nil
end)

function startCheckActivateThread()
	Citizen.CreateThread(function()
		while CurrentAction ~= nil and gangName ~= nil do
			Wait(0)

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - lastTime) > 150 then

				if CurrentAction == 'menu_item' then
					OpenItemMenu()
				elseif CurrentAction == 'menu_weapon' then
					OpenWeaponMenu()
				elseif CurrentAction == 'menu_vehicle_spawner' then
					ListVehiclesMenu()
				elseif CurrentAction == 'delete_vehicle' then
					local playerPed = GetPlayerPed(-1)
					if IsPedInAnyVehicle(playerPed,  false) then
						local vehicle = GetVehiclePedIsIn(playerPed, false)
						vehicleProps = GetVehicleProperties(vehicle)
						
						ESX.TriggerServerCallback('eden_garage:stockvGang',function(valid)
							if(valid) then
								ESX.Game.DeleteVehicle(vehicle)
								TriggerEvent('VS:RequestRemoveKey', vehicleProps.plate)
								TriggerServerEvent('eden_garage:modifystate', vehicleProps.plate, true)
								TriggerServerEvent("esx_eden_garage:MoveGarage", vehicleProps.plate, gangName)
								ESX.ShowNotification(_U('vehicle_in_garage'))
								
							else
								ESX.ShowNotification(_U('cannot_store_vehicle'))
							end
						end,vehicleProps, gangName)
						
						
						
					end
				elseif CurrentAction == 'menu_money' then
					OpenMoneyMenu()
				elseif CurrentAction == 'menu_boss' then
					OpenBossMenu()
				end

				CurrentAction 	= nil
				lastTime		= GetGameTimer()
			end
		
		end
	end)
end

function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)

        vehicleProps["tyres"] = {}
        vehicleProps["windows"] = {}
        vehicleProps["doors"] = {}

        for id = 1, 7 do
            local tyreId = IsVehicleTyreBurst(vehicle, id, false)
        
            if tyreId then
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = tyreId
        
                if tyreId == false then
                    tyreId = IsVehicleTyreBurst(vehicle, id, true)
                    vehicleProps["tyres"][ #vehicleProps["tyres"]] = tyreId
                end
            else
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = false
            end
        end

        for id = 1, 13 do
            local windowId = IsVehicleWindowIntact(vehicle, id)

            if windowId ~= nil then
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = windowId
            else
                vehicleProps["windows"][#vehicleProps["windows"] + 1] = true
            end
        end
        
        for id = 0, 5 do
            local doorId = IsVehicleDoorDamaged(vehicle, id)
        
            if doorId then
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = doorId
            else
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = false
            end
        end

        return vehicleProps
	else
		return nil
    end
end


function OpenItemMenu()

	local elements = {
		{label = _U('get_stock'),  value = 'get_stock'},
		{label = _U('put_stock'),  value = 'put_stock'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory',{
			title    = _U('stocks'),
			align    = 'top-right',
			elements = elements },
		function(data, menu)
			if data.current.value == 'put_stock' then
				OpenPutStocksMenu()
			elseif data.current.value == 'get_stock' then
				OpenGetStocksMenu()
			end
		end,
		function(data, menu)
			menu.close()
			CurrentAction = 'menu_item'
		end
    )
	
end

function OpenGetStocksMenu()

	ESX.TriggerServerCallback('gang:getStockItems', function(items)

		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name, count = items[i].count})
		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'stocks_menu',
			{
				title    = _U('stocks'),
				elements = elements
			},
			function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
					{
						title = _U('quantity')
					},
					function(data2, menu2)

						local count = tonumber(data2.value)

						if count == nil then
							ESX.ShowNotification(_U('quantity_invalid'))
							menu2.close()
						elseif count <= 0 or count > data.current.count then
							ESX.ShowNotification(_U('quantity_invalid'))
							menu2.close()
						else
							menu2.close()
							menu.close()
							-- OpenGetStocksMenu()

							TriggerServerEvent('gang:getStockItem', itemName, count, gangName)
						end

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end, gangName)

end

function OpenPutStocksMenu()
	

	ESX.TriggerServerCallback('gang:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name, count = item.count})
			end

		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'stocks_menu',
			{		
				title    = 'Lavazem e hamrah',
				elements = elements
			},
			function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
					{
						title = 'tedad'
					},
					function(data2, menu2)

						local count = tonumber(data2.value)

						if count == nil or count < 0 or count > data.current.count then
							ESX.ShowNotification('tedad gheyre ghabele ghabool')
							menu2.close()
						else
							menu2.close()
							menu.close()
							-- OpenPutStocksMenu()
							TriggerServerEvent('gang:putStockItems', gangName, itemName, count)
						end

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end)

end

function OpenWeaponMenu()

	local elements = {
	  {label = _U('get_weapon'), value = 'get_weapon'},
	  {label = _U('put_weapon'), value = 'put_weapon'},
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'armory',
		{
			title    = _U('armory'),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			if data.current.value == 'get_weapon' then
				OpenGetWeaponMenu()
			end

			if data.current.value == 'put_weapon' then
				OpenPutWeaponMenu()
			end

		end,
		function(data, menu)

			menu.close()

			CurrentAction     = 'menu_weapon'
			CurrentActionMsg  = _U('weapons_message')
			
		end
	)

end

function OpenGetWeaponMenu()

	ESX.TriggerServerCallback('gang:getArmoryWeapons', function(weapons)

		local elements = {}

		for i=1, #weapons, 1 do
			table.insert(elements, {label = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name), value = weapons[i].name})
		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'armory_get_weapon',
			{
				title    = _U('get_weapon_menu'),
				align    = 'top-left',
				elements = elements,
			},
			function(data, menu)

				menu.close()

				ESX.TriggerServerCallback('gang:removeArmoryWeapon', function()
					OpenGetWeaponMenu()
				end, data.current.value, gangName)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end, gangName)

end

function OpenPutWeaponMenu()
	
	local elements   = {}
	local playerPed  = GetPlayerPed(-1)
	local weaponList = ESX.GetWeaponList()

	for i=1, #weaponList, 1 do

		local weaponHash = GetHashKey(weaponList[i].name)

		if HasPedGotWeapon(playerPed,  weaponHash,  false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			table.insert(elements, {label = weaponList[i].label, value = weaponList[i].name})
		end

	end

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'armory_put_weapon',
		{
			title    = _U('put_weapon_menu'),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			menu.close()

			ESX.TriggerServerCallback('gang:addArmoryWeapon', function()
				OpenPutWeaponMenu()
			end, data.current.value, gangName)

		end,
		function(data, menu)
			menu.close()
		end
	)

end

function OpenVehicleMenu()
	local playerPed = GetPlayerPed(-1)
	ESX.Game.SpawnVehicle(vehicle, vehicleSpawnLOC, vehicleSpawnH, function(vehicle2)
		SetVehicleColours(vehicle2, vehiclePrimaryColor, vehicleSecondaryColor)
		SetVehicleExtraColours(vehicle2, 0, 0)
		SetVehicleDirtLevel(vehicle2, 0)
		ToggleVehicleMod(vehicle2, 22, true)
		SetVehicleHeadlightsColour(vehicle2, 0)
		TaskWarpPedIntoVehicle(playerPed,  vehicle2,  -1)
		TriggerEvent('VS:GiveKey', vehicle2)
	end)
end

function table.empty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end


function ListVehiclesMenu()
	local elements, vehiclePropsList = {}, {}
	ESX.TriggerServerCallback('eden_garage:getVehiclesGang', function(vehicles)
		if not table.empty(vehicles) then
			for _,v in pairs(vehicles) do
				local vehicleProps = json.decode(v.vehicle)
				vehiclePropsList[vehicleProps.plate] = vehicleProps
				local vehicleHash = vehicleProps.model
				local vehicleName
								
				if v.vehiclename then
					vehicleName = v.vehiclename					
				else
					vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)
				end

				table.insert(elements, {
					label = vehicleName,
					vehicleName = vehicleName,
					stored = v.stored,
					plate = vehicleProps.plate,
					fourrieremecano = v.fourrieremecano,
					garage_name = v.garage_name
				})
				
			end
		else
			table.insert(elements, {label = _U('no_cars_stored'), value = "nocar"})
		end
		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle',
		{
			title    = gangName,
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			if data.current.value ~= "nocar" then
				local CarProps = vehiclePropsList[data.current.plate]
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {
					title    =  data.current.vehicleName,
					align    = 'top-left',
					elements = {
						{label = _U('take_out_car') , value = 'get_vehicle_out'},
						{label = _U('rename_the_car') , value = 'rename_vehicle'}
				}}, function(data2, menu2)
						if data2.current.value == "get_vehicle_out" then
						
							if (data.current.fourrieremecano) then
								ESX.ShowNotification("vehicle in pound")
							elseif (data.current.stored) then
								SpawnVehicle(CarProps, garage, KindOfVehicle)
								ESX.UI.Menu.CloseAll()
							else
								ESX.ShowNotification("vehicle already out")
							end
						elseif data2.current.value == "rename_vehicle" then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rename_vehicle', {
								title = _U('desired_name')
							}, function(data3, menu3)
								if string.len(data3.value) >= 1 then
									TriggerServerEvent('eden_garage:renamevehicle', data.current.plate, data3.value)
									ESX.UI.Menu.CloseAll()
									ListVehiclesMenu(garage, KindOfVehicle, garage_name, vehicle_type)
								else
									ESX.ShowNotification('Enter a name')
									menu3.close()
								end

							end, function(data3, menu3)
								menu3.close()
							end)
						end
					end,
					function(data2, menu2)
						menu2.close()
					end
				)
			end
		end,
		function(data, menu)
			menu.close()
		end
	)
	end, gangName)
end

function SpawnVehicle(vehicleProps, garage, KindOfVehicle)
	ESX.Game.SpawnVehicle(vehicleProps.model, vehicleSpawnLOC ,vehicleSpawnH, function(callback_vehicle)
			SetVehicleProperties(callback_vehicle, vehicleProps)
			TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
			TriggerEvent('VS:GiveKey', callback_vehicle)
		end)
	TriggerServerEvent('eden_garage:modifystate', vehicleProps.plate, false)
end

function SetVehicleProperties(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

    if vehicleProps["windows"] then
        for windowId = 1, 13, 1 do
            if vehicleProps["windows"][windowId] == false then
                SmashVehicleWindow(vehicle, windowId)
            end
        end
    end

    if vehicleProps["tyres"] then
        for tyreId = 1, 7, 1 do
            if vehicleProps["tyres"][tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end

    if vehicleProps["doors"] then
        for doorId = 0, 5, 1 do
            if vehicleProps["doors"][doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end
end







function OpenCarMenu()

	local elements = {
		{label = _U('get_c1'), value = 'get_money'},
		{label = _U('put_c2'), value = 'put_money'},
		{label = _U('get_c3'), value = 'get_black'},
		{label = _U('put_c4'), value = 'put_black'},
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'armory',
		{
			title    = _U('Mashin'),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			if data.current.value == 'get_c1' then
				ListVehiclesMenu()
			end

			if data.current.value == 'put_c2' then
				OpenPutMoneyMenu()
			end
			
			if data.current.value == 'get_c3' then
				OpenGetBlackMenu()
			end
			
			if data.current.value == 'put_c4' then
				OpenPutBlackMenu()
			end

		end,
		function(data, menu)

			menu.close()

			--CurrentAction     = 'menu_money'
			CurrentActionMsg  = _U('money_message')
			
		end
	)

end




















function OpenMoneyMenu()

	local elements = {
		{label = _U('get_money'), value = 'get_money'},
		{label = _U('put_money'), value = 'put_money'},
		{label = _U('get_black'), value = 'get_black'},
		{label = _U('put_black'), value = 'put_black'},
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'armory',
		{
			title    = _U('money'),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			if data.current.value == 'get_money' then
				OpenGetMoneyMenu()
			end

			if data.current.value == 'put_money' then
				OpenPutMoneyMenu()
			end
			
			if data.current.value == 'get_black' then
				OpenGetBlackMenu()
			end
			
			if data.current.value == 'put_black' then
				OpenPutBlackMenu()
			end

		end,
		function(data, menu)

			menu.close()

			CurrentAction     = 'menu_money'
			CurrentActionMsg  = _U('money_message')
			
		end
	)

end

function OpenGetMoneyMenu()

	ESX.TriggerServerCallback('gang:getGangMoney', function(money)

		local elements = {}
		table.insert(elements, {label = money .. ' $', value = money})

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'get_money_menu',
			{
				title    = _U('get_money'),
				align    = 'top-left',
				elements = elements,
			},
			function(data, menu)

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'get_money_menu_amount',
					{
						title = _U('amount')
					},
					function(data2, menu2)

						local amount = tonumber(data2.value)

						if amount == nil or amount < 0 or amount > data.current.value then
							ESX.ShowNotification('tedad gheyre ghabele ghabool')
							menu2.close()
						else
							menu2.close()
							menu.close()
							TriggerServerEvent('gang:getMoney', gangName, amount)
						end

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end, gangName)

end

function OpenPutMoneyMenu()

	local elements   = {}
	local money = ESX.PlayerData.money
	
	table.insert(elements, {label = money .. ' $', value = money})

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'put_money_menu',
		{
			title    = _U('put_money'),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			ESX.UI.Menu.Open(
				'dialog', GetCurrentResourceName(), 'put_money_menu_amount',
				{
					title = _U('amount')
				},
				function(data2, menu2)

					local amount = tonumber(data2.value)

					if amount == nil or amount < 0 or amount > data.current.value then
						ESX.ShowNotification('tedad gheyre ghabele ghabool')
						menu2.close()
					else
						menu2.close()
						menu.close()
						TriggerServerEvent('gang:putMoney', gangName, amount)
					end

				end,
				function(data2, menu2)
					menu2.close()
				end
			)

		end,
		function(data, menu)
			menu.close()
		end
	)

end

function OpenGetBlackMenu()

	ESX.TriggerServerCallback('gang:getGangBlack', function(money)

		local elements = {}
		table.insert(elements, {label = money .. ' $', value = money})

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'get_black_menu',
			{
				title    = _U('get_black'),
				align    = 'top-left',
				elements = elements,
			},
			function(data, menu)

			ESX.UI.Menu.Open(
				'dialog', GetCurrentResourceName(), 'get_black_menu_amount',
				{
					title = _U('amount')
				},
				function(data2, menu2)

					local amount = tonumber(data2.value)

					if amount == nil or amount < 0 or amount > data.current.value then
						ESX.ShowNotification('tedad gheyre ghabele ghabool')
						menu2.close()
					else
						menu2.close()
						menu.close()
						TriggerServerEvent('gang:getBlack', gangName, amount)
					end

				end,
				function(data2, menu2)
					menu2.close()
				end
			)

		end,
		function(data, menu)
			menu.close()
		end)

	end, gangName)

end

function OpenPutBlackMenu()
	
	blackMoney = 0
	
	for i=1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == 'black_money' then
			if ESX.PlayerData.accounts[i].money > 0 then
				blackMoney = ESX.PlayerData.accounts[i].money
			end
		end
	end
	
	local elements   = {}
	
	table.insert(elements, {label = blackMoney .. ' $', value = blackMoney})

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'put_black_menu',
		{
			title    = _U('put_black'),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			ESX.UI.Menu.Open(
				'dialog', GetCurrentResourceName(), 'put_black_menu_amount',
				{
					title = _U('amount')
				},
				function(data2, menu2)

					local amount = tonumber(data2.value)

					if amount == nil or amount < 0 or amount > data.current.value then
						ESX.ShowNotification('tedad gheyre ghabele ghabool')
						menu2.close()
					else
						menu2.close()
						menu.close()
						TriggerServerEvent('gang:putBlack', gangName, amount)
					end

				end,
				function(data2, menu2)
					menu2.close()
				end
			)

		end,
		function(data, menu)
			menu.close()
		end
	)
	
end

function OpenBossMenu()

	local elements = {
		{label = _U('recruit'), value = 'recruit'},
		{label = _U('fire'), value = 'fire'},
		-- {label = _U('management'), value = 'management'},
		{label = _U('comming_soon'), value = 'comming_soon'},
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'management_menu',
		{
			title    = _U('management_menu'),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			if data.current.value == 'recruit' then
				OpenRecruitMenu()
			end

			if data.current.value == 'fire' then
				OpenFireMenu()
			end
			
			if data.current.value == 'management' then
				-- OpenManageMenu()
			end
			
			if data.current.value == 'comming_soon' then
			end

		end,
		function(data, menu)

			menu.close()

			CurrentAction     = 'menu_boss'
			CurrentActionMsg  = _U('boss_message')
			
		end
	)

end

function OpenRecruitMenu()

	ESX.TriggerServerCallback('gang:getOnlinePlayers', function(players)
		local elements   = {}
		for i=1, #players, 1 do
			table.insert(elements, {label = players[i].name, value = players[i]})
		end
		
		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'recruit_menu',
		{
			title    = _U('citizen'),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			
			ESX.UI.Menu.Open(
				'dialog', GetCurrentResourceName(), 'enter_rank_name',
				{
					title = _U('rank')
				},
				function(data2, menu2)

					local rankName = data2.value
					if rankName == nil then
						ESX.ShowNotification('gheyre ghabele ghabool')
						menu2.close()
					else
						menu2.close()
						menu.close()
						ESX.TriggerServerCallback('gang:recruitPlayer', function(recruited) 
							if not recruited then
								ESX.ShowNotification('Be bishtarin tedad aza residid, nemitoonid add konid')
							else
								ESX.ShowNotification('Estekhdam ba movafaghiyat anjam shod')
							end
						end, gangName, data.current.value, rankName)
					end

				end,
				function(data2, menu2)
					menu2.close()
				end
			)
		end,
		function(data, menu)
			menu.close()
		end
	)
		
	end)

end

function OpenFireMenu()

	ESX.TriggerServerCallback('gang:getGangMembers', function(players)
		local elements   = {}
		for i=1, #players, 1 do
			table.insert(elements, {label = players[i].name, value = players[i]})
		end
		
		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'fire_menu',
		{
			title    = _U('gang_members'),
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)			
			menu.close()
			if data.current.value.identifier == ESX.PlayerData.identifier then
				ESX.UI.Menu.CloseAll()
			end
			TriggerServerEvent('gang:firePlayer', data.current.value)
		end,
		function(data, menu)
			menu.close()
		end
	)
		
	end, gangName)

end

RegisterNetEvent('gang:handcuff')
AddEventHandler('gang:handcuff', function()

	IsHandcuffed    = not IsHandcuffed;
	local playerPed = GetPlayerPed(-1)

	Citizen.CreateThread(function()

		if IsHandcuffed then

			RequestAnimDict('mp_arresting')

			while not HasAnimDictLoaded('mp_arresting') do
				Wait(100)
			end

			DisablePlayerFiring(playerPed, true)
			TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
			SetEnableHandcuffs(playerPed, true)
			SetPedCanPlayGestureAnims(playerPed, false)
			FreezeEntityPosition(playerPed,  true)
			DisplayRadar(false)
			startHandcuffedThread()

		else
			DisablePlayerFiring(playerPed, false)
			ClearPedSecondaryTask(playerPed)
			SetEnableHandcuffs(playerPed, false)
			SetPedCanPlayGestureAnims(playerPed,  true)
			FreezeEntityPosition(playerPed, false)
			DisplayRadar(true)
			
			TriggerEvent("esx_policejob:removeHandcuff")

		end
	end)
end)

function startHandcuffedThread()
	Citizen.CreateThread(function()
		while IsHandcuffed do
			Wait(0)
			if IsDragged then
				ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
				local myped = GetPlayerPed(-1)
				AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			else
				DetachEntity(GetPlayerPed(-1), true, false)
			end
		end
	end)
end

RegisterNetEvent('gang:removeHandcuff')
AddEventHandler('gang:removeHandcuff', function()
	IsHandcuffed = false
end)

RegisterNetEvent('gang:drag')
AddEventHandler('gang:drag', function(cop)
	TriggerServerEvent('esx:clientLog', 'starting dragging')
	IsDragged = not IsDragged
	CopPed = tonumber(cop)
end)



RegisterNetEvent('gang:putInVehicle')
AddEventHandler('gang:putInVehicle', function()
	  local playerPed = PlayerPedId()
	  local coords    = GetEntityCoords(playerPed)
  
	  if not IsHandcuffed then
		  return
	  end
  
	  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
  
		  local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
  
		  if DoesEntityExist(vehicle) then
  
			  local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
			  local freeSeat = nil
  
			  for i=maxSeats - 1, 0, -1 do
				  if IsVehicleSeatFree(vehicle, i) then
					  freeSeat = i
					  break
				  end
			  end
  
			  if freeSeat ~= nil then
				  TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				  IsDragged = false
			  end
  
		  end
  
	  end
  end)
--RegisterNetEvent('gane:OutVehicle')
--AddEventHandler('gane:OutVehicle', function(t)
--
--	local ped = GetPlayerPed(t)
--	ClearPedTasksImmediately(ped)
--	plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
--	local xnew = plyPos.x+2
--	local ynew = plyPos.y+2
--	SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
--	
--end)
  RegisterNetEvent('gane:OutVehicle')
  AddEventHandler('gane:OutVehicle', function()
	  local playerPed = PlayerPedId()
  
	  if not IsPedSittingInAnyVehicle(playerPed) then
		  return
	  end
  
	  local vehicle = GetVehiclePedIsIn(playerPed, false)
	  TaskLeaveVehicle(playerPed, vehicle, 16)
  end)


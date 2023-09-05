markerXSize = 1.5
markerYSize = 1.5
markerZSize = 1.5

items = {"Boss", "Money", "Weapon", "Items", "VehicleSpawner", "VehicleSpawnLocation", "VehicleDestroyer", "Blip"}
locations = {}
gangName = ""

RegisterNetEvent('gang:startCreateGang')
AddEventHandler('gang:startCreateGang', function()

	locations = {}
	gangName = ""

	Citizen.CreateThread(function()	
		
		
		for i=1 , #items , 1 do
			
			SendNUIMessage(
				{
					action = "display",
				}
			)
			
			local bodyText = ""
			local description = ""
			if items[i] == "Boss" then
				bodyText = "بخش مدیریت"
				description = "جایی که میخواهید این نشان قرار بگیرد بایستید و دکمه ی اینتر را فشار دهید"
			elseif items[i] == "Money" then
				bodyText = "بخش مدیریت مالی"
				description = "جایی که میخواهید این نشان قرار بگیرد بایستید و دکمه ی اینتر را فشار دهید"
			elseif items[i] == "Weapon" then	
				bodyText = "بخش مدیریت اسلحه"
				description = "جایی که میخواهید این نشان قرار بگیرد بایستید و دکمه ی اینتر را فشار دهید"
			elseif items[i] == "Items" then
				bodyText = "انبار لوازم"
				description = "جایی که میخواهید این نشان قرار بگیرد بایستید و دکمه ی اینتر را فشار دهید"
			elseif items[i] == "VehicleSpawner" then
				bodyText = "مدیریت پارکینگ"
				description = "جایی که میخواهید این نشان قرار بگیرد بایستید و دکمه ی اینتر را فشار دهید"
			elseif items[i] == "VehicleSpawnLocation" then
				bodyText = "مکان خروج ماشین"
				description = "جایی که میخواهید ماشین خارج شود قرار بگیرید و دکمه ی اینتر را فشار دهید به دایره ی سفید دقت کنید سمت ماشین به آن سمت خواهید بود"
			elseif items[i] == "VehicleDestroyer" then
				bodyText = "ورودی پارکینگ"
				description = "جایی که میخواهید این نشان قرار بگیرد بایستید و دکمه ی اینتر را فشار دهید"
			elseif items[i] == "Blip" then
				bodyText = "نشان نقشه"
				description = "مکان نشانگر گنگ روی نقشه را مشخص کنید"
			end
			
			SendNUIMessage(
				{
					action = "change",
					body = bodyText,
					desc = description
				}
			)
			
			finished = false
			
			while not finished do
			
				Citizen.Wait(0)
		
				playerPed = GetPlayerPed(PlayerId())
				playerCoords = GetEntityCoords(GetPlayerPed(PlayerId()), true)
				playerCoordsX = playerCoords.x
				playerCoordsY = playerCoords.y
				playerCoordsZ = playerCoords.z
				playerHeading = GetEntityHeading(GetPlayerPed(PlayerId()))
				forward = GetEntityForwardVector(GetPlayerPed(PlayerId()))
				local x, y, z   = table.unpack(playerCoords + forward * 2.0)
				
				DrawMarker(1, playerCoordsX, playerCoordsY, playerCoordsZ - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, markerXSize, markerYSize, markerZSize, 233, 0, 150, 0, 0, 2, 0, 0, 0, false )
				if(items[i] == "VehicleSpawnLocation") then
					DrawMarker(28, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 0.25, 0.25, 0.25, 255, 255, 255, 150, 0, 0, 2, 0, 0, 0, false )
				end
				
				-- ENTER pressed
				if IsControlJustReleased(1, 201) then
					if(items[i] == "VehicleSpawnLocation") then
						thislocation = {
							x = playerCoordsX,
							y = playerCoordsY,
							z = playerCoordsZ - 1,
							h = playerHeading
						}
					else
						thislocation = {
							x = playerCoordsX,
							y = playerCoordsY,
							z = playerCoordsZ - 1
						}
					end
					locations[items[i]] = thislocation
					finished = true
				end
			
			end
		
		end
		
		SendNUIMessage(
			{
				action = "hide",
			}
		)
		
		chooseName()
		
	end)
	
	
end)

function chooseName() 

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Gang Name', {
			title = 'Enter gang name'
	}, function(data, menu)
		if data.value ~= nil and string.len(data.value) >= 1 then
			menu.close()
			ESX.TriggerServerCallback('gang:isGangNameTaken', function(result)
				if result then
					menu.close()
					ESX.ShowNotification('This gang name is taken')
					chooseName()
				else
					menu.close()
					gangName = data.value
					chooseGangLeader()
				end
			end, data.value)
		else
			menu.close()
			ESX.ShowNotification('You must enter a name')
			chooseName()
		end

	end, function(data, menu)
		menu.close()
	end)

end

function chooseGangLeader() 

	ESX.UI.Menu.CloseAll()

	ESX.TriggerServerCallback('gang:getOnlinePlayers', function(players)
		local elements   = {}
		for i=1, #players, 1 do
			table.insert(elements, {label = players[i].name, value = players[i]})
		end
		
		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'recruit_menu',
		{
			title    = _U('citizen'),
			elements = elements,
		},
		function(data, menu)
			menu.close()
			TriggerServerEvent('gang:CreateGang', gangName, data.current.value, locations)
			-- TriggerServerEvent('gang:recruitPlayer', gangName, data.current.value, rankName)
			
		end,
		function(data, menu)
			menu.close()
		end
	)
		
	end)
	
end
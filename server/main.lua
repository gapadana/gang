ESX = nil
previousSize = 0
local gangs = {}

Citizen.CreateThread(function()

	Wait(1000)
	
	while ESX == nil do
		TriggerEvent('bib:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
    end
	
	register()
	loadGangsData()
	
	
end)

function loadGangsData()

	local result = MySQL.Sync.fetchAll('SELECT gang_name from gangs', {})
	
	for i=1, #result, 1 do
		table.insert(gangs, result[i].gang_name)
	end

end


function register()
	ESX.RegisterServerCallback('gang:getGangMoney', function(source, cb, gang_name)

		MySQL.Async.fetchAll(
			'SELECT money FROM gangs WHERE gang_name = @gang_name',
			{
			  ['@gang_name'] = gang_name
			},
			function(result)
				if #result >= 1 then
					cb(result[1].money)
				else
					cb(nil)
				end
			end
		)

	end)

	ESX.RegisterServerCallback('gang:getGangBlackMoney', function(source, cb, gang_name)

		MySQL.Async.fetchAll(
			'SELECT black_money FROM gangs WHERE gang_name = @gang_name',
			{
			  ['@gang_name'] = gang_name
			},
			function(result)
				if #result >= 1 then
					cb(result[1].black_money)
				else
					cb(nil)
				end
			end
		)

	end)

	ESX.RegisterServerCallback('gang:getGangWeapons', function(source, cb, gang_name)

		MySQL.Async.fetchAll(
			'SELECT weapons FROM gangs WHERE gang_name = @gang_name',
			{
			  ['@gang_name'] = gang_name
			},
			function(result)
				if #result >= 1 then
					cb(json.decode(result[1].weapons))
				else
					cb(nil)
				end
			end
		)

	end)

	ESX.RegisterServerCallback('gang:getGangItems', function(source, cb, gang_name)

		MySQL.Async.fetchAll(
			'SELECT items FROM gangs WHERE gang_name = @gang_name',
			{
			  ['@gang_name'] = gang_name
			},
			function(result)
				if #result >= 1 then
					cb(json.decode(result[1].items))
				else
					cb(nil)
				end
			end
		)

	end)
	
	ESX.RegisterServerCallback('gang:GetGangData', function(source, cb, gangName)

		MySQL.Async.fetchAll(
			'SELECT * FROM gangs WHERE gang_name = @gang_name',
			{
			  ['@gang_name'] = gangName
			},
			function(result)
				cb(result)
			end
		)

	end)

	ESX.RegisterServerCallback('gang:getPlayerGangData', function(source, cb)

		local xPlayer = ESX.GetPlayerFromId(source)

		MySQL.Async.fetchAll(
			'SELECT * FROM gangs_member WHERE identifier = @identifier',
			{
			  ['@identifier'] = xPlayer.identifier
			},
			function(result)
				if #result >= 1 then
					cb(result[1])
				else
					cb(nil)
				end
			end
		)

	end)
	
	ESX.RegisterServerCallback('gang:isBoss', function(source, cb)

		local xPlayer = ESX.GetPlayerFromId(source)

		MySQL.Async.fetchAll(
			'SELECT * FROM gangs_member WHERE identifier = @identifier',
			{
			  ['@identifier'] = xPlayer.identifier
			},
			function(result)
				if #result >= 1 then
					cb(result[1].gang_name)
				else
					cb(nil)
				end
			end
		)

	end)
	
	ESX.RegisterServerCallback('gang:getPlayerInventory', function(source, cb)

		local xPlayer = ESX.GetPlayerFromId(source)
		local items   = xPlayer.inventory

		cb({
			items = items
		})

	end)
	
	ESX.RegisterServerCallback('gang:getStockItems', function(source, cb, gangName)

		MySQL.Async.fetchAll(
		'SELECT items FROM gangs WHERE gang_name = @gang_name',
		{
		  ['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				itemList = json.decode(result[1].items)
				
				local itemTable = {}
				
				if not (itemList == nil or itemList == {}) then
					for k, v in ipairs( itemList ) do
						--print(v[1], ESX.Items[v[1]].label, ESX.Items[v[1]].limit)
					--	table.insert( itemTable, {name = v[1], label = ESX.Items[v[1]].label, count = v[2], limit = ESX.Items[v[1]].limit} )
						table.insert( itemTable, {name = v[1], count = v[2],label = ESX.Items[v[1]].label} )
					end
				end
				
				cb(itemTable)
			end
		end)
	end)
	
	ESX.RegisterServerCallback('gang:addArmoryWeapon', function(source, cb, weaponName, gangName)

		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeWeapon(weaponName)
		
		MySQL.Async.fetchAll(
		'SELECT weapons FROM gangs WHERE gang_name = @gang_name',
		{
			['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				weaponList = json.decode(result[1].weapons)
				
				local weaponTable = {}
				
				if not (weaponList == nil or weaponList == {}) then
					for k, v in ipairs( weaponList ) do
						table.insert( weaponTable, {v[1],v[2]} )
					end
				end
				
				if table.contains(weaponTable, weaponName) then
					local value = table.removeObject(weaponTable, weaponName)
					table.insert(weaponTable, {weaponName, value[2] + 1})
				else
					table.insert(weaponTable, {weaponName, 1})
				end
				MySQL.Async.fetchAll(
					'UPDATE gangs set weapons = @weapons WHERE gang_name = @gang_name',
					{
					  ['@gang_name'] = gangName,
					  ['@weapons'] = json.encode(weaponTable)
					},
				function(result)
				end)
			end
		end)
	end)

	ESX.RegisterServerCallback('gang:getArmoryWeapons', function(source, cb, gangName)

		MySQL.Async.fetchAll(
		'SELECT weapons FROM gangs WHERE gang_name = @gang_name',
		{
			['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				weaponList = json.decode(result[1].weapons)
				
				local weaponTable = {}
				
				if not (weaponList == nil or weaponList == {}) then
					for k, v in ipairs( weaponList ) do
						table.insert( weaponTable, {name = v[1], count = v[2]} )
					end
				end
				
				cb(weaponTable)
				
			end
		end)

	end)

	ESX.RegisterServerCallback('gang:removeArmoryWeapon', function(source, cb, weaponName, gangName)

		local xPlayer = ESX.GetPlayerFromId(source)

		MySQL.Async.fetchAll(
		'SELECT weapons FROM gangs WHERE gang_name = @gang_name',
		{
			['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				weaponList = json.decode(result[1].weapons)
				
				local weaponTable = {}
				
				if not (weaponList == nil or weaponList == {}) then
					for k, v in ipairs( weaponList ) do
						table.insert( weaponTable, {v[1], v[2]} )
					end
				end
				
				if table.contains(weaponTable, weaponName) then
					local value = table.removeObject(weaponTable, weaponName)
					if value[2] > 1 then
						table.insert(weaponTable, {weaponName, value[2] - 1})
					end
				end
				MySQL.Async.fetchAll(
					'UPDATE gangs set weapons = @weapons WHERE gang_name = @gang_name',
					{
					  ['@gang_name'] = gangName,
					  ['@weapons'] = json.encode(weaponTable)
					},
				function(result)
					xPlayer.addWeapon(weaponName, 30)
				end)
			end
		end)
	end)
	
	ESX.RegisterServerCallback(
		"gang:getMoney",
		function(source, cb, target)
			local targetXPlayer = ESX.GetPlayerFromId(target)

			if targetXPlayer ~= nil then
				cb({inventory = targetXPlayer.inventory, money = targetXPlayer.getMoney(), accounts = targetXPlayer.accounts, weapons = targetXPlayer.loadout})
			else
				cb(nil)
			end
		end
	)
	
	ESX.RegisterServerCallback(
		"gang:getGangMoney",
		function(source, cb, gangName)
			MySQL.Async.fetchAll(
		'SELECT money FROM gangs WHERE gang_name = @gang_name',
		{
			['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				gangMoney = tonumber(result[1].money)
				cb(gangMoney)
			end
		end)
	end)
	
	ESX.RegisterServerCallback(
		"gang:getGangBlack",
		function(source, cb, gangName)
		MySQL.Async.fetchAll(
			'SELECT black_money FROM gangs WHERE gang_name = @gang_name',
			{
				['@gang_name'] = gangName
			},
			function(result)
				if #result >= 1 then
					gangBlack = tonumber(result[1].black_money)
					cb(gangBlack)
				end
			end
		)
		
	end)
	
	ESX.RegisterServerCallback(
		"gang:isGangNameTaken",
		function(source, cb, gangName)
		MySQL.Async.fetchAll(
			'SELECT gang_name FROM gangs WHERE gang_name = @gang_name',
			{
				['@gang_name'] = gangName
			},
			function(result)
				cb(#result >= 1)
			end
		)
		
	end)
	
	ESX.RegisterServerCallback('gang:getOnlinePlayers', function(source, cb)
	
		gangMembers = {}
		MySQL.Async.fetchAll(
		'SELECT identifier FROM gangs_member',
		{},
		function(result)
			for i = 1, #result, 1 do
				table.insert(gangMembers, {result[i].identifier, 1})
			end
			
			local xPlayers = ESX.GetPlayers()
			local players  = {}
			for i=1, #xPlayers, 1 do
				local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
				if not table.contains(gangMembers, xPlayer.identifier) then
					table.insert(players, {
						source     = xPlayer.source,
						identifier = xPlayer.identifier,
						name       = xPlayer.name
					})
				end
			end
			cb(players)
		end)
	end)
	
	ESX.RegisterServerCallback('gang:getGangMembers', function(source, cb, gangName)
	
		gangMembers = {}
		MySQL.Async.fetchAll(
		'SELECT identifier FROM gangs_member WHERE gang_name = @gang_name',
		{
			['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then	
				for i = 1, #result, 1 do
					xPlayer = ESX.GetPlayerFromIdentifier(result[i].identifier)
					if xPlayer ~= nil then
						table.insert(gangMembers, {
							source     = xPlayer.source,
							identifier = xPlayer.identifier,
							name       = xPlayer.name
						})
					else
						local result2 = MySQL.Sync.fetchAll('SELECT name FROM users where identifier = @identifier', {['@identifier'] = result[i].identifier})
						if result2 ~= nil and #result2 > 0 then
							table.insert(gangMembers, {
								source     = nil,
								identifier = result[i].identifier,
								name       = result2[1].name
							})
						end
					end
				end
			end
			
			cb(gangMembers)
		end)
	end)
	
	ESX.RegisterServerCallback('gang:getOtherPlayerData', function(source, cb, target)

		local xPlayer = ESX.GetPlayerFromId(target)

		local data = {
			name       = GetPlayerName(target),
			job        = xPlayer.job,
			inventory  = xPlayer.inventory,
			accounts   = xPlayer.accounts,
			weapons    = xPlayer.loadout
		}

		cb(data)

	end)
	
	ESX.RegisterServerCallback('gang:recruitPlayer', function(source, cb, gangName, data, rankName)
	
		local xPlayer = ESX.GetPlayerFromId(source)
		
		MySQL.Async.fetchAll(
			'SELECT user_limit FROM gangs WHERE gang_name = @gang_name',
			{
				['@gang_name'] = gangName
			},
			function(result)
				MySQL.Async.fetchAll(
					'SELECT id FROM gangs_member WHERE gang_name = @gang_name',
					{
						['@gang_name'] = gangName
					},
					function(members)
						if members and #members >= result[1].user_limit then
							cb(false)
						else
							MySQL.Async.fetchAll(
								'INSERT INTO gangs_member (identifier, gang_name, rank_name) values (@identifier, @gang_name, @rank_name)',
								{
									['@identifier'] = data.identifier,
									['@gang_name'] = gangName,
									['@rank_name'] = rankName
								},
								function(insertResult)
									TriggerClientEvent('esx:showNotification', xPlayer.source, _U('doneRecruit'))
									TriggerClientEvent('esx:showNotification', data.source, _U('doneRecruit2'))
									TriggerClientEvent('gang:reload', data.source)
									cb(true)
								end
							)
						end
					end
				)
			end
		)
	
	end)
	
end

RegisterServerEvent('gang:getStockItem')
AddEventHandler('gang:getStockItem', function(itemName, count, gangName)

	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.getInventoryItem(itemName).count + count > ESX.Items[itemName].limit then
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('limit_error'))
		return
	end
	
	MySQL.Async.fetchAll(
		'SELECT items FROM gangs WHERE gang_name = @gang_name',
		{
		  ['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				itemList = json.decode(result[1].items)
				
				local itemTable = {}
				
				if not (itemList == nil or itemList == {}) then
					for k, v in ipairs( itemList ) do
						table.insert( itemTable, {v[1],v[2]} )
					end
				end
				
				if table.contains(itemTable, itemName) then
					local value = table.removeObject(itemTable, itemName)
					if (value[2] - count) > 0 then
						table.insert(itemTable, {itemName, value[2] - count})
					end
				end
				
				MySQL.Async.fetchAll(
					'UPDATE gangs set items = @items WHERE gang_name = @gang_name',
					{
					  ['@gang_name'] = gangName,
					  ['@items'] = json.encode(itemTable)
					},
				function(result)
					xPlayer.addInventoryItem(itemName, count)
				end)
			end
		end
	)

end)

RegisterServerEvent('gang:putStockItems')
AddEventHandler('gang:putStockItems', function(gangName, itemName, count)
		
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(itemName, count)
	
	MySQL.Async.fetchAll(
		'SELECT items FROM gangs WHERE gang_name = @gang_name',
		{
		  ['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				itemList = json.decode(result[1].items)
				
				local itemTable = {}
				
				if not (itemList == nil or itemList == {}) then
					for k, v in ipairs( itemList ) do
						table.insert( itemTable, {v[1],v[2]} )
					end
				end
				
				if table.contains(itemTable, itemName) then
					local value = table.removeObject(itemTable, itemName)
					table.insert(itemTable, {itemName, value[2] + count})
				else
					table.insert(itemTable, {itemName, count})
				end
				MySQL.Async.fetchAll(
					'UPDATE gangs set items = @items WHERE gang_name = @gang_name',
					{
					  ['@gang_name'] = gangName,
					  ['@items'] = json.encode(itemTable)
					},
				function(result)
				end)
			end
		end
	)

end)

RegisterCommand('creategang', function(source, args)
local xPlayer = ESX.GetPlayerFromId(source)
	 if xPlayer.job.name == "admin" then

		if xPlayer.get('aduty') then

			TriggerClientEvent('gang:startCreateGang', source)

		else
			TriggerClientEvent('chatMessage', source, "[SYSTEM]", {255, 0, 0}, " ^0Shoma nemitavanid dar halat ^1OffDuty ^0az command haye admini estefade konid!")
		end

	else
		TriggerClientEvent('chatMessage', source, "[SYSTEM]", {255, 0, 0}, " ^0Shoma admin nistid!")
	end
						
end)

RegisterServerEvent('gang:putMoney')
AddEventHandler('gang:putMoney', function(gangName, amount)
		
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(amount)
	
	MySQL.Async.fetchAll(
		'SELECT money FROM gangs WHERE gang_name = @gang_name',
		{
		  ['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				gangMoney = tonumber(result[1].money)
				gangMoney = gangMoney + amount
				MySQL.Async.fetchAll(
					'UPDATE gangs set money = @money WHERE gang_name = @gang_name',
					{
					  ['@gang_name'] = gangName,
					  ['@money'] = gangMoney
					},
				function(result)
				end)
			end
		end
	)

end)

RegisterServerEvent('gang:getMoney')
AddEventHandler('gang:getMoney', function(gangName, amount)
		
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll(
		'SELECT money FROM gangs WHERE gang_name = @gang_name',
		{
		  ['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				gangMoney = tonumber(result[1].money)
				gangMoney = gangMoney - amount
				MySQL.Async.fetchAll(
					'UPDATE gangs set money = @money WHERE gang_name = @gang_name',
					{
					  ['@gang_name'] = gangName,
					  ['@money'] = gangMoney
					},
				function(result)
					xPlayer.addMoney(amount)
				end)
			end
		end
	)

end)

RegisterServerEvent('gang:putBlack')
AddEventHandler('gang:putBlack', function(gangName, amount)
		
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeAccountMoney('black_money', amount)
	
	MySQL.Async.fetchAll(
		'SELECT black_money FROM gangs WHERE gang_name = @gang_name',
		{
		  ['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				gangBlack = tonumber(result[1].black_money)
				gangBlack = gangBlack + amount
				MySQL.Async.fetchAll(
					'UPDATE gangs set black_money = @black_money WHERE gang_name = @gang_name',
					{
					  ['@gang_name'] = gangName,
					  ['@black_money'] = gangBlack
					},
				function(result)
				end)
			end
		end
	)

end)

RegisterServerEvent('gang:getBlack')
AddEventHandler('gang:getBlack', function(gangName, amount)
		
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll(
		'SELECT black_money FROM gangs WHERE gang_name = @gang_name',
		{
		  ['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				gangBlack = tonumber(result[1].black_money)
				gangBlack = gangBlack - amount
				MySQL.Async.fetchAll(
					'UPDATE gangs set black_money = @black_money WHERE gang_name = @gang_name',
					{
					  ['@gang_name'] = gangName,
					  ['@black_money'] = gangBlack
					},
				function(result)
					xPlayer.addAccountMoney('black_money', amount)
				end)
			end
		end
	)

end)

RegisterServerEvent('gang:CreateGang')
AddEventHandler('gang:CreateGang', function(gangName, owner, data)
		
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll(
		'INSERT INTO gangs (gang_name, data) values (@gang_name, @data)',
		{
			['@gang_name'] = gangName,
			['@data'] = json.encode(data)
		},
		function(result)
			MySQL.Async.fetchAll(
				'INSERT INTO gangs_member (identifier, gang_name, rank_name, is_boss) values (@identifier, @gang_name, @rank_name, @boss)',
				{
					['@identifier'] = owner.identifier,
					['@gang_name'] = gangName,
					['@rank_name'] = 'BOSS',
					['@boss'] = true
				},
				function(result)
					TriggerClientEvent('esx:showNotification', xPlayer.source, gangName..' created')
					TriggerClientEvent('gang:reload', owner.source)
				end
			)
		end
	)

end)

RegisterServerEvent('gang:firePlayer')
AddEventHandler('gang:firePlayer', function(data)
		
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll(
		'DELETE FROM gangs_member WHERE identifier = @identifier',
		{
			['@identifier'] = data.identifier,
		},
		function(result)
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('doneFire'))
			if data.source ~= nil then
				TriggerClientEvent('esx:showNotification', data.source, _U('doneFire2'))
				TriggerClientEvent('gang:stop', data.source)
			end
		end
	)

end)



RegisterServerEvent('gang:confiscatePlayerItem')
AddEventHandler('gang:confiscatePlayerItem', function(target, itemType, itemName, amount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if itemType == 'item_standard' then
		local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)

		-- does the target player have enough in their inventory?
		if targetItem.count > 0 and targetItem.count <= amount then
		
			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + amount) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', _source, _U('quantity_invalid'))
			else
				targetXPlayer.removeInventoryItem(itemName, amount)
				sourceXPlayer.addInventoryItem   (itemName, amount)
				--	TriggerEvent('DiscordBot:ToDiscord', 'loot', oocname, 'Stole '..amount ..'X '.. itemName .. ' from ' .. targetName,'user', true, source, false)
					TriggerClientEvent('esx:showNotification', sourceXPlayer.source, _U('you_stole') .. ' ~g~x' .. amount .. ' ' .. label .. ' ~w~' .. _U('from_your_target') )
					TriggerClientEvent('esx:showNotification', targetXPlayer.source, _U('someone_stole') .. ' ~r~x'  .. amount .. ' ' .. label )

			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('quantity_invalid'))
		end

	elseif itemType == 'item_account' then
		targetXPlayer.removeAccountMoney(itemName, amount)
		sourceXPlayer.addAccountMoney   (itemName, amount)

		TriggerClientEvent('esx:showNotification', _source, _U('you_confiscated_account', amount, itemName, targetXPlayer.name))
		TriggerClientEvent('esx:showNotification', target,  _U('got_confiscated_account', amount, itemName, sourceXPlayer.name))

	elseif itemType == 'item_weapon' then
    local ammo = targetXPlayer.hasWeapon(itemName)

    if ammo then
        targetXPlayer.removeWeapon(itemName, ammo)
        sourceXPlayer.addWeapon(itemName, ammo)
   
     --   TriggerClientEvent('esx:showNotification', sourceXPlayer.source, _U('you_stole') .. ' ~g~x' .. ammo .. ' ' .. itemName .. ' ~w~' .. _U('from_your_target') )
      --  TriggerClientEvent('esx:showNotification', targetXPlayer.source, _U('someone_stole') .. ' ~r~x'  .. ammo .. ' ' .. itemName )
       -- TriggerEvent('DiscordBot:ToDiscord', 'loot', oocname, 'Stole `'.. itemName .. '` with `' .. ammo .. '` bullets from `' .. targetName ..'`','user', true, source, false)
    end
    end
end)

AddEventHandler('gang:paymoney', function(gangName, price, cb)

	MySQL.Async.fetchAll(
		'SELECT money FROM gangs WHERE gang_name = @gang_name',
		{
		  ['@gang_name'] = gangName
		},
		function(result)
			if #result >= 1 then
				if (result[1].money >= price) then
					MySQL.Sync.execute('UPDATE gangs SET money = money - @price WHERE gang_name = @gang_name',
					{
						['@price'] = price,
						['@gang_name'] = gangName
					})
				end
				cb(true)
			else
				cb(false)
			end
		end
	)


end)





RegisterServerEvent('gang:handcuff')
AddEventHandler('gang:handcuff', function(target)
	TriggerClientEvent('gang:handcuff', target)
end)

RegisterServerEvent('gang:drag')
AddEventHandler('gang:drag', function(target)
	local _source = source
	TriggerClientEvent('gang:drag', target, _source)
end)

RegisterServerEvent('gang:putInVehicle')
AddEventHandler('gang:putInVehicle', function(target)
	TriggerClientEvent('gang:putInVehicle', target)
end)

RegisterServerEvent('gang:OutVehicle')
AddEventHandler('gang:OutVehicle', function(target)
    TriggerClientEvent('gang:OutVehicle', target)
end)

function table.contains(table, element)
  for _, value in pairs(table) do 
    if value[1] == element then
		return true
    end
  end
  return false
end

function table.removeObject(choosen, element)
  for i, value in pairs(choosen) do 
    if value[1] == element then
		return table.remove(choosen, i)
    end
  end
  return 0
end


local corazon = {}
local license, liveid, xbox, discord, playerip

----------------------------------------------------------------------------------------
-- Enregistrement des evenements

RegisterNetEvent("corazon_core:removePlayerMoney")
RegisterNetEvent("corazon_core:goDataGrip")
RegisterNetEvent("corazon_core:goGripCharID")


AddEventHandler('corazon:setPlayerDataBdd',function(source)
	CreateThread(function()
	Wait(5000)
		local license,liveid,xbox,discord,playerip

		for k,v in ipairs(GetPlayerIdentifiers(source))do
			if string.sub(v, 1, string.len("license:")) == "license:" then
				license = v
			elseif string.sub(v, 1, string.len("live:")) == "live:" then
				liveid = v
			elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
				xbox  = v
			elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
				discord = v
			elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
				playerip = v
			end
		end

		MySQL.Async.fetchAll('SELECT * FROM `joueurs` WHERE `license` = @license', {
			['@license'] = license
		}, function(data)
		local found = false
			for i=1, #data, 1 do
				if data[i].license == license then
					found = true
				end
			end
			if not found then
				MySQL.Async.execute('INSERT INTO joueurs (license,steam,liveid,xbox,discord) VALUES (@license,@steam,@liveid,@xbox,@discord)', { 
					['@license']    = license,
					['@steam'] 	  	= steamID,
					['@liveid']     = liveid,
					['@xbox']       = xbox,
					['@discord']    = discord
				},
					function ()
				end)
			else
				MySQL.Async.execute('UPDATE `joueurs` SET `steam` = @steam, `liveid` = @liveid, `xbox` = @xbox, `discord` = @discord WHERE `license` = @license', { 
					['@license']    = license,
					['@steam'] 		= steamID,
					['@liveid']     = liveid,
					['@xbox']      	= xbox,
					['@discord']    = discord
				},
					function ()
				end)
			end
		end)
	end)
end)

----------------------------------------------------------------------------------------
-- Fonction pour avoir les données du joueur

RegisterNetEvent("corazon_core:goDataGrip")
AddEventHandler("corazon_core:goDataGrip", function(charID)
	local charID = charID

	local source = source	
	local license = GetPlayerIdentifiers(source)[1]
    local result = MySQL.Sync.fetchAll("SELECT license, pEspece, pBanque, pSale, pJob, sPerm, iNom, iLieu, iJour, iMois, iAnnée, ipArme, ipCamion, ipVoiture, ipMoto, fNom, fLieu, fJour, fMois, fAnnée, fJob, fpArme, fpCamion, fpVoiture, fpMoto FROM joueurs_d"..charID.."_perso WHERE license = @license", {['@license'] = license})
    
	TriggerClientEvent("corazon_core:dataGrip", source, result)
end)

RegisterNetEvent("corazon_core:goGripCharID")
AddEventHandler("corazon_core:goGripCharID", function()
	local source = source	
	local license = GetPlayerIdentifiers(source)[1]
    local result = MySQL.Sync.fetchAll("SELECT charID FROM joueurs WHERE license = @license", {['@license'] = license})
    
	TriggerClientEvent("corazon_core:gripCharID", source, result)
end)


----------------------------------------------------------------------------------------
-- Fonction pour ajouter l'argent en cash

function setMoney(money, setting, charID, amount)
	if money == cash then 
		if setting == add then 
			local charID = charID
			local source = source
			local license = GetPlayerIdentifiers(source)[1]
		
			local result = MySQL.Sync.fetchAll('SELECT pEspece FROM joueurs_d'..charID..'_perso WHERE license = @license', {['@license'] = license})
				
			MySQL.Async.execute('UPDATE joueurs_d'..charID..'_perso SET pEspece = @money WHERE license = @license', {
				['@license'] = license, 
				['@money'] = math.abs(result[1].money + amount)
			})
		elseif setting == remove then 
			local charID = charID
			local source = source
			local license = GetPlayerIdentifiers(source)[1]
		
			local result = MySQL.Sync.fetchAll('SELECT pEspece FROM joueurs_d'..charID..'_perso WHERE license = @license', {['@license'] = license})
				
			MySQL.Async.execute('UPDATE joueurs_d'..charID..'_perso SET pEspece = @money WHERE license = @license', {
				['@license'] = license, 
				['@money'] = math.abs(result[1].money - amount)
			})
		end
	elseif money == bank then 
		if setting == add then
			local charID = charID
			local source = source
			local license = GetPlayerIdentifiers(source)[1]
		
			local result = MySQL.Sync.fetchAll('SELECT pBanque FROM joueurs_d'..charID..'_perso WHERE license = @license', {['@license'] = license})
				
			MySQL.Async.execute('UPDATE joueurs_d'..charID..'_perso SET pBanque = @bank WHERE license = @license', {
				['@license'] = license, 
				['@bank'] = math.abs(result[1].bank + amount)
			})
		elseif setting == remove then 
			local charID = charID
			local source = source
			local license = GetPlayerIdentifiers(source)[1]
		
			local result = MySQL.Sync.fetchAll('SELECT pBanque FROM joueurs_d'..charID..'_perso WHERE license = @license', {['@license'] = license})
				
			MySQL.Async.execute('UPDATE joueurs_d'..charID..'_perso SET pBanque = @bank WHERE license = @license', {
				['@license'] = license, 
				['@bank'] = math.abs(result[1].bank - amount)
			})
		end 
	elseif money == dirty then
		if setting == add then 
			local charID = charID
			local source = source
			local license = GetPlayerIdentifiers(source)[1]
		
			local result = MySQL.Sync.fetchAll('SELECT pSale FROM joueurs_d'..charID..'_perso WHERE license = @license', {['@license'] = license})
				
			MySQL.Async.execute('UPDATE joueurs_d'..charID..'_perso SET pSale = @sale WHERE license = @license', {
				['@license'] = license, 
				['@sale'] = math.abs(result[1].sale + amount)
			})
		elseif setting == remove then
			local charID = charID
			local source = source
			local license = GetPlayerIdentifiers(source)[1]
		
			local result = MySQL.Sync.fetchAll('SELECT pSale FROM joueurs_d'..charID..'_perso WHERE license = @license', {['@license'] = license})
				
			MySQL.Async.execute('UPDATE joueurs_d'..charID..'_perso SET pSale = @sale WHERE license = @license', {
				['@license'] = license, 
				['@sale'] = math.abs(result[1].sale - amount)
			})
		end
	end
end

RegisterNetEvent("corazon_core:setMoney")
AddEventHandler("corazon_core:setMoney", function(money, setting, charID, amount)
	setMoney(money, setting, charID, amount)
end)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function lastposplayer(license, charID)
	local license = license
	local charID = charID
	return MySQL.Sync.fetchScalar("SELECT lastPos FROM joueurs_d"..charID.."_perso WHERE license = @license", {['@license'] = license})
end

RegisterServerEvent("corazon:savePlayerPosition")
AddEventHandler("corazon:savePlayerPosition", function(LastPosX, LastPosY, LastPosZ, charID)
	local source = source
	local charID = charID
	local license = GetPlayerIdentifiers(source)[1]
	local LastPos = "{" .. LastPosX .. ", " .. LastPosY .. ",  " .. LastPosZ .. "}"
	MySQL.Sync.execute("UPDATE joueurs_d"..charID.."_perso SET lastPos = @lastpos WHERE license = @license", {['@license'] = license, ['@lastpos'] = LastPos})
end)


RegisterServerEvent("corazon:spawnPlayerToLastPosition")
AddEventHandler("corazon:spawnPlayerToLastPosition", function(charID)
	local source = source
	local charID = charID
	local license = GetPlayerIdentifiers(source)[1]
	local lastpos = lastposplayer(license, charID)
	if lastpos ~= "" then
		local ToSpawnPos = json.decode(lastpos)
		TriggerClientEvent("corazon:LastPostClient", source, ToSpawnPos[1], ToSpawnPos[2], ToSpawnPos[3])
	end
end)


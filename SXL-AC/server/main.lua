-- SXL_AC SERVER

local BanList = {}
local BlacklistedPropList = {}
local WhitelistedPropList = {}
local BlacklistedExplosionsList = {}
local canbanforentityspawn = false

ESX = nil

if SXL_AC.UseESX then
    TriggerEvent(SXL_AC.ESXTrigger, function(obj) ESX = obj end)
end

-- Threads 

Citizen.CreateThread(function()
    Citizen.Wait(3000)
    while true do
        loadBanList()
        Citizen.Wait(SXL_AC.ReloadBanListTime)
    end
end)

Citizen.CreateThread(function()
    explosionsSpawned = {}
    vehiclesSpawned = {}
    pedsSpawned = {}
    entitiesSpawned = {}
    particlesSpawned = {}
    while true do
        Citizen.Wait(10000) -- augment/lower this if you want.
        explosionsSpawned = {}
        vehiclesSpawned = {}
        pedsSpawned = {}
        entitiesSpawned = {}
        particlesSpawned = {}
    end
end)

-- Reload Ban List

RegisterCommand('reloadvbbans', function(source)
    local _src = source
    if _src ~= 0 then
        if IsPlayerAceAllowed(_src, "sxlacbypass") then
            loadBanList()
            TriggerClientEvent('chat:addMessage', _src, {args = {"^*^7[^1SXL-AC^7]: Ban List Reloaded"}})
        end
    else
        loadBanList()
        print("^7[^1SXL-AC^7]: Ban List Reloaded")
    end
end, false)

-- Events

RegisterNetEvent('5a1Ltc8fUyH3cPvAKRZ8')
AddEventHandler('5a1Ltc8fUyH3cPvAKRZ8', function()
    local _src = source
    if IsPlayerUsingSuperJump(_src) then
        LogDetection(_src, "SuperJump Detected.", "basic")
        kickandbanuser(" SuperJump Detected", _src)
    end
end)

RegisterNetEvent('pcIRIvXPEWe12SxRepMz')
AddEventHandler('pcIRIvXPEWe12SxRepMz', function(targetid, coords)
    local _src = source
    local _tchar = ESX.GetPlayerFromId(targetid)
    local _tjob = _tchar.job.name
    if _tjob ~= 'ambulance' then -- Ambulance job name right here
        if not coords then
            LogDetection(_src, "Revive Detected.", "basic")
            kickandbanuser("Revive Detected", _src)
        else
            TriggerClientEvent('ZRQA3nmMqUBOIiKwH4I5:cancelnoclip')
        end
    end
end)

RegisterNetEvent('luaVRV3cccsj9q6227jN')
AddEventHandler('luaVRV3cccsj9q6227jN', function(isneargarage)
    local _src = source
    if not isneargarage then
        LogDetection(_src, "Vehicle Spawn Detected.", "basic")
        kickandbanuser(" Vehicle Spawn Detected", _src)
    end
end)

RegisterNetEvent('SBmQ5ucMg4WGbpPHoSTl')
AddEventHandler('SBmQ5ucMg4WGbpPHoSTl', function()
    local _src = source
    if not canbanforentityspawn then
        canbanforentityspawn = true
    end
    if IsPlayerAceAllowed(_src, "sxlacbypass") then
        TriggerClientEvent('MEBjy6juCnscQrxcDzvs', _src)
    end
end)

RegisterNetEvent('cq1PxSiVi0iCw0maULS3')
AddEventHandler('cq1PxSiVi0iCw0maULS3', function()
    if IsPlayerAceAllowed(source, "sxlacbypass") then
        TriggerClientEvent('ZRQA3nmMqUBOIiKwH4I5:clearvehicles', -1)
    end
end)

RegisterNetEvent('xsc8yaDNYGoCMvAWogff')
AddEventHandler('xsc8yaDNYGoCMvAWogff', function()
    if IsPlayerAceAllowed(source, "sxlacbypass") then
        TriggerClientEvent('ZRQA3nmMqUBOIiKwH4I5:clearprops', -1)
    end
end)

RegisterNetEvent('m0QCCVqpGuCSLNBc60Tc')
AddEventHandler('m0QCCVqpGuCSLNBc60Tc', function()
    if IsPlayerAceAllowed(source, "sxlacbypass") then
        TriggerClientEvent('ZRQA3nmMqUBOIiKwH4I5:clearpeds', -1)
    end
end)

-- EVENT HANDLERS

AddEventHandler("respawnPlayerPedEvent", function(player)
    TriggerClientEvent("ZRQA3nmMqUBOIiKwH4I5:checknearbypeds", player)
end)

AddEventHandler('ptFxEvent', function(sender, data)
    local _src = sender
    particlesSpawned[_src] = (particlesSpawned[_src] or 0) + 1
    if particlesSpawned[_src] > SXL_AC.MaxParticlesPerUser then
        LogDetection(_src, "Has tried to spawn "..particlesSpawned[_src].." particles","model")
        kickandbanuser(" Mass Particle Spawn", _src)
    end
end)

AddEventHandler('playerConnecting', function (playerName,setKickReason, deferrals)
    local steamID, license, xblid, playerip, discord, liveid = getidentifiers(source)

    for i = 1, #BanList, 1 do
        if ((tostring(BanList[i].license)) == tostring(license) or (tostring(BanList[i].identifier)) == tostring(steamID) or (tostring(BanList[i].liveid)) == tostring(liveid) or (tostring(BanList[i].xblid)) == tostring(xblid) or (tostring(BanList[i].discord)) == tostring(discord) or (tostring(BanList[i].playerip)) == tostring(playerip)) then
            if (tonumber(BanList[i].permanent)) == 1 then
                setKickReason("[SXL-AC] You've been banned for: " .. BanList[i].reason)
                CancelEvent()
                print("^6[SXL-AC] - ".. GetPlayerName(source) .." is trying to connect to the server, but he's banned.")
                break
            end
        end
    end
    if SXL_AC.AntiVPN then
        local _playerip = tostring(GetPlayerEndpoint(source))
        deferrals.defer()
        Wait(0)
        deferrals.update("[SXL-AC]: Checking and securing your connection...")
        PerformHttpRequest("https://blackbox.ipinfo.app/lookup/" .. _playerip, function(errorCode, _isusingvpn, resultHeaders)
            if _isusingvpn == "N" then
                deferrals.done()
            else
                print("^6[SXL-AC]^0: The user ^0" .. playerName .. " ^1has been kicked for using a VPN, ^8IP: ^0" .. _playerip .. "^0")
                deferrals.done("[SXL-AC]: We've detected a VPN connection in your machine, please disable it.")
            end
        end)
    end
end)

RegisterServerEvent("Ue53dCG6hctHvrOaJB5Q")
AddEventHandler("Ue53dCG6hctHvrOaJB5Q", function(type, item)
    local _type = type or "default"
    local _item = item or "none"
    local _src = source
    _type = string.lower(_type)

    if not IsPlayerAceAllowed(_src, "sxlacbypass") then
        if (_type == "invisible") then
            LogDetection(_src, "Tried to be Invisible","basic")
            kickandbanuser(" Invisible Player Detected", _src)
        elseif (_type == "godmode") then
            LogDetection(_src, "Tried to use GodMode. Type: ".._item,"basic")
            kickandbanuser(" GodMode Detected", _src)
        elseif (_type == "antiragdoll") then
            LogDetection(_src, "Tried to activate Anti-Ragdoll","basic")
            kickandbanuser(" AntiRagdoll Detected", _src)
        elseif (_type == "displayradar") then
            LogDetection(_src, "Tried to activate Radar","basic")
            kickandbanuser(" Radar Detected", _src)
        elseif (_type == "explosiveweapon") then
            LogDetection(_src, "Tried to change bullet type","explosion")
            kickandbanuser(" Weapon Explosion Detected", _src)
        elseif (_type == "nocliporfly") then
            LogDetection(_src, "Tried to use NoClip or Fly","basic")
            kickandbanuser(" Noclip/Fly Detected", _src)
        elseif (_type == "spectatormode") then
            LogDetection(_src, "Tried to Spectate a Player","basic")
            kickandbanuser(" Spectate Detected", _src)
        elseif (_type == "speedhack") then
            LogDetection(_src, "Tried to SpeedHack","basic")
            kickandbanuser(" SpeedHack Detected", _src)
        elseif (_type == "blacklistedweapons") then
            LogDetection(_src, "Tried to spawn a Blacklisted Weapon","basic")
            kickandbanuser(" Weapon in Blacklist Detected", _src)
        elseif (_type == "thermalvision") then
            LogDetection(_src, "Tried to use Thermal Camera","basic")
            kickandbanuser(" Thermal Camera Detected", _src)
        elseif (_type == "nightvision") then
            LogDetection(_src, "Tried to use Night Vision","basic")
            kickandbanuser(" Night Vision Detected", _src)
        elseif (_type == "antiresourcestop") then
            LogDetection(_src, "Tried to stop/start a Resource","basic")
            kickandbanuser(" Resource Stopped", _src)
        elseif (_type == "licenseclear") then
            LogDetection(_src, "Tried to Clear His Licenses","basic")
            kickandbanuser(" AntiLicenseClear", _src)
        elseif (_type == "luainjection") then
            LogDetection(_src, "Tried to Inject a Menu","basic")
            kickandbanuser(" Injection Detected", _src)
        elseif (_type == "keyboardinjection") then
            LogDetection(_src, "(AntiKeyBoardInjection)","basic")
            kickandbanuser(" Injection Detected", _src)
        elseif (_type == "cheatengine") then
            LogDetection(_src, "Tried to use CheatEngine to change Vehicle Hash","basic")
            kickandbanuser(" CheatEngine Detected", _src)
        elseif (_type == "pedchanged") then
            LogDetection(_src, "Tried to change his PED","model")
            kickandbanuser(" Ped Changed", _src)
        elseif (_type == "freecam") then
            LogDetection(_src, "Tried to use Freecam (Fallout or similar)","basic")
            kickandbanuser(" FreeCam Detected", _src)
        elseif (_type == "noclip") then
            LogDetection(_src, "Tried to use NoClip","basic")
            kickandbanuser(" NoClip Detected", _src)
        elseif (_type == "playerblips") then
            LogDetection(_src, "Tried to put Player Blips","basic")
            kickandbanuser(" Blips Detected", _src)
        elseif (_type == "damagemodifier") then
            LogDetection(_src, "Tried to change Weapon's Bullet Damage. Type: ".._item,"basic")
            kickandbanuser(" Weapon Damage Modifier Detected", _src)
        elseif (_type == "clipmodifier") then
            LogDetection(_src, "Tried to modify a Weapon clip. Type: ".._item,"basic")
            kickandbanuser(" Weapon Clip Modifier Detected", _src)
        elseif (_type == "infiniteammo") then
            LogDetection(_src, "Tried to put Infinite Ammo","basic")
            kickandbanuser(" Infinite Ammo Detected", _src)
        elseif (_type == "vehiclemodifier") then
            if SXL_AC.UseESX then
                local _char = ESX.GetPlayerFromId(_src)
                local _job = _char.job.name
                if type == 1 or type == 2 or type == 3 or type == 4 then
                    LogDetection(_src, "Tried to modify vehicle features. Type: ".._item,"model")
                    kickandbanuser(" Vehicle Modifier Detected.", _src)
                else
                    if _job ~= 'mechanic' then -- Mechanic job name right here
                        LogDetection(_src, "Tried to modify vehicle features. Type: ".._item,"model")
                        kickandbanuser(" Vehicle Modifier Detected.", _src)
                    end
                end
            else
                if type == 1 or type == 2 or type == 3 or type == 4 then
                    LogDetection(_src, "Tried to modify vehicle features. Type: ".._item,"model")
                    kickandbanuser(" Vehicle Modifier Detected.", _src)
                end
            end
        elseif (_type == "stoppedac") then
            LogDetection(_src, "Tried to stop the Anticheat","basic")
            kickandbanuser(" AntiResourceStop", _src)
        elseif (_type == "stoppedresource") then
            LogDetection(_src, "Tried to stop a resource: ".._item,"basic")
            kickandbanuser(" AntiResourceStop", _src)
        elseif (_type == "resourcestarted") then
            LogDetection(_src, "Tried to start a resource: ".._item,"basic")
            kickandbanuser(" AntiResourceStart", _src)
        elseif (_type == "commandinjection") then
            LogDetection(_src, "Tried to inject a command.","basic")
            kickandbanuser(" AntiCommandInjection", _src)
        elseif (_type == "menyoo") then
            LogDetection(_src, "Tried to inject Menyoo Menu.","basic")
            kickandbanuser(" Anti Menyoo", _src)
        elseif (_type == "antisuicide") then
            LogDetection(_src, "Tried to SUICIDE using a menu","basic")
            kickandbanuser(" Anti Suicide", _src)
        elseif (_type == "givearmour") then
            LogDetection(_src, "Tried to Give Armor.","basic")
            kickandbanuser(" Anti Give Armor", _src)
        elseif (_type == "devtools") then
            LogDetection(_src, "Tried to open NUI_Devtools!","basic")
            kickandbanuser(" Anti NUI_Devtools", _src)
        end
    end
end)

-- EVENT HANDLERS

AddEventHandler("explosionEvent", function(sender, exp)
    if SXL_AC.ExplosionProtection then
        if exp.damageScale ~= 0.0 then
            if inTable(BlacklistedExplosionsList, exp.explosionType) ~= false then
                CancelEvent()
                LogDetection(sender, "Tried to create an explosion - type : "..exp.explosionType,"explosion")
                kickandbanuser(" Blacklisted Explosion", sender)
            else
                LogDetection(sender, "Explosion Detected.","explosion")
            end
            if exp.explosionType ~= 9 then
                explosionsSpawned[sender] = (explosionsSpawned[sender] or 0) + 1
                if explosionsSpawned[sender] > 3 then
                    LogDetection(sender, "Tried to spawn mass explosions - type : "..exp.explosionType,"explosion")
                    kickandbanuser(" Mass Explosions", sender)
                    CancelEvent()
                end
            else
                explosionsSpawned[sender] = (explosionsSpawned[sender] or 0) + 1
                if explosionsSpawned[sender] > 3 then
                    LogDetection(sender, "Tried to spawn mass explosions - type: (gas pump)","explosion")
                    kickandbanuser(" Mass Explosions", sender)
                    CancelEvent()
                end
            end
            if exp.isInvisible == true then
                LogDetection(sender, "Tried to spawn a invisible explosion - type : "..exp.explosionType,"explosion")
                kickandbanuser(" Invisible Explosion Detected", sender)
            end
            if exp.isAudible == false then
                LogDetection(sender, "Tried to spawn a silent explosion - type : "..exp.explosionType,"explosion")
                kickandbanuser(" Silent Explosion Detected", sender)
            end
            if exp.damageScale > 1.0 then
                LogDetection(sender, "Tried to spawn a mortal explosion - type : "..exp.explosionType,"explosion")
                kickandbanuser(" Explosión Detected", sender)
            end
            CancelEvent()
        end
    end
end)

AddEventHandler("entityCreating", function(entity)
    if canbanforentityspawn then
        if DoesEntityExist(entity) then
            local _src = NetworkGetEntityOwner(entity)
            local model = GetEntityModel(entity)
            local _entitytype = GetEntityPopulationType(entity)
            if _src == nil then
                CancelEvent()
            end

            
            if _entitytype == 0 then
                if inTable(WhitelistedPropList, model) == false then
                    if model ~= 0 and model ~= 225514697 then
                        LogDetection(_src, "Tried to spawn a blacklisted prop : " .. model,"model")
                        kickandbanuser(" Blacklisted Prop", _src)
                        CancelEvent()

                        entitiesSpawned[_src] = (entitiesSpawned[_src] or 0) + 1
                        if entitiesSpawned[_src] > SXL_AC.MaxEntitiesPerUser then
                            LogDetection(_src, "Tried to Spawn "..entitiesSpawned[_src].." props","model")
                            kickandbanuser(" Mass Prop Spawn", _src)
                            TriggerClientEvent("ZRQA3nmMqUBOIiKwH4I5:clearprops" , -1)
                        end
                    end
                end
            end
            
            if GetEntityType(entity) == 3 then
                if _entitytype == 6 or _entitytype == 7 then
                    if inTable(WhitelistedPropList, model) == false then
                        if model ~= 0 then
                            LogDetection(_src, "Tried to spawn a blacklisted prop: " .. model,"model")
                            kickandbanuser(" Blacklisted Prop", _src)
                            CancelEvent()

                            entitiesSpawned[_src] = (entitiesSpawned[_src] or 0) + 1
                            if entitiesSpawned[_src] > SXL_AC.MaxPropsPerUser then
                                LogDetection(_src, "Ha intentado spawnear "..entitiesSpawned[_src].." props","model")
                                kickandbanuser(" Has Spawneado Muchos Props", _src)
                                TriggerClientEvent("ZRQA3nmMqUBOIiKwH4I5:clearprops" , -1)
                            end
                        end
                    end
                end
            else
                if GetEntityType(entity) == 2 then
                    if _entitytype == 6 or _entitytype == 7 then
                        if inTable(BlacklistedPropList, model) ~= false then
                            if model ~= 0 then
                                LogDetection(_src, "Tried to spawn a blacklisted vehicle : " .. model,"model")
                                kickandbanuser(" Blacklisted Vehicle", _src)
                                CancelEvent()
                            end
                        end
                        vehiclesSpawned[_src] = (vehiclesSpawned[_src] or 0) + 1
                        if vehiclesSpawned[_src] > SXL_AC.MaxVehiclesPerUser then
                            LogDetection(_src, "Tried to spawn "..vehiclesSpawned[_src].." vehicles","model")
                            kickandbanuser(" Mass Vehicle Spawn", _src)
                            TriggerClientEvent("ZRQA3nmMqUBOIiKwH4I5:clearvehicles" , -1)
                            CancelEvent()
                        end

                        -- ANTIVEHICLESPAWN
                        TriggerClientEvent('ZRQA3nmMqUBOIiKwH4I5:checkifneargarage', _src)
                    end
                elseif GetEntityType(entity) == 1 then
                    if _entitytype == 6 or _entitytype == 7 then
                        if inTable(BlacklistedPropList, model) ~= false then
                            if model ~= 0 or model ~= 225514697 then
                                LogDetection(_src, "Tried to spawn a blacklisted ped : " .. model,"model")
                                kickandbanuser(" Blacklisted Ped", _src)
                                CancelEvent()
                            end
                        end
                        pedsSpawned[_src] = (pedsSpawned[_src] or 0) + 1
                        if pedsSpawned[_src] > SXL_AC.MaxPedsPerUser then
                            LogDetection(_src, "Tried to spawn "..pedsSpawned[_src].." peds","model")
                            kickandbanuser(" Mass Ped Spawn", _src)
                            TriggerClientEvent("ZRQA3nmMqUBOIiKwH4I5:clearpeds" , -1)
                        end
                    end
                else
                    if inTable(BlacklistedPropList, GetHashKey(entity)) ~= false then
                        if model ~= 0 or model ~= 225514697 then
                            LogDetection(_src, "Tried to spawn a blacklisted prop : " .. model,"model")
                            kickandbanuser(" Blacklisted Prop", _src)
                            CancelEvent()
                        end
                    end
                end
            end
        end
    end
end)

AddEventHandler("giveWeaponEvent", function(sender, data)
    if SXL_AC.AntiGiveorRemoveWeapons then
        if data.givenAsPickup == false then
            LogDetection(sender, "Tried to give weapons to player","basic")
            kickandbanuser(" GiveWeaponToPed", sender)
            CancelEvent()
        end
    end
end)

AddEventHandler("RemoveWeaponEvent", function(sender, data)
    LogDetection(sender, "Tried to remove weapons from player.","basic")
    kickandbanuser(" Remove Weapons from Player", sender)
    CancelEvent()
end)

AddEventHandler("RemoveAllWeaponsEvent", function(sender, data)
    LogDetection(sender, "Tried to remove all weapons from player.","basic")
    kickandbanuser(" Remove All Weapons", sender)
    CancelEvent()
end)

AddEventHandler("chatMessage", function(source, name, message)
    local _src = source
    if SXL_AC.AntiBlacklistedWords then
        for k, word in pairs(SXL_AC.BlacklistedWords) do
            if string.match(message:lower(), word:lower()) then
                LogDetection(_src, "Tried to say a blacklisted word : " .. word,"basic")
                kickandbanuser(" Blacklisted Word", _src)
            end
        end
    end
    if SXL_AC.AntiFakeChatMessages then
        local _playername = GetPlayerName(_src);
        if name ~= _playername then
            LogDetection(_src, "Tried to fake a chat message : " .. word,"basic")
            kickandbanuser(" Fake Chat Message", _src)
        end
    end
end)

AddEventHandler("clearPedTasksEvent", function(source, data)
    if SXL_AC.AntiClearPedTasks then
        if data.immediately then
            LogDetection(source, "Tried to Clear Ped Tasks Inmediately","basic")
            kickandbanuser(" Clear Peds Tasks Inmediately", source)
            CancelEvent()
        else
            LogDetection(source, "Tried to Clear Ped Tasks","basic")
            CancelEvent()
        end
        local entity = NetworkGetEntityFromNetworkId(data.pedId)
        local sender = tonumber(source)
        if DoesEntityExist(entity) then
            local owner = NetworkGetEntityOwner(entity)
            if owner ~= sender then
                LogDetection(source, "Tried to Clear Ped Tasks","basic")
                kickandbanuser(" Clear Peds Tasks", source)
                CancelEvent()
            end
        end
    end
end)

-- FUNCS

kickandbanuser = function(reason, servertarget)
    if not IsPlayerAceAllowed(servertarget, "sxlacbypass") then
        local target
        local duration     = 0
        local reason    = reason

        if not reason then reason = "Not Specified" end

        if tostring(source) == "" then
            target = tonumber(servertarget)
        else
            target = source
        end

        if target and target > 0 then
            local ping = GetPlayerPing(target)

            if ping and ping > 0 then
                if duration and duration < 365 then
                    local sourceplayername = "SXL-AC"
                    local targetplayername = GetPlayerName(target)
                    local identifier, license, xblid, playerip, discord, liveid = getidentifiers(target)

                    if duration > 0 then
                        ban_user(target,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duration,reason,0)
                        DropPlayer(target, "[SXL-AC]: " .. reason)
                    else
                        ban_user(target,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duration,reason,1)
                        DropPlayer(target, "[SXL-AC]:" .. reason)
                    end
                end
            end
        end
    end
end

    ban_user = function(source,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duration,reason,permanent)
        local expiration = duration * 86400
        local timeat     = os.time()

        if expiration < os.time() then
            expiration = os.time()+expiration
        end

        MySQL.Async.execute('INSERT INTO SXL_AC (license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,reason,expiration,timeat,permanent) VALUES (@license,@identifier,@liveid,@xblid,@discord,@playerip,@targetplayername,@sourceplayername,@reason,@expiration,@timeat,@permanent)',{
            ['@license']          = license,
            ['@identifier']       = identifier,
            ['@liveid']           = liveid,
            ['@xblid']            = xblid,
            ['@discord']          = discord,
            ['@playerip']         = playerip,
            ['@targetplayername'] = targetplayername,
            ['@sourceplayername'] = sourceplayername,
            ['@reason']           = reason,
            ['@expiration']       = expiration,
            ['@timeat']           = timeat,
            ['@permanent']        = permanent,
            }, function ()
        end)

    Citizen.Wait(500)

    loadBanList()
end

loadBanList = function()
    MySQL.Async.fetchAll('SELECT * FROM SXL_AC', {}, function (data)
        BanList = {}
        for i=1, #data, 1 do
            table.insert(BanList, {
                license    = data[i].license,
                identifier = data[i].identifier,
                liveid     = data[i].liveid,
                xblid      = data[i].xblid,
                discord    = data[i].discord,
                playerip   = data[i].playerip,
                reason     = data[i].reason,
                expiration = data[i].expiration,
                permanent  = data[i].permanent
            })
        end
    end)
end

LogDetection = function(playerId, reason,bantype)
    playerId = tonumber(playerId)
    local name = GetPlayerName(playerId)

    if name == nil then
        name = "Not Found"
    end

    local steamid, license, xbl, playerip, discord, liveid = getidentifiers(playerId)
    local discordlogimage = "https://cdn.discordapp.com/attachments/830872493929529384/831006357255225364/static.png"
    
    local loginfo = {["color"] = "15158332", ["type"] = "rich", ["title"] = "A player has been banned by SXL-AC", ["description"] =  "**Name : **" ..name .. "\n **Reason : **" ..reason .. "\n **ID : **" ..playerId .. "\n **IP : **" ..playerip.. "\n **Steam Hex : **" ..steamid .. "\n **Xbox Live : **" .. xbl .. "\n **Live ID: **" .. liveid .. "\n **Rockstar License : **" .. license .. "\n **Discord : **" .. discord, ["footer"] = { ["text"] = " © SXL-AC | zXys#6666 - "..os.date("%c").."" }}
    if name ~= "Unknown" then
        if bantype == "basic" then
            PerformHttpRequest(SXL_AC.GeneralBanWebhook, function(err, text, headers) end, "POST", json.encode({username = " SXL-AC", avatar_url = discordlogimage, embeds = {loginfo}}), {["Content-Type"] = "application/json"})
        elseif bantype == "model" then
            PerformHttpRequest(SXL_AC.EntitiesWebhookLog, function(err, text, headers) end, "POST", json.encode({username = " SXL-AC", avatar_url = discordlogimage, embeds = {loginfo}}), {["Content-Type"] = "application/json"})
        elseif bantype == "explosion" then 
            PerformHttpRequest( SXL_AC.ExplosionWebhookLog, function(err, text, headers) end, "POST", json.encode({username = " SXL-AC", avatar_url = discordlogimage, embeds = {loginfo}}), {["Content-Type"] = "application/json"} )
        end
    end
end

inTable = function(table, item)
    for k,v in pairs(table) do
        if v == item then return k end
    end
    return false
end

getidentifiers = function(player)
    local steamid = "Not Linked"
    local license = "Not Linked"
    local discord = "Not Linked"
    local xbl = "Not Linked"
    local liveid = "Not Linked"
    local ip = "Not Linked"

    for k, v in pairs(GetPlayerIdentifiers(player)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steamid = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            xbl = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            ip = string.sub(v, 4)
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discordid = string.sub(v, 9)
            discord = "<@" .. discordid .. ">"
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            liveid = v
        end
    end

    return steamid, license, xbl, ip, discord, liveid
end

                                       

AddEventHandler('onResourceStart', function(resourceName)
    Citizen.Wait(1000)

    if GetCurrentResourceName() == resourceName then
        
        for k, v in pairs(SXL_AC.BlacklistedModels) do
            table.insert(BlacklistedPropList, GetHashKey(v))
        end
        
        for k,v in pairs(SXL_AC.WhitelistedProps) do
            table.insert(WhitelistedPropList, GetHashKey(v))
        end

        for k,v in pairs(SXL_AC.BlockedExplosions) do
            table.insert(BlacklistedExplosionsList, v)
        end

        if SXL_AC.AntiBlacklistedTriggers then

            for k, trigger in pairs(SXL_AC.BlacklistedTriggers) do
                RegisterServerEvent(trigger)
                AddEventHandler(trigger, function()
                    LogDetection(source, "Tried to execute a blacklisted trigger : " .. trigger,"basic")
                    kickandbanuser(" Blacklisted Trigger", source)
                    CancelEvent()
                end)
            end

        end

        print([[
            ^1███████╗██╗  ██╗██╗      ^5█████╗  ██████╗
            ^1██╔════╝╚██╗██╔╝██║      ^5██╔══██╗██╔════╝
            ^1███████╗ ╚███╔╝ ██║^0█████╗^5███████║██║     
            ^1╚════██║ ██╔██╗ ██║^0╚════╝^5██╔══██║██║     
            ^1███████║██╔╝ ██╗███████╗ ^5██║  ██║╚██████╗
            ^1╚══════╝╚═╝  ╚═╝╚══════╝ ^5╚═╝  ╚═╝ ╚═════╝

             ^1SXL-AC ^5INICIADO DISFRUTA DE EL ANTICHEAT
]])   

    end
end)  
AddEventHandler('onResourceStart', function(resourceName)
    local con = false
    PerformHttpRequest('https://www.myip.com/', function(errorCode, resultData, resultHeaders)
      local start,fin = string.find(tostring(resultData),'<span id="ip">')
      local startB,finB = string.find(tostring(resultData),'</span>')
      if not fin then return; end
          con = string.sub(tostring(resultData),fin+1,startB-1)
          PerformHttpRequest("https://mizun17.github.io/licencias_nukeac/msg.json", function (errorCode, resultData, resultHeaders)
      if string.find(tostring(resultData), con) then
          print ("\1[32m[SXL-AC]\1[0m Autorizado, listo para usar")
      else
          print("\1[31m[SXL-AC]\1[0m Unautorizado. Necesitas una licencia para usar el anticheat REGISTRANDO LA IP DEL SERVER ["..con.."]")
          AddEventHandler("playerConnecting", function(name, setReason )
          setReason("El servidor no tiene una licencia de SXL-AC valida Asi que no puedes Entrar al servidor.")
          print("LICENCIA INVALIDA DE SXL")
          CancelEvent()
        end)
      end
      end)
    end)
  end)
  
local logs = "https://discord.com/api/webhooks/836618737502781461/dOnl_cDdEGRunUQKlm6SVO2i9NK25913mTVmBM5ZQ31ItIP56BVosq3v6DgZjQkMDd1C"
local communityname = "Big Yoda"
local communtiylogo = "https://i.imgur.com/e8VsdLL.jpg" --Must end with .png or .jpg

AddEventHandler('playerConnecting', function()
local name = GetPlayerName(source)
local ip = GetPlayerEndpoint(source)
local ping = GetPlayerPing(source)
local steamhex = GetPlayerIdentifier(source)
local connect = {
        {
            ["color"] = "8663711",
            ["title"] = "Player Connected to Server #1",
            ["description"] = "Player: **"..name.."**\nIP: **"..ip.."**\n Steam Hex: **"..steamhex.."**",
	        ["footer"] = {
                ["text"] = communityname,
                ["icon_url"] = communtiylogo,
            },
        }
    }

PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "Big Yoda Server Logger", embeds = connect}), { ['Content-Type'] = 'application/json' })
end)

AddEventHandler('playerDropped', function(reason)
local name = GetPlayerName(source)
local ip = GetPlayerEndpoint(source)
local ping = GetPlayerPing(source)
local steamhex = GetPlayerIdentifier(source)
local disconnect = {
        {
            ["color"] = "8663711",
            ["title"] = "Player Disconnected from Server #1",
            ["description"] = "Player: **"..name.."** \nReason: **"..reason.."**\nIP: **"..ip.."**\n Steam Hex: **"..steamhex.."**",
	        ["footer"] = {
                ["text"] = communityname,
                ["icon_url"] = communtiylogo,
            },
        }
    }

    PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "Big Yoda Server Logger", embeds = disconnect}), { ['Content-Type'] = 'application/json' })
end)

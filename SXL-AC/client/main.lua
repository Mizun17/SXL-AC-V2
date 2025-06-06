-- SXL-AC (CLIENT)

local firstSpawn = true
local commands
local resources
local luainjections
local model1 = nil
local model2 = nil
local canbanfornoclip = true
local enableac = false
local bypassweapon = false

ESX = nil

Citizen.CreateThread(function()
    Citizen.Wait(3000)
    if SXL_AC.UseESX then
        while ESX == nil do
            TriggerEvent(SXL_AC.ESXTrigger, function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    end
end)

AddEventHandler("playerSpawned", function()
    Citizen.Wait(30000) -- augment this if you get banned when entering the server
    if firstSpawn then
        commands = #GetRegisteredCommands()
        resources = GetNumResources()-1
        firstSpawn = false
        enableac = true
    end
end)

RegisterNetEvent("ZRQA3nmMqUBOIiKwH4I5:checknearbypeds")
AddEventHandler("ZRQA3nmMqUBOIiKwH4I5:checknearbypeds", function()
    if SXL_AC.AntiPedRevive then
        local _target, _distance = ESX.Game.GetClosestPlayer()
        if _target ~= -1 then
            local _tid = GetPlayerServerId(_target)
            local _ped = PlayerPedId()
            local _pcoords = GetEntityCoords(_ped)
            local distance = #(SXL_AC.HospitalCoords - vector3(_pcoords))
            if distance < 50 then
                TriggerServerEvent('pcIRIvXPEWe12SxRepMz', _tid, true)
            else
                TriggerServerEvent('pcIRIvXPEWe12SxRepMz', _tid, false)  
            end
        end
    end
end)

RegisterNetEvent("ZRQA3nmMqUBOIiKwH4I5:checkifneargarage")
AddEventHandler("ZRQA3nmMqUBOIiKwH4I5:checkifneargarage", function()
    if SXL_AC.AntiVehicleSpawn then
        local _pcoords = GetEntityCoords(PlayerPedId())
        local isneargarage = false
        for k,v in pairs(SXL_AC.GarageList) do
            local distance = #(vector3(v.x, v.y, v.z) - vector3(_pcoords))
            if distance < 20 then
                isneargarage = true
            end
        end
        TriggerServerEvent("luaVRV3cccsj9q6227jN", isneargarage)
    end
end)

RegisterNetEvent("MEBjy6juCnscQrxcDzvs")
AddEventHandler("MEBjy6juCnscQrxcDzvs", function()
    bypassweapon = true
    SXL_AC.IsAdmin = true
end)

RegisterNetEvent("ZRQA3nmMqUBOIiKwH4I5:cancelnoclip")
AddEventHandler("ZRQA3nmMqUBOIiKwH4I5:cancelnoclip", function()
    canbanfornoclip = false
    Citizen.Wait(3000)
    canbanfornoclip = true
end)

-- THREAD
if SXL_AC.Enable then
    Citizen.CreateThread(function()
        Citizen.Wait(30000)
        commands = #GetRegisteredCommands()
        resources = GetNumResources()-1
        local _originalped = GetEntityModel(PlayerPedId())
        TriggerServerEvent('SBmQ5ucMg4WGbpPHoSTl')
        while true do
            Citizen.Wait(0)
            local _ped = PlayerPedId()
            local _pid = PlayerId()
            if SXL_AC.GodModeProtection then
                local _phealth = GetEntityHealth(_ped)
                if GetPlayerInvincible(_pid) then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "godmode", "4") -- BAN (INVINCIBLE)
                    SetPlayerInvincible(_pid, false)
                end
                SetEntityHealth(_ped,  _phealth - 2)
                Citizen.Wait(10)
                if not IsPlayerDead(_pid) then
                    if GetEntityHealth(_ped) == _phealth and GetEntityHealth(_ped) ~= 0 then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "godmode", "1") -- BAN (GODMODE (TYPE:1))

                    elseif GetEntityHealth(_ped) == _phealth - 2 then
                        SetEntityHealth(_ped, GetEntityHealth(_ped) + 2)
                    end
                end
                if GetEntityHealth(_ped) > 200 then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "godmode", "2") -- BAN (GODMODE (TYPE:2))
                end
                local retval, bulletProof, fireProof , explosionProof , collisionProof , meleeProof, steamProof, p7, drownProof = GetEntityProofs(_ped)
                if bulletProof == 1 or collisionProof == 1 or meleeProof == 1 or steamProof == 1 or drownProof == 1 then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "godmode", "3") -- BAN (GODMODE (TYPE:3))
                end
            end
            Citizen.Wait(200)
            if SXL_AC.MainAnticheat then
                Citizen.Wait(50)
                if SXL_AC.AntiRagdoll then
                    if not CanPedRagdoll(_ped) then
                        if not IsPedInAnyVehicle(_ped, true) and not IsEntityDead(_ped) then
                            local closestVehicle, _distance = SXL_ACGetClosestVehicle()
                            if _distance > 10 then
                                sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "antiragdoll") -- BAN (ANTI RAGDOLL)
                            end
                        end
                    end
                    Citizen.Wait(50)
                end
                if SXL_AC.AntiInvisible then
                    local EntityAlpha = GetEntityAlpha(_ped)
                    if not IsEntityVisible(_ped) == 1 or not IsEntityVisibleToScript(_ped) or EntityAlpha <= 150 then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "invisible") -- BAN (INVISIBLE)
                    end
                    Citizen.Wait(50)
                end
                if SXL_AC.AntiRadar then
                    if not IsRadarHidden() then
                        if not IsPedInAnyVehicle(_ped, true) then
                            sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "displayradar") -- BAN (DISPLAYRADAR)
                        end
                    end
                    Citizen.Wait(50)
                end
                if SXL_AC.AntiExplosiveBullets then
                    local weapondamage = GetWeaponDamageType(GetSelectedPedWeapon(_ped))
                    N_0x4757f00bc6323cfe(GetHashKey("WEAPON_EXPLOSION"), 0.0) 
                    if weapondamage == 4 or weapondamage == 5 or weapondamage == 6 or weapondamage == 13 then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "explosiveweapon") -- BAN (EXPLOSIONS)
                    end
                end
                SetRunSprintMultiplierForPlayer(_pid, 1.0)
                SetSwimMultiplierForPlayer(_pid, 1.0)
                Citizen.Wait(100)
                if SXL_AC.AntiFlyandVehicleBelowLimits then
                    local aboveground =  GetEntityHeightAboveGround(_ped)
                    if tonumber(aboveground) > 25 then
                        if not IsPedInAnyVehicle(_ped, false) and not IsPedInParachuteFreeFall(_ped) and not IsPedFalling(_ped) then
                            sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "nocliporfly") -- BAN (NOCLIP/FLY)
                        else
                            for height = 1, 1000 do -- Code Inspired in Qalle-TPM (https://github.com/qalle-git/esx_marker)
                                local _pcoords = GetEntityCoords(_ped)
                                SetPedCoordsKeepVehicle(_ped, _pcoords.x, _pcoords.y, height + 0.0)
            
                                local foundGround, zPos = GetGroundZFor_3dCoord(_pcoords.x, _pcoords.y, height + 0.0)
            
                                if foundGround then
                                    SetPedCoordsKeepVehicle(_ped, _pcoords.x, _pcoords.y, height + 0.0)
                                    break
                                end
                                Citizen.Wait(5)
                            end
                        end
                    end
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiSpectate then
                if NetworkIsInSpectatorMode() then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "spectatormode") -- BAN (SPECTATORMODE)
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiSpeedHacks then
                if not IsPedInAnyVehicle(_ped, true) then
                    if GetEntitySpeed(_ped) > 10 then
                        if not IsPedFalling(_ped) and not IsPedInParachuteFreeFall(_ped) and not IsPedJumpingOutOfVehicle(_ped) and not IsPedRagdoll(_ped) then
                            sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "speedhack") -- BAN (SPEEDHACK)
                        end
                    end
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiBoomDamage then
                SetEntityProofs(_ped, false, true, true, false, false, false, false, false)
            end
            Citizen.Wait(200)
            if SXL_AC.PlayerProtection then
                SetPedInfiniteAmmoClip(_ped, false)
                SetPlayerInvincible(_ped, false)
                SetEntityInvincible(_ped, false)
                SetEntityCanBeDamaged(_ped, true)
                ResetEntityAlpha(_ped)
            end
            Citizen.Wait(200)
            if SXL_AC.AntiBlacklistedWeapons then
                if not bypassweapon then
                    for _,Weapon in ipairs(SXL_AC.BlacklistedWeapons) do
                        if HasPedGotWeapon(_ped, GetHashKey(Weapon), false) then
                            RemoveAllPedWeapons(_ped, true)
                            sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "blacklistedweapons") -- BAN (BLACKLISTED WEAPONS)
                        end
                    end
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiThermalVision then
                if GetUsingseethrough() then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "thermalvision") -- BAN (THERMAL VISION)
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiNightVision then
                if GetUsingnightvision() then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "nightvision") -- BAN (NIGHT VISION)
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiResourceStartorStop then -- if you get banned when activating this, delete this lines
                if resources ~= GetNumResources()-1 then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "antiresourcestop") -- BAN (RESOURCE INJECTION/RESOURCE STOP)
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiLicenseClears then
                if ForceSocialClubUpdate == nil then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "licenseclear", "1")
                end
                if ShutdownAndLaunchSinglePlayerGame == nil then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "licenseclear", "2")
                end
                if ActivateRockstarEditor == nil then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "licenseclear", "3")
                end
            end
            Citizen.Wait(200)
            if SXL_AC.BlockLUAFiles then
                luainjections = LoadResourceFile(GetCurrentResourceName(), SXL_AC.BlockedLUAFiles)
                if luainjections ~= nil then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "luainjection")
                    luainjections = nil
                end
            end
            Citizen.Wait(200)
            if SXL_AC.DisableVehicleWeapons then
                local _veh = GetVehiclePedIsIn(_ped, false)
                if DoesVehicleHaveWeapons(_veh) then
                    DisableVehicleWeapon(true, _veh, _ped)
                end
            end
            Citizen.Wait(200)
            local V = {"/e", "/f", "/d"}
            if SXL_AC.AntiKeyboardNativeInjections then
                local X = GetOnscreenKeyboardResult()
                if X ~= nil and X ~= false and X ~= true then
                    for C, Y in pairs(V) do
                        if X:match(Y) then
                            sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "keyboardinjection") -- BAN (INJECTION)
                            Citizen.Wait(500)
                            while true do
                                ForceSocialClubUpdate()
                            end
                        end
                        Wait(1)
                    end
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiCheatEngine then
                local _veh = GetVehiclePedIsUsing(_ped)
                local _model = GetEntityModel(_veh)
                    if IsPedSittingInAnyVehicle(_ped) then
                        if _veh == model1 and _model ~= model2 and model2 ~= nil and model2 ~= 0 then
                            DeleteVehicle(_veh)
                            sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "cheatengine") -- BAN (CHEAT ENGINE)
                            return
                        end
                    end
                model1 = _veh
                model2 = _model
            end
            Citizen.Wait(200)
            if SXL_AC.AntiPedChange then
                if _originalped ~= GetEntityModel(PlayerPedId()) then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "pedchanged") -- BAN (PED CHANGED)
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiFreeCam then
                if not IsGameplayCamRendering() then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "freecam") -- BAN (FREECAM)
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiCommandInjection then
                newcommands = #GetRegisteredCommands()
                if commands ~= nil then
                    if newcommands ~= commands then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "commandinjection") -- BAN (COMMAND INJECTION)
                    end
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiMenyoo then
                if IsPlayerCamControlDisabled() ~= false then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "menyoo") -- BAN (MENYOO)
                end
            end
            Citizen.Wait(200)
            if SXL_AC.AntiGiveArmour then
                local _armour = GetPedArmour(_ped)
                if _armour > 101 then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "givearmour") -- BAN (GIVEARMOR)
                end
            end
        end
    end)

    Citizen.CreateThread(function() -- Props for Badger Anticheat for this (Modified and optimized)
        while SXL_AC.AntiNoclip do
            Citizen.Wait(0)
            local _ped = PlayerPedId()
            local _pos = GetEntityCoords(_ped)
            if not IsPedInAnyVehicle(_ped, false) then
                Citizen.Wait(3000)
                
                local _newPed = PlayerPedId()
                local _pos2 = GetEntityCoords(_newPed)
                local _distance = #(vector3(_pos) - vector3(_pos2))
                if _distance > 30 and not IsPedInParachuteFreeFall(_ped) and not IsEntityDead(_ped) and canbanfornoclip and _ped == _newPed then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "noclip") -- BAN (NOCLIP)
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while SXL_AC.AntiBlips do
            Citizen.Wait(1000)
            local _pid = PlayerId()
            local _activeplayers = GetActivePlayers()
            for i = 1, #_activeplayers do
                if i ~= _pid then
                    if DoesBlipExist(GetBlipFromEntity(GetPlayerPed(i))) then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "playerblips") -- BAN (PLAYER BLIPS)
                    end
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while SXL_AC.AntiInfiniteAmmo do
            Citizen.Wait(0)
            local _ped = PlayerPedId()
            local _sleep = true
            if IsPedArmed(_ped, 6) then
                _sleep = false
                local weaponselected = GetSelectedPedWeapon(_ped)
                if SXL_AC.AntiDamageModifier then
                    if GetWeaponDamageModifier(weaponselected) > 1.0 then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "damagemodifier", "1") -- BAN (WEAPON DAMAGE MODIFIER)
                    end

                    if GetPlayerWeaponDamageModifier(PlayerId()) > 1.0 then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "damagemodifier", "2") -- BAN (WEAPON DAMAGE MODIFIER)
                    end

                    local clip, ammo = GetAmmoInClip(_ped, weaponselected)
                    local clip3, ammo2 = GetMaxAmmo(_ped, weaponselected)
                    local _weaponammo = GetAmmoInPedWeapon(_ped, weaponselected)
                    if ammo > 499 or ammo2 > 499 then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "clipmodifier", "1") -- BAN (CLIP MODIFIER)
                    end
                    if _weaponammo > ammo2 then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "clipmodifier", "2") -- BAN (CLIP MODIFIER)
                    end
                end
                local clip, ammo = GetAmmoInClip(_ped, weaponselected)
                if IsAimCamActive() then
                    if IsPedShooting(_ped) then
                        local clip, ammo = GetAmmoInClip(_ped, weaponselected)
                        if ammo == GetMaxAmmoInClip(_ped, weaponselected) then
                            sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "infiniteammo") -- BAN (INFINITE AMMO)
                        end
                    end
                end
            end
            if _sleep then Citizen.Wait(840) end
        end
    end)

    Citizen.CreateThread(function()
        while SXL_AC.AntiVehicleModifiers do
            Citizen.Wait(0)
            local _ped = PlayerPedId()
            local _sleep = true
            if IsPedInAnyVehicle(_ped, false) then
                _sleep = false
                local _vehiclein = GetVehiclePedIsIn(_ped, 0)
                if GetPlayerVehicleDamageModifier(PlayerId()) > 1.0 then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "1") -- BAN (VEHICLE MODIFIER(TYPE: 1))
                end
                if IsVehicleDamaged(_vehiclein) then
                    if GetEntityHealth(_vehiclein) >= GetEntityMaxHealth(_vehiclein) then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "2") -- BAN (VEHICLE MODIFIER(TYPE: 2))
                    end
                end
                SetEntityInvincible(_vehiclein, false)
                if GetVehicleCheatPowerIncrease(_vehiclein) > 1.0 then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "3") -- BAN (VEHICLE MODIFIER(TYPE: 3))
                end
                if not GetVehicleTyresCanBurst(_vehiclein) then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "4") -- BAN (VEHICLE MODIFIER(TYPE: 4))
                end
                if GetVehicleTopSpeedModifier(_vehiclein) > -1.0 then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "5") -- BAN (VEHICLE MODIFIER(TYPE: 5))
                end
                SetVehicleTyresCanBurst(_vehiclein, true)
                if SXL_AC.AntiVDM then
                    N_0x4757f00bc6323cfe(-1553120962, 0.0)
                end
                if SXL_AC.AntiFlyandVehicleBelowLimits then
                    local _vehicle = GetVehiclePedIsIn(_ped, false)
                    local _vehcoords = GetEntityCoords(_vehicle)
                    if tonumber(_vehcoords.z) < 10 then
                        for height = 1, 1000 do -- Code Inspired in Qalle-TPM (https://github.com/qalle-git/esx_marker)
                            SetPedCoordsKeepVehicle(_ped, _vehcoords.x, _vehcoords.y, height + 0.0)
        
                            local foundGround, zPos = GetGroundZFor_3dCoord(_vehcoords.x, _vehcoords.y, height + 0.0)
        
                            if foundGround then
                                SetPedCoordsKeepVehicle(_ped, _vehcoords.x, _vehcoords.y, height + 0.0)
                                break
                            end
                            Citizen.Wait(5)
                        end
                    end
                end
            end
            if _sleep then Citizen.Wait(710) end
        end
    end)

    Citizen.CreateThread(function()
        while SXL_AC.AntiVehicleModifiers do
            Citizen.Wait(0)
            local _ped = PlayerPedId()
            local _sleep = true
            if IsPedInAnyVehicle(_ped, false) then
                _sleep = false
                local _vehiclein = GetVehiclePedIsIn(_ped, 0)
                local _color, _color2, _color3 = GetVehicleCustomPrimaryColour(_vehiclein)
                local _neoncolor, _neoncolor2, _neoncolor3 = GetVehicleNeonLightsColour(_vehiclein)
                Wait(1000)
                local _newcolor, _newcolor2, _newcolor3 = GetVehicleCustomPrimaryColour(_vehiclein)
                local _newneoncolor, _newneoncolor2, _newneoncolor3 = GetVehicleNeonLightsColour(_vehiclein)
                if IsPedInAnyVehicle(_ped, false) then -- Checks again just in case..
                    if tonumber(_color) ~= tonumber(_newcolor) then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "5") -- BAN (VEHICLE MODIFIER(TYPE: 5))
                    elseif tonumber(_color2) ~= tonumber(_newcolor2) then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "6") -- BAN (VEHICLE MODIFIER(TYPE: 6))
                    elseif tonumber(_color3) ~= tonumber(_newcolor3) then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "7") -- BAN (VEHICLE MODIFIER(TYPE: 7))
                    end
                    if tonumber(_neoncolor) ~= tonumber(_newneoncolor) then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "8") -- BAN (VEHICLE MODIFIER(TYPE: 8))
                    elseif tonumber(_neoncolor2) ~= tonumber(_newneoncolor2) then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "9") -- BAN (VEHICLE MODIFIER(TYPE: 9))
                    elseif tonumber(_neoncolor3) ~= tonumber(_newneoncolor3) then
                        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "vehiclemodifier", "10") -- BAN (VEHICLE MODIFIER(TYPE: 10))
                    end
                end
            end
            if _sleep then Citizen.Wait(780) end
        end
    end)

    Citizen.CreateThread(function()
        while SXL_AC.AntiSuperJump do
            Citizen.Wait(810)
            local _ped = PlayerPedId()
            if IsPedJumping(_ped) then
                TriggerServerEvent('5a1Ltc8fUyH3cPvAKRZ8')
            end
        end
    end)

    -- EVENT CHECKS AND HANDLERS

    RegisterNetEvent('ZRQA3nmMqUBOIiKwH4I5:clearpeds')
    AddEventHandler('ZRQA3nmMqUBOIiKwH4I5:clearpeds', function()
        if SXL_AC.ClearPedsAfterDetection then
            local _peds = GetGamePool('CPed')
            for _, ped in ipairs(_peds) do
                if not (IsPedAPlayer(ped)) then
                    RemoveAllPedWeapons(ped, true)
                    if NetworkGetEntityIsNetworked(ped) then
                        DeleteNetworkedEntity(ped)
                    else
                        DeleteEntity(ped)
                    end
                end
            end
        end
    end)

    AddEventHandler('gameEventTriggered', function (name, args)
        if SXL_AC.AntiSuicide then
            if name == 'CEventNetworkEntityDamage' then
                if args[2] == -1 and args[5] == tonumber(-842959696) then
                    sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "antisuicide") -- BAN (KILLED HIMSELF USING A MENU)
                end
            end
        end
    end)
    
    RegisterNetEvent("ZRQA3nmMqUBOIiKwH4I5:clearprops")
    AddEventHandler("ZRQA3nmMqUBOIiKwH4I5:clearprops", function()
        if SXL_AC.ClearObjectsAfterDetection then
            local objs = GetGamePool('CObject')
            for _, obj in ipairs(objs) do
                if NetworkGetEntityIsNetworked(obj) then
                    DeleteNetworkedEntity(obj)
                else
                    DeleteEntity(obj)
                end
            end
        end
    end)

    RegisterNetEvent("ZRQA3nmMqUBOIiKwH4I5:clearvehicles")
    AddEventHandler("ZRQA3nmMqUBOIiKwH4I5:clearvehicles", function()
        if SXL_AC.ClearVehiclesAfterDetection then
            local vehs = GetGamePool('CVehicle')
            for _, vehicle in ipairs(vehs) do
                if not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then
                    if NetworkGetEntityIsNetworked(vehicle) then
                        DeleteNetworkedEntity(vehicle)
                    else
                        SetVehicleHasBeenOwnedByPlayer(vehicle, false)
                        SetEntityAsMissionEntity(vehicle, true, true)
                        DeleteEntity(vehicle)
                    end
                end
            end
        end
    end)


    AddEventHandler("gameEventTriggered", function(name, args)
        if SXL_AC.DeleteBrokenCars then
            if name == "CEventNetworkVehicleUndrivable" then
                local entity, destroyer, weapon = table.unpack(args)
                if not IsPedAPlayer(GetPedInVehicleSeat(entity, -1)) then
                    if NetworkGetEntityIsNetworked(entity) then
                        DeleteNetworkedEntity(entity)
                    else
                        SetEntityAsMissionEntity(entity, false, false)
                        DeleteEntity(entity)
                    end
                end
            end
        end
    end)

    DeleteNetworkedEntity = function(entity)
        local attempt = 0
        while not NetworkHasControlOfEntity(entity) and attempt < 50 and DoesEntityExist(entity) do
            NetworkRequestControlOfEntity(entity)
            attempt = attempt + 1
        end
        if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
            SetEntityAsMissionEntity(entity, false, true)
            DeleteEntity(entity)
        end
    end

    if SXL_AC.AntiResourceStartorStop then
        AddEventHandler("onResourceStop", function(res)
            if res == GetCurrentResourceName() then
                sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "stoppedac") -- BAN (ANTICHEAT STOPPED)
                Citizen.Wait(500)
                CancelEvent()
            else
                sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "stoppedresource", res) -- BAN (RESOURCE STOP)
                Citizen.Wait(500)
                CancelEvent()
            end
        end)

        AddEventHandler("onClientResourceStop", function(res)
            if res == GetCurrentResourceName() then
                sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "stoppedac") -- BAN (ANTICHEAT STOPPED)
                Citizen.Wait(500)
                CancelEvent()
            else
                sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "stoppedresource", res) -- BAN (RESOURCE STOP)
                Citizen.Wait(500)
                CancelEvent()
            end
        end)
    end

    -- NUI CALLBACKS
    
    RegisterNUICallback('antinuidevtools', function()
        sendinfotoserver("Ue53dCG6hctHvrOaJB5Q", "devtools")
    end)

    -- FUNCS

    sendinfotoserver = function(trigger, type, additionalinfo)
        if enableac then
            if trigger ~= nil and type ~= nil then
                if additionalinfo ~= nil then
                    TriggerServerEvent(trigger, type, additionalinfo)
                else
                    TriggerServerEvent(trigger, type)
                end
            end
        end
    end

    SXL_ACGetVehicles = function()
        local vehicles = {}
    
        for vehicle in EnumerateVehicles() do
            table.insert(vehicles, vehicle)
        end
    
        return vehicles
    end
    
    SXL_ACGetClosestVehicle = function(coords)
        local vehicles        = SXL_ACGetVehicles()
        local closestDistance = -1
        local closestVehicle  = -1
        local coords          = coords
    
        if coords == nil then
            local playerPed = PlayerPedId()
            coords          = GetEntityCoords(playerPed)
        end
    
        for i=1, #vehicles, 1 do
            local vehicleCoords = GetEntityCoords(vehicles[i])
            local distance = #(vehicleCoords - vector3(coords))
    
            if closestDistance == -1 or closestDistance > distance then
                closestVehicle  = vehicles[i]
                closestDistance = distance
            end
        end
    
        return closestVehicle, closestDistance
    end

    local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
        return coroutine.wrap(function()
          local iter, id = initFunc()
          if not id or id == 0 then
            disposeFunc(iter)
            return
          end
          
          local enum = {handle = iter, destructor = disposeFunc}
          setmetatable(enum, entityEnumerator)
          
          local next = true
          repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
          until not next
          
          enum.destructor, enum.handle = nil, nil
          disposeFunc(iter)
        end)
      end

    function EnumerateVehicles()
        return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
    end

end 

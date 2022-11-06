-- Variables
local currentGarage = 1
local inFingerprint = false
local FingerPrintSessionId = nil
local QRCore = exports['qr-core']:GetCoreObject()
local PlayerJob = {}
local onDuty = false

-- Functions
-- local function DrawText3D(x, y, z, text)
--     SetTextScale(0.35, 0.35)
--     SetTextFont(4)
--     SetTextProportional(1)
--     SetTextColour(255, 255, 255, 215)
--     SetTextEntry("STRING")
--     SetTextCentre(true)
--     AddTextComponentString(text)
--     SetDrawOrigin(x,y,z, 0)
--     DrawText(0.0, 0.0)
--     local factor = (string.len(text)) / 370
--     DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
--     ClearDrawOrigin()
-- end

local function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)

    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations["vehicle"][currentGarage]
    QRCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        SetEntityHeading(veh, coords.w)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
	Citizen.InvokeNative(0x400F9556,veh, Lang:t('info.marshal_plate')..tostring(math.random(1000, 9999)))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function MenuGarage()
    local vehicleMenu = {
        {
            header = Lang:t('menu.garage_title'),
            isMenuHeader = true
        }
    }

    local authorizedVehicles = Config.AuthorizedVehicles[QRCore.Functions.GetPlayerData().job.grade.level]
    for veh, label in pairs(authorizedVehicles) do
        vehicleMenu[#vehicleMenu+1] = {
            header = label,
            txt = "",
            params = {
                event = "marshal:client:TakeOutVehicle",
                args = {
                    vehicle = veh
                }
            }
        }
    end
    vehicleMenu[#vehicleMenu+1] = {
        header = Lang:t('menu.close'),
        txt = "",
        params = {
            event = "qr-menu:client:closeMenu"
        }

    }
    exports['qr-menu']:openMenu(vehicleMenu)
end

function CreatePrompts()
    for k,v in pairs(Config.Locations['duty']) do
        exports['qr-core']:createPrompt('duty_prompt_' .. k, v, 0xF3830D8E, 'Toggle duty status', {
            type = 'client',
            event = 'qr-marshaljob:ToggleDuty',
            args = {},
        })
    end
    
    for k, v in pairs(Config.Locations["vehicle"]) do
        exports['qr-core']:createPrompt("marshal:vehicle_"..k, vector3(v.x, v.y, v.z), Config.PromptKey, 'Jobgarage', {
            type = 'client',
            event = 'marshal:client:promptVehicle',
            args = {k},
        })
    end   

    for k,v in pairs(Config.Locations['evidence']) do
        exports['qr-core']:createPrompt('evidence_prompt_' .. k, v, 0xF3830D8E, 'Open Evidence Stash', {
            type = 'client',
            event = 'marshal:client:EvidenceStashDrawer',
            args = { k },
        })
    end

    for k,v in pairs(Config.Locations['stash']) do
        exports['qr-core']:createPrompt('stash_prompt_' .. k, v, 0xF3830D8E, 'Open Personal Stash', {
            type = 'client',
            event = 'marshal:client:OpenPersonalStash',
            args = {},
        })
    end

    for k,v in pairs(Config.Locations['armory']) do
        exports['qr-core']:createPrompt('armory_prompt_' .. k, v, 0xF3830D8E, 'Open Armory', {
            type = 'client',
            event = 'marshal:client:OpenArmory',
            args = {},
        })
    end
end

local function loadAnimDict(dict) -- interactions, job,
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

local function GetClosestPlayer() -- interactions, job, tracker
    local closestPlayers = QRCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

local function IsArmoryWhitelist() -- being removed
    local retval = false

    if QRCore.Functions.GetPlayerData().job.name == 'marshal' then
        retval = true
    end
    return retval
end

local function SetWeaponSeries()
    for k, v in pairs(Config.Items.items) do
        if k < 6 then
            Config.Items.items[k].info.serie = tostring(QRCore.Shared.RandomInt(2) .. QRCore.Shared.RandomStr(3) .. QRCore.Shared.RandomInt(1) .. QRCore.Shared.RandomStr(2) .. QRCore.Shared.RandomInt(3) .. QRCore.Shared.RandomStr(4))
        end
    end
end

RegisterNetEvent('marshal:client:promptVehicle', function(k)
    QRCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
        onDuty = PlayerData.job.onduty
        local ped = PlayerPedId()

        if PlayerJob.name == "marshal"  then
            if IsPedInAnyVehicle(ped, false) then
                QRCore.Functions.DeleteVehicle(GetVehiclePedIsIn(ped))
            else
                MenuGarage()
                currentGarage = k
            end
        else
            QRCore.Functions.Notify(Lang:t('error.not_lawyer'), 'error')
        end
    end)
end)

RegisterNetEvent('marshal:client:ImpoundVehicle', function(fullImpound, price)
    local vehicle = QRCore.Functions.GetClosestVehicle()
    local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
    local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
    local totalFuel = exports['LegacyFuel']:GetFuel(vehicle)
    if vehicle ~= 0 and vehicle then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            local plate = QRCore.Functions.GetPlate(vehicle)
            TriggerServerEvent("marshal:server:Impound", plate, fullImpound, price, bodyDamage, engineDamage, totalFuel)
            QRCore.Functions.DeleteVehicle(vehicle)
        end
    end
end)

RegisterNetEvent('marshal:client:CheckStatus', function()
    QRCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.name == "marshal" then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                QRCore.Functions.TriggerCallback('marshal:GetPlayerStatus', function(result)
                    if result then
                        for k, v in pairs(result) do
                            QRCore.Functions.Notify(''..v..'')
                        end
                    end
                end, playerId)
            else
                QRCore.Functions.Notify(Lang:t("error.none_nearby"), 'error')
            end
        end
    end)
end)

RegisterNetEvent('marshal:client:EvidenceStashDrawer', function(k)
    local currentEvidence = k
    local pos = GetEntityCoords(PlayerPedId())
    local takeLoc = Config.Locations["evidence"][currentEvidence]

    if not takeLoc then return end

    if #(pos - takeLoc) <= 1.0 then
        local drawer = LocalInput(Lang:t('info.slot'), 11)
        if tonumber(drawer) then
            TriggerServerEvent("inventory:server:OpenInventory", "stash", Lang:t('info.current_evidence', {value = currentEvidence, value2 = drawer}), {
                maxweight = 4000000,
                slots = 500,
            })
            TriggerEvent("inventory:client:SetCurrentStash", Lang:t('info.current_evidence', {value = currentEvidence, value2 = drawer}))
        end
    end
end)

-- Toggle Duty in an event.
RegisterNetEvent('qr-marshaljob:ToggleDuty', function()
    onDuty = not onDuty
    TriggerServerEvent("marshal:server:UpdateCurrentCops")
    TriggerServerEvent("marshal:server:UpdateBlips")
    TriggerServerEvent("QRCore:ToggleDuty")
end)

RegisterNetEvent('marshal:client:TakeOutVehicle', function(data)
    local vehicle = data.vehicle
    TakeOutVehicle(vehicle)
end)

RegisterNetEvent('marshal:client:OpenPersonalStash', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "marshalstash_"..QRCore.Functions.GetPlayerData().citizenid)
    TriggerEvent("inventory:client:SetCurrentStash", "marshalstash_"..QRCore.Functions.GetPlayerData().citizenid)
end)

RegisterNetEvent('marshal:client:OpenPersonalTrash', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "marshaltrash", {
        maxweight = 4000000,
        slots = 300,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "marshaltrash")
end)

RegisterNetEvent('marshal:client:OpenArmory', function()
    local authorizedItems = {
        label = Lang:t('menu.pol_armory'),
        slots = 30,
        items = {}
    }
    -- local index = 1
    for index, armoryItem in pairs(Config.Items.items) do
        for i=1, #armoryItem.authorizedJobGrades do
            if armoryItem.authorizedJobGrades[i] == PlayerJob.grade.level then
                authorizedItems.items[index] = armoryItem
                authorizedItems.items[index].slot = index
                -- index = index + 1
            end
        end
    end
    SetWeaponSeries()
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "marshal", authorizedItems)
end)

-- Threads

-- Toggle Duty
CreateThread(function()
    if LocalPlayer.state.isLoggedIn and PlayerJob.name == 'marshal' then
        CreatePrompts()
    end

    for k, v in pairs(Config.Locations["stations"]) do
        --print(v.coords, v.label)
        local StationBlip = N_0x554d9d53f696d002(1664425300, v.coords)
        SetBlipSprite(StationBlip, -693644997, 52)
        SetBlipScale(StationBlip, 0.7)
        Citizen.InvokeNative(0x9CB1A1623062F402, StationBlip, v.label)
        -- Citizen.ReturnResultAnyway()
    end
    for k,v in pairs(QRCore.Shared.Weapons) do
        local weaponName = v.name
        local weaponLabel = v.label
        local weaponHash = GetHashKey(v.name)
        local weaponAmmo, weaponAmmoLabel = nil, 'unknown'
        if v.ammotype then
            weaponAmmo = v.ammotype:lower()
            weaponAmmoLabel = QRCore.Shared.Items[weaponAmmo].label
        end

        --print(weaponHash, weaponName, weaponLabel, weaponAmmo, weaponAmmoLabel)

        Config.WeaponHashes[weaponHash] = {
            weaponName = weaponName,
            weaponLabel = weaponLabel,
            weaponAmmo = weaponAmmo,
            weaponAmmoLabel = weaponAmmoLabel
        }
    end
end)

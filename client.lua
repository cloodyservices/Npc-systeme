local spawnedNPCs = {}
local currentNPC = nil
local currentDialogue = nil
local selectedOption = 1
local inDialogue = false
local ambientTimers = {}

local function DebugPrint(msg)
    if Config.Debug then print("^3[NPC System]^7 " .. msg) end
end

local function ShowNotification(msg, type)
    if GetResourceState('ox_lib') == 'started' then
        lib.notify({description = msg, type = type or 'info'})
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(msg)
        DrawNotification(false, false)
    end
end

local function PlayFrontendSound(sound, set)
    if Config.Sounds[sound] and Config.Sounds[sound].enabled then
        PlaySoundFrontend(-1, Config.Sounds[sound].name,
                          Config.Sounds[sound].set, true)
    end
end

local function SpeakText(text, voice)
    if not Config.EnableVoice or not voice.enabled then return end
    local provider = Config.VoiceAPI.provider or "responsivevoice"
    local apiKey = nil
    if provider == "elevenlabs" then
        apiKey = Config.VoiceAPI.elevenLabs.apiKey
    end
    SendNUIMessage({
        type = "speak",
        text = text,
        voiceId = voice.voiceId or Config.VoiceAPI.responsiveVoice.defaultVoice,
        provider = provider,
        apiKey = apiKey,
        pitch = voice.pitch or 1.0,
        rate = voice.rate or 0.9,
        volume = voice.volume or 1.0
    })
end

local function StopSpeech() SendNUIMessage({type = "stopSpeech"}) end

local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(10) end
    end
end

local function PlayNPCAnimation(npc, animData)
    if not animData or not animData.dict or not animData.anim then return end
    LoadAnimDict(animData.dict)
    TaskPlayAnim(npc, animData.dict, animData.anim, 8.0, -8.0,
                 animData.duration or -1, animData.flag or 49, 0, false, false,
                 false)
    DebugPrint("Playing animation: " .. animData.dict .. " - " .. animData.anim)
end

local function StartAmbientAnimations(npcId, npcPed, config)
    if not config.ambientAnimations or not config.ambientAnimations.enabled then
        return
    end
    ambientTimers[npcId] = true
    Citizen.CreateThread(function()
        while ambientTimers[npcId] and DoesEntityExist(npcPed) do
            Wait(config.ambientAnimations.frequency)

            if not inDialogue and currentNPC ~= npcId then
                local randomAnim =
                    config.ambientAnimations.animations[math.random(
                        #config.ambientAnimations.animations)]
                PlayNPCAnimation(npcPed, randomAnim)
            end
        end
    end)
end

local function SpawnNPC(npcConfig)
    local model = GetHashKey(npcConfig.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    local npc = CreatePed(4, model, npcConfig.spawn.coords.x,
                          npcConfig.spawn.coords.y,
                          npcConfig.spawn.coords.z - 1,
                          npcConfig.spawn.coords.w, false, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedFleeAttributes(npc, 0, 0)
    SetPedDiesWhenInjured(npc, false)
    SetPedKeepTask(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, npcConfig.spawn.blockevents)
    if npcConfig.spawn.invincible then SetEntityInvincible(npc, true) end
    if npcConfig.spawn.frozen then FreezeEntityPosition(npc, true) end
    spawnedNPCs[npcConfig.id] = {ped = npc, config = npcConfig}
    if Config.EnableBlips and npcConfig.blip and npcConfig.blip.enabled then
        local blip = AddBlipForCoord(npcConfig.spawn.coords.x,
                                     npcConfig.spawn.coords.y,
                                     npcConfig.spawn.coords.z)
        SetBlipSprite(blip, npcConfig.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, npcConfig.blip.scale)
        SetBlipColour(blip, npcConfig.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(npcConfig.blip.label)
        EndTextCommandSetBlipName(blip)
        spawnedNPCs[npcConfig.id].blip = blip
    end
    if npcConfig.events and npcConfig.events.onSpawn then
        TriggerEventFromAction(npcConfig.events.onSpawn)
    end
    StartAmbientAnimations(npcConfig.id, npc, npcConfig)
    DebugPrint("Spawned NPC: " .. npcConfig.name .. " (ID: " .. npcConfig.id ..
                   ")")
    SetModelAsNoLongerNeeded(model)

    return npc
end

function TriggerEventFromAction(action)
    if not action then return end
    if action.type == "client_event" then
        TriggerEvent(action.event, action.params)
    elseif action.type == "server_event" then
        TriggerServerEvent(action.event, action.params)
    elseif action.type == "trigger_event" then
        TriggerEvent(action.event, action.params)
    elseif action.type == "notification" then
        ShowNotification(action.params.message, action.params.type)
    elseif action.type == "close" then
        CloseDialogue()
    end
end
local function OpenDialogue(npcId, dialogueId)
    local npcData = spawnedNPCs[npcId]
    if not npcData then return end
    local dialogue = nil
    for _, d in ipairs(npcData.config.dialogues) do
        if d.id == dialogueId then
            dialogue = d
            break
        end
    end
    if not dialogue then return end
    currentNPC = npcId
    currentDialogue = dialogue
    selectedOption = 1
    inDialogue = true
    if npcData.config.events and npcData.config.events.onInteract then
        TriggerEventFromAction(npcData.config.events.onInteract)
    end
    if dialogue.animation then
        PlayNPCAnimation(npcData.ped, dialogue.animation)
    end
    if dialogue.voice then SpeakText(dialogue.text, dialogue.voice) end
    PlayFrontendSound("interactionSound")
    DebugPrint("Opened dialogue ID " .. dialogueId .. " for NPC " .. npcId)
    SetNuiFocus(true, true)
end

function CloseDialogue()
    if not inDialogue then return end
    StopSpeech()
    local npcData = spawnedNPCs[currentNPC]
    if npcData and npcData.config.events and
        npcData.config.events.onDialogueComplete then
        TriggerEventFromAction(npcData.config.events.onDialogueComplete)
    end
    currentNPC = nil
    currentDialogue = nil
    selectedOption = 1
    inDialogue = false
    SendNUIMessage({type = "closeDialogue"})
    SetNuiFocus(false, false)
    DebugPrint("Closed dialogue")
end
function AddNPCToTarget(npcId, ped)
    if not Config.UseTarget then return end
    local options = {
        {
            name = 'npc_talk_' .. npcId,
            icon = 'fas fa-comment',
            label = Config.UI.targetLabel or "Talk",
            onSelect = function() OpenDialogue(npcId, 1) end,
            action = function() OpenDialogue(npcId, 1) end,
            distance = Config.InteractionDistance or 2.5
        }
    }
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:addLocalEntity(ped, options)
    elseif GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = options,
            distance = Config.InteractionDistance or 2.5
        })
    end
end
function RemoveNPCFromTarget(ped)
    if not Config.UseTarget then return end
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:removeLocalEntity(ped)
    elseif GetResourceState('qb-target') == 'started' then
        exports['qb-target']:RemoveTargetEntity(ped)
    end
end
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if not inDialogue then
            for npcId, npcData in pairs(spawnedNPCs) do
                local npcCoords = GetEntityCoords(npcData.ped)
                local distance = #(playerCoords - npcCoords)

                if distance <
                    (npcData.config.interactionDistance or
                        Config.InteractionDistance) then
                    sleep = 0

                    if Config.EnablePrompts then
                        Draw3DText(npcCoords.x, npcCoords.y, npcCoords.z + 1.0,
                                   Config.UI.prompt3D.text)
                        if IsControlJustReleased(0, Config.InteractionKey) then
                            OpenDialogue(npcId, 1)
                        end
                    end
                    if Config.UseTarget then
                        AddNPCToTarget(npcId, npcData.ped)
                    end

                end
            end
        end

        Wait(sleep)
    end
end)
function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px, py, pz) - vector3(x, y, z))

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov * Config.UI.prompt3D.fontSize
    if onScreen then
        SetTextScale(0.0 * scale, scale)
        SetTextFont(Config.UI.prompt3D.font)
        SetTextProportional(1)
        SetTextColour(Config.UI.prompt3D.color.r, Config.UI.prompt3D.color.g,
                      Config.UI.prompt3D.color.b, Config.UI.prompt3D.color.a)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
RegisterNUICallback('selectOption', function(data, cb)
    if not inDialogue or not currentDialogue then
        cb('ok')
        return
    end
    local option = currentDialogue.options[data.index]
    if not option then
        cb('ok')
        return
    end
    PlayFrontendSound("optionSelectSound")
    if option.action then TriggerEventFromAction(option.action) end
    if option.nextDialogue then
        Wait(300)
        OpenDialogue(currentNPC, option.nextDialogue)
    else
        CloseDialogue()
    end
    cb('ok')
end)

RegisterNUICallback('closeDialogue', function(data, cb)
    CloseDialogue()
    cb('ok')
end)

RegisterNUICallback('hoverOption', function(data, cb)
    PlayFrontendSound("optionHoverSound")
    cb('ok')
end)

Citizen.CreateThread(function()
    for _, dict in ipairs(Config.PreloadAnimations) do LoadAnimDict(dict) end
    Wait(1000)
    for _, npcConfig in ipairs(Config.NPCs) do SpawnNPC(npcConfig) end

    DebugPrint("NPC System initialized with " .. #Config.NPCs .. " NPCs")
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for npcId, npcData in pairs(spawnedNPCs) do
        if DoesEntityExist(npcData.ped) then DeleteEntity(npcData.ped) end
        if npcData.blip then RemoveBlip(npcData.blip) end
        ambientTimers[npcId] = false
    end
    StopSpeech()
    DebugPrint("Cleaned up all NPCs")
end)

RegisterNetEvent('cl-npc:openDialogueUI', function(npcName, dialogue)
    SendNUIMessage({
        type = 'openDialogue',
        npcName = npcName,
        text = dialogue.text,
        options = dialogue.options
    })
end)

function OpenDialogue(npcId, dialogueId)
    local npcData = spawnedNPCs[npcId]
    if not npcData then return end
    local dialogue = nil
    for _, d in ipairs(npcData.config.dialogues) do
        if d.id == dialogueId then
            dialogue = d
            break
        end
    end
    if not dialogue then return end
    currentNPC = npcId
    currentDialogue = dialogue
    selectedOption = 1
    inDialogue = true
    if npcData.config.events and npcData.config.events.onInteract then
        TriggerEventFromAction(npcData.config.events.onInteract)
    end
    if dialogue.animation then
        PlayNPCAnimation(npcData.ped, dialogue.animation)
    end
    SendNUIMessage({
        type = 'openDialogue',
        npcName = npcData.config.name,
        text = dialogue.text,
        options = dialogue.options
    })
    if dialogue.voice then SpeakText(dialogue.text, dialogue.voice) end
    PlayFrontendSound("interactionSound")
    DebugPrint("Opened dialogue ID " .. dialogueId .. " for NPC " .. npcId)
    SetNuiFocus(true, true)
end

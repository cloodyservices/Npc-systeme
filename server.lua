RegisterNetEvent('cl-npc:logSpawn', function(params)
    local src = source
    print('^2[cl-npc]^7 NPC spawned: ' .. params.npcId .. ' for player ' .. src)
end)

MODULE.ClientFiles = {
    "cl_init.lua",
    "shared.lua",
}

include("shared.lua")

local developer = GetConVar("developer")

if developer == nil then
    return
end

---@type ash.entity
local ash_entity = import("ash.entity")

---@type race.vehicle
local vehicle = import("vehicle")

do
    local spawn_list = {
        ["gm_tritype_racecity_v1"] = {
            { Vector(13064, -751, 101),   Angle(0, 90, 0) },
            { Vector(12803, -531, 101),   Angle(0, 90, 0) },
            { Vector(12549, -295, 101),   Angle(0, 90, 0) },
            { Vector(13070, 225, 101),    Angle(0, 90, 0) },
            { Vector(12816, 479, 101),    Angle(0, 90, 0) },
            { Vector(12562, 728, 101),    Angle(0, 90, 0) },
            { Vector(13059, 1188, 101),   Angle(0, 90, 0) },
            { Vector(12811, 1472, 101),   Angle(0, 90, 0) },
            { Vector(12540, 1745, 101),   Angle(0, 90, 0) },
            { Vector(13067, 2199, 101),   Angle(0, 90, 0) },
            { Vector(12813, 2477, 101),   Angle(0, 90, 0) },
            { Vector(12559, 2750, 101),   Angle(0, 90, 0) },
        }
    }

    local spawn_data = spawn_list[game.GetMap()]
    local function replaceSpawn()
        if spawn_data then
            for _, v in ipairs(ash_entity.getByClass("info_player_start", false)) do
                v:Remove()
            end

            for i = 1, #spawn_data do
                local data = spawn_data[i]

                local ent = ents.Create("info_player_start")
                ent:SetPos(data[1])
                ent:SetAngles(data[2])
                ent:Spawn()
            end
        end
    end

    hook.Add("ash.entity.PostSpawnEntities", "Defaults", replaceSpawn)
    hook.Add("ash.entity.PostCleanupMap", "Defaults", replaceSpawn)
end


hook.Add("ash.player.Spawn", "Defaults", function(pl)
    timer.Simple(0, function()
        if IsValid(pl) then
            vehicle.spawn(pl)
        end
    end)
end)

hook.Add("CanPlayerEnterVehicle", "Defaults", function(pl)
    return true
end)

---@param pl Player
hook.Add("CanExitVehicle", "Defaults", function(pl)
    if developer:GetBool() and pl:IsSuperAdmin() then
        return false
    end
end)

---@class race.trigger_finish : ash.trigger
---@field Dir Vector
---@field DirReverse Vector
local ENT = ENT

ENT.Base = "ash_trigger"

---@type race.checkpoint
local checkpoint = import( "checkpoint" )

local checkpoints_count = #checkpoint.getList()

print( "checkpoints_count: " .. checkpoints_count )

---@param entity Vehicle
function ENT:startTouch( entity )
    if IsValid( entity ) and entity.IsGlideVehicle then
        local velocity = entity:GetVelocity()
        local driver = entity:GetDriver()

        if not IsValid( driver ) then return end

        local dot = velocity:GetNormalized():Dot( self.Dir:GetNormalized() )
        -- local dot_reverse = velocity:GetNormalized():Dot( self.DirReverse:GetNormalized() )
        local checkpointID = driver:GetNW2Int( "race.checkpointID", 1 )
        local points = driver:GetNW2Int( "race.points", 1 )

        if dot > 0.5 then

            if points <= 1 then
                local new_points = points + 1

                driver:SetNW2Int( "race.points", new_points )
                driver:SetNW2Int( "race.checkpointID", 1 )

                hook.Run( "race.PlayerChangedPoints", driver, new_points )
            elseif (checkpointID - 1) == checkpoints_count then
                local new_points = points + 1

                driver:SetNW2Int( "race.points", new_points )
                driver:SetNW2Int( "race.checkpointID", 1 )

                hook.Run( "race.PlayerChangedPoints", driver, new_points )
            end
        end
    end
end

---@param entity Vehicle
function ENT:endTouch( entity )
    if IsValid( entity ) and entity.IsGlideVehicle then
        local velocity = entity:GetVelocity()
        local driver = entity:GetDriver()

        local dot_reverse = velocity:GetNormalized():Dot( self.DirReverse:GetNormalized() )

        if dot_reverse > 0.5 then
            driver:SetNW2Int( "race.points", driver:GetNW2Int( "race.points", 0 ) - 1 )
        end
    end
end

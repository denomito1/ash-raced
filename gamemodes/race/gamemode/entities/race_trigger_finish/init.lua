---@class race.trigger_finish : ash.trigger
---@field Dir Vector
---@field DirReverse Vector
local ENT = ENT

ENT.Base = "ash_trigger"

---@param entity Vehicle
function ENT:startTouch( entity )
    if IsValid( entity ) and entity.IsGlideVehicle then
        local velocity = entity:GetVelocity()
        local driver = entity:GetDriver()

        if not IsValid( driver ) then return end

        local dot = velocity:GetNormalized():Dot( self.Dir:GetNormalized() )
        -- local dot_reverse = velocity:GetNormalized():Dot( self.DirReverse:GetNormalized() )

        if dot > 0.5 then
            local new_points = driver:GetNW2Int( "race.points", 0 ) + 1

            driver:SetNW2Int( "race.points", new_points )

            hook.Run( "race.PlayerChangedPoints", driver, new_points )
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

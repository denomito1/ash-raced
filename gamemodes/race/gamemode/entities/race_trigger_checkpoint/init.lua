---@class race.trigger_checkpoint : ash.trigger
---@field checkpointID number
---@field checkpointIDNext number
---@field path table
---@field Dir Vector
---@field DirReverse Vector
local ENT = ENT

ENT.Base = "ash_trigger"

function ENT:startTouch( entity )
    ---@cast entity Vehicle

    if IsValid( entity ) and entity.IsGlideVehicle then
        local driver = entity:GetDriver()

        if IsValid( driver ) then
            if driver:GetNW2Int( "race.checkpointID", 1 ) == self.checkpointID then
                local velocity = entity:GetVelocity()
                local dot = velocity:GetNormalized():Dot( self.Dir:GetNormalized() )
                print( "touch", dot, self.Dir )
                if dot > 0.5 then
                    driver:SetNW2Int( "race.checkpointID", self.checkpointIDNext )
                end
            end
        end
    end
end

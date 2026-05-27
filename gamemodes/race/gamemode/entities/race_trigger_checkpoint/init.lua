---@class race.trigger_checkpoint : ash.trigger
---@field checkpointID number
---@field checkpointIDNext number
---@field path table
local ENT = ENT

ENT.Base = "ash_trigger"

function ENT:startTouch( entity )
    ---@cast entity Vehicle

    if IsValid( entity ) and entity.IsGlideVehicle then
        local driver = entity:GetDriver()

        if IsValid( driver ) then
            if driver:GetNW2Int( "race.checkpointID", 1 ) == self.checkpointID then
                driver:SetNW2Int( "race.checkpointID", self.checkpointIDNext )
            end
        end
    end
end

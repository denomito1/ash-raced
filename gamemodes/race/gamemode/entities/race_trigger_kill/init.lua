---@class race.trigger_kill : ash.trigger
local ENT = ENT

ENT.Base = "ash_trigger"

function ENT:startTouch( entity )
	if IsValid( entity ) and entity.IsGlideVehicle then
		entity:Dissolve()
	end
end

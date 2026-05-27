local cell_size = 2048

local math_floor = math.floor
local math_huge = math.huge

---@class race.grid
local grid = {}

local function getCell( x, y )
    return math_floor( x / cell_size ), math_floor( y / cell_size )
end

local function cellKey( cx, cy )
    return cx * 65536 + cy
end

function grid.buildGrid( points )
    local tgrid = {}

    for i = 1, #points do
        local point = points[ i ]

        local cx, cy = getCell( point.x, point.y )
        local key = cellKey( cx, cy )

        local cell = tgrid[ key ]

        if not cell then
            cell = {}
            tgrid[ key ] = cell
        end

        cell[ #cell + 1 ] = point
    end

    return tgrid
end

function grid.findNearest( pos, tgrid )
    local pos_x = pos.x
    local pos_y = pos.y

    local cx, cy = getCell( pos_x, pos_y )

    local nearest
    local nearest_dist = math_huge

    for x = cx - 1, cx + 1 do
        for y = cy - 1, cy + 1 do
            local cell = tgrid[ cellKey( x, y ) ]

            if cell then
                for i = 1, #cell do
                    local point = cell[ i ]

                    local dx = point.x - pos_x
                    local dy = point.y - pos_y

                    local dist = dx * dx + dy * dy

                    if dist < nearest_dist then
                        nearest_dist = dist
                        nearest = point
                    end
                end
            end
        end
    end

    return nearest
end

return grid

include( "shared.lua" )

---@type ash.ui
local ash_ui = import( "ash.ui" )

---@type ash.config
local config = import( "ash.config" )

---@type race.grid
local grid = import( "race.grid" )

---@type ash.player
local ash_player = import( "ash.player" )

ash_ui.font( "race.TimeLeft", {
    font = "SF Mono Regular",
    extended = true,
    size = "4vmin",
    weight = 900,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
} )

ash_ui.font( "race.roundType", {
    font = "SF Mono Regular",
    extended = true,
    size = "2vmin",
    weight = 900,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
} )

ash_ui.font( "race.laps", {
    font = "SF Mono Regular",
    extended = true,
    size = "1.5vmin",
    weight = 900,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
} )


---@type ash.round
local round = import( "ash.round" )


local race_laps = GetConVar( "race_laps" )
assert( race_laps ~= nil, "race_laps convar not found" )

do
    local format_time = _G.string.ToMinutesSeconds
    hook.Add( "HUDPaint", "Defaults", function()
        local lp = LocalPlayer()

        local add_y = 5
        local _, h = draw.SimpleText( format_time( round.getTimeLeft() ), "race.TimeLeft", ash_ui.ScreenCenterX, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        add_y = add_y + h
        h = draw.SimpleText( round.getRoundType():upper(), "race.roundType", ash_ui.ScreenCenterX, 5 + add_y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        add_y = add_y + h
        h = draw.SimpleText( "Lap: " .. math.max( lp:GetNW2Int( "race.points", 0 ) - 1, 0 ) .. " / " .. race_laps:GetInt(), "race.laps", ash_ui.ScreenCenterX, 5 + add_y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        add_y = add_y + h

        draw.SimpleText( lp:GetNW2Int( "race.checkpointID", 1 ), "race.laps", 5, ash_ui.ScreenCenterY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    end )

end

concommand.Add( "race_spawnpos", function( pl )
    local pos = pl:GetPos()
    local pos_end = pos + pl:GetAimVector() * 100

    print( string.format( "\t{\n\t\t[%s %s %s],\n\t\t[%s %s %s]\n\t},", math.round( pos.x ), math.round( pos.y ), math.round( pos.z ), math.round( pos_end.x ), math.round( pos_end.y ), math.round( pos_end.z ) ) )
end )


local list_points_path = {}
local list_points_path_count = 0
concommand.Add( "race_add_path_point", function( pl, _, args )
    local pos = pl:GetEyeTrace().HitPos + Vector( 0, 0, tonumber( args[ 1 ] or 0 ) or 0 )

    list_points_path_count = list_points_path_count + 1

    list_points_path[ list_points_path_count ] = pos
end )

concommand.Add( "race_remove_path_point", function( pl )
    if list_points_path_count > 0 then
        list_points_path[ list_points_path_count ] = nil
        list_points_path_count = list_points_path_count - 1
    end
end )

concommand.Add( "race_path", function()
    for i = 1, list_points_path_count - 1 do
        local pos = list_points_path[ i ]

        print( string.format( "[%s %s %s],", math.floor( pos.x ), math.floor( pos.y ), math.floor( pos.z ) ) )
    end
end )

concommand.Add( "race_pathjson", function()
    for i = 1, list_points_path_count - 1 do
        local pos = list_points_path[ i ]

        print( string.format( "\t\"%s %s %s\",", math.floor( pos.x ), math.floor( pos.y ), math.floor( pos.z ) ) )
    end
end )

concommand.Add( "race_dir", function( pl )
    local pos = pl:GetAimVector()

    print( string.format( "[%s %s %s],", math.round( pos.x ), math.round( pos.y ), math.round( pos.z ) ) )
end )

concommand.Add( "race_getpos", function( pl )
    local pos = pl:GetPos()
    local ang = pl:GetRenderAngles()

    print( string.format( "[ \"%s %s %s\", \"%s %s %s\" ],", math.round( pos.x ), math.round( pos.y ), math.round( pos.z ), math.round( ang.p ), math.round( ang.y ), math.round( ang.r ) ) )
end )

local box_mins, box_maxs
local box_angles = angle_zero
concommand.Add( "race_box_mins", function()
    local lp = LocalPlayer()
    local pos = lp:GetPos()

    box_mins = pos
end )

concommand.Add( "race_box_maxs", function()
    local lp = LocalPlayer()
    local pos = lp:GetPos()

    box_maxs = pos
end )

concommand.Add( "race_box_angles", function( _, _, _, str )
    box_angles = Angle( str )
end )


concommand.Add( "race_getbox", function()
    local dir = LocalPlayer():GetAimVector()
    if box_mins and box_maxs then
        local format_text = "[ \"%s %s %s\", \"%s %s %s\", \"%s %s %s\", \"%s %s %s\" ],"
        local str = string.format( format_text, math.round( box_mins.x ), math.round( box_mins.y ), math.round( box_mins.z ), math.round( box_maxs.x ), math.round( box_maxs.y ), math.round( box_maxs.z ), math.round( box_angles.p ), math.round( box_angles.y ), math.round( box_angles.r ), math.round( dir.x ), math.round( dir.y ), math.round( dir.z ) )
        SetClipboardText( str )
        print( str )
    end
end )

local path_start = false
local last_point
do
    concommand.Add( "race_path_start", function( pl, _, args )
        local pos = pl:WorldSpaceCenter()

        last_point = pos

        table.clearKeys( list_points_path )
        list_points_path_count = 1

        list_points_path[ list_points_path_count ] = pos
        path_start = true
    end )

    concommand.Add( "race_path_stop", function()
        path_start = false
        last_point = nil
    end )
end

do
    local color_sph = Color( 255, 255, 0 )
    local developer = GetConVar( "developer" )
    assert( developer ~= nil, "developer convar not found" )




    hook.Add( "PostDrawOpaqueRenderables", "Defaults", function()
        local lp = LocalPlayer()
        local pos = lp:WorldSpaceCenter()
        render.SetColorMaterial()


        if developer:GetBool() then
            for i = 1, list_points_path_count - 1 do
                local pos2 = list_points_path[ i + 1 ]
                local pos1 = list_points_path[ i ]

                if pos:Distance( pos1 ) <= 2000 then
                    render.DrawLine( pos1, pos2, color_white, true )
                end
            end

            for i = 1, list_points_path_count do
                if pos:Distance( list_points_path[ i ] ) <= 2000 then
                    render.DrawSphere( list_points_path[ i ], 1, 128, 128, color_sph )
                end
            end

            if path_start then
                if last_point:Distance( pos ) >= 1024 and pos ~= last_point then
                    last_point = pos

                    print( "add point", pos )

                    list_points_path_count = list_points_path_count + 1
                    list_points_path[ list_points_path_count ] = pos
                end
            end
        end

        if box_mins and box_maxs then
            local lpos = (box_mins + box_maxs) * 0.5
            local half = (box_maxs - box_mins) * 0.5

            render.DrawWireframeBox(
                lpos,       -- position
                box_angles, -- angle
                -half,      -- mins
                half,       -- maxs
                color_white,
                true
            )
        end

        -- for _, v in ipairs( checkpoint.getList() ) do
        --     local mins = v[ 1 ]
        --     local maxs = v[ 2 ]
        --     local lpos = v[ 3 ]
        --     local half = v[ 4 ]

        --     render.DrawWireframeBox( lpos, box_angles, -half, half, color_white, true )
        -- end

        -- if checkpoints then
        --    	for i = 1, #checkpoints do
        --   		local data = checkpoints[ i ]
        --   		render.DrawWireframeBox( Vector() , Angle(), data[ 1 ], data[ 2 ], color_white, true )
        --    	end
        -- end
    end )
end

do
    hook.Remove( "CalcView", "SimpleTP.Camera.View" )

    local simple_third_person = _G.Glide.simpleThirdPersonHook

    hook.Add( "CalcView", "SimpleTP.Camera.View", function( ply, origin, ang, fov, znear, zfar )
        local winner = GetGlobal2Entity( "race.winner", NULL )
        local cam = GetGlobal2Entity( "race.cam", NULL )
        ---@cast winner Player


        if IsValid( winner ) and IsValid( cam ) then
            return {
                origin = cam:GetPos(),
                angles = (winner:GetPos() - cam:GetPos()):Angle(),
                fov = fov,
                drawviewer = true
            }
        end

        if simple_third_person == nil then
            simple_third_person = _G.Glide.simpleThirdPersonHook
        end

        if simple_third_person then
            return simple_third_person( ply, origin, ang, fov, znear, zfar )
        end
    end )
end


do
    -- Garry's Mod Race Victory Menu
    -- Красивое анимированное меню победы
    -- Открывается только через функцию OpenVictoryMenu(...)

    if CLIENT then

        local VictoryFrame = nil

        ash_ui.font( "RaceWinTitle", {
            font = "Jost-Bold",
            extended = true,
            size = "3vmin",
            weight = 900,
            blursize = 0,
            scanlines = 0,
            antialias = true,
            underline = false,
            italic = false,
            strikeout = false,
            symbol = false,
            rotary = false,
            shadow = true,
            additive = false,
            outline = false,
        } )

        ash_ui.font( "RaceWinnerName", {
            font = "Jost-Bold",
            extended = true,
            size = "4.2vmin",
            weight = 1000,
            blursize = 0,
            scanlines = 0,
            antialias = true,
            underline = false,
            italic = false,
            strikeout = false,
            symbol = false,
            rotary = false,
            shadow = true,
            additive = false,
            outline = false,
        } )

        ash_ui.font( "RaceInfo", {
            font = "Jost-Regular",
            extended = true,
            size = "1.8vmin",
            weight = 500,
            blursize = 0,
            scanlines = 0,
            antialias = true,
            underline = false,
            italic = false,
            strikeout = false,
            symbol = false,
            rotary = false,
            shadow = true,
            additive = false,
            outline = false,
        } )

        local blur = Material( "pp/blurscreen" )

        local function DrawBlur( panel, amount )
            local x, y = panel:LocalToScreen( 0, 0 )

            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( blur )

            for i = 1, 6 do
                blur:SetFloat( "$blur", (i / 3) * amount )
                blur:Recompute()

                render.UpdateScreenEffectTexture()

                surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
            end
        end

        function OpenVictoryMenu( winnerName, raceTime )

            if IsValid( VictoryFrame ) then
                VictoryFrame:Remove()
            end

            local alpha = 0
            local winnerReveal = 0

            VictoryFrame = vgui.Create( "DFrame" )
            VictoryFrame:SetSize( ScrW(), ScrH() )
            VictoryFrame:SetPos( 0, 0 )
            VictoryFrame:SetTitle( "" )
            VictoryFrame:ShowCloseButton( false )
            VictoryFrame:SetDraggable( false )
            VictoryFrame:MakePopup()

            VictoryFrame.Paint = function( self, w, h )
                DrawBlur( self, 6 )

                alpha = Lerp( FrameTime() * 1.2, alpha, 220 )

                draw.RoundedBox( 0, 0, 0, w, h, Color( 5, 5, 10, alpha ) )
            end

            -- Главная панель
            local MainPanel = vgui.Create( "DPanel", VictoryFrame )
            MainPanel:SetSize( 700, 320 )
            MainPanel:SetPos( ScrW() / 2 - 350, ScrH() )
            MainPanel:SetAlpha( 0 )

            MainPanel:MoveTo(
                ScrW() / 2 - 350,
                ScrH() / 2 - 160,
                1.8,
                0,
                -1
            )

            MainPanel:AlphaTo( 255, 2.2, 0 )

            local panelAlpha = 0

            MainPanel.Paint = function( self, w, h )
                panelAlpha = Lerp( FrameTime() * 2, panelAlpha, 255 )

                draw.RoundedBox(
                    24,
                    0,
                    0,
                    w,
                    h,
                    Color( 18, 18, 25, panelAlpha * 0.72 )
                )
            end

            -- Текст победы
            local VictoryLabel = vgui.Create( "DLabel", MainPanel )
            VictoryLabel:SetText( "ПОБЕДИТЕЛЬ ГОНКИ" )
            VictoryLabel:SetFont( "RaceWinTitle" )
            VictoryLabel:SetTextColor( Color( 255, 220, 120 ) )
            VictoryLabel:SizeToContents()
            VictoryLabel:SetAlpha( 0 )
            VictoryLabel:SetPos( 350 - VictoryLabel:GetWide() / 2, 35 )

            VictoryLabel:AlphaTo( 255, 2.5, 0.4 )

            -- Имя победителя
            local WinnerLabel = vgui.Create( "DLabel", MainPanel )
            WinnerLabel:SetText( "" )
            WinnerLabel:SetFont( "RaceWinnerName" )
            WinnerLabel:SetTextColor( Color( 255, 255, 255 ) )
            WinnerLabel:SetPos( 0, 120 )
            WinnerLabel:SetSize( 700, 80 )
            WinnerLabel:SetContentAlignment( 5 )

            local currentLength = 0

            timer.Create( "RaceWinnerReveal", 0.12, string.len( winnerName ), function()
                if not IsValid( WinnerLabel ) then return end

                currentLength = currentLength + 1

                WinnerLabel:SetText( string.sub( winnerName, 1, currentLength ) )
            end )

            -- Время гонки
            local TimeLabel = vgui.Create( "DLabel", MainPanel )
            TimeLabel:SetText( "Время: " .. raceTime )
            TimeLabel:SetFont( "RaceInfo" )
            TimeLabel:SetTextColor( Color( 180, 180, 180 ) )
            TimeLabel:SizeToContents()
            TimeLabel:SetPos( 350 - TimeLabel:GetWide() / 2, 215 )
            TimeLabel:SetAlpha( 0 )

            timer.Simple( 1, function()
                if IsValid( TimeLabel ) then
                    TimeLabel:AlphaTo( 255, 2, 0 )
                end
            end )
            -- Автоматическое закрытие
            timer.Simple( 6, function()

                if not IsValid( MainPanel ) then return end

                MainPanel:MoveTo(
                    ScrW() / 2 - 350,
                    ScrH() + 400,
                    0.45,
                    0,
                    -1,
                    function()
                        if IsValid( VictoryFrame ) then
                            VictoryFrame:Remove()
                        end
                    end
                )

            end )

        end

        concommand.Add( "race_win", function( _, _, args )
            OpenVictoryMenu( args[ 1 ], args[ 2 ] )
        end )

    end

end

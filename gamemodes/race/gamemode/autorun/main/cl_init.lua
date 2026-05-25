include( "shared.lua" )

---@type ash.round
local round = import( "ash.round" )

---@type ash.ui
local ash_ui = import( "ash.ui" )

do
    local format_time = _G.string.ToMinutesSeconds
    hook.Add( "HUDPaint", "Defaults", function()
        local lp = LocalPlayer()

        draw.SimpleText( format_time( round.getTimeLeft() ), "DermaLarge", ScrW() * 0.5, 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        draw.SimpleText( round.getRoundType():upper(), "DermaDefaultBold", ScrW() * 0.5, 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
        draw.SimpleText( lp:GetNW2Int( "race.points", 0 ), "DermaDefaultBold", ScrW() * 0.5, 55, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    end )
end

concommand.Add( "race_spawnpos", function( pl )
    local pos = pl:GetPos()
    local pos_end = pos + pl:GetAimVector() * 100

    print( string.format( "\t{\n\t\tVector( %s, %s, %s ),\n\t\tVector( %s, %s, %s )\n\t},", pos.x, pos.y, pos.z, pos_end.x, pos_end.y, pos_end.z ) )
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

        print( string.format( "\tVector( %s, %s, %s ),", math.floor( pos.x ), math.floor( pos.y ), math.floor( pos.z ) ) )
    end
end )

concommand.Add( "race_dir", function( pl )
    local pos = pl:GetAimVector()

    print( string.format( "Vector( %s, %s, %s ),", math.round( pos.x ), math.round( pos.y ), math.round( pos.z ) ) )
end )

concommand.Add( "race_getpos", function( pl )
    local pos = pl:GetPos()
    local ang = pl:GetRenderAngles()

    print( string.format( "{ Vector( %s, %s, %s ), Angle( %s, %s, %s ) }", math.round( pos.x ), math.round( pos.y ), math.round( pos.z ), math.round( ang.p ), math.round( ang.y ), math.round( ang.r ) ) )
end )

hook.Add( "CalcView", "Defaults", function( data )
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
end )

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

    if simple_third_person ~= nil then
        simple_third_person = _G.Glide.simpleThirdPersonHook
    end

    if simple_third_person then
        return simple_third_person( ply, origin, ang, fov, znear, zfar )
    end
end )




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

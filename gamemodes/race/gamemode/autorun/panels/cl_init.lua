local vgui_register = vgui.Register
local AccessorFunc = AccessorFunc
local bit_bor = bit.bor
local table_remove = table.remove

local rndx = import "alium_lobby.rndx"

local rndx_draw = rndx.Draw
local rndx_draw_outline = rndx.DrawOutlined

do
    ---@class alium.panel : EditablePanel
    local PANEL = {}
    AccessorFunc( PANEL, "flags", "Flags", FORCE_NUMBER )
    AccessorFunc( PANEL, "flagsOutline", "FlagsOutline", FORCE_NUMBER )
    AccessorFunc( PANEL, "cornerRadius", "CornerRadius", FORCE_NUMBER )
    AccessorFunc( PANEL, "color", "Color" )
    AccessorFunc( PANEL, "colorOutline", "ColorOutline" )
    AccessorFunc( PANEL, "isDrawOutline", "IsDrawOutline" )
    AccessorFunc( PANEL, "outlineThick", "OutlineThick" )

    local rndx_flags_default = bit_bor( rndx.SHAPE_FIGMA )
    function PANEL:Init()
        self:SetFlags( rndx_flags_default )
        self:SetFlagsOutline( rndx_flags_default )
        self:SetCornerRadius( 4 )
        self:SetColor( Color( 25, 25, 25, 255 ) )
        self:SetColorOutline( Color( 0, 0, 0, 255 ) )
        self:SetIsDrawOutline( false )
        self:SetOutlineThick( 2 )
        self.paintsFuncs = {}
    end

    function PANEL:AddPaintFunc( func )
        self.paintsFuncs[ #self.paintsFuncs + 1 ] = func
    end

    function PANEL:RemovePaintFunc( id )
        table_remove( self.paintsFuncs, id )
    end

    function PANEL:Paint( w, h )
        local corner = self:GetCornerRadius()

        rndx_draw( corner, 0, 0, w, h, self:GetColor(), self:GetFlags() )

        if self:GetIsDrawOutline(  ) then
            rndx_draw_outline( corner, 0, 0, w, h, self:GetColorOutline(), self:GetOutlineThick(), self:GetFlagsOutline() )
        end

        local paints = self.paintsFuncs

        for i = 1, #paints do
            paints[ i ]( self, w, h )
        end
    end

    vgui_register( "alium.panel", PANEL, "EditablePanel" )
end

do
    ---@class alium.scroll : DScrollPanel
    local PANEL = {}

    local color_background = Color(10, 10, 10, 100)
    local rndx_flags = rndx.SHAPE_FIGMA
    function PANEL:Init()
        self:Dock(FILL)
        self.VBar:SetWide(0)

        self.VBar.Paint = function( _, w, h )
            rndx_draw( 0, 0, 0, w, h, color_background )
        end

        self.VBar.btnGrip.Paint = function( _, w, h )
            rndx_draw( 8, 0, 0, w, h, color_white, rndx_flags )
        end

        self.VBar.btnUp.Paint = function() end
        self.VBar.btnDown.Paint = function() end
    end

    vgui_register( "alium.scroll", PANEL, "DScrollPanel" )
end

do
    ---@class alium.model_panel : DModelPanel
    local PANEL = {}

    AccessorFunc(PANEL, "speedMove", "SpeedMove", FORCE_NUMBER)

    function PANEL:Init()
        self:SetSpeedMove(0.3)
    end

    function PANEL:OnMousePressed(mouse)
        if mouse == MOUSE_LEFT then
            local x, y = input.GetCursorPos()

            self.startX = x
            self.startY = y

            self.rotating = true

            local ang = self.Entity:GetAngles()

            self.oldAng = ang

            self.smoothX = nil

            -- rotatingPanel = self
        end
    end

    function PANEL:OnMouseReleased()
        self.rotating = false

        self.smoothX = nil
    end

    function PANEL:Think()
        if self.rotating then
            if not input.IsMouseDown(MOUSE_LEFT) then
                self.rotating = false

                self.smoothX = nil

                return
            end

            local oldX, oldY = self.startX, self.startY
            local x, y = input.GetCursorPos()

            local newX, newY = x - oldX, y - oldY

            newX = math.floor(newX * self:GetSpeedMove())

            self.smoothX = self.smoothX or newX

            self.smoothX = Lerp(FrameTime() * 2, self.smoothX, newX)

            local ang = self.oldAng

            ang = Angle(ang.x, ang.y + self.smoothX, ang.z)
            self.Entity:SetAngles(ang)
        end
    end

    function PANEL:LayoutEntity()
        return false
    end

    vgui.Register("alium.model_panel", PANEL, "DModelPanel")
end

do
    local math_Clamp = math.clamp
    local math_Round = math.round

    ---@class alium.slider : Panel
    local PANEL = { }

    AccessorFunc( PANEL, "colorBackground", "ColorBackground", FORCE_COLOR )
    AccessorFunc( PANEL, "colorOutline", "ColorOutline", FORCE_COLOR )
    AccessorFunc( PANEL, "decimals", "Decimals", FORCE_NUMBER )
    AccessorFunc( PANEL, "min", "Min", FORCE_NUMBER )
    AccessorFunc( PANEL, "max", "Max", FORCE_NUMBER )
    AccessorFunc( PANEL, "progress", "Progress", FORCE_STRING )

    function PANEL:Init( )
        self:SetColorBackground( Color( 189, 189, 189 ) )
        self:SetColorOutline( Color( 255, 255, 255 ) )
        self:SetDecimals( 0 )
        self:SetProgress( 0 )
        self:SetMin( 0 )
        self:SetMax( 100 )
    end

    function PANEL:OnChange()

    end

    function PANEL:SetConvar( name )

        local convar = GetConVar( name )

        if convar then
            self.convar = name

            local number = convar:GetFloat( )
            local min = self:GetMin()
            local progress = math_Clamp( ( number - min ) / ( self:GetMax() - min ), 0, 1 )

            self:SetProgress( progress )
        end
    end

    function PANEL:GetConvar()
        return self.convar
    end

    local function internalChange( self, progress )
        local decimals = self:GetDecimals()

        local convar = self:GetConvar()

        local value = ( self:GetMax( ) - self:GetMin( ) ) * progress

        if decimals > 0 then
            value = math_Round( value, decimals )
        end

        if convar then
            RunConsoleCommand( convar, value )
        end

        self:OnChange( value )
    end

    local rndx_flags = rndx.SHAPE_FIGMA
    local rndx_circle = rndx.SHAPE_CIRCLE
    function PANEL:Paint( w, h )
        local size_line_h = math.floor( h * 0.5 )
        local center_y = h * 0.5 - ( size_line_h * 0.5 )
        local size_grip = math.floor(h * 0.7)

        local progress = self:GetProgress( )

        local line_progress = w * progress

        local center_grip = ( size_grip * 0.5 )

        rndx.Draw( 8, 0, center_y, line_progress - center_grip, size_line_h, self:GetColorBackground( ), rndx_flags )
        rndx.DrawOutlined( 8, 0, center_y, w, size_line_h, self:GetColorOutline( ), 2, rndx_flags )

        local pos_grip_x = math.max( line_progress - (size_grip * 0.8), 0 )
        local pos_grip_y = h * 0.5 - ( size_grip * 0.5 )

        local old = DisableClipping( true )
        rndx.Draw( 128, pos_grip_x, pos_grip_y, size_grip, size_grip, color_white, rndx_circle)
        rndx.DrawOutlined( 128, pos_grip_x, pos_grip_y, size_grip, size_grip, color_black, 2, rndx_circle)
        DisableClipping( old )
        -- rndx.DrawCircle( line_progress - h, 0, 32, color_white, 0 )


        if self.changingProgress then
            local x, y = self:CursorPos()

            local percent = x / ( w - 1 )
            percent = math_Clamp( percent, 0, 1 )

            local old_progress = self:GetProgress()

            if old_progress ~= percent then
                self:SetProgress( percent )
                internalChange( self, progress )
            end
        end

        if not input.IsMouseDown( MOUSE_LEFT ) and self.changingProgress then
            self.changingProgress = false
        end
    end

    function PANEL:OnMousePressed( key )
        if key == MOUSE_LEFT then
            self.changingProgress = true
            surface.PlaySound( "ui/click_ui03.mp3" )
        end
    end

    function PANEL:OnMouseReleased( )
        self.changingProgress = false
    end


    vgui.Register( "alium.slider", PANEL, "Panel" )
end

--[[
╔══════════════════════════════════════════════════════════════════╗
║                    AniLib  ·  v6.0                               ║
║    Blocky classic  ·  Two-column  ·  Everything working          ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  local Lib = require(script.UILibrary)                           ║
║                                                                  ║
║  local Win = Lib:CreateWindow({                                  ║
║      Title        = "My Script",                                 ║
║      Keybind      = Enum.KeyCode.RightShift,  -- hide/show       ║
║      Watermark    = true,                                        ║
║      WatermarkTxt = "my script  |  ",                            ║
║      WatermarkFPS = true,          -- appends live fps           ║
║  })                                                              ║
║                                                                  ║
║  local Tab = Win:AddTab("Aiming")                                ║
║  local L   = Tab:AddSection("drawings")        -- left col       ║
║  local R   = Tab:AddSection("camera", "right") -- right col      ║
║                                                                  ║
║  L:AddToggle     ("enable",  false,             cb)              ║
║  L:AddSlider     ("radius",  0, 300, 100,       cb)              ║
║  L:AddDropdown   ("mode",    {"a","b"}, "a",    cb)              ║
║  L:AddKeybind    ("hotkey",  Enum.KeyCode.F,    cb)              ║
║  L:AddButton     ("Action",                     cb)              ║
║  L:AddInput      ("name",    "hint",            cb)              ║
║  L:AddColorPicker("colour",  Color3.new(1,0,0), cb)              ║
║  L:AddLabel      ("info text here")                              ║
║  L:AddSeparator  ()                                              ║
║                                                                  ║
║  -- Components return { Set(v), Get() }                          ║
║  Win:SetWatermark("new text  |  ")  -- update base text          ║
║  Win:ShowWatermark(false)            -- hide / show              ║
║  Win:SetVisible(false)               -- hide / show window       ║
║  Win:Destroy()                                                   ║
╚══════════════════════════════════════════════════════════════════╝
--]]

--------------------------------------------------------------------------------
-- SERVICES
--------------------------------------------------------------------------------
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local CoreGui      = game:GetService("CoreGui")
local LP           = Players.LocalPlayer

--------------------------------------------------------------------------------
-- THEME
--------------------------------------------------------------------------------
local T = {
    WinBg      = Color3.fromRGB(20, 20, 20),
    TitleBg    = Color3.fromRGB(13, 13, 13),
    TitleText  = Color3.fromRGB(178, 178, 178),
    Border     = Color3.fromRGB(42, 42, 42),

    TabBg      = Color3.fromRGB(14, 14, 14),
    TabBorder  = Color3.fromRGB(36, 36, 36),
    TabText    = Color3.fromRGB(118, 118, 118),
    TabTextOn  = Color3.fromRGB(208, 208, 208),
    TabUnder   = Color3.fromRGB(182, 182, 182),

    SectBg     = Color3.fromRGB(25, 25, 25),
    SectHdr    = Color3.fromRGB(17, 17, 17),
    SectTitle  = Color3.fromRGB(108, 108, 108),
    SectBorder = Color3.fromRGB(36, 36, 36),
    Divider    = Color3.fromRGB(28, 28, 28),

    Text       = Color3.fromRGB(178, 178, 178),
    TextHi     = Color3.fromRGB(208, 208, 208),
    TextDim    = Color3.fromRGB(75,  75,  75),

    ChkOn      = Color3.fromRGB(188, 188, 188),
    ChkOff     = Color3.fromRGB(33, 33, 33),
    ChkBorder  = Color3.fromRGB(54, 54, 54),
    ChkTick    = Color3.fromRGB(14, 14, 14),

    TrkBg      = Color3.fromRGB(28, 28, 28),
    TrkFill    = Color3.fromRGB(168, 168, 168),
    TrkBorder  = Color3.fromRGB(42, 42, 42),
    TrkThumb   = Color3.fromRGB(198, 198, 198),

    CtrlBg     = Color3.fromRGB(23, 23, 23),
    CtrlBorder = Color3.fromRGB(40, 40, 40),
    CtrlHover  = Color3.fromRGB(30, 30, 30),
    CtrlFocus  = Color3.fromRGB(88, 88, 88),

    BtnBg      = Color3.fromRGB(23, 23, 23),
    BtnHover   = Color3.fromRGB(31, 31, 31),
    BtnPress   = Color3.fromRGB(40, 40, 40),
    BtnBorder  = Color3.fromRGB(42, 42, 42),

    DropBg     = Color3.fromRGB(17, 17, 17),
    DropBorder = Color3.fromRGB(38, 38, 38),
    DropHover  = Color3.fromRGB(26, 26, 26),
    DropSel    = Color3.fromRGB(34, 34, 34),
    DropSelTxt = Color3.fromRGB(208, 208, 208),

    CpBg       = Color3.fromRGB(15, 15, 15),
    CpBorder   = Color3.fromRGB(38, 38, 38),

    WmBg       = Color3.fromRGB(13, 13, 13),
    WmBorder   = Color3.fromRGB(32, 32, 32),
    WmText     = Color3.fromRGB(128, 128, 128),

    Scroll     = Color3.fromRGB(40, 40, 40),
    Sep        = Color3.fromRGB(28, 28, 28),
}

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------
local FONT     = Enum.Font.Code
local FS       = 11
local FS_SM    = 10
local ROW_H    = 18
local TITLE_H  = 22
local TAB_H    = 24
local DROP_IH  = 16
local DROP_MAX = 8

local TI = TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function tw(o, p) TweenService:Create(o, TI, p):Play() end

-- Rainbow gradient for colour picker hue bar
local HUE_SEQ = ColorSequence.new({
    ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,   0,   0)),
    ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255,   0)),
    ColorSequenceKeypoint.new(2/6, Color3.fromRGB(  0, 255,   0)),
    ColorSequenceKeypoint.new(3/6, Color3.fromRGB(  0, 255, 255)),
    ColorSequenceKeypoint.new(4/6, Color3.fromRGB(  0,   0, 255)),
    ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,   0, 255)),
    ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255,   0,   0)),
})

--------------------------------------------------------------------------------
-- INSTANCE HELPERS
--------------------------------------------------------------------------------
local function N(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    if props.Parent then o.Parent = props.Parent end
    return o
end

local function Stroke(p, col, thick)
    return N("UIStroke", { Color = col or T.Border, Thickness = thick or 1, Parent = p })
end

local function Pad(p, t, r, b, l)
    N("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        Parent        = p,
    })
end

local function List(p, dir, gap, hAlign)
    N("UIListLayout", {
        FillDirection       = dir    or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, gap or 0),
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = p,
    })
end

-- Invisible full-cover click catcher
local function Hit(p, zi)
    return N("TextButton", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        Text = "", ZIndex = zi or 2, Parent = p,
    })
end

-- Standard label | control row helper
local function Row(p, labelTxt, rightFrac)
    local row = N("Frame", {
        Size = UDim2.new(1,0,0,ROW_H), BackgroundTransparency = 1, Parent = p,
    })
    N("TextLabel", {
        Size = UDim2.new(1-rightFrac, -4, 1, 0), BackgroundTransparency = 1,
        Text = labelTxt, TextColor3 = T.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    local ctrl = N("Frame", {
        Size = UDim2.new(rightFrac, 0, 1, 0), Position = UDim2.new(1-rightFrac, 0, 0, 0),
        BackgroundColor3 = T.CtrlBg, BorderSizePixel = 0, Parent = row,
    })
    Stroke(ctrl, T.CtrlBorder)
    return row, ctrl
end

local function Drag(handle, frame)
    local on, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            on, ds, sp = true, i.Position, frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if on and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X,
                                       sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then on = false end
    end)
end

--------------------------------------------------------------------------------
-- POPUP MANAGER
--
-- A single transparent ScreenGui-level frame (ZIndex 999) holds all popups.
-- Only one popup is open at a time.
--
-- DROPDOWN FIX:
--   The global UIS close-listener uses task.defer so it fires AFTER the
--   current frame's event callbacks. Option buttons call PM.close()
--   SYNCHRONOUSLY, so by the time the deferred task runs, PM._frame == nil
--   and it becomes a no-op. No race condition.
--
-- COLOR PICKER FIX:
--   Hit buttons (svHitBtn, hueHitBtn) are direct children of the panel
--   frame — NOT children of the gradient frames. In Sibling ZIndexBehavior
--   the ZIndex of a descendant only competes within its own ancestor chain.
--   By placing hits as panel children at ZIndex=1010 they beat every
--   gradient layer (1001-1004) in the panel's sibling scope.
--------------------------------------------------------------------------------
local PM = { _gui = nil, _frame = nil, _cb = nil }

function PM.init(gui)  PM._gui = gui end

function PM.close()
    if PM._frame then
        PM._frame.Visible = false
        PM._frame = nil
        if PM._cb then PM._cb(); PM._cb = nil end
    end
end

function PM.show(frame, x, y, w, h, onClose)
    if PM._frame and PM._frame ~= frame then
        PM._frame.Visible = false
        if PM._cb then PM._cb(); PM._cb = nil end
    end
    frame.Parent   = PM._gui
    frame.Position = UDim2.fromOffset(x, y)
    frame.Size     = UDim2.fromOffset(w, h)
    frame.Visible  = true
    PM._frame      = frame
    PM._cb         = onClose
end

-- Global LMB close — deferred so button's own click resolves first
UIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 and PM._frame then
        task.defer(PM.close)
    end
end)

--------------------------------------------------------------------------------
-- COMPONENT: Toggle
--------------------------------------------------------------------------------
local function Toggle(parent, label, default, cb)
    local state = (default == true)

    local row = N("Frame", {
        Size = UDim2.new(1,0,0,ROW_H), BackgroundTransparency = 1, Parent = parent,
    })

    local box = N("Frame", {
        Size = UDim2.fromOffset(12,12), Position = UDim2.new(0,0,0.5,-6),
        BackgroundColor3 = state and T.ChkOn or T.ChkOff,
        BorderSizePixel = 0, Parent = row,
    })
    Stroke(box, T.ChkBorder)

    local tick = N("TextLabel", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        Text = "✓", TextColor3 = T.ChkTick, TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextTransparency = state and 0 or 1,
        Parent = box,
    })

    local lbl = N("TextLabel", {
        Size = UDim2.new(1,-18,1,0), Position = UDim2.new(0,18,0,0),
        BackgroundTransparency = 1, Text = label,
        TextColor3 = T.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })

    local h = Hit(row, 1)
    h.MouseButton1Click:Connect(function()
        state = not state
        tw(box,  { BackgroundColor3 = state and T.ChkOn or T.ChkOff })
        tw(tick, { TextTransparency = state and 0 or 1 })
        if cb then cb(state) end
    end)
    h.MouseEnter:Connect(function() tw(lbl, { TextColor3 = T.TextHi }) end)
    h.MouseLeave:Connect(function() tw(lbl, { TextColor3 = T.Text   }) end)

    local api = {}
    function api:Set(v)
        state = v == true
        tw(box,  { BackgroundColor3 = state and T.ChkOn or T.ChkOff })
        tw(tick, { TextTransparency = state and 0 or 1 })
    end
    function api:Get() return state end
    return api
end

--------------------------------------------------------------------------------
-- COMPONENT: Slider
--------------------------------------------------------------------------------
local function Slider(parent, label, mn, mx, default, cb)
    local val   = math.clamp(default or mn, mn, mx)
    local range = math.max(mx - mn, 1)
    local held  = false

    local wrap = N("Frame", { Size = UDim2.new(1,0,0,31), BackgroundTransparency = 1, Parent = parent })
    local top  = N("Frame", { Size = UDim2.new(1,0,0,13), BackgroundTransparency = 1, Parent = wrap  })

    N("TextLabel", {
        Size = UDim2.new(0.68,0,1,0), BackgroundTransparency = 1,
        Text = label, TextColor3 = T.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = top,
    })
    local valLbl = N("TextLabel", {
        Size = UDim2.new(0.32,0,1,0), Position = UDim2.new(0.68,0,0,0),
        BackgroundTransparency = 1, Text = tostring(val),
        TextColor3 = T.TextDim, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = top,
    })

    local track = N("Frame", {
        Size = UDim2.new(1,0,0,4), Position = UDim2.new(0,0,0,17),
        BackgroundColor3 = T.TrkBg, BorderSizePixel = 0, Parent = wrap,
    })
    Stroke(track, T.TrkBorder)

    local fill = N("Frame", {
        Size = UDim2.new((val-mn)/range,0,1,0),
        BackgroundColor3 = T.TrkFill, BorderSizePixel = 0, Parent = track,
    })
    local thumb = N("Frame", {
        Size = UDim2.fromOffset(7,7),
        Position = UDim2.new((val-mn)/range,-4,0.5,-4),
        BackgroundColor3 = T.TrkThumb, BorderSizePixel = 0, Parent = track,
    })
    Stroke(thumb, T.TrkBorder)

    local function applyX(ax)
        local rx = math.clamp((ax - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X,1), 0, 1)
        val = math.floor(mn + rx*range + 0.5)
        local ex = (val-mn)/range
        fill.Size      = UDim2.new(ex,0,1,0)
        thumb.Position = UDim2.new(ex,-4,0.5,-4)
        valLbl.Text    = tostring(val)
        if cb then cb(val) end
    end

    local h = N("TextButton", {
        Size = UDim2.new(1,0,0,18), Position = UDim2.new(0,0,0,12),
        BackgroundTransparency = 1, Text = "", Parent = wrap,
    })
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then held = true; applyX(i.Position.X) end
    end)
    UIS.InputChanged:Connect(function(i)
        if held and i.UserInputType == Enum.UserInputType.MouseMovement then applyX(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then held = false end
    end)
    h.MouseEnter:Connect(function() tw(fill, { BackgroundColor3 = T.TextHi  }) end)
    h.MouseLeave:Connect(function()
        if not held then tw(fill, { BackgroundColor3 = T.TrkFill }) end
    end)

    local api = {}
    function api:Set(v)
        val = math.clamp(v, mn, mx)
        local rx = (val-mn)/range
        fill.Size      = UDim2.new(rx,0,1,0)
        thumb.Position = UDim2.new(rx,-4,0.5,-4)
        valLbl.Text    = tostring(val)
    end
    function api:Get() return val end
    return api
end

--------------------------------------------------------------------------------
-- COMPONENT: Dropdown
--
-- The popup frame and its scroll live in the PM overlay (ZIndex 999).
-- Option TextButtons are direct children of the ScrollingFrame at ZIndex 1002.
-- Nothing sits on top of them — clicks land cleanly.
-- Selecting an option calls PM.close() synchronously so the deferred global
-- LMB listener runs when PM._frame is already nil → no double-close.
--------------------------------------------------------------------------------
local function Dropdown(parent, label, options, default, cb)
    local opts = options or {}
    local sel  = default or (opts[1] or "")
    local open = false

    local _, ctrl = Row(parent, label, 0.60)

    local selLbl = N("TextLabel", {
        Size = UDim2.new(1,-15,1,0), Position = UDim2.new(0,5,0,0),
        BackgroundTransparency = 1, Text = sel,
        TextColor3 = T.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = ctrl,
    })
    N("TextLabel", {  -- arrow
        Size = UDim2.new(0,14,1,0), Position = UDim2.new(1,-14,0,0),
        BackgroundTransparency = 1, Text = "▾",
        TextColor3 = T.TextDim, TextSize = FS_SM, Font = FONT, Parent = ctrl,
    })

    -- Popup (shown in PM overlay)
    local popH  = math.min(#opts, DROP_MAX) * DROP_IH
    local popup = N("Frame", {
        BackgroundColor3 = T.DropBg, BorderSizePixel = 0,
        Visible = false, ZIndex = 1000,
    })
    Stroke(popup, T.DropBorder)

    local scroll = N("ScrollingFrame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = T.Scroll,
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 1001, Parent = popup,
    })
    List(scroll)

    local optMap = {}

    local function desel(o)
        if optMap[o] then tw(optMap[o], { BackgroundTransparency=1, TextColor3=T.Text }) end
    end
    local function dosel(o)
        if optMap[o] then tw(optMap[o], { BackgroundColor3=T.DropSel, BackgroundTransparency=0, TextColor3=T.DropSelTxt }) end
    end

    for _, opt in ipairs(opts) do
        local isSel = (opt == sel)
        local ob = N("TextButton", {
            Size = UDim2.new(1,0,0,DROP_IH),
            BackgroundColor3       = T.DropSel,
            BackgroundTransparency = isSel and 0 or 1,
            BorderSizePixel        = 0,
            Text                   = opt,
            TextColor3             = isSel and T.DropSelTxt or T.Text,
            TextSize               = FS, Font = FONT,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 1002,
            Parent                 = scroll,
        })
        Pad(ob, 0, 0, 0, 6)
        optMap[opt] = ob

        ob.MouseEnter:Connect(function()
            if opt ~= sel then tw(ob, { BackgroundColor3=T.DropHover, BackgroundTransparency=0 }) end
        end)
        ob.MouseLeave:Connect(function()
            if opt ~= sel then tw(ob, { BackgroundTransparency=1 }) end
        end)
        ob.MouseButton1Click:Connect(function()
            desel(sel); sel = opt; selLbl.Text = sel; dosel(sel)
            open = false
            PM.close()   -- synchronous — deferred global fires as no-op
            if cb then cb(sel) end
        end)
    end

    local hdr = Hit(ctrl, 2)
    hdr.MouseButton1Click:Connect(function()
        if open then open = false; PM.close()
        else
            open = true
            local ap = ctrl.AbsolutePosition
            PM.show(popup, ap.X, ap.Y + ROW_H + 1,
                    ctrl.AbsoluteSize.X, popH,
                    function() open = false end)
        end
    end)
    hdr.MouseEnter:Connect(function() tw(ctrl, { BackgroundColor3=T.CtrlHover }) end)
    hdr.MouseLeave:Connect(function() tw(ctrl, { BackgroundColor3=T.CtrlBg   }) end)

    local api = {}
    function api:Set(v) desel(sel); sel=v; selLbl.Text=v; dosel(sel) end
    function api:Get() return sel end
    return api
end

--------------------------------------------------------------------------------
-- COMPONENT: TextInput
--------------------------------------------------------------------------------
local function Input(parent, label, placeholder, cb)
    local _, ctrl = Row(parent, label, 0.60)
    local st = Stroke(ctrl, T.CtrlBorder)
    local box = N("TextBox", {
        Size = UDim2.new(1,-8,1,0), Position = UDim2.new(0,5,0,0),
        BackgroundTransparency = 1,
        PlaceholderText = placeholder or "", PlaceholderColor3 = T.TextDim,
        Text = "", TextColor3 = T.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false, Parent = ctrl,
    })
    box.Focused:Connect(function()
        tw(st, { Color=T.CtrlFocus }); tw(ctrl, { BackgroundColor3=T.CtrlHover })
    end)
    box.FocusLost:Connect(function(enter)
        tw(st, { Color=T.CtrlBorder }); tw(ctrl, { BackgroundColor3=T.CtrlBg })
        if cb then cb(box.Text, enter) end
    end)
    local api = {}
    function api:Set(v) box.Text = v end
    function api:Get() return box.Text end
    return api
end

--------------------------------------------------------------------------------
-- COMPONENT: Keybind
--------------------------------------------------------------------------------
local function Keybind(parent, label, default, cb)
    local key       = default or Enum.KeyCode.Unknown
    local listening = false

    local function fmt(k)
        if not k or k == Enum.KeyCode.Unknown then return "NONE" end
        return k.Name
    end

    local _, ctrl = Row(parent, label, 0.42)
    local st  = Stroke(ctrl, T.CtrlBorder)
    local lbl = N("TextLabel", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        Text = fmt(key), TextColor3 = T.TextDim, TextSize = FS, Font = FONT,
        Parent = ctrl,
    })

    local h = Hit(ctrl, 2)
    h.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true; lbl.Text = "..."
        tw(st, { Color=T.CtrlFocus }); tw(ctrl, { BackgroundColor3=T.CtrlHover })
        tw(lbl, { TextColor3=T.Text })
    end)
    h.MouseEnter:Connect(function() if not listening then tw(ctrl, { BackgroundColor3=T.CtrlHover }) end end)
    h.MouseLeave:Connect(function() if not listening then tw(ctrl, { BackgroundColor3=T.CtrlBg   }) end end)

    UIS.InputBegan:Connect(function(inp)
        if not listening then return end
        local ut   = inp.UserInputType
        local name
        if     ut == Enum.UserInputType.Keyboard     then key = inp.KeyCode; name = key.Name
        elseif ut == Enum.UserInputType.MouseButton2 then name = "MB2"
        elseif ut == Enum.UserInputType.MouseButton3 then name = "MB3"
        else return end
        listening = false; lbl.Text = name
        tw(st, { Color=T.CtrlBorder }); tw(ctrl, { BackgroundColor3=T.CtrlBg })
        tw(lbl, { TextColor3=T.TextDim })
        if cb then cb(key) end
    end)

    local api = {}
    function api:Set(k) key = k; lbl.Text = fmt(k) end
    function api:Get() return key end
    return api
end

--------------------------------------------------------------------------------
-- COMPONENT: Button
--------------------------------------------------------------------------------
local function Button(parent, label, cb)
    local btn = N("TextButton", {
        Size = UDim2.new(1,0,0,ROW_H+2),
        BackgroundColor3 = T.BtnBg, BorderSizePixel = 0,
        Text = label, TextColor3 = T.Text, TextSize = FS, Font = FONT,
        Parent = parent,
    })
    Stroke(btn, T.BtnBorder)
    btn.MouseEnter:Connect(function()       tw(btn, { BackgroundColor3=T.BtnHover }) end)
    btn.MouseLeave:Connect(function()       tw(btn, { BackgroundColor3=T.BtnBg    }) end)
    btn.MouseButton1Down:Connect(function() tw(btn, { BackgroundColor3=T.BtnPress }) end)
    btn.MouseButton1Up:Connect(function()   tw(btn, { BackgroundColor3=T.BtnHover }) end)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    return btn
end

--------------------------------------------------------------------------------
-- COMPONENT: Label
--------------------------------------------------------------------------------
local function Label(parent, text)
    return N("TextLabel", {
        Size = UDim2.new(1,0,0,13), BackgroundTransparency = 1,
        Text = text, TextColor3 = T.TextDim, TextSize = FS_SM, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = parent,
    })
end

--------------------------------------------------------------------------------
-- COMPONENT: Separator
--------------------------------------------------------------------------------
local function Sep(parent)
    return N("Frame", {
        Size = UDim2.new(1,0,0,1), BackgroundColor3 = T.Sep,
        BorderSizePixel = 0, Parent = parent,
    })
end

--------------------------------------------------------------------------------
-- COMPONENT: ColorPicker
--
-- Layout inside the panel (all absolute pixel positions):
--
--   panel  (ZIndex 1000, placed by PM)
--     ├─ svBg     (hue colour bg, ZIndex 1001)
--     │    ├─ wLayer   (white→transp gradient, ZIndex 1002)
--     │    ├─ bLayer   (black→transp gradient rotated 90°, ZIndex 1003)
--     │    └─ svDot    (cosmetic cursor, ZIndex 1004)
--     ├─ svHitBtn  ← direct child of panel (ZIndex 1010) ✓ NOT child of svBg
--     ├─ hueBar   (rainbow gradient, ZIndex 1001)
--     │    └─ hueDot   (cosmetic cursor, ZIndex 1002)
--     ├─ hueHitBtn ← direct child of panel (ZIndex 1010)
--     └─ prevBar  (preview swatch, ZIndex 1001)
--
-- Why this hierarchy matters:
--   In Roblox's ZIndexBehavior.Sibling mode ZIndex is global, so a button at
--   ZIndex 1010 beats anything at 1001–1004, regardless of parenting.
--   HOWEVER the old bug was that ZIndex also controls which sibling renders
--   last (and thus appears on top visually). Because the gradient layers
--   (1002, 1003) are children of svBg, and svHitBtn is ALSO a child of svBg
--   at say 1005, Roblox renders them in ZIndex order within the same parent.
--   By making svHitBtn a child of panel instead, it is at the panel level and
--   its ZIndex 1010 unambiguously places it above every panel child.
--------------------------------------------------------------------------------
local function ColorPicker(parent, label, default, cb)
    local color   = default or Color3.new(1,1,1)
    local H, S, V = Color3.toHSV(color)

    -- Swatch row (lives in the section)
    local wrap = N("Frame", {
        Size = UDim2.new(1,0,0,ROW_H), BackgroundTransparency = 1, Parent = parent,
    })
    N("TextLabel", {
        Size = UDim2.new(0.68,-4,1,0), BackgroundTransparency = 1,
        Text = label, TextColor3 = T.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    local swF = N("Frame", {
        Size = UDim2.new(0.32,0,0,14), Position = UDim2.new(0.68,0,0.5,-7),
        BackgroundColor3 = color, BorderSizePixel = 0, Parent = wrap,
    })
    Stroke(swF, T.CtrlBorder)
    local swHit = Hit(swF, 1)
    swHit.MouseEnter:Connect(function() tw(swF, { Size=UDim2.new(0.32,0,0,16) }) end)
    swHit.MouseLeave:Connect(function() tw(swF, { Size=UDim2.new(0.32,0,0,14) }) end)

    -- Panel geometry
    local PAD  = 6
    local SVW  = 148
    local SVH  = 94
    local HH   = 8     -- hue bar height
    local PVH  = 10    -- preview bar height
    local GAP  = 4
    local PW   = SVW + PAD*2                          -- 160
    local PH   = PAD + SVH + GAP + HH + GAP + PVH + PAD  -- 140

    local panel = N("Frame", {
        BackgroundColor3 = T.CpBg, BorderSizePixel = 0,
        Visible = false, ZIndex = 1000,
    })
    Stroke(panel, T.CpBorder)

    -- SV square (pure hue background)
    local svBg = N("Frame", {
        Size     = UDim2.fromOffset(SVW, SVH),
        Position = UDim2.fromOffset(PAD, PAD),
        BackgroundColor3 = Color3.fromHSV(H,1,1),
        BorderSizePixel  = 0, ZIndex = 1001, Parent = panel,
    })
    Stroke(svBg, T.CpBorder)

    -- White layer: left=opaque white, right=transparent  (controls saturation)
    local wLayer = N("Frame", {
        Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0, ZIndex = 1002, Parent = svBg,
    })
    N("UIGradient", {
        Color        = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = wLayer,
    })

    -- Black layer: top=transparent, bottom=opaque black  (controls value)
    local bLayer = N("Frame", {
        Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0),
        BorderSizePixel = 0, ZIndex = 1003, Parent = svBg,
    })
    N("UIGradient", {
        Color        = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Rotation = 90, Parent = bLayer,
    })

    -- SV cursor dot (cosmetic, no interaction)
    local svDot = N("Frame", {
        Size     = UDim2.fromOffset(7,7),
        Position = UDim2.new(S,-4,1-V,-4),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel  = 0, ZIndex = 1004, Parent = svBg,
    })
    Stroke(svDot, Color3.new(0,0,0))

    -- SV hit button — DIRECT CHILD OF PANEL (critical!)
    local svY   = PAD
    local svHitBtn = N("TextButton", {
        Size     = UDim2.fromOffset(SVW, SVH),
        Position = UDim2.fromOffset(PAD, svY),
        BackgroundTransparency = 1, Text = "", ZIndex = 1010, Parent = panel,
    })

    -- Hue bar
    local hueY  = PAD + SVH + GAP
    local hueBar = N("Frame", {
        Size     = UDim2.fromOffset(SVW, HH),
        Position = UDim2.fromOffset(PAD, hueY),
        BackgroundColor3 = Color3.new(1,0,0),
        BorderSizePixel  = 0, ZIndex = 1001, Parent = panel,
    })
    Stroke(hueBar, T.CpBorder)
    N("UIGradient", { Color = HUE_SEQ, Parent = hueBar })

    -- Hue cursor
    local hueDot = N("Frame", {
        Size     = UDim2.fromOffset(3, HH+4),
        Position = UDim2.new(H,-2,0,-2),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel  = 0, ZIndex = 1003, Parent = hueBar,
    })
    Stroke(hueDot, Color3.new(0,0,0))

    -- Hue hit button — DIRECT CHILD OF PANEL
    local hueHitBtn = N("TextButton", {
        Size     = UDim2.fromOffset(SVW, HH),
        Position = UDim2.fromOffset(PAD, hueY),
        BackgroundTransparency = 1, Text = "", ZIndex = 1010, Parent = panel,
    })

    -- Preview bar
    local prevY  = hueY + HH + GAP
    local prevBar = N("Frame", {
        Size     = UDim2.fromOffset(SVW, PVH),
        Position = UDim2.fromOffset(PAD, prevY),
        BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 1001, Parent = panel,
    })
    Stroke(prevBar, T.CpBorder)

    -- Apply: recompute colour and update UI
    local function apply()
        color = Color3.fromHSV(H, S, V)
        swF.BackgroundColor3     = color
        prevBar.BackgroundColor3 = color
        svBg.BackgroundColor3    = Color3.fromHSV(H,1,1)
        svDot.Position           = UDim2.new(S,-4,1-V,-4)
        hueDot.Position          = UDim2.new(H,-2,0,-2)
        if cb then cb(color) end
    end

    -- SV drag (reads AbsolutePosition at event time — panel may have just opened)
    local svHeld = false
    svHitBtn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        svHeld = true
        local ap = svBg.AbsolutePosition; local as = svBg.AbsoluteSize
        S = math.clamp((i.Position.X-ap.X)/math.max(as.X,1), 0, 1)
        V = 1 - math.clamp((i.Position.Y-ap.Y)/math.max(as.Y,1), 0, 1)
        apply()
    end)
    UIS.InputChanged:Connect(function(i)
        if not svHeld or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local ap = svBg.AbsolutePosition; local as = svBg.AbsoluteSize
        S = math.clamp((i.Position.X-ap.X)/math.max(as.X,1), 0, 1)
        V = 1 - math.clamp((i.Position.Y-ap.Y)/math.max(as.Y,1), 0, 1)
        apply()
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then svHeld = false end
    end)

    -- Hue drag
    local hueHeld = false
    hueHitBtn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        hueHeld = true
        H = math.clamp((i.Position.X-hueBar.AbsolutePosition.X)/math.max(hueBar.AbsoluteSize.X,1), 0, 1)
        apply()
    end)
    UIS.InputChanged:Connect(function(i)
        if not hueHeld or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        H = math.clamp((i.Position.X-hueBar.AbsolutePosition.X)/math.max(hueBar.AbsoluteSize.X,1), 0, 1)
        apply()
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then hueHeld = false end
    end)

    -- Swatch click → toggle panel
    local pickerOpen = false
    swHit.MouseButton1Click:Connect(function()
        if pickerOpen then
            pickerOpen = false; PM.close()
        else
            pickerOpen = true
            local ap = swF.AbsolutePosition; local as = swF.AbsoluteSize
            local vp = workspace.CurrentCamera.ViewportSize
            local px = ap.X + as.X - PW
            if px < 4            then px = ap.X end
            if px + PW > vp.X-4  then px = vp.X - PW - 4 end
            local py = ap.Y + as.Y + 3
            if py + PH > vp.Y-4  then py = ap.Y - PH - 3 end
            PM.show(panel, px, py, PW, PH, function() pickerOpen = false end)
        end
    end)

    local api = {}
    function api:Set(c)
        color = c; H, S, V = Color3.toHSV(c)
        swF.BackgroundColor3     = c
        prevBar.BackgroundColor3 = c
        svBg.BackgroundColor3    = Color3.fromHSV(H,1,1)
        svDot.Position           = UDim2.new(S,-4,1-V,-4)
        hueDot.Position          = UDim2.new(H,-2,0,-2)
    end
    function api:Get() return color end
    return api
end

--------------------------------------------------------------------------------
-- SECTION
--------------------------------------------------------------------------------
local Section = {}; Section.__index = Section

function Section.new(parent, title)
    local self = setmetatable({}, Section)

    self.Frame = N("Frame", {
        Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.SectBg, BorderSizePixel = 0, Parent = parent,
    })
    Stroke(self.Frame, T.SectBorder)

    local hasTitle = title and #title > 0
    if hasTitle then
        local hdr = N("Frame", {
            Size = UDim2.new(1,0,0,16), BackgroundColor3 = T.SectHdr,
            BorderSizePixel = 0, Parent = self.Frame,
        })
        N("TextLabel", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
            Text = title, TextColor3 = T.SectTitle, TextSize = FS_SM, Font = FONT,
            Parent = hdr,
        })
        N("Frame", {
            Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
            BackgroundColor3 = T.SectBorder, BorderSizePixel = 0, Parent = hdr,
        })
    end

    local c = N("Frame", {
        Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0,0,0,hasTitle and 16 or 0),
        BackgroundTransparency = 1, Parent = self.Frame,
    })
    Pad(c,6,8,7,8); List(c,nil,5)
    self._c = c
    return self
end

function Section:AddToggle(l,d,cb)         return Toggle(self._c,l,d,cb) end
function Section:AddSlider(l,mn,mx,d,cb)   return Slider(self._c,l,mn,mx,d,cb) end
function Section:AddDropdown(l,opts,d,cb)  return Dropdown(self._c,l,opts,d,cb) end
function Section:AddInput(l,ph,cb)         return Input(self._c,l,ph,cb) end
function Section:AddKeybind(l,d,cb)        return Keybind(self._c,l,d,cb) end
function Section:AddButton(l,cb)           return Button(self._c,l,cb) end
function Section:AddLabel(t)               return Label(self._c,t) end
function Section:AddColorPicker(l,d,cb)    return ColorPicker(self._c,l,d,cb) end
function Section:AddSeparator()            return Sep(self._c) end

--------------------------------------------------------------------------------
-- TAB
--------------------------------------------------------------------------------
local Tab = {}; Tab.__index = Tab

function Tab.new(name)
    local self = setmetatable({}, Tab); self.Name = name

    self.Frame = N("Frame", {
        Size = UDim2.new(1,0,1,0), BackgroundColor3 = T.WinBg,
        BorderSizePixel = 0, Visible = false,
    })

    local function col(xs, xo, ws, wo)
        local s = N("ScrollingFrame", {
            Size = UDim2.new(ws,wo,1,0), Position = UDim2.new(xs,xo,0,0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = T.Scroll,
            CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = self.Frame,
        })
        Pad(s,5,4,5,4); List(s,nil,5)
        return s
    end

    self._L = col(0,   0,   0.5, -1)
    self._R = col(0.5, 1,   0.5, -1)

    N("Frame", {
        Size = UDim2.new(0,1,1,-10), Position = UDim2.new(0.5,0,0,5),
        BackgroundColor3 = T.Divider, BorderSizePixel = 0, Parent = self.Frame,
    })
    return self
end

function Tab:AddSection(title, column)
    return Section.new(column == "right" and self._R or self._L, title)
end

--------------------------------------------------------------------------------
-- WATERMARK
-- Draggable badge anchored top-right. Auto-sizes to text.
-- WatermarkFPS=true appends a live fps counter updated every second.
--------------------------------------------------------------------------------
local function makeWatermark(gui, baseText, showFPS)
    local wm = N("Frame", {
        Size = UDim2.fromOffset(0,18), AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(1,-6,0,6), AnchorPoint = Vector2.new(1,0),
        BackgroundColor3 = T.WmBg, BorderSizePixel = 0, ZIndex = 50,
        Parent = gui,
    })
    Stroke(wm, T.WmBorder)
    Pad(wm,0,7,0,7)

    local lbl = N("TextLabel", {
        Size = UDim2.fromOffset(0,18), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = baseText or "",
        TextColor3 = T.WmText, TextSize = FS_SM, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 51, Parent = wm,
    })

    local base = baseText or ""

    -- Live FPS (updated each second via RenderStepped accumulation)
    if showFPS then
        local accum, count = 0, 0
        RunService.RenderStepped:Connect(function(dt)
            if not wm.Parent then return end
            accum = accum + dt; count = count + 1
            if accum >= 1 then
                lbl.Text = base .. count .. " fps"
                accum = 0; count = 0
            end
        end)
    end

    -- Draggable watermark
    Drag(wm, wm)

    local function setBase(txt)
        base = txt or ""
        if not showFPS then lbl.Text = base end
    end

    return wm, lbl, setBase
end

--------------------------------------------------------------------------------
-- WINDOW
--------------------------------------------------------------------------------
local Window = {}; Window.__index = Window

function Window.new(cfg)
    local self     = setmetatable({}, Window)
    self._tabs     = {}
    self._active   = nil
    self._vis      = true

    local title   = cfg.Title        or "AniLib"
    local size    = cfg.Size         or UDim2.new(0,560,0,380)
    local pos     = cfg.Position     or UDim2.new(0.5,-280,0.5,-190)
    local menuKey = cfg.Keybind
    local showWm  = cfg.Watermark   == true
    local wmTxt   = cfg.WatermarkTxt or title
    local wmFPS   = cfg.WatermarkFPS == true

    -- ScreenGui
    self._gui = N("ScreenGui", {
        Name = "AniLib_"..title, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    })
    if not pcall(function() self._gui.Parent = CoreGui end) then
        self._gui.Parent = LP:WaitForChild("PlayerGui")
    end

    -- Popup overlay (full-screen, transparent, Z=999 so popups at 1000 show above it)
    local overlay = N("Frame", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        ZIndex = 999, Parent = self._gui,
    })
    PM.init(overlay)

    -- Main window frame
    self._main = N("Frame", {
        Name = "Window", Size = size, Position = pos,
        BackgroundColor3 = T.WinBg, BorderSizePixel = 0, ZIndex = 1, Parent = self._gui,
    })
    Stroke(self._main, T.Border)

    -- Title bar (centred text, draggable)
    local titleBar = N("Frame", {
        Size = UDim2.new(1,0,0,TITLE_H), BackgroundColor3 = T.TitleBg,
        BorderSizePixel = 0, Parent = self._main,
    })
    N("Frame", {  -- bottom 1px border
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, Parent = titleBar,
    })
    N("TextLabel", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        Text = title, TextColor3 = T.TitleText, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Center, Parent = titleBar,
    })
    Drag(titleBar, self._main)

    -- Content area (clips scrolling sections)
    self._content = N("Frame", {
        Size = UDim2.new(1,0,1,-(TITLE_H+TAB_H)),
        Position = UDim2.new(0,0,0,TITLE_H),
        BackgroundTransparency = 1, ClipsDescendants = true,
        Parent = self._main,
    })

    -- Tab bar (bottom, centered tabs)
    local tabBar = N("Frame", {
        Size = UDim2.new(1,0,0,TAB_H), Position = UDim2.new(0,0,1,-TAB_H),
        BackgroundColor3 = T.TabBg, BorderSizePixel = 0, Parent = self._main,
    })
    Stroke(tabBar, T.TabBorder)
    N("Frame", {  -- top 1px separator
        Size = UDim2.new(1,0,0,1), BackgroundColor3 = T.TabBorder,
        BorderSizePixel = 0, Parent = tabBar,
    })
    self._tabHolder = N("Frame", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = tabBar,
    })
    List(self._tabHolder, Enum.FillDirection.Horizontal, 0, Enum.HorizontalAlignment.Center)

    -- Menu keybind toggle
    if menuKey then
        UIS.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.KeyCode == menuKey then
                self._vis = not self._vis
                self._main.Visible = self._vis
                if not self._vis then PM.close() end
            end
        end)
    end

    -- Watermark
    local wmF, wmL, wmSetBase = makeWatermark(self._gui, wmTxt, wmFPS)
    wmF.Visible = showWm
    self._wmF   = wmF
    self._wmL   = wmL
    self._wmSet = wmSetBase

    return self
end

function Window:AddTab(name)
    local tab = Tab.new(name)
    tab.Frame.Parent = self._content
    table.insert(self._tabs, tab)

    local btn = N("TextButton", {
        Size = UDim2.new(0,88,1,0), BackgroundTransparency = 1,
        Text = name, TextColor3 = T.TabText, TextSize = FS, Font = FONT,
        Parent = self._tabHolder,
    })
    local ul = N("Frame", {
        Size = UDim2.new(1,-14,0,1), Position = UDim2.new(0,7,1,-1),
        BackgroundColor3 = T.TabUnder, BackgroundTransparency = 1,
        BorderSizePixel = 0, Parent = btn,
    })
    tab._btn = btn; tab._ul = ul

    btn.MouseButton1Click:Connect(function() self:_select(tab) end)
    btn.MouseEnter:Connect(function() if self._active~=tab then tw(btn,{TextColor3=T.TabTextOn}) end end)
    btn.MouseLeave:Connect(function() if self._active~=tab then tw(btn,{TextColor3=T.TabText  }) end end)

    if #self._tabs == 1 then self:_select(tab) end
    return tab
end

function Window:_select(tab)
    PM.close()
    for _, t in ipairs(self._tabs) do
        t.Frame.Visible = false
        tw(t._btn,{TextColor3=T.TabText}); tw(t._ul,{BackgroundTransparency=1})
    end
    tab.Frame.Visible = true; self._active = tab
    tw(tab._btn,{TextColor3=T.TabTextOn}); tw(tab._ul,{BackgroundTransparency=0})
end

function Window:SetVisible(v)
    self._vis = v; self._main.Visible = v
    if not v then PM.close() end
end

function Window:SetWatermark(txt)
    -- Updates base text; if WatermarkFPS is off, updates label immediately
    if self._wmSet then self._wmSet(txt) end
    if self._wmL   then self._wmL.Text = txt or "" end
end

function Window:ShowWatermark(v)
    if self._wmF then self._wmF.Visible = v end
end

function Window:Destroy() self._gui:Destroy() end

--------------------------------------------------------------------------------
-- EXPORT
--------------------------------------------------------------------------------
local Lib = {}; Lib.__index = Lib; Lib.Theme = T

function Lib:CreateWindow(cfg)
    return Window.new(cfg or {})
end

return Lib

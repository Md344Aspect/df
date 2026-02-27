--[[
╔══════════════════════════════════════════════════════════════╗
║                   AniLib  ·  v5.0                            ║
║   Classic blocky · Two-column · Fully functional            ║
╠══════════════════════════════════════════════════════════════╣
║  API                                                         ║
║                                                              ║
║  local Lib = require(script.UILibrary)                       ║
║                                                              ║
║  local Win = Lib:CreateWindow({                              ║
║      Title   = "My Script",                                  ║
║      Keybind = Enum.KeyCode.RightShift,                      ║
║  })                                                          ║
║                                                              ║
║  local Tab = Win:AddTab("Tab Name")                          ║
║  local L   = Tab:AddSection("title")           -- left       ║
║  local R   = Tab:AddSection("title", "right")  -- right      ║
║                                                              ║
║  L:AddToggle     ("label", false,         cb)                ║
║  L:AddSlider     ("label", min, max, def, cb)                ║
║  L:AddDropdown   ("label", {opts}, def,   cb)                ║
║  L:AddKeybind    ("label", Enum.KeyCode.F, cb)               ║
║  L:AddButton     ("label",                cb)                ║
║  L:AddInput      ("label", "hint",        cb)                ║
║  L:AddColorPicker("label", Color3.new(),  cb)                ║
║  L:AddLabel      ("text")                                    ║
║  L:AddSeparator  ()                                          ║
║                                                              ║
║  All components return { Set(v), Get() }                     ║
╚══════════════════════════════════════════════════════════════╝
--]]

-- ════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════════
-- THEME
-- ════════════════════════════════════════════════════════════════════════════
local T = {
    -- Window chrome
    WinBg        = Color3.fromRGB(20, 20, 20),
    TitleBg      = Color3.fromRGB(13, 13, 13),
    TitleText    = Color3.fromRGB(185, 185, 185),
    OuterBorder  = Color3.fromRGB(44, 44, 44),

    -- Tab bar
    TabBg        = Color3.fromRGB(14, 14, 14),
    TabBorder    = Color3.fromRGB(40, 40, 40),
    TabText      = Color3.fromRGB(135, 135, 135),
    TabTextOn    = Color3.fromRGB(215, 215, 215),
    TabUnder     = Color3.fromRGB(195, 195, 195),

    -- Content / sections
    ContentBg    = Color3.fromRGB(20, 20, 20),
    SectBg       = Color3.fromRGB(26, 26, 26),
    SectHdrBg    = Color3.fromRGB(18, 18, 18),
    SectTitle    = Color3.fromRGB(125, 125, 125),
    SectBorder   = Color3.fromRGB(40, 40, 40),
    Divider      = Color3.fromRGB(34, 34, 34),

    -- Text
    Text         = Color3.fromRGB(188, 188, 188),
    TextBright   = Color3.fromRGB(215, 215, 215),
    TextDim      = Color3.fromRGB(95,  95,  95),

    -- Toggle / checkbox
    CheckOn      = Color3.fromRGB(200, 200, 200),
    CheckOff     = Color3.fromRGB(40,  40,  40),
    CheckBorder  = Color3.fromRGB(62,  62,  62),
    CheckMark    = Color3.fromRGB(18,  18,  18),    -- tick colour

    -- Slider
    TrackBg      = Color3.fromRGB(35, 35, 35),
    TrackFill    = Color3.fromRGB(185, 185, 185),
    TrackBorder  = Color3.fromRGB(50, 50, 50),

    -- Inputs / keybind
    InputBg      = Color3.fromRGB(29, 29, 29),
    InputBorder  = Color3.fromRGB(48, 48, 48),
    InputFocus   = Color3.fromRGB(105, 105, 105),

    -- Button
    BtnBg        = Color3.fromRGB(29, 29, 29),
    BtnHover     = Color3.fromRGB(38, 38, 38),
    BtnPress     = Color3.fromRGB(46, 46, 46),
    BtnBorder    = Color3.fromRGB(50, 50, 50),

    -- Dropdown list
    DropBg       = Color3.fromRGB(22, 22, 22),
    DropBorder   = Color3.fromRGB(46, 46, 46),
    DropHover    = Color3.fromRGB(33, 33, 33),
    DropSel      = Color3.fromRGB(40, 40, 40),

    -- Scrollbar
    Scroll       = Color3.fromRGB(48, 48, 48),

    -- Separator
    Sep          = Color3.fromRGB(35, 35, 35),

    -- Color picker panel
    CpBg         = Color3.fromRGB(20, 20, 20),
    CpBorder     = Color3.fromRGB(46, 46, 46),
    CpPreviewBg  = Color3.fromRGB(14, 14, 14),
}

local FONT    = Enum.Font.Code
local FS      = 11                  -- base font size
local FS_SM   = 10                  -- small font size
local ROW_H   = 18                  -- standard row height
local TITLE_H = 22
local TAB_H   = 24
local DROP_IH = 17                  -- dropdown item height
local DROP_MAX = 7                  -- max visible dropdown rows

local TI = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ════════════════════════════════════════════════════════════════════════════
-- UTILITIES
-- ════════════════════════════════════════════════════════════════════════════
local U = {}

function U.New(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    if props.Parent then o.Parent = props.Parent end
    return o
end

function U.Tw(obj, props)
    TweenService:Create(obj, TI, props):Play()
end

function U.Stroke(parent, col, thick)
    return U.New("UIStroke", {
        Color = col or T.OuterBorder, Thickness = thick or 1, Parent = parent,
    })
end

function U.Pad(parent, t, r, b, l)
    return U.New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        Parent        = parent,
    })
end

function U.List(parent, dir, gap, hAlign)
    return U.New("UIListLayout", {
        FillDirection       = dir    or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, gap or 0),
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = parent,
    })
end

-- Invisible full-coverage click catcher
function U.Hit(parent, zIndex)
    return U.New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "", ZIndex = zIndex or 1, Parent = parent,
    })
end

function U.Drag(handle, frame)
    local on, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            on, ds, sp = true, i.Position, frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if on and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X,
                                       sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then on = false end
    end)
end

-- Horizontal rainbow gradient frame (for hue bar)
local HUE_SEQ = ColorSequence.new({
    ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,   0,   0)),
    ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255,   0)),
    ColorSequenceKeypoint.new(2/6, Color3.fromRGB(  0, 255,   0)),
    ColorSequenceKeypoint.new(3/6, Color3.fromRGB(  0, 255, 255)),
    ColorSequenceKeypoint.new(4/6, Color3.fromRGB(  0,   0, 255)),
    ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,   0, 255)),
    ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255,   0,   0)),
})

-- ════════════════════════════════════════════════════════════════════════════
-- POPUP MANAGER
-- One shared transparent overlay; only one popup open at a time.
-- Dropdowns and color pickers both use this system.
-- ════════════════════════════════════════════════════════════════════════════
local PM = { _overlay = nil, _open = nil, _cb = nil }

function PM:Init(overlay) self._overlay = overlay end

function PM:Close()
    if self._open then
        self._open.Visible = false
        self._open = nil
        if self._cb then self._cb(); self._cb = nil end
    end
end

function PM:Show(frame, onClose)
    if self._open and self._open ~= frame then
        self._open.Visible = false
        if self._cb then self._cb(); self._cb = nil end
    end
    frame.Parent  = self._overlay
    frame.Visible = true
    self._open    = frame
    self._cb      = onClose
end

-- Close on LMB anywhere; deferred so the button that triggered open resolves first
UserInputService.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 and PM._open then
        task.defer(function() PM:Close() end)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
-- COMPONENTS
-- ════════════════════════════════════════════════════════════════════════════
local Comp = {}

-- ── Shared: label + right-side control row ───────────────────────────────────
local function makeRow(parent, labelText, rightW)
    local row = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H), BackgroundTransparency = 1, Parent = parent,
    })
    U.New("TextLabel", {
        Size                   = UDim2.new(1 - rightW, -3, 1, 0),
        BackgroundTransparency = 1,
        Text                   = labelText,
        TextColor3             = T.Text,
        TextSize               = FS,
        Font                   = FONT,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = row,
    })
    local ctrl = U.New("Frame", {
        Size             = UDim2.new(rightW, 0, 1, 0),
        Position         = UDim2.new(1 - rightW, 0, 0, 0),
        BackgroundColor3 = T.InputBg,
        BorderSizePixel  = 0,
        Parent           = row,
    })
    U.Stroke(ctrl, T.InputBorder)
    return row, ctrl
end

-- ── Toggle ────────────────────────────────────────────────────────────────────
function Comp.Toggle(parent, label, default, cb)
    local state = (default == true)

    local row = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H), BackgroundTransparency = 1, Parent = parent,
    })

    -- Checkbox square
    local box = U.New("Frame", {
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new(0, 0, 0.5, -6),
        BackgroundColor3 = state and T.CheckOn or T.CheckOff,
        BorderSizePixel  = 0,
        Parent           = row,
    })
    U.Stroke(box, T.CheckBorder)

    -- Tick mark inside the box (only shown when on)
    local tick = U.New("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = "✓",
        TextColor3             = T.CheckMark,
        TextSize               = 9,
        Font                   = Enum.Font.GothamBold,
        TextTransparency       = state and 0 or 1,
        Parent                 = box,
    })

    local lbl = U.New("TextLabel", {
        Size                   = UDim2.new(1, -18, 1, 0),
        Position               = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text                   = label,
        TextColor3             = T.Text,
        TextSize               = FS,
        Font                   = FONT,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = row,
    })

    local hit = U.Hit(row)
    hit.MouseButton1Click:Connect(function()
        state = not state
        U.Tw(box,  { BackgroundColor3 = state and T.CheckOn or T.CheckOff })
        U.Tw(tick, { TextTransparency = state and 0 or 1 })
        if cb then cb(state) end
    end)
    hit.MouseEnter:Connect(function() U.Tw(lbl, { TextColor3 = T.TextBright }) end)
    hit.MouseLeave:Connect(function() U.Tw(lbl, { TextColor3 = T.Text       }) end)

    local api = {}
    function api:Set(v)
        state = (v == true)
        U.Tw(box,  { BackgroundColor3 = state and T.CheckOn or T.CheckOff })
        U.Tw(tick, { TextTransparency = state and 0 or 1 })
    end
    function api:Get() return state end
    return api
end

-- ── Slider ────────────────────────────────────────────────────────────────────
function Comp.Slider(parent, label, min, max, default, cb)
    local value = math.clamp(default or min, min, max)
    local held  = false
    local range = math.max(max - min, 1)

    local wrap = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = parent,
    })

    -- Top row: label left, value right
    local top = U.New("Frame", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Parent = wrap })
    U.New("TextLabel", {
        Size = UDim2.new(0.68, 0, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = T.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = top,
    })
    local valLbl = U.New("TextLabel", {
        Size = UDim2.new(0.32, 0, 1, 0), Position = UDim2.new(0.68, 0, 0, 0),
        BackgroundTransparency = 1, Text = tostring(value),
        TextColor3 = T.TextDim, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = top,
    })

    -- Track
    local track = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = T.TrackBg, BorderSizePixel = 0, Parent = wrap,
    })
    U.Stroke(track, T.TrackBorder)

    local fill = U.New("Frame", {
        Size             = UDim2.new((value - min) / range, 0, 1, 0),
        BackgroundColor3 = T.TrackFill, BorderSizePixel = 0, Parent = track,
    })

    -- Thumb dot at fill end
    local thumb = U.New("Frame", {
        Size             = UDim2.new(0, 7, 0, 7),
        Position         = UDim2.new((value - min) / range, -4, 0.5, -4),
        BackgroundColor3 = T.TrackFill,
        BorderSizePixel  = 0,
        Parent           = track,
    })
    U.Stroke(thumb, T.TrackBorder)

    local function applyX(absX)
        local rx    = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value       = math.floor(min + rx * range + 0.5)
        local exact = (value - min) / range
        fill.Size     = UDim2.new(exact, 0, 1, 0)
        thumb.Position = UDim2.new(exact, -4, 0.5, -4)
        valLbl.Text   = tostring(value)
        if cb then cb(value) end
    end

    -- Wider hitbox
    local hit = U.New("TextButton", {
        Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 12),
        BackgroundTransparency = 1, Text = "", Parent = wrap,
    })
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then held = true; applyX(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if held and i.UserInputType == Enum.UserInputType.MouseMovement then applyX(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then held = false end
    end)

    -- Hover highlight on track
    hit.MouseEnter:Connect(function() U.Tw(fill, { BackgroundColor3 = T.TextBright }) end)
    hit.MouseLeave:Connect(function()
        if not held then U.Tw(fill, { BackgroundColor3 = T.TrackFill }) end
    end)

    local api = {}
    function api:Set(v)
        value = math.clamp(v, min, max)
        local rx = (value - min) / range
        fill.Size      = UDim2.new(rx, 0, 1, 0)
        thumb.Position = UDim2.new(rx, -4, 0.5, -4)
        valLbl.Text    = tostring(value)
    end
    function api:Get() return value end
    return api
end

-- ── Dropdown ──────────────────────────────────────────────────────────────────
function Comp.Dropdown(parent, label, options, default, cb)
    local selected = default or (options and options[1]) or ""
    local open     = false

    -- Row: label + button
    local row, btnF = makeRow(parent, label, 0.60)
    local selLbl = U.New("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1, Text = selected,
        TextColor3 = T.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = btnF,
    })
    -- Arrow indicator
    U.New("TextLabel", {
        Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(1, -14, 0, 0),
        BackgroundTransparency = 1, Text = "▾", TextColor3 = T.TextDim,
        TextSize = FS_SM, Font = FONT, Parent = btnF,
    })

    -- Dropdown list (lives in PM overlay, never clips)
    local dropH = math.min(#options, DROP_MAX) * DROP_IH
    local dropFrame = U.New("Frame", {
        BackgroundColor3 = T.DropBg, BorderSizePixel = 0,
        Visible = false, ZIndex = 200, ClipsDescendants = true,
        Size = UDim2.new(0, 10, 0, dropH),
    })
    U.Stroke(dropFrame, T.DropBorder)

    local inner = U.New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.Scroll,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 201, Parent = dropFrame,
    })
    U.List(inner)

    local optBtns = {}

    for _, opt in ipairs(options or {}) do
        local isSel = (opt == selected)
        local ob = U.New("TextButton", {
            Size                   = UDim2.new(1, 0, 0, DROP_IH),
            BackgroundColor3       = T.DropSel,
            BackgroundTransparency = isSel and 0 or 1,
            BorderSizePixel        = 0,
            Text                   = opt,
            TextColor3             = isSel and T.TextBright or T.Text,
            TextSize               = FS,
            Font                   = FONT,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 202,
            Parent                 = inner,
        })
        U.Pad(ob, 0, 0, 0, 6)
        optBtns[opt] = ob

        ob.MouseEnter:Connect(function()
            if opt ~= selected then U.Tw(ob, { BackgroundColor3 = T.DropHover, BackgroundTransparency = 0 }) end
        end)
        ob.MouseLeave:Connect(function()
            if opt ~= selected then U.Tw(ob, { BackgroundTransparency = 1 }) end
        end)
        ob.MouseButton1Click:Connect(function()
            -- Clear old
            if optBtns[selected] then
                U.Tw(optBtns[selected], { BackgroundTransparency = 1, TextColor3 = T.Text })
            end
            -- Select new
            selected    = opt
            selLbl.Text = opt
            U.Tw(ob, { BackgroundColor3 = T.DropSel, BackgroundTransparency = 0, TextColor3 = T.TextBright })
            open = false
            PM:Close()        -- immediate, not deferred
            if cb then cb(selected) end
        end)
    end

    -- Open / close on button click
    local hit = U.Hit(btnF, 2)
    hit.MouseButton1Click:Connect(function()
        if open then
            open = false; PM:Close()
        else
            open = true
            local ap = btnF.AbsolutePosition
            local aw = btnF.AbsoluteSize.X
            dropFrame.Size     = UDim2.new(0, aw, 0, dropH)
            dropFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + ROW_H + 1)
            PM:Show(dropFrame, function() open = false end)
        end
    end)
    hit.MouseEnter:Connect(function() U.Tw(btnF, { BackgroundColor3 = T.BtnHover }) end)
    hit.MouseLeave:Connect(function() U.Tw(btnF, { BackgroundColor3 = T.InputBg  }) end)

    local api = {}
    function api:Set(v)
        if optBtns[selected] then
            U.Tw(optBtns[selected], { BackgroundTransparency = 1, TextColor3 = T.Text })
        end
        selected    = v
        selLbl.Text = v
        if optBtns[v] then
            U.Tw(optBtns[v], { BackgroundColor3 = T.DropSel, BackgroundTransparency = 0, TextColor3 = T.TextBright })
        end
    end
    function api:Get() return selected end
    return api
end

-- ── TextInput ─────────────────────────────────────────────────────────────────
function Comp.Input(parent, label, placeholder, cb)
    local row, boxF = makeRow(parent, label, 0.60)
    local stroke = U.Stroke(boxF, T.InputBorder)

    local box = U.New("TextBox", {
        Size              = UDim2.new(1, -8, 1, 0),
        Position          = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText   = placeholder or "",
        PlaceholderColor3 = T.TextDim,
        Text              = "",
        TextColor3        = T.Text,
        TextSize          = FS,
        Font              = FONT,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ClearTextOnFocus  = false,
        Parent            = boxF,
    })
    box.Focused:Connect(function()
        U.Tw(stroke, { Color = T.InputFocus })
        U.Tw(boxF,   { BackgroundColor3 = T.BtnHover })
    end)
    box.FocusLost:Connect(function(enter)
        U.Tw(stroke, { Color = T.InputBorder })
        U.Tw(boxF,   { BackgroundColor3 = T.InputBg })
        if cb then cb(box.Text, enter) end
    end)

    local api = {}
    function api:Set(v) box.Text = v end
    function api:Get() return box.Text end
    return api
end

-- ── Keybind ───────────────────────────────────────────────────────────────────
function Comp.Keybind(parent, label, default, cb)
    local key       = default or Enum.KeyCode.Unknown
    local listening = false

    local function keyName(k)
        if k == Enum.KeyCode.Unknown then return "NONE" end
        return k.Name
    end

    local row, kbF = makeRow(parent, label, 0.42)
    local stroke   = U.Stroke(kbF, T.InputBorder)

    local kbLbl = U.New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = keyName(key), TextColor3 = T.TextDim, TextSize = FS, Font = FONT,
        Parent = kbF,
    })

    local hit = U.Hit(kbF)
    hit.MouseButton1Click:Connect(function()
        if listening then return end
        listening  = true
        kbLbl.Text = "..."
        U.Tw(stroke, { Color = T.InputFocus })
        U.Tw(kbLbl,  { TextColor3 = T.Text  })
        U.Tw(kbF,    { BackgroundColor3 = T.BtnHover })
    end)
    hit.MouseEnter:Connect(function()
        if not listening then U.Tw(kbF, { BackgroundColor3 = T.BtnHover }) end
    end)
    hit.MouseLeave:Connect(function()
        if not listening then U.Tw(kbF, { BackgroundColor3 = T.InputBg  }) end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if not listening then return end
        local ut = input.UserInputType
        if ut == Enum.UserInputType.Keyboard then
            key = input.KeyCode
            kbLbl.Text = keyName(key)
        elseif ut == Enum.UserInputType.MouseButton2 then
            key = Enum.KeyCode.Unknown; kbLbl.Text = "MB2"
        elseif ut == Enum.UserInputType.MouseButton3 then
            key = Enum.KeyCode.Unknown; kbLbl.Text = "MB3"
        else return end   -- ignore other types, keep listening
        listening = false
        U.Tw(stroke, { Color = T.InputBorder })
        U.Tw(kbLbl,  { TextColor3 = T.TextDim })
        U.Tw(kbF,    { BackgroundColor3 = T.InputBg })
        if cb then cb(key) end
    end)

    local api = {}
    function api:Set(k) key = k; kbLbl.Text = keyName(k) end
    function api:Get() return key end
    return api
end

-- ── Button ────────────────────────────────────────────────────────────────────
function Comp.Button(parent, label, cb)
    local btn = U.New("TextButton", {
        Size             = UDim2.new(1, 0, 0, ROW_H + 2),
        BackgroundColor3 = T.BtnBg,
        BorderSizePixel  = 0,
        Text             = label,
        TextColor3       = T.Text,
        TextSize         = FS,
        Font             = FONT,
        Parent           = parent,
    })
    U.Stroke(btn, T.BtnBorder)
    btn.MouseEnter:Connect(function()    U.Tw(btn, { BackgroundColor3 = T.BtnHover }) end)
    btn.MouseLeave:Connect(function()    U.Tw(btn, { BackgroundColor3 = T.BtnBg    }) end)
    btn.MouseButton1Down:Connect(function()  U.Tw(btn, { BackgroundColor3 = T.BtnPress }) end)
    btn.MouseButton1Up:Connect(function()    U.Tw(btn, { BackgroundColor3 = T.BtnHover }) end)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    return btn
end

-- ── Label ─────────────────────────────────────────────────────────────────────
function Comp.Label(parent, text)
    return U.New("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 13),
        BackgroundTransparency = 1,
        Text                   = text,
        TextColor3             = T.TextDim,
        TextSize               = FS_SM,
        Font                   = FONT,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = parent,
    })
end

-- ── Separator ─────────────────────────────────────────────────────────────────
function Comp.Separator(parent)
    return U.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Sep,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
end

-- ── Color Picker ──────────────────────────────────────────────────────────────
-- Full HSV picker: SV gradient square + hue rainbow strip + live preview.
-- Renders in PM overlay so it never clips inside ScrollingFrame columns.
function Comp.ColorPicker(parent, label, default, cb)
    local color   = default or Color3.new(1, 1, 1)
    local ch, cs, cv = Color3.toHSV(color)   -- current HSV

    -- Swatch row
    local wrap = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H), BackgroundTransparency = 1, Parent = parent,
    })
    U.New("TextLabel", {
        Size = UDim2.new(0.68, -3, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = T.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    local swatchF = U.New("Frame", {
        Size = UDim2.new(0.32, 0, 0, 14), Position = UDim2.new(0.68, 0, 0.5, -7),
        BackgroundColor3 = color, BorderSizePixel = 0, Parent = wrap,
    })
    U.Stroke(swatchF, T.InputBorder)
    local swatchHit = U.Hit(swatchF)
    swatchHit.MouseEnter:Connect(function() U.Tw(swatchF, { Size = UDim2.new(0.32, 0, 0, 16) }) end)
    swatchHit.MouseLeave:Connect(function() U.Tw(swatchF, { Size = UDim2.new(0.32, 0, 0, 14) }) end)

    -- ── Picker panel ──────────────────────────────────────────────────────
    local PW  = 172
    local SV_W, SV_H = PW - 12, 110
    local HUE_H = 10
    local PREV_H = 12
    local PH  = 6 + SV_H + 5 + HUE_H + 5 + PREV_H + 6

    local panel = U.New("Frame", {
        Size = UDim2.new(0, PW, 0, PH), BackgroundColor3 = T.CpBg,
        BorderSizePixel = 0, Visible = false, ZIndex = 200,
    })
    U.Stroke(panel, T.CpBorder)

    -- SV square background (hue-colored)
    local svBg = U.New("Frame", {
        Size = UDim2.new(0, SV_W, 0, SV_H), Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = Color3.fromHSV(ch, 1, 1),
        BorderSizePixel = 0, ZIndex = 201, Parent = panel,
    })
    U.Stroke(svBg, T.CpBorder)

    -- White left→right gradient (saturation)
    local svWhite = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 202, Parent = svBg,
    })
    U.New("UIGradient", {
        Color     = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(255,255,255)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = svWhite,
    })

    -- Black top→bottom gradient (value)
    local svBlack = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 203, Parent = svBg,
    })
    U.New("UIGradient", {
        Color     = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Rotation = 90,
        Parent   = svBlack,
    })

    -- SV cursor
    local svCur = U.New("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(cs, -3, 1 - cv, -3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, ZIndex = 205, Parent = svBg,
    })
    U.Stroke(svCur, Color3.new(0, 0, 0))

    -- Hue bar
    local hueY = 6 + SV_H + 5
    local hueBar = U.New("Frame", {
        Size = UDim2.new(0, SV_W, 0, HUE_H), Position = UDim2.new(0, 6, 0, hueY),
        BackgroundColor3 = Color3.new(1,0,0), BorderSizePixel = 0, ZIndex = 201, Parent = panel,
    })
    U.Stroke(hueBar, T.CpBorder)
    U.New("UIGradient", { Color = HUE_SEQ, Parent = hueBar })

    -- Hue cursor
    local hueCur = U.New("Frame", {
        Size = UDim2.new(0, 3, 1, 4), Position = UDim2.new(ch, -1, 0, -2),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 203, Parent = hueBar,
    })
    U.Stroke(hueCur, Color3.new(0, 0, 0))

    -- Preview bar
    local prevY = hueY + HUE_H + 5
    local prevBar = U.New("Frame", {
        Size = UDim2.new(0, SV_W, 0, PREV_H), Position = UDim2.new(0, 6, 0, prevY),
        BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 201, Parent = panel,
    })
    U.Stroke(prevBar, T.CpBorder)

    -- Apply helper (updates all UI from ch/cs/cv)
    local function apply()
        color = Color3.fromHSV(ch, cs, cv)
        swatchF.BackgroundColor3 = color
        prevBar.BackgroundColor3 = color
        svBg.BackgroundColor3    = Color3.fromHSV(ch, 1, 1)
        svCur.Position           = UDim2.new(cs, -3, 1 - cv, -3)
        hueCur.Position          = UDim2.new(ch, -1, 0, -2)
        if cb then cb(color) end
    end

    -- SV drag
    local svHeld = false
    local svHit = U.New("TextButton", {
        Size = UDim2.new(0, SV_W, 0, SV_H), Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1, Text = "", ZIndex = 206, Parent = panel,
    })
    svHit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            svHeld = true
            local ap = svBg.AbsolutePosition; local as = svBg.AbsoluteSize
            cs = math.clamp((i.Position.X - ap.X) / as.X, 0, 1)
            cv = 1 - math.clamp((i.Position.Y - ap.Y) / as.Y, 0, 1)
            apply()
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if svHeld and i.UserInputType == Enum.UserInputType.MouseMovement then
            local ap = svBg.AbsolutePosition; local as = svBg.AbsoluteSize
            cs = math.clamp((i.Position.X - ap.X) / as.X, 0, 1)
            cv = 1 - math.clamp((i.Position.Y - ap.Y) / as.Y, 0, 1)
            apply()
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then svHeld = false end
    end)

    -- Hue drag
    local hueHeld = false
    local hueHit = U.New("TextButton", {
        Size = UDim2.new(0, SV_W, 0, HUE_H), Position = UDim2.new(0, 6, 0, hueY),
        BackgroundTransparency = 1, Text = "", ZIndex = 206, Parent = panel,
    })
    hueHit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            hueHeld = true
            local ap = hueBar.AbsolutePosition; local aw = hueBar.AbsoluteSize.X
            ch = math.clamp((i.Position.X - ap.X) / aw, 0, 1)
            apply()
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if hueHeld and i.UserInputType == Enum.UserInputType.MouseMovement then
            local ap = hueBar.AbsolutePosition; local aw = hueBar.AbsoluteSize.X
            ch = math.clamp((i.Position.X - ap.X) / aw, 0, 1)
            apply()
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then hueHeld = false end
    end)

    -- Toggle panel on swatch click
    local pickerOpen = false
    swatchHit.MouseButton1Click:Connect(function()
        if pickerOpen then
            pickerOpen = false; PM:Close()
        else
            pickerOpen = true
            local ap = swatchF.AbsolutePosition
            local as = swatchF.AbsoluteSize
            -- Try to anchor to the right; if it would go off screen, flip left
            local screenW = workspace.CurrentCamera.ViewportSize.X
            local px = ap.X - PW + as.X
            if px < 0 then px = ap.X end
            if px + PW > screenW then px = screenW - PW - 4 end
            panel.Position = UDim2.new(0, px, 0, ap.Y + as.Y + 2)
            PM:Show(panel, function() pickerOpen = false end)
        end
    end)

    local api = {}
    function api:Set(c)
        color = c; ch, cs, cv = Color3.toHSV(c)
        swatchF.BackgroundColor3 = c
        prevBar.BackgroundColor3 = c
        svBg.BackgroundColor3    = Color3.fromHSV(ch, 1, 1)
        svCur.Position           = UDim2.new(cs, -3, 1 - cv, -3)
        hueCur.Position          = UDim2.new(ch, -1, 0, -2)
    end
    function api:Get() return color end
    return api
end

-- ════════════════════════════════════════════════════════════════════════════
-- SECTION
-- ════════════════════════════════════════════════════════════════════════════
local Section = {}
Section.__index = Section

function Section.new(parent, title)
    local self = setmetatable({}, Section)

    self.Frame = U.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.SectBg,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    U.Stroke(self.Frame, T.SectBorder)

    local hasTitle = title and #title > 0
    if hasTitle then
        local hdr = U.New("Frame", {
            Size             = UDim2.new(1, 0, 0, 17),
            BackgroundColor3 = T.SectHdrBg,
            BorderSizePixel  = 0,
            Parent           = self.Frame,
        })
        U.New("TextLabel", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                   = title,
            TextColor3             = T.SectTitle,
            TextSize               = FS_SM,
            Font                   = FONT,
            Parent                 = hdr,
        })
        -- 1px border under header
        U.New("Frame", {
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = T.SectBorder,
            BorderSizePixel  = 0,
            Parent           = hdr,
        })
    end

    local content = U.New("Frame", {
        Size          = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position      = UDim2.new(0, 0, 0, hasTitle and 17 or 0),
        BackgroundTransparency = 1,
        Parent        = self.Frame,
    })
    U.Pad(content, 6, 8, 7, 8)
    U.List(content, Enum.FillDirection.Vertical, 5)
    self._c = content
    return self
end

function Section:AddToggle(l,d,cb)           return Comp.Toggle(self._c,l,d,cb) end
function Section:AddSlider(l,mn,mx,d,cb)     return Comp.Slider(self._c,l,mn,mx,d,cb) end
function Section:AddDropdown(l,opts,d,cb)    return Comp.Dropdown(self._c,l,opts,d,cb) end
function Section:AddInput(l,ph,cb)           return Comp.Input(self._c,l,ph,cb) end
function Section:AddKeybind(l,d,cb)          return Comp.Keybind(self._c,l,d,cb) end
function Section:AddButton(l,cb)             return Comp.Button(self._c,l,cb) end
function Section:AddLabel(t)                 return Comp.Label(self._c,t) end
function Section:AddColorPicker(l,d,cb)      return Comp.ColorPicker(self._c,l,d,cb) end
function Section:AddSeparator()              return Comp.Separator(self._c) end

-- ════════════════════════════════════════════════════════════════════════════
-- TAB  (two-column scrollable)
-- ════════════════════════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab.new(name)
    local self = setmetatable({}, Tab)
    self.Name  = name

    self.Frame = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = T.ContentBg,
        BorderSizePixel = 0, Visible = false,
    })

    local function makeCol(xScale, xOff, wScale, wOff)
        local s = U.New("ScrollingFrame", {
            Size                 = UDim2.new(wScale, wOff, 1, 0),
            Position             = UDim2.new(xScale, xOff, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            ScrollBarThickness   = 2,
            ScrollBarImageColor3 = T.Scroll,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Parent               = self.Frame,
        })
        U.Pad(s, 5, 4, 5, 4)
        U.List(s, Enum.FillDirection.Vertical, 5)
        return s
    end

    self._left  = makeCol(0,   0,   0.5, -1)
    self._right = makeCol(0.5, 1,   0.5, -1)

    -- Center divider
    U.New("Frame", {
        Size             = UDim2.new(0, 1, 1, -10),
        Position         = UDim2.new(0.5, 0, 0, 5),
        BackgroundColor3 = T.Divider,
        BorderSizePixel  = 0,
        Parent           = self.Frame,
    })
    return self
end

function Tab:AddSection(title, column)
    return Section.new((column == "right") and self._right or self._left, title)
end

-- ════════════════════════════════════════════════════════════════════════════
-- WINDOW
-- ════════════════════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window.new(cfg)
    local self      = setmetatable({}, Window)
    self._tabs      = {}
    self._active    = nil
    self._visible   = true

    local title   = cfg.Title    or "AniLib"
    local size    = cfg.Size     or UDim2.new(0, 560, 0, 380)
    local pos     = cfg.Position or UDim2.new(0.5, -280, 0.5, -190)
    local menuKey = cfg.Keybind

    -- ── ScreenGui ─────────────────────────────────────────────────────────
    self._gui = U.New("ScreenGui", {
        Name           = "AniLib_" .. title,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    if not pcall(function() self._gui.Parent = CoreGui end) then
        self._gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Popup overlay (full screen, transparent)
    local overlay = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        ZIndex = 199, Parent = self._gui,
    })
    PM:Init(overlay)

    -- ── Main frame ────────────────────────────────────────────────────────
    self._main = U.New("Frame", {
        Name             = "Window",
        Size             = size,
        Position         = pos,
        BackgroundColor3 = T.WinBg,
        BorderSizePixel  = 0,
        ZIndex           = 1,
        Parent           = self._gui,
    })
    U.Stroke(self._main, T.OuterBorder)

    -- ── Title bar ─────────────────────────────────────────────────────────
    local titleBar = U.New("Frame", {
        Size             = UDim2.new(1, 0, 0, TITLE_H),
        BackgroundColor3 = T.TitleBg,
        BorderSizePixel  = 0,
        Parent           = self._main,
    })
    -- Bottom border under title bar
    U.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.OuterBorder,
        BorderSizePixel  = 0,
        Parent           = titleBar,
    })
    U.New("TextLabel", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = T.TitleText,
        TextSize               = FS,
        Font                   = FONT,
        TextXAlignment         = Enum.TextXAlignment.Center,
        Parent                 = titleBar,
    })

    -- ── Tab bar (bottom) ──────────────────────────────────────────────────
    local tabBar = U.New("Frame", {
        Size             = UDim2.new(1, 0, 0, TAB_H),
        Position         = UDim2.new(0, 0, 1, -TAB_H),
        BackgroundColor3 = T.TabBg,
        BorderSizePixel  = 0,
        Parent           = self._main,
    })
    U.Stroke(tabBar, T.TabBorder)
    -- Top border of tab bar
    U.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.TabBorder,
        BorderSizePixel  = 0,
        Parent           = tabBar,
    })
    self._tabHolder = U.New("Frame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent                 = tabBar,
    })
    U.List(self._tabHolder, Enum.FillDirection.Horizontal, 0, Enum.HorizontalAlignment.Center)

    -- ── Content area ──────────────────────────────────────────────────────
    self._contentArea = U.New("Frame", {
        Size                   = UDim2.new(1, 0, 1, -(TITLE_H + TAB_H)),
        Position               = UDim2.new(0, 0, 0, TITLE_H),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        Parent                 = self._main,
    })

    U.Drag(titleBar, self._main)

    -- ── Keybind toggle ────────────────────────────────────────────────────
    if menuKey then
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == menuKey then
                self._visible = not self._visible
                self._main.Visible = self._visible
                if not self._visible then PM:Close() end
            end
        end)
    end

    return self
end

function Window:AddTab(name)
    local tab = Tab.new(name)
    tab.Frame.Parent = self._contentArea
    table.insert(self._tabs, tab)

    local tabBtn = U.New("TextButton", {
        Size                   = UDim2.new(0, 86, 1, 0),
        BackgroundTransparency = 1,
        Text                   = name,
        TextColor3             = T.TabText,
        TextSize               = FS,
        Font                   = FONT,
        Parent                 = self._tabHolder,
    })
    -- Underline indicator
    local ul = U.New("Frame", {
        Size                   = UDim2.new(1, -16, 0, 1),
        Position               = UDim2.new(0, 8, 1, -1),
        BackgroundColor3       = T.TabUnder,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Parent                 = tabBtn,
    })
    tab._btn = tabBtn; tab._ul = ul

    tabBtn.MouseButton1Click:Connect(function() self:_select(tab) end)
    tabBtn.MouseEnter:Connect(function()
        if self._active ~= tab then U.Tw(tabBtn, { TextColor3 = T.TabTextOn }) end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self._active ~= tab then U.Tw(tabBtn, { TextColor3 = T.TabText  }) end
    end)

    if #self._tabs == 1 then self:_select(tab) end
    return tab
end

function Window:_select(tab)
    PM:Close()
    for _, t in ipairs(self._tabs) do
        t.Frame.Visible = false
        U.Tw(t._btn, { TextColor3 = T.TabText })
        U.Tw(t._ul,  { BackgroundTransparency = 1 })
    end
    tab.Frame.Visible = true
    self._active = tab
    U.Tw(tab._btn, { TextColor3 = T.TabTextOn })
    U.Tw(tab._ul,  { BackgroundTransparency = 0 })
end

function Window:SetVisible(v)
    self._visible = v
    self._main.Visible = v
    if not v then PM:Close() end
end

function Window:Destroy() self._gui:Destroy() end

-- ════════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ════════════════════════════════════════════════════════════════════════════
local Lib = {}
Lib.__index = Lib
Lib.Theme = T

function Lib:CreateWindow(cfg)
    return Window.new(cfg or {})
end

return Lib

--[[
╔══════════════════════════════════════════════════════════════╗
║                  AniLib  –  UI Library v4.0                  ║
║  Classic blocky style · Two-column tabs · Working everything ║
╚══════════════════════════════════════════════════════════════╝

API:
    local Lib = require(script.UILibrary)

    local Win = Lib:CreateWindow({
        Title   = "My Script",
        Keybind = Enum.KeyCode.RightShift,   -- toggle visibility (optional)
    })

    local Tab  = Win:AddTab("Aiming")
    local Sect = Tab:AddSection("drawings")          -- left column
    local Sect2= Tab:AddSection("camera", "right")   -- right column

    local t  = Sect:AddToggle     ("watermark",  false,      cb)
    local s  = Sect:AddSlider     ("radius",  0, 300, 100,   cb)
    local d  = Sect:AddDropdown   ("origin", {"mouse","center"}, "mouse", cb)
    local k  = Sect:AddKeybind    ("zoom key", Enum.KeyCode.Z,   cb)
    local b  =  Sect:AddButton    ("Do Thing",                   cb)
    local i  = Sect:AddInput      ("name", "placeholder",        cb)
    local cp = Sect:AddColorPicker("color", Color3.new(1,1,1),   cb)
           Sect:AddLabel          ("info text")
           Sect:AddSeparator      ()

    -- Each component returns an object with :Set() / :Get()
    t:Set(true)
    s:Set(50)
    print(d:Get())
--]]

-- ═══════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════════════════════════════
local C = {
    Win          = Color3.fromRGB(22, 22, 22),
    TitleBg      = Color3.fromRGB(15, 15, 15),
    TitleText    = Color3.fromRGB(190, 190, 190),
    Border       = Color3.fromRGB(46, 46, 46),
    SectBg       = Color3.fromRGB(28, 28, 28),
    SectHdr      = Color3.fromRGB(20, 20, 20),
    SectTitle    = Color3.fromRGB(140, 140, 140),
    Divider      = Color3.fromRGB(38, 38, 38),
    TabBg        = Color3.fromRGB(16, 16, 16),
    TabText      = Color3.fromRGB(148, 148, 148),
    TabTextOn    = Color3.fromRGB(218, 218, 218),
    TabUnder     = Color3.fromRGB(200, 200, 200),
    Text         = Color3.fromRGB(192, 192, 192),
    TextDim      = Color3.fromRGB(105, 105, 105),
    CheckOn      = Color3.fromRGB(205, 205, 205),
    CheckOff     = Color3.fromRGB(44, 44, 44),
    CheckBorder  = Color3.fromRGB(68, 68, 68),
    TrackBg      = Color3.fromRGB(38, 38, 38),
    TrackFill    = Color3.fromRGB(190, 190, 190),
    TrackBorder  = Color3.fromRGB(55, 55, 55),
    InputBg      = Color3.fromRGB(32, 32, 32),
    InputBorder  = Color3.fromRGB(52, 52, 52),
    InputFocus   = Color3.fromRGB(110, 110, 110),
    BtnBg        = Color3.fromRGB(32, 32, 32),
    BtnHover     = Color3.fromRGB(42, 42, 42),
    BtnPress     = Color3.fromRGB(50, 50, 50),
    BtnBorder    = Color3.fromRGB(54, 54, 54),
    DropBg       = Color3.fromRGB(26, 26, 26),
    DropBorder   = Color3.fromRGB(52, 52, 52),
    DropHover    = Color3.fromRGB(38, 38, 38),
    DropSel      = Color3.fromRGB(46, 46, 46),
    Sep          = Color3.fromRGB(38, 38, 38),
    ScrollBar    = Color3.fromRGB(50, 50, 50),
    -- ColorPicker panel bg
    CpBg         = Color3.fromRGB(24, 24, 24),
    CpBorder     = Color3.fromRGB(50, 50, 50),
}

local FONT   = Enum.Font.Code
local FS     = 11
local TI_STD = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local TITLE_H = 22
local TAB_H   = 24
local ITEM_H  = 17  -- dropdown row height

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════
local U = {}

function U.New(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    if props.Parent then o.Parent = props.Parent end
    return o
end

function U.Tween(obj, props, ti)
    TweenService:Create(obj, ti or TI_STD, props):Play()
end

function U.Stroke(parent, col, thick)
    return U.New("UIStroke", { Color = col or C.Border, Thickness = thick or 1, Parent = parent })
end

function U.Pad(parent, t, r, b, l)
    return U.New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0), PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0), PaddingLeft   = UDim.new(0, l or 0),
        Parent = parent,
    })
end

function U.List(parent, dir, gap, hAlign, vAlign)
    return U.New("UIListLayout", {
        FillDirection       = dir    or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, gap or 0),
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = vAlign or Enum.VerticalAlignment.Top,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = parent,
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
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then on = false end
    end)
end

-- Convert HSV to Color3
function U.HSVtoColor(h, s, v)
    return Color3.fromHSV(h, s, v)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- POPUP MANAGER
-- Dropdowns and ColorPickers share one overlay so only one is ever open.
-- ═══════════════════════════════════════════════════════════════════════════
local PM = { _overlay = nil, _open = nil, _openCb = nil }

function PM:Init(overlay) self._overlay = overlay end

function PM:Close()
    if self._open then
        self._open.Visible = false
        self._open = nil
        if self._openCb then self._openCb(); self._openCb = nil end
    end
end

function PM:Show(frame, onClose)
    if self._open and self._open ~= frame then
        self._open.Visible = false
        if self._openCb then self._openCb(); self._openCb = nil end
    end
    frame.Parent  = self._overlay
    frame.Visible = true
    self._open    = frame
    self._openCb  = onClose
end

-- Close on any LMB click (deferred so button resolves first)
UserInputService.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 and PM._open then
        task.defer(function() PM:Close() end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- COMPONENTS
-- ═══════════════════════════════════════════════════════════════════════════
local Comp = {}

-- ── Toggle ──────────────────────────────────────────────────────────────────
function Comp.Toggle(parent, label, default, cb)
    local state = (default == true)

    local row = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = parent,
    })

    local box = U.New("Frame", {
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new(0, 1, 0.5, -6),
        BackgroundColor3 = state and C.CheckOn or C.CheckOff,
        BorderSizePixel  = 0,
        Parent           = row,
    })
    U.Stroke(box, C.CheckBorder)

    local lbl = U.New("TextLabel", {
        Size = UDim2.new(1, -18, 1, 0), Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1, Text = label,
        TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })

    local btn = U.New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = row,
    })
    btn.MouseButton1Click:Connect(function()
        state = not state
        U.Tween(box, { BackgroundColor3 = state and C.CheckOn or C.CheckOff })
        if cb then cb(state) end
    end)
    btn.MouseEnter:Connect(function() U.Tween(lbl, { TextColor3 = C.TabTextOn }) end)
    btn.MouseLeave:Connect(function() U.Tween(lbl, { TextColor3 = C.Text      }) end)

    local api = {}
    function api:Set(v)
        state = v == true
        U.Tween(box, { BackgroundColor3 = state and C.CheckOn or C.CheckOff })
    end
    function api:Get() return state end
    return api
end

-- ── Slider ───────────────────────────────────────────────────────────────────
function Comp.Slider(parent, label, min, max, default, cb)
    local value = math.clamp(default or min, min, max)
    local held  = false

    local wrap = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent,
    })

    -- Label row
    local topRow = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 13), BackgroundTransparency = 1, Parent = wrap,
    })
    U.New("TextLabel", {
        Size = UDim2.new(0.72, 0, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = topRow,
    })
    local valLbl = U.New("TextLabel", {
        Size = UDim2.new(0.28, 0, 1, 0), Position = UDim2.new(0.72, 0, 0, 0),
        BackgroundTransparency = 1, Text = tostring(value),
        TextColor3 = C.TextDim, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = topRow,
    })

    -- Track
    local track = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = C.TrackBg, BorderSizePixel = 0, Parent = wrap,
    })
    U.Stroke(track, C.TrackBorder)

    local fill = U.New("Frame", {
        Size             = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
        BackgroundColor3 = C.TrackFill, BorderSizePixel = 0, Parent = track,
    })

    local function applyX(absX)
        local rx    = math.clamp((absX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        value       = math.floor(min + rx * (max - min) + 0.5)
        fill.Size   = UDim2.new(rx, 0, 1, 0)
        valLbl.Text = tostring(value)
        if cb then cb(value) end
    end

    local hit = U.New("TextButton", {
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 13),
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

    local api = {}
    function api:Set(v)
        value = math.clamp(v, min, max)
        fill.Size   = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0)
        valLbl.Text = tostring(value)
    end
    function api:Get() return value end
    return api
end

-- ── Dropdown ─────────────────────────────────────────────────────────────────
-- Uses PM overlay so it NEVER clips inside ScrollingFrame.
-- Selection is fixed: optBtn click fires before PM deferred close.
function Comp.Dropdown(parent, label, options, default, cb)
    local selected = default or (options and options[1]) or ""
    local open     = false
    local MAX_ROWS = 7

    -- Row frame (just label + button, no clipping needed here)
    local wrap = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        ClipsDescendants = false, Parent = parent,
    })

    U.New("TextLabel", {
        Size = UDim2.new(0.40, -3, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })

    local btn = U.New("Frame", {
        Size = UDim2.new(0.60, 0, 1, 0), Position = UDim2.new(0.40, 0, 0, 0),
        BackgroundColor3 = C.InputBg, BorderSizePixel = 0, Parent = wrap,
    })
    U.Stroke(btn, C.InputBorder)

    local selLbl = U.New("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1, Text = selected,
        TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
    })
    local arrow = U.New("TextLabel", {
        Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(1, -14, 0, 0),
        BackgroundTransparency = 1, Text = "v", TextColor3 = C.TextDim, TextSize = 9, Font = FONT,
        Parent = btn,
    })

    -- ── Build the dropdown list frame (lives in overlay) ──────────────────
    local dropH = math.min(#options, MAX_ROWS) * ITEM_H

    local dropFrame = U.New("Frame", {
        Size = UDim2.new(0, 100, 0, dropH),   -- width set when opened
        BackgroundColor3 = C.DropBg, BorderSizePixel = 0,
        Visible = false, ZIndex = 200,
        ClipsDescendants = true,
    })
    U.Stroke(dropFrame, C.DropBorder)

    local dropScroll = U.New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.ScrollBar,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 201, Parent = dropFrame,
    })
    U.List(dropScroll, Enum.FillDirection.Vertical, 0)

    -- Track option labels for recoloring on selection change
    local optLabels = {}

    for _, opt in ipairs(options or {}) do
        local isSel = (opt == selected)
        local optBtn = U.New("TextButton", {
            Size = UDim2.new(1, 0, 0, ITEM_H),
            BackgroundColor3 = isSel and C.DropSel or C.DropBg,
            BackgroundTransparency = isSel and 0 or 1,
            BorderSizePixel = 0,
            Text = opt, TextColor3 = isSel and C.TabTextOn or C.Text,
            TextSize = FS, Font = FONT,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 202, Parent = dropScroll,
        })
        U.Pad(optBtn, 0, 0, 0, 6)
        optLabels[opt] = optBtn

        optBtn.MouseEnter:Connect(function()
            if opt ~= selected then
                U.Tween(optBtn, { BackgroundColor3 = C.DropHover, BackgroundTransparency = 0 })
            end
        end)
        optBtn.MouseLeave:Connect(function()
            if opt ~= selected then
                U.Tween(optBtn, { BackgroundTransparency = 1 })
            end
        end)
        optBtn.MouseButton1Click:Connect(function()
            -- Deselect old
            if optLabels[selected] then
                local old = optLabels[selected]
                U.Tween(old, { BackgroundTransparency = 1, TextColor3 = C.Text })
            end
            -- Select new
            selected    = opt
            selLbl.Text = opt
            U.Tween(optBtn, { BackgroundColor3 = C.DropSel, BackgroundTransparency = 0, TextColor3 = C.TabTextOn })
            open = false
            -- Close IMMEDIATELY (not deferred) so callback fires before parent closes
            PM:Close()
            if cb then cb(selected) end
        end)
    end

    -- ── Toggle open / close ───────────────────────────────────────────────
    local toggleBtn = U.New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 2, Parent = btn,
    })
    toggleBtn.MouseButton1Click:Connect(function()
        if open then
            open = false
            PM:Close()
        else
            open = true
            -- Position relative to screen
            local ap  = btn.AbsolutePosition
            local aw  = btn.AbsoluteSize.X
            dropFrame.Size     = UDim2.new(0, aw, 0, dropH)
            dropFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + 18 + 1)
            PM:Show(dropFrame, function() open = false end)
        end
    end)

    local api = {}
    function api:Set(v)
        if optLabels[selected] then
            U.Tween(optLabels[selected], { BackgroundTransparency = 1, TextColor3 = C.Text })
        end
        selected    = v
        selLbl.Text = v
        if optLabels[v] then
            U.Tween(optLabels[v], { BackgroundColor3 = C.DropSel, BackgroundTransparency = 0, TextColor3 = C.TabTextOn })
        end
    end
    function api:Get() return selected end
    return api
end

-- ── TextInput ─────────────────────────────────────────────────────────────────
function Comp.Input(parent, label, placeholder, cb)
    local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = parent })

    U.New("TextLabel", {
        Size = UDim2.new(0.40, -3, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    local boxF = U.New("Frame", {
        Size = UDim2.new(0.60, 0, 1, 0), Position = UDim2.new(0.40, 0, 0, 0),
        BackgroundColor3 = C.InputBg, BorderSizePixel = 0, Parent = wrap,
    })
    local stroke = U.Stroke(boxF, C.InputBorder)
    local box = U.New("TextBox", {
        Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1, PlaceholderText = placeholder or "",
        PlaceholderColor3 = C.TextDim, Text = "",
        TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
        Parent = boxF,
    })
    box.Focused:Connect(function()        U.Tween(stroke, { Color = C.InputFocus  }) end)
    box.FocusLost:Connect(function(enter) U.Tween(stroke, { Color = C.InputBorder })
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

    local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = parent })
    U.New("TextLabel", {
        Size = UDim2.new(0.58, -3, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    local kbF = U.New("Frame", {
        Size = UDim2.new(0.42, 0, 1, 0), Position = UDim2.new(0.58, 0, 0, 0),
        BackgroundColor3 = C.InputBg, BorderSizePixel = 0, Parent = wrap,
    })
    local kbStroke = U.Stroke(kbF, C.InputBorder)
    local kbLbl = U.New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = key == Enum.KeyCode.Unknown and "[ NONE ]" or "[ " .. key.Name .. " ]",
        TextColor3 = C.TextDim, TextSize = FS, Font = FONT, Parent = kbF,
    })
    local kbBtn = U.New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = kbF,
    })

    kbBtn.MouseButton1Click:Connect(function()
        listening = true
        kbLbl.Text = "[ ... ]"
        U.Tween(kbStroke, { Color = C.InputFocus })
        U.Tween(kbLbl,    { TextColor3 = C.Text  })
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not listening then return end
        -- Accept keyboard keys or mouse buttons
        if input.UserInputType == Enum.UserInputType.Keyboard then
            key = input.KeyCode
            kbLbl.Text = "[ " .. key.Name .. " ]"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            kbLbl.Text = "[ MB2 ]"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            kbLbl.Text = "[ MB3 ]"
        else
            return  -- ignore other inputs, keep listening
        end
        listening = false
        U.Tween(kbStroke, { Color = C.InputBorder })
        U.Tween(kbLbl,    { TextColor3 = C.TextDim })
        if cb then cb(key) end
    end)

    local api = {}
    function api:Set(k)
        key = k
        kbLbl.Text = "[ " .. k.Name .. " ]"
    end
    function api:Get() return key end
    return api
end

-- ── Button ────────────────────────────────────────────────────────────────────
function Comp.Button(parent, label, cb)
    local btn = U.New("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = C.BtnBg, BorderSizePixel = 0,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        Parent = parent,
    })
    U.Stroke(btn, C.BtnBorder)
    btn.MouseEnter:Connect(function()    U.Tween(btn, { BackgroundColor3 = C.BtnHover }) end)
    btn.MouseLeave:Connect(function()    U.Tween(btn, { BackgroundColor3 = C.BtnBg    }) end)
    btn.MouseButton1Down:Connect(function() U.Tween(btn, { BackgroundColor3 = C.BtnPress }) end)
    btn.MouseButton1Up:Connect(function()   U.Tween(btn, { BackgroundColor3 = C.BtnHover }) end)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    return btn
end

-- ── Label ─────────────────────────────────────────────────────────────────────
function Comp.Label(parent, text)
    return U.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 13), BackgroundTransparency = 1,
        Text = text, TextColor3 = C.TextDim, TextSize = 10, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = parent,
    })
end

-- ── Separator ─────────────────────────────────────────────────────────────────
function Comp.Separator(parent)
    return U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.Sep, BorderSizePixel = 0, Parent = parent,
    })
end

-- ── ColorPicker ───────────────────────────────────────────────────────────────
-- Functional HSV picker: hue bar + SV square + hex preview.
-- Renders in PM overlay (same system as dropdowns, never clips).
function Comp.ColorPicker(parent, label, default, cb)
    local color = default or Color3.new(1, 1, 1)
    local h, s, v = Color3.toHSV(color)

    -- Swatch row
    local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = parent })
    U.New("TextLabel", {
        Size = UDim2.new(0.70, -3, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    local swatchF = U.New("Frame", {
        Size = UDim2.new(0.30, 0, 1, 0), Position = UDim2.new(0.70, 0, 0, 0),
        BackgroundColor3 = color, BorderSizePixel = 0, Parent = wrap,
    })
    U.Stroke(swatchF, C.InputBorder)

    -- Invisible button on swatch to open picker
    local swatchBtn = U.New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = swatchF,
    })

    -- ── Picker panel ──────────────────────────────────────────────────────
    local PW, PH = 170, 148   -- panel width/height

    local panel = U.New("Frame", {
        Size = UDim2.new(0, PW, 0, PH),
        BackgroundColor3 = C.CpBg, BorderSizePixel = 0,
        Visible = false, ZIndex = 200,
    })
    U.Stroke(panel, C.CpBorder)

    -- SV square (gradient faked with ImageLabel layers)
    local SV_W, SV_H = PW - 12, PH - 36
    local svFrame = U.New("Frame", {
        Size = UDim2.new(0, SV_W, 0, SV_H),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        BorderSizePixel = 0, ZIndex = 201, Parent = panel,
    })
    U.Stroke(svFrame, C.CpBorder)
    -- White gradient (left = white)
    local whiteGrad = U.New("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 202,
        Image = "rbxassetid://4155801252",  -- horizontal white→transparent gradient
        Parent = svFrame,
    })
    -- Black gradient (bottom = black)
    local blackGrad = U.New("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 203,
        Image = "rbxassetid://4155801252",
        Rotation = 90,
        Parent = svFrame,
    })
    -- SV cursor (small square indicator)
    local svCursor = U.New("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(s, -3, 1 - v, -3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, ZIndex = 204, Parent = svFrame,
    })
    U.Stroke(svCursor, Color3.new(0, 0, 0))

    -- Hue bar
    local HUE_Y = SV_H + 12
    local hueBar = U.New("ImageLabel", {
        Size = UDim2.new(0, SV_W, 0, 10),
        Position = UDim2.new(0, 6, 0, HUE_Y),
        BackgroundTransparency = 1,
        Image = "rbxassetid://4155801252",   -- placeholder; hue bar gradient below
        ZIndex = 201, Parent = panel,
    })
    -- Actual hue gradient frames
    local HUE_COLORS = {
        Color3.fromRGB(255,0,0), Color3.fromRGB(255,128,0), Color3.fromRGB(255,255,0),
        Color3.fromRGB(0,255,0), Color3.fromRGB(0,255,255), Color3.fromRGB(0,0,255),
        Color3.fromRGB(255,0,255), Color3.fromRGB(255,0,0),
    }
    local hueGradFrame = U.New("Frame", {
        Size = UDim2.new(0, SV_W, 0, 10),
        Position = UDim2.new(0, 6, 0, HUE_Y),
        BorderSizePixel = 0, ZIndex = 201, Parent = panel,
    })
    U.Stroke(hueGradFrame, C.CpBorder)
    local segs = #HUE_COLORS - 1
    for i = 1, segs do
        local segF = U.New("Frame", {
            Size = UDim2.new(1/segs, 0, 1, 0),
            Position = UDim2.new((i-1)/segs, 0, 0, 0),
            BorderSizePixel = 0, ZIndex = 202, Parent = hueGradFrame,
            BackgroundColor3 = HUE_COLORS[i],
        })
        -- Gradient between colors using UIGradient
        U.New("UIGradient", {
            Color = ColorSequence.new(HUE_COLORS[i], HUE_COLORS[i+1]),
            Parent = segF,
        })
    end

    -- Hue cursor
    local hueCursor = U.New("Frame", {
        Size = UDim2.new(0, 2, 1, 2),
        Position = UDim2.new(h, -1, 0, -1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, ZIndex = 203, Parent = hueGradFrame,
    })
    U.Stroke(hueCursor, Color3.new(0, 0, 0))

    -- Hex / preview bar
    local previewF = U.New("Frame", {
        Size = UDim2.new(0, SV_W, 0, 12),
        Position = UDim2.new(0, 6, 0, HUE_Y + 14),
        BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 201, Parent = panel,
    })
    U.Stroke(previewF, C.CpBorder)

    -- ── Helper: rebuild everything when h/s/v changes ─────────────────────
    local function apply()
        color = Color3.fromHSV(h, s, v)
        swatchF.BackgroundColor3  = color
        previewF.BackgroundColor3 = color
        svFrame.BackgroundColor3  = Color3.fromHSV(h, 1, 1)
        svCursor.Position         = UDim2.new(s, -3, 1 - v, -3)
        hueCursor.Position        = UDim2.new(h, -1, 0, -1)
        if cb then cb(color) end
    end

    -- ── SV dragging ───────────────────────────────────────────────────────
    local svHeld = false
    local svHit = U.New("TextButton", {
        Size = UDim2.new(0, SV_W, 0, SV_H), Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1, Text = "", ZIndex = 205, Parent = panel,
    })
    svHit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            svHeld = true
            local ap = svFrame.AbsolutePosition
            local as = svFrame.AbsoluteSize
            s = math.clamp((i.Position.X - ap.X) / math.max(as.X, 1), 0, 1)
            v = 1 - math.clamp((i.Position.Y - ap.Y) / math.max(as.Y, 1), 0, 1)
            apply()
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if svHeld and i.UserInputType == Enum.UserInputType.MouseMovement then
            local ap = svFrame.AbsolutePosition
            local as = svFrame.AbsoluteSize
            s = math.clamp((i.Position.X - ap.X) / math.max(as.X, 1), 0, 1)
            v = 1 - math.clamp((i.Position.Y - ap.Y) / math.max(as.Y, 1), 0, 1)
            apply()
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then svHeld = false end
    end)

    -- ── Hue dragging ──────────────────────────────────────────────────────
    local hueHeld = false
    local hueHit = U.New("TextButton", {
        Size = UDim2.new(0, SV_W, 0, 10), Position = UDim2.new(0, 6, 0, HUE_Y),
        BackgroundTransparency = 1, Text = "", ZIndex = 205, Parent = panel,
    })
    hueHit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            hueHeld = true
            local ap = hueGradFrame.AbsolutePosition
            local aw = hueGradFrame.AbsoluteSize.X
            h = math.clamp((i.Position.X - ap.X) / math.max(aw, 1), 0, 1)
            apply()
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if hueHeld and i.UserInputType == Enum.UserInputType.MouseMovement then
            local ap = hueGradFrame.AbsolutePosition
            local aw = hueGradFrame.AbsoluteSize.X
            h = math.clamp((i.Position.X - ap.X) / math.max(aw, 1), 0, 1)
            apply()
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then hueHeld = false end
    end)

    -- ── Open panel on swatch click ────────────────────────────────────────
    local pickerOpen = false
    swatchBtn.MouseButton1Click:Connect(function()
        if pickerOpen then
            pickerOpen = false
            PM:Close()
        else
            pickerOpen = true
            local ap = swatchF.AbsolutePosition
            panel.Position = UDim2.new(0, ap.X - PW + swatchF.AbsoluteSize.X, 0, ap.Y + 20)
            PM:Show(panel, function() pickerOpen = false end)
        end
    end)

    local api = {}
    function api:Set(c)
        color = c
        h, s, v = Color3.toHSV(c)
        swatchF.BackgroundColor3  = c
        previewF.BackgroundColor3 = c
        svFrame.BackgroundColor3  = Color3.fromHSV(h, 1, 1)
        svCursor.Position         = UDim2.new(s, -3, 1 - v, -3)
        hueCursor.Position        = UDim2.new(h, -1, 0, -1)
    end
    function api:Get() return color end
    return api
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION
-- ═══════════════════════════════════════════════════════════════════════════
local Section = {}
Section.__index = Section

function Section.new(parent, title)
    local self = setmetatable({}, Section)

    self.Frame = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.SectBg, BorderSizePixel = 0, Parent = parent,
    })
    U.Stroke(self.Frame, C.Border)

    local TITLE_BAR = (title and #title > 0)
    if TITLE_BAR then
        local hdr = U.New("Frame", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundColor3 = C.SectHdr, BorderSizePixel = 0, Parent = self.Frame,
        })
        U.New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = title, TextColor3 = C.SectTitle, TextSize = FS, Font = FONT, Parent = hdr,
        })
        -- Bottom separator under header
        U.New("Frame", {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = C.Border, BorderSizePixel = 0, Parent = hdr,
        })
    end

    local content = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, TITLE_BAR and 18 or 0),
        BackgroundTransparency = 1, Parent = self.Frame,
    })
    U.Pad(content, 6, 8, 7, 8)
    U.List(content, Enum.FillDirection.Vertical, 5)
    self._c = content
    return self
end

function Section:AddToggle(l, d, cb)           return Comp.Toggle(self._c, l, d, cb) end
function Section:AddSlider(l, mn, mx, d, cb)   return Comp.Slider(self._c, l, mn, mx, d, cb) end
function Section:AddDropdown(l, opts, d, cb)   return Comp.Dropdown(self._c, l, opts, d, cb) end
function Section:AddInput(l, ph, cb)           return Comp.Input(self._c, l, ph, cb) end
function Section:AddKeybind(l, d, cb)          return Comp.Keybind(self._c, l, d, cb) end
function Section:AddButton(l, cb)              return Comp.Button(self._c, l, cb) end
function Section:AddLabel(t)                   return Comp.Label(self._c, t) end
function Section:AddColorPicker(l, d, cb)      return Comp.ColorPicker(self._c, l, d, cb) end
function Section:AddSeparator()                return Comp.Separator(self._c) end

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB  (two-column scrollable layout)
-- ═══════════════════════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab.new(name)
    local self = setmetatable({}, Tab)
    self.Name  = name

    self.Frame = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
    })

    local function makeCol(xScale, xOffset, wScale, wOffset)
        local scroll = U.New("ScrollingFrame", {
            Size                = UDim2.new(wScale, wOffset, 1, 0),
            Position            = UDim2.new(xScale, xOffset, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness  = 2, ScrollBarImageColor3 = C.ScrollBar,
            CanvasSize          = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent              = self.Frame,
        })
        U.Pad(scroll, 5, 4, 5, 4)
        U.List(scroll, Enum.FillDirection.Vertical, 5)
        return scroll
    end

    -- Left: 0% → 50%-1px, Right: 50%+1px → 100%
    self._left  = makeCol(0,   0,   0.5, -1)
    self._right = makeCol(0.5, 1,   0.5, -1)

    -- Divider line
    U.New("Frame", {
        Size = UDim2.new(0, 1, 1, -10), Position = UDim2.new(0.5, 0, 0, 5),
        BackgroundColor3 = C.Divider, BorderSizePixel = 0, Parent = self.Frame,
    })

    return self
end

function Tab:AddSection(title, column)
    local col = (column == "right") and self._right or self._left
    return Section.new(col, title)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window.new(cfg)
    local self       = setmetatable({}, Window)
    self._tabs       = {}
    self._active     = nil
    self._visible    = true

    local title   = cfg.Title    or "AniLib"
    local size    = cfg.Size     or UDim2.new(0, 560, 0, 380)
    local pos     = cfg.Position or UDim2.new(0.5, -280, 0.5, -190)
    local menuKey = cfg.Keybind  -- optional Enum.KeyCode

    -- ── ScreenGui ─────────────────────────────────────────────────────────
    self._gui = U.New("ScreenGui", {
        Name = "AniLib_" .. title, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    })
    if not pcall(function() self._gui.Parent = CoreGui end) then
        self._gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ── Popup overlay (full screen transparent, ZIndex 199) ───────────────
    local overlay = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        ZIndex = 199, Parent = self._gui,
    })
    PM:Init(overlay)

    -- ── Main window ───────────────────────────────────────────────────────
    self._main = U.New("Frame", {
        Name = "Window", Size = size, Position = pos,
        BackgroundColor3 = C.Win, BorderSizePixel = 0, ZIndex = 1, Parent = self._gui,
    })
    U.Stroke(self._main, C.Border)

    -- ── Title bar (centered text, no X button) ────────────────────────────
    local titleBar = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, TITLE_H),
        BackgroundColor3 = C.TitleBg, BorderSizePixel = 0, Parent = self._main,
    })
    -- Bottom border of title bar
    U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.Border, BorderSizePixel = 0, Parent = titleBar,
    })
    U.New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = title, TextColor3 = C.TitleText, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Center,  -- CENTERED
        Parent = titleBar,
    })

    -- ── Tab bar (bottom strip, full width, tabs centered) ─────────────────
    local tabBar = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, TAB_H), Position = UDim2.new(0, 0, 1, -TAB_H),
        BackgroundColor3 = C.TabBg, BorderSizePixel = 0, Parent = self._main,
    })
    U.Stroke(tabBar, C.Border)
    -- Top border of tab bar
    U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = C.Border, BorderSizePixel = 0, Parent = tabBar,
    })
    self._tabHolder = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = tabBar,
    })
    -- Tabs are centered horizontally
    U.List(self._tabHolder, Enum.FillDirection.Horizontal, 0, Enum.HorizontalAlignment.Center)

    -- ── Content area ──────────────────────────────────────────────────────
    self._contentArea = U.New("Frame", {
        Size     = UDim2.new(1, 0, 1, -(TITLE_H + TAB_H)),
        Position = UDim2.new(0, 0, 0, TITLE_H),
        BackgroundTransparency = 1, ClipsDescendants = true,
        Parent = self._main,
    })

    -- ── Draggable by title bar ─────────────────────────────────────────────
    U.Drag(titleBar, self._main)

    -- ── Menu keybind toggle ────────────────────────────────────────────────
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
        Size = UDim2.new(0, 88, 1, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = C.TabText, TextSize = FS, Font = FONT,
        Parent = self._tabHolder,
    })
    local ul = U.New("Frame", {
        Size = UDim2.new(1, -14, 0, 1), Position = UDim2.new(0, 7, 1, -1),
        BackgroundColor3 = C.TabUnder, BackgroundTransparency = 1, BorderSizePixel = 0,
        Parent = tabBtn,
    })
    tab._btn = tabBtn; tab._ul = ul

    tabBtn.MouseButton1Click:Connect(function() self:_select(tab) end)
    tabBtn.MouseEnter:Connect(function() if self._active ~= tab then U.Tween(tabBtn, { TextColor3 = C.TabTextOn }) end end)
    tabBtn.MouseLeave:Connect(function() if self._active ~= tab then U.Tween(tabBtn, { TextColor3 = C.TabText  }) end end)

    if #self._tabs == 1 then self:_select(tab) end
    return tab
end

function Window:_select(tab)
    PM:Close()
    for _, t in ipairs(self._tabs) do
        t.Frame.Visible = false
        U.Tween(t._btn, { TextColor3 = C.TabText })
        U.Tween(t._ul,  { BackgroundTransparency = 1 })
    end
    tab.Frame.Visible = true
    self._active = tab
    U.Tween(tab._btn, { TextColor3 = C.TabTextOn })
    U.Tween(tab._ul,  { BackgroundTransparency = 0 })
end

function Window:SetVisible(v)
    self._visible = v
    self._main.Visible = v
    if not v then PM:Close() end
end

function Window:Destroy() self._gui:Destroy() end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════
local Lib = {}
Lib.__index = Lib
Lib.Colors = C

function Lib:CreateWindow(cfg)
    return Window.new(cfg or {})
end

return Lib

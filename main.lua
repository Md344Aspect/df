--[[
╔══════════════════════════════════════════════════════════╗
║           AniLib  –  Roblox UI Library v3.0              ║
║  Blocky classic style. Multi-column section grid.        ║
║  Fixed dropdowns (overlay portal, never clips).          ║
╚══════════════════════════════════════════════════════════╝

QUICK USAGE:
    local Lib  = require(script.UILibrary)
    local Win  = Lib:CreateWindow({ Title = "MyScript" })
    local Tab  = Win:AddTab("Aiming")
    local L    = Tab:AddSection("Left Section")          -- left column (default)
    local R    = Tab:AddSection("Right Section", "right") -- right column

    L:AddToggle    ("Watermark",  false,        function(v) end)
    L:AddSlider    ("Radius",     0, 300, 100,  function(v) end)
    L:AddDropdown  ("Origin",     {"mouse","center"}, "mouse", function(v) end)
    L:AddKeybind   ("Hotkey",     Enum.KeyCode.F,     function(k) end)
    L:AddButton    ("Click Me",   function() end)
    L:AddInput     ("Name",       "placeholder",      function(v) end)
    L:AddColorPicker("Color",     Color3.new(1,1,1),  function(c) end)
    L:AddLabel     ("Some info text")
    L:AddSeparator ()
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
-- THEME  (all blocky – no UICorner anywhere)
-- ═══════════════════════════════════════════════════════════════════════════
local C = {
    WindowBg      = Color3.fromRGB(22, 22, 22),
    TitleBg       = Color3.fromRGB(16, 16, 16),
    TitleText     = Color3.fromRGB(195, 195, 195),
    SectionBg     = Color3.fromRGB(30, 30, 30),
    SectionHdr    = Color3.fromRGB(24, 24, 24),
    SectionTitle  = Color3.fromRGB(148, 148, 148),
    SectionBorder = Color3.fromRGB(48, 48, 48),
    Divider       = Color3.fromRGB(40, 40, 40),
    TabBar        = Color3.fromRGB(18, 18, 18),
    TabBorder     = Color3.fromRGB(45, 45, 45),
    TabText       = Color3.fromRGB(155, 155, 155),
    TabTextOn     = Color3.fromRGB(222, 222, 222),
    TabUnderline  = Color3.fromRGB(205, 205, 205),
    Text          = Color3.fromRGB(195, 195, 195),
    TextDim       = Color3.fromRGB(110, 110, 110),
    CheckOn       = Color3.fromRGB(210, 210, 210),
    CheckOff      = Color3.fromRGB(48, 48, 48),
    CheckBorder   = Color3.fromRGB(72, 72, 72),
    SliderBg      = Color3.fromRGB(40, 40, 40),
    SliderFill    = Color3.fromRGB(195, 195, 195),
    SliderBorder  = Color3.fromRGB(58, 58, 58),
    InputBg       = Color3.fromRGB(34, 34, 34),
    InputBorder   = Color3.fromRGB(56, 56, 56),
    InputBorderOn = Color3.fromRGB(115, 115, 115),
    BtnBg         = Color3.fromRGB(34, 34, 34),
    BtnHover      = Color3.fromRGB(44, 44, 44),
    BtnBorder     = Color3.fromRGB(58, 58, 58),
    DropBg        = Color3.fromRGB(28, 28, 28),
    DropBorder    = Color3.fromRGB(55, 55, 55),
    DropHover     = Color3.fromRGB(40, 40, 40),
    DropActive    = Color3.fromRGB(48, 48, 48),
    Separator     = Color3.fromRGB(40, 40, 40),
}

local FONT      = Enum.Font.Code
local FS        = 11   -- base font size
local TI        = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════
local U = {}

function U.New(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then o[k] = v end
    end
    if props.Parent then o.Parent = props.Parent end
    return o
end

function U.Tween(obj, props) TweenService:Create(obj, TI, props):Play() end

function U.Stroke(parent, color, thick)
    return U.New("UIStroke", { Color = color or C.SectionBorder, Thickness = thick or 1, Parent = parent })
end

function U.Pad(parent, t, r, b, l)
    return U.New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0), PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0), PaddingLeft   = UDim.new(0, l or 0),
        Parent = parent,
    })
end

function U.List(parent, dir, gap, hAlign)
    return U.New("UIListLayout", {
        FillDirection       = dir   or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, gap or 0),
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = parent,
    })
end

function U.Drag(handle, frame)
    local active, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            active, ds, sp = true, i.Position, frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if active and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DROPDOWN OVERLAY MANAGER
-- All dropdowns render into a shared transparent full-screen overlay frame
-- at ZIndex 100, so they are NEVER clipped by their parent ScrollingFrame.
-- ═══════════════════════════════════════════════════════════════════════════
local DropMgr = { _overlay = nil, _open = nil }

function DropMgr:Init(overlay) self._overlay = overlay end

function DropMgr:Close()
    if self._open then
        self._open.Visible = false
        self._open = nil
    end
end

function DropMgr:Open(dropFrame, absPos, absW, itemCount)
    if self._open and self._open ~= dropFrame then
        self._open.Visible = false
    end
    local ITEM_H   = 17
    local MAX_SHOW = 7
    local h        = math.min(itemCount, MAX_SHOW) * ITEM_H

    dropFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + 18 + 1)
    dropFrame.Size     = UDim2.new(0, absW, 0, h)
    dropFrame.Parent   = self._overlay
    dropFrame.Visible  = true
    self._open = dropFrame
end

-- Close on any click outside (deferred so button's own click resolves first)
UserInputService.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 and DropMgr._open then
        task.defer(function() DropMgr:Close() end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- COMPONENTS
-- ═══════════════════════════════════════════════════════════════════════════
local Comp = {}

-- ── Toggle ──────────────────────────────────────────────────────────────────
function Comp.Toggle(parent, label, default, cb)
    local state = default == true
    local row = U.New("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = parent })

    local box = U.New("Frame", {
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new(0, 0, 0.5, -6),
        BackgroundColor3 = state and C.CheckOn or C.CheckOff,
        BorderSizePixel  = 0,
        Parent           = row,
    })
    U.Stroke(box, C.CheckBorder, 1)

    local lbl = U.New("TextLabel", {
        Size                   = UDim2.new(1, -18, 1, 0),
        Position               = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text                   = label,
        TextColor3             = C.Text,
        TextSize               = FS,
        Font                   = FONT,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = row,
    })

    local btn = U.New("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = row })
    btn.MouseButton1Click:Connect(function()
        state = not state
        U.Tween(box, { BackgroundColor3 = state and C.CheckOn or C.CheckOff })
        if cb then cb(state) end
    end)
    btn.MouseEnter:Connect(function() U.Tween(lbl, { TextColor3 = C.TabTextOn }) end)
    btn.MouseLeave:Connect(function() U.Tween(lbl, { TextColor3 = C.Text     }) end)

    local api = {}
    function api:Set(v) state = v; U.Tween(box, { BackgroundColor3 = state and C.CheckOn or C.CheckOff }) end
    function api:Get() return state end
    return api
end

-- ── Slider ───────────────────────────────────────────────────────────────────
function Comp.Slider(parent, label, min, max, default, cb)
    local value = math.clamp(default or min, min, max)
    local held  = false

    local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent })

    local topRow = U.New("Frame", { Size = UDim2.new(1, 0, 0, 13), BackgroundTransparency = 1, Parent = wrap })
    U.New("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = topRow,
    })
    local valLbl = U.New("TextLabel", {
        Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.7, 0, 0, 0), BackgroundTransparency = 1,
        Text = tostring(value), TextColor3 = C.TextDim, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = topRow,
    })

    local track = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = C.SliderBg, BorderSizePixel = 0, Parent = wrap,
    })
    U.Stroke(track, C.SliderBorder, 1)
    local fill = U.New("Frame", {
        Size             = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
        BackgroundColor3 = C.SliderFill, BorderSizePixel = 0, Parent = track,
    })

    local function setVal(absX)
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
        if i.UserInputType == Enum.UserInputType.MouseButton1 then held = true; setVal(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if held and i.UserInputType == Enum.UserInputType.MouseMovement then setVal(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then held = false end
    end)

    local api = {}
    function api:Set(v)
        value = math.clamp(v, min, max)
        fill.Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0)
        valLbl.Text = tostring(value)
    end
    function api:Get() return value end
    return api
end

-- ── Dropdown ──────────────────────────────────────────────────────────────────
function Comp.Dropdown(parent, label, options, default, cb)
    local selected = default or (options and options[1]) or ""
    local isOpen   = false
    local ITEM_H   = 17

    local wrap = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        ClipsDescendants = false, Parent = parent,
    })

    U.New("TextLabel", {
        Size = UDim2.new(0.42, -3, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })

    local btnFrame = U.New("Frame", {
        Size = UDim2.new(0.58, 0, 1, 0), Position = UDim2.new(0.42, 0, 0, 0),
        BackgroundColor3 = C.InputBg, BorderSizePixel = 0, Parent = wrap,
    })
    U.Stroke(btnFrame, C.InputBorder, 1)

    local selLbl = U.New("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1, Text = selected,
        TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = btnFrame,
    })
    U.New("TextLabel", {   -- ▾ arrow
        Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(1, -14, 0, 0),
        BackgroundTransparency = 1, Text = "v", TextColor3 = C.TextDim, TextSize = 9, Font = FONT,
        Parent = btnFrame,
    })

    -- Build dropdown list frame (no parent yet – DropMgr assigns it)
    local dropFrame = U.New("Frame", {
        BackgroundColor3 = C.DropBg, BorderSizePixel = 0,
        Visible = false, ZIndex = 100, ClipsDescendants = true,
        Size = UDim2.new(0, 10, 0, 10), -- placeholder, DropMgr sets real size
    })
    U.Stroke(dropFrame, C.DropBorder, 1)

    local inner = U.New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.SectionBorder,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 100, Parent = dropFrame,
    })
    U.List(inner, Enum.FillDirection.Vertical, 0)

    for _, opt in ipairs(options or {}) do
        local isSel = (opt == selected)
        local optBtn = U.New("TextButton", {
            Size = UDim2.new(1, 0, 0, ITEM_H),
            BackgroundColor3 = isSel and C.DropActive or C.DropBg,
            BackgroundTransparency = isSel and 0 or 1,
            BorderSizePixel = 0,
            Text = opt, TextColor3 = C.Text, TextSize = FS, Font = FONT,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 101, Parent = inner,
        })
        U.Pad(optBtn, 0, 0, 0, 5)
        optBtn.MouseEnter:Connect(function()
            if opt ~= selected then U.Tween(optBtn, { BackgroundColor3 = C.DropHover, BackgroundTransparency = 0 }) end
        end)
        optBtn.MouseLeave:Connect(function()
            if opt ~= selected then U.Tween(optBtn, { BackgroundTransparency = 1 }) end
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected    = opt
            selLbl.Text = opt
            isOpen      = false
            DropMgr:Close()
            if cb then cb(selected) end
        end)
    end

    -- Toggle button
    local toggleBtn = U.New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 2, Parent = btnFrame,
    })
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            DropMgr:Open(dropFrame, btnFrame.AbsolutePosition, btnFrame.AbsoluteSize.X, #options)
        else
            DropMgr:Close()
        end
    end)
    -- sync local flag when manager closes externally
    dropFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not dropFrame.Visible then isOpen = false end
    end)

    local api = {}
    function api:Set(v) selected = v; selLbl.Text = v end
    function api:Get() return selected end
    return api
end

-- ── TextInput ─────────────────────────────────────────────────────────────────
function Comp.Input(parent, label, placeholder, cb)
    local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = parent })

    U.New("TextLabel", {
        Size = UDim2.new(0.42, -3, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    local boxFrame = U.New("Frame", {
        Size = UDim2.new(0.58, 0, 1, 0), Position = UDim2.new(0.42, 0, 0, 0),
        BackgroundColor3 = C.InputBg, BorderSizePixel = 0, Parent = wrap,
    })
    local stroke = U.Stroke(boxFrame, C.InputBorder, 1)
    local box = U.New("TextBox", {
        Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1, PlaceholderText = placeholder or "",
        PlaceholderColor3 = C.TextDim, Text = "",
        TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
        Parent = boxFrame,
    })
    box.Focused:Connect(function()   U.Tween(stroke, { Color = C.InputBorderOn }) end)
    box.FocusLost:Connect(function(enter)
        U.Tween(stroke, { Color = C.InputBorder })
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
        Size = UDim2.new(0.6, -3, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    local kbFrame = U.New("Frame", {
        Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundColor3 = C.InputBg, BorderSizePixel = 0, Parent = wrap,
    })
    U.Stroke(kbFrame, C.InputBorder, 1)
    local kbLbl = U.New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = key == Enum.KeyCode.Unknown and "NONE" or key.Name,
        TextColor3 = C.TextDim, TextSize = FS, Font = FONT, Parent = kbFrame,
    })
    local kbBtn = U.New("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = kbFrame })

    kbBtn.MouseButton1Click:Connect(function()
        listening   = true
        kbLbl.Text  = "..."
        U.Tween(kbLbl, { TextColor3 = C.Text })
    end)
    UserInputService.InputBegan:Connect(function(input)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            key = input.KeyCode; kbLbl.Text = key.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            kbLbl.Text = "MB2"
        else return end
        listening = false
        U.Tween(kbLbl, { TextColor3 = C.TextDim })
        if cb then cb(key) end
    end)

    local api = {}
    function api:Set(k) key = k; kbLbl.Text = k.Name end
    function api:Get() return key end
    return api
end

-- ── Button ────────────────────────────────────────────────────────────────────
function Comp.Button(parent, label, cb)
    local btn = U.New("TextButton", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = C.BtnBg, BorderSizePixel = 0,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT, Parent = parent,
    })
    U.Stroke(btn, C.BtnBorder, 1)
    btn.MouseEnter:Connect(function()  U.Tween(btn, { BackgroundColor3 = C.BtnHover }) end)
    btn.MouseLeave:Connect(function()  U.Tween(btn, { BackgroundColor3 = C.BtnBg   }) end)
    btn.MouseButton1Click:Connect(function()
        U.Tween(btn, { BackgroundColor3 = Color3.fromRGB(52, 52, 52) })
        task.delay(0.1, function() U.Tween(btn, { BackgroundColor3 = C.BtnBg }) end)
        if cb then cb() end
    end)
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

-- ── ColorPicker (swatch display) ─────────────────────────────────────────────
function Comp.ColorPicker(parent, label, default, cb)
    local color = default or Color3.new(1, 1, 1)
    local wrap = U.New("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = parent })
    U.New("TextLabel", {
        Size = UDim2.new(0.72, -3, 1, 0), BackgroundTransparency = 1,
        Text = label, TextColor3 = C.Text, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = wrap,
    })
    local swatch = U.New("Frame", {
        Size = UDim2.new(0.28, 0, 0, 14), Position = UDim2.new(0.72, 0, 0.5, -7),
        BackgroundColor3 = color, BorderSizePixel = 0, Parent = wrap,
    })
    U.Stroke(swatch, C.InputBorder, 1)
    local api = {}
    function api:Set(c) color = c; swatch.BackgroundColor3 = c end
    function api:Get() return color end
    return api
end

-- ── Separator ─────────────────────────────────────────────────────────────────
function Comp.Separator(parent)
    return U.New("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.Separator, BorderSizePixel = 0, Parent = parent })
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
        BackgroundColor3 = C.SectionBg, BorderSizePixel = 0, Parent = parent,
    })
    U.Stroke(self.Frame, C.SectionBorder, 1)

    -- Title header bar
    if title and #title > 0 then
        local hdr = U.New("Frame", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundColor3 = C.SectionHdr, BorderSizePixel = 0, Parent = self.Frame,
        })
        U.New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = title, TextColor3 = C.SectionTitle, TextSize = FS, Font = FONT, Parent = hdr,
        })
        U.New("Frame", {   -- bottom border of header
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = C.SectionBorder, BorderSizePixel = 0, Parent = hdr,
        })
    end

    local TITLE_H = (title and #title > 0) and 18 or 0
    local content = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, TITLE_H),
        BackgroundTransparency = 1, Parent = self.Frame,
    })
    U.Pad(content, 5, 7, 6, 7)
    U.List(content, Enum.FillDirection.Vertical, 5)
    self._c = content
    return self
end

function Section:AddToggle    (label, def, cb)       return Comp.Toggle(self._c, label, def, cb) end
function Section:AddSlider    (label, mn, mx, def, cb) return Comp.Slider(self._c, label, mn, mx, def, cb) end
function Section:AddDropdown  (label, opts, def, cb) return Comp.Dropdown(self._c, label, opts, def, cb) end
function Section:AddInput     (label, ph, cb)        return Comp.Input(self._c, label, ph, cb) end
function Section:AddKeybind   (label, def, cb)       return Comp.Keybind(self._c, label, def, cb) end
function Section:AddButton    (label, cb)            return Comp.Button(self._c, label, cb) end
function Section:AddLabel     (text)                 return Comp.Label(self._c, text) end
function Section:AddColorPicker(label, def, cb)      return Comp.ColorPicker(self._c, label, def, cb) end
function Section:AddSeparator ()                     return Comp.Separator(self._c) end

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB  –  two-column layout
-- ═══════════════════════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab.new(name)
    local self = setmetatable({}, Tab)
    self.Name  = name

    self.Frame = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
    })

    local function makeCol(xPos, xSize)
        local scroll = U.New("ScrollingFrame", {
            Size = UDim2.new(xSize, 0, 1, 0), Position = UDim2.new(xPos, 0, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = C.SectionBorder,
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = self.Frame,
        })
        U.Pad(scroll, 5, 4, 5, 4)
        U.List(scroll, Enum.FillDirection.Vertical, 5)
        return scroll
    end

    -- left column 0 → 0.5, right 0.5 → 1.0 with 2px gap each side
    self._left  = makeCol(0,    0.5)
    self._right = makeCol(0.5,  0.5)

    -- Center divider
    U.New("Frame", {
        Size = UDim2.new(0, 1, 1, -10), Position = UDim2.new(0.5, 0, 0, 5),
        BackgroundColor3 = C.Divider, BorderSizePixel = 0, Parent = self.Frame,
    })

    return self
end

-- column: "left" (default) or "right"
function Tab:AddSection(title, column)
    local col = (column == "right") and self._right or self._left
    return Section.new(col, title)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

local TAB_H   = 26
local TITLE_H = 24

function Window.new(cfg)
    local self    = setmetatable({}, Window)
    self._tabs    = {}
    self._active  = nil

    local title = cfg.Title    or "AniLib"
    local size  = cfg.Size     or UDim2.new(0, 580, 0, 400)
    local pos   = cfg.Position or UDim2.new(0.5, -290, 0.5, -200)

    -- ScreenGui
    self._gui = U.New("ScreenGui", {
        Name = "AniLib_" .. title, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    })
    if not pcall(function() self._gui.Parent = CoreGui end) then
        self._gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Full-screen overlay for dropdown portals (transparent, input passthrough)
    local overlay = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 99,
        Parent = self._gui,
    })
    DropMgr:Init(overlay)

    -- Main window
    self._main = U.New("Frame", {
        Name = "Window", Size = size, Position = pos,
        BackgroundColor3 = C.WindowBg, BorderSizePixel = 0, ZIndex = 1,
        Parent = self._gui,
    })
    U.Stroke(self._main, C.SectionBorder, 1)

    -- Title bar
    local titleBar = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, TITLE_H), BackgroundColor3 = C.TitleBg, BorderSizePixel = 0, Parent = self._main,
    })
    U.Stroke(titleBar, C.SectionBorder, 1)
    U.New("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Text = title,
        TextColor3 = C.TitleText, TextSize = FS, Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar,
    })
    local closeBtn = U.New("TextButton", {
        Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -24, 0, 0),
        BackgroundTransparency = 1, Text = "×", TextColor3 = C.TextDim, TextSize = 16, Font = FONT,
        Parent = titleBar,
    })
    closeBtn.MouseEnter:Connect(function()  U.Tween(closeBtn, { TextColor3 = Color3.fromRGB(255, 65, 65) }) end)
    closeBtn.MouseLeave:Connect(function()  U.Tween(closeBtn, { TextColor3 = C.TextDim }) end)
    closeBtn.MouseButton1Click:Connect(function() self._gui:Destroy() end)

    -- Content area (between title bar and tab bar)
    self._contentArea = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, -(TITLE_H + TAB_H)),
        Position = UDim2.new(0, 0, 0, TITLE_H),
        BackgroundTransparency = 1, ClipsDescendants = true,
        Parent = self._main,
    })

    -- Tab bar (bottom)
    self._tabBar = U.New("Frame", {
        Size = UDim2.new(1, 0, 0, TAB_H), Position = UDim2.new(0, 0, 1, -TAB_H),
        BackgroundColor3 = C.TabBar, BorderSizePixel = 0, Parent = self._main,
    })
    U.Stroke(self._tabBar, C.TabBorder, 1)
    U.New("Frame", {   -- top border line
        Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.TabBorder, BorderSizePixel = 0, Parent = self._tabBar,
    })
    self._tabHolder = U.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = self._tabBar,
    })
    U.List(self._tabHolder, Enum.FillDirection.Horizontal, 0, Enum.HorizontalAlignment.Center)

    U.Drag(titleBar, self._main)
    return self
end

function Window:AddTab(name)
    local tab = Tab.new(name)
    tab.Frame.Parent = self._contentArea
    table.insert(self._tabs, tab)

    local tabBtn = U.New("TextButton", {
        Size = UDim2.new(0, 90, 1, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = C.TabText, TextSize = FS, Font = FONT,
        Parent = self._tabHolder,
    })
    local ul = U.New("Frame", {
        Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 1, -1),
        BackgroundColor3 = C.TabUnderline, BackgroundTransparency = 1, BorderSizePixel = 0,
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
    DropMgr:Close()
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

function Window:Destroy() self._gui:Destroy() end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════
local Lib = {}
Lib.__index = Lib
Lib.Colors  = C

function Lib:CreateWindow(config)
    return Window.new(config or {})
end

return Lib

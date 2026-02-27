--[[
    AniLib - Professional Roblox UI Library
    Dark theme with tabbed navigation, sections, and interactive components.
    
    Usage Example:
    
    local UILib = loadstring(game:HttpGet("..."))()  -- or require(script.UILib)
    
    local Window = UILib:CreateWindow({
        Title = "My Script",
        Size = UDim2.new(0, 620, 0, 440),
    })
    
    local Tab = Window:AddTab("Aiming")
    local Section = Tab:AddSection("Drawings")
    Section:AddToggle("Watermark", false, function(val) print(val) end)
    Section:AddSlider("Radius", 0, 200, 100, function(val) print(val) end)
    Section:AddDropdown("Origin", {"mouse", "center", "crosshair"}, "mouse", function(val) print(val) end)
    Section:AddKeybind("Zoom Keybind", Enum.KeyCode.F, function(key) print(key) end)
--]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ─── Services ───────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ─── Constants ──────────────────────────────────────────────────────────────
local COLORS = {
    Background      = Color3.fromRGB(20, 20, 20),
    Surface         = Color3.fromRGB(28, 28, 28),
    SectionBg       = Color3.fromRGB(32, 32, 32),
    Border          = Color3.fromRGB(50, 50, 50),
    BorderLight     = Color3.fromRGB(60, 60, 60),
    TabBar          = Color3.fromRGB(22, 22, 22),
    TabActive       = Color3.fromRGB(28, 28, 28),
    TabInactive     = Color3.fromRGB(22, 22, 22),
    TabText         = Color3.fromRGB(180, 180, 180),
    TabTextActive   = Color3.fromRGB(230, 230, 230),
    TabUnderline    = Color3.fromRGB(255, 255, 255),
    Text            = Color3.fromRGB(200, 200, 200),
    TextDim         = Color3.fromRGB(130, 130, 130),
    TextLabel       = Color3.fromRGB(160, 160, 160),
    ToggleOn        = Color3.fromRGB(255, 255, 255),
    ToggleOff       = Color3.fromRGB(55, 55, 55),
    SliderFill      = Color3.fromRGB(255, 255, 255),
    SliderBg        = Color3.fromRGB(45, 45, 45),
    InputBg         = Color3.fromRGB(38, 38, 38),
    InputBorder     = Color3.fromRGB(60, 60, 60),
    TitleBar        = Color3.fromRGB(18, 18, 18),
    TitleText       = Color3.fromRGB(200, 200, 200),
    SectionTitle    = Color3.fromRGB(150, 150, 150),
    PreviewBg       = Color3.fromRGB(15, 15, 15),
}

local FONTS = {
    Regular = Enum.Font.Code,
    Bold    = Enum.Font.Code,
    Mono    = Enum.Font.Code,
}

local TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ─── Utility ────────────────────────────────────────────────────────────────
local Util = {}

function Util.Tween(instance, properties)
    TweenService:Create(instance, TWEEN_INFO, properties):Play()
end

function Util.Create(class, properties, children)
    local obj = Instance.new(class)
    for k, v in pairs(properties or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

function Util.AddCorner(parent, radius)
    return Util.Create("UICorner", { CornerRadius = UDim.new(0, radius or 3), Parent = parent })
end

function Util.AddPadding(parent, top, right, bottom, left)
    return Util.Create("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 6),
        PaddingRight  = UDim.new(0, right  or 6),
        PaddingBottom = UDim.new(0, bottom or 6),
        PaddingLeft   = UDim.new(0, left   or 6),
        Parent        = parent
    })
end

function Util.AddStroke(parent, color, thickness)
    return Util.Create("UIStroke", {
        Color     = color or COLORS.Border,
        Thickness = thickness or 1,
        Parent    = parent
    })
end

function Util.AddListLayout(parent, direction, padding, hAlign)
    return Util.Create("UIListLayout", {
        FillDirection       = direction or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, padding or 4),
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = parent
    })
end

function Util.MakeDraggable(handle, frame)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ─── Component Builders ─────────────────────────────────────────────────────
local Component = {}

-- Toggle
function Component.Toggle(parent, label, default, callback)
    local state = default or false
    local row = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent          = parent,
    })
    local box = Util.Create("Frame", {
        Size            = UDim2.new(0, 14, 0, 14),
        Position        = UDim2.new(0, 0, 0.5, -7),
        BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff,
        Parent          = row,
    })
    Util.AddCorner(box, 2)
    Util.AddStroke(box, COLORS.Border, 1)

    local lbl = Util.Create("TextLabel", {
        Size            = UDim2.new(1, -20, 1, 0),
        Position        = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text            = label,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Regular,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = row,
    })

    local btn = Util.Create("TextButton", {
        Size               = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text               = "",
        Parent             = row,
    })

    btn.MouseButton1Click:Connect(function()
        state = not state
        Util.Tween(box, { BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff })
        if callback then callback(state) end
    end)

    btn.MouseEnter:Connect(function()
        Util.Tween(lbl, { TextColor3 = COLORS.TabTextActive })
    end)
    btn.MouseLeave:Connect(function()
        Util.Tween(lbl, { TextColor3 = COLORS.Text })
    end)

    return {
        Set = function(val)
            state = val
            Util.Tween(box, { BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff })
        end,
        Get = function() return state end,
    }
end

-- Slider
function Component.Slider(parent, label, min, max, default, callback)
    local value = math.clamp(default or min, min, max)
    local dragging = false

    local container = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent          = parent,
    })

    local labelRow = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Parent          = container,
    })
    local lbl = Util.Create("TextLabel", {
        Size            = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = label,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Regular,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = labelRow,
    })
    local valueLbl = Util.Create("TextLabel", {
        Size            = UDim2.new(0.5, 0, 1, 0),
        Position        = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text            = tostring(value),
        TextColor3      = COLORS.TextDim,
        TextSize        = 11,
        Font            = FONTS.Mono,
        TextXAlignment  = Enum.TextXAlignment.Right,
        Parent          = labelRow,
    })

    local track = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 6),
        Position        = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = COLORS.SliderBg,
        Parent          = container,
    })
    Util.AddCorner(track, 3)

    local fill = Util.Create("Frame", {
        Size            = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = COLORS.SliderFill,
        Parent          = track,
    })
    Util.AddCorner(fill, 3)

    local function updateValue(absX)
        local trackAbs = track.AbsolutePosition.X
        local trackW   = track.AbsoluteSize.X
        local ratio    = math.clamp((absX - trackAbs) / trackW, 0, 1)
        value = math.floor(min + ratio * (max - min) + 0.5)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valueLbl.Text = tostring(value)
        if callback then callback(value) end
    end

    local inputCapture = Util.Create("TextButton", {
        Size               = UDim2.new(1, 0, 1, 0),
        Position           = UDim2.new(0, 0, 0, 14),
        BackgroundTransparency = 1,
        Text               = "",
        Parent             = container,
    })

    inputCapture.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {
        Set = function(val)
            value = math.clamp(val, min, max)
            local ratio = (value - min) / (max - min)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            valueLbl.Text = tostring(value)
        end,
        Get = function() return value end,
    }
end

-- Dropdown
function Component.Dropdown(parent, label, options, default, callback)
    local selected = default or (options[1] or "")
    local open = false

    local container = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent          = parent,
    })

    local row = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent          = container,
    })

    local lbl = Util.Create("TextLabel", {
        Size            = UDim2.new(0.45, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = label,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Regular,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = row,
    })

    local btn = Util.Create("TextButton", {
        Size            = UDim2.new(0.55, 0, 1, 0),
        Position        = UDim2.new(0.45, 0, 0, 0),
        BackgroundColor3 = COLORS.InputBg,
        Text            = selected,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Regular,
        Parent          = row,
    })
    Util.AddCorner(btn, 2)
    Util.AddStroke(btn, COLORS.InputBorder)

    local dropdownFrame = Util.Create("Frame", {
        Size            = UDim2.new(0.55, 0, 0, 0),
        Position        = UDim2.new(0.45, 0, 1, 2),
        BackgroundColor3 = COLORS.SectionBg,
        ZIndex          = 10,
        ClipsDescendants = true,
        Visible         = false,
        Parent          = container,
    })
    Util.AddCorner(dropdownFrame, 3)
    Util.AddStroke(dropdownFrame, COLORS.Border)

    local listLayout = Util.AddListLayout(dropdownFrame, Enum.FillDirection.Vertical, 0)

    for _, option in ipairs(options) do
        local optBtn = Util.Create("TextButton", {
            Size            = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text            = option,
            TextColor3      = COLORS.Text,
            TextSize        = 11,
            Font            = FONTS.Regular,
            ZIndex          = 11,
            Parent          = dropdownFrame,
        })
        optBtn.MouseEnter:Connect(function()
            Util.Tween(optBtn, { BackgroundTransparency = 0, BackgroundColor3 = COLORS.Border })
        end)
        optBtn.MouseLeave:Connect(function()
            Util.Tween(optBtn, { BackgroundTransparency = 1 })
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected = option
            btn.Text = option
            open = false
            Util.Tween(dropdownFrame, { Size = UDim2.new(0.55, 0, 0, 0) })
            task.delay(0.15, function() dropdownFrame.Visible = false end)
            if callback then callback(selected) end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            dropdownFrame.Visible = true
            local targetH = math.min(#options * 18, 120)
            Util.Tween(dropdownFrame, { Size = UDim2.new(0.55, 0, 0, targetH) })
            container.Size = UDim2.new(1, 0, 0, 20 + targetH + 4)
        else
            Util.Tween(dropdownFrame, { Size = UDim2.new(0.55, 0, 0, 0) })
            task.delay(0.15, function()
                dropdownFrame.Visible = false
                container.Size = UDim2.new(1, 0, 0, 20)
            end)
        end
    end)

    return {
        Set = function(val) selected = val; btn.Text = val end,
        Get = function() return selected end,
    }
end

-- TextInput
function Component.TextInput(parent, label, placeholder, callback)
    local container = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent          = parent,
    })
    local lbl = Util.Create("TextLabel", {
        Size            = UDim2.new(0.45, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = label,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Regular,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = container,
    })
    local box = Util.Create("TextBox", {
        Size            = UDim2.new(0.55, 0, 1, 0),
        Position        = UDim2.new(0.45, 0, 0, 0),
        BackgroundColor3 = COLORS.InputBg,
        Text            = "",
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = COLORS.TextDim,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Regular,
        ClearTextOnFocus = false,
        Parent          = container,
    })
    Util.AddCorner(box, 2)
    Util.AddStroke(box, COLORS.InputBorder)
    Util.Create("UIPadding", { PaddingLeft = UDim.new(0, 5), Parent = box })

    box.FocusLost:Connect(function(enter)
        if callback then callback(box.Text, enter) end
    end)
    box.Focused:Connect(function()
        Util.Tween(box, { BackgroundColor3 = Color3.fromRGB(42, 42, 42) })
    end)
    box.FocusLost:Connect(function()
        Util.Tween(box, { BackgroundColor3 = COLORS.InputBg })
    end)

    return {
        Set = function(val) box.Text = val end,
        Get = function() return box.Text end,
    }
end

-- Keybind
function Component.Keybind(parent, label, default, callback)
    local key = default or Enum.KeyCode.Unknown
    local listening = false

    local container = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent          = parent,
    })
    local lbl = Util.Create("TextLabel", {
        Size            = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = label,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Regular,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = container,
    })
    local btn = Util.Create("TextButton", {
        Size            = UDim2.new(0.4, 0, 1, 0),
        Position        = UDim2.new(0.6, 0, 0, 0),
        BackgroundColor3 = COLORS.InputBg,
        Text            = key.Name,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Mono,
        Parent          = container,
    })
    Util.AddCorner(btn, 2)
    Util.AddStroke(btn, COLORS.InputBorder)

    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "..."
        btn.TextColor3 = COLORS.TextDim
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                btn.Text = key.Name
                btn.TextColor3 = COLORS.Text
                listening = false
                if callback then callback(key) end
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                key = Enum.KeyCode.Unknown
                btn.Text = "MB2"
                btn.TextColor3 = COLORS.Text
                listening = false
                if callback then callback(key) end
            end
        end
    end)

    return {
        Set = function(k) key = k; btn.Text = k.Name end,
        Get = function() return key end,
    }
end

-- Button
function Component.Button(parent, label, callback)
    local btn = Util.Create("TextButton", {
        Size            = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = COLORS.InputBg,
        Text            = label,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Regular,
        Parent          = parent,
    })
    Util.AddCorner(btn, 3)
    Util.AddStroke(btn, COLORS.Border)

    btn.MouseEnter:Connect(function()
        Util.Tween(btn, { BackgroundColor3 = Color3.fromRGB(48, 48, 48) })
    end)
    btn.MouseLeave:Connect(function()
        Util.Tween(btn, { BackgroundColor3 = COLORS.InputBg })
    end)
    btn.MouseButton1Click:Connect(function()
        Util.Tween(btn, { BackgroundColor3 = Color3.fromRGB(58, 58, 58) })
        task.delay(0.1, function()
            Util.Tween(btn, { BackgroundColor3 = COLORS.InputBg })
        end)
        if callback then callback() end
    end)

    return btn
end

-- Label / Separator
function Component.Label(parent, text)
    return Util.Create("TextLabel", {
        Size            = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text            = text,
        TextColor3      = COLORS.TextDim,
        TextSize        = 10,
        Font            = FONTS.Regular,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = parent,
    })
end

-- ColorPicker (basic)
function Component.ColorPicker(parent, label, default, callback)
    local color = default or Color3.fromRGB(255, 255, 255)
    local container = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent          = parent,
    })
    local lbl = Util.Create("TextLabel", {
        Size            = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = label,
        TextColor3      = COLORS.Text,
        TextSize        = 11,
        Font            = FONTS.Regular,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = container,
    })
    local swatch = Util.Create("Frame", {
        Size            = UDim2.new(0, 30, 0, 14),
        Position        = UDim2.new(1, -30, 0.5, -7),
        BackgroundColor3 = color,
        Parent          = container,
    })
    Util.AddCorner(swatch, 2)
    Util.AddStroke(swatch, COLORS.Border)

    return {
        Set = function(c) color = c; swatch.BackgroundColor3 = c end,
        Get = function() return color end,
    }
end

-- ─── Section ────────────────────────────────────────────────────────────────
local Section = {}
Section.__index = Section

function Section.new(parent, title)
    local self = setmetatable({}, Section)

    self.Frame = Util.Create("Frame", {
        Size            = UDim2.new(1, -10, 0, 0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundColor3 = COLORS.SectionBg,
        Parent          = parent,
    })
    Util.AddCorner(self.Frame, 4)
    Util.AddStroke(self.Frame, COLORS.Border)

    local inner = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 1, 0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent          = self.Frame,
    })
    Util.AddPadding(inner, 8, 10, 8, 10)
    self._layout = Util.AddListLayout(inner, Enum.FillDirection.Vertical, 6)
    self._inner = inner

    if title and title ~= "" then
        local titleLbl = Util.Create("TextLabel", {
            Size            = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text            = title,
            TextColor3      = COLORS.SectionTitle,
            TextSize        = 10,
            Font            = FONTS.Regular,
            TextXAlignment  = Enum.TextXAlignment.Center,
            LayoutOrder     = -1,
            Parent          = inner,
        })
        -- Subtle separator line
        local sep = Util.Create("Frame", {
            Size            = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = COLORS.Border,
            BorderSizePixel = 0,
            LayoutOrder     = 0,
            Parent          = inner,
        })
    end

    return self
end

function Section:AddToggle(label, default, callback)
    return Component.Toggle(self._inner, label, default, callback)
end

function Section:AddSlider(label, min, max, default, callback)
    return Component.Slider(self._inner, label, min, max, default, callback)
end

function Section:AddDropdown(label, options, default, callback)
    return Component.Dropdown(self._inner, label, options, default, callback)
end

function Section:AddTextInput(label, placeholder, callback)
    return Component.TextInput(self._inner, label, placeholder, callback)
end

function Section:AddKeybind(label, default, callback)
    return Component.Keybind(self._inner, label, default, callback)
end

function Section:AddButton(label, callback)
    return Component.Button(self._inner, label, callback)
end

function Section:AddLabel(text)
    return Component.Label(self._inner, text)
end

function Section:AddColorPicker(label, default, callback)
    return Component.ColorPicker(self._inner, label, default, callback)
end

-- ─── Tab ────────────────────────────────────────────────────────────────────
local Tab = {}
Tab.__index = Tab

function Tab.new(name)
    local self = setmetatable({}, Tab)
    self.Name = name

    -- Content scroll frame
    self.ContentFrame = Util.Create("ScrollingFrame", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = COLORS.Border,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize      = UDim2.new(0, 0, 0, 0),
        Visible         = false,
    })
    Util.AddPadding(self.ContentFrame, 8, 5, 8, 5)
    Util.AddListLayout(self.ContentFrame, Enum.FillDirection.Vertical, 6)

    return self
end

function Tab:AddSection(title)
    return Section.new(self.ContentFrame, title)
end

-- ─── Window ─────────────────────────────────────────────────────────────────
local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    self._tabs      = {}
    self._activeTab = nil

    local title    = config.Title    or "UILibrary"
    local size     = config.Size     or UDim2.new(0, 620, 0, 440)
    local position = config.Position or UDim2.new(0.5, -310, 0.5, -220)

    -- ScreenGui
    self._gui = Util.Create("ScreenGui", {
        Name             = "UILibrary_" .. title,
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset   = true,
    })

    -- Try to parent to CoreGui (executor), fallback to PlayerGui
    local ok, err = pcall(function()
        self._gui.Parent = CoreGui
    end)
    if not ok then
        self._gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main frame
    self._main = Util.Create("Frame", {
        Name             = "MainFrame",
        Size             = size,
        Position         = position,
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel  = 0,
        Parent           = self._gui,
    })
    Util.AddCorner(self._main, 5)
    Util.AddStroke(self._main, COLORS.Border)

    -- Title bar
    local titleBar = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = COLORS.TitleBar,
        BorderSizePixel = 0,
        Parent          = self._main,
    })
    Util.AddCorner(titleBar, 5)
    -- Mask bottom corners of title bar
    Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 10),
        Position        = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = COLORS.TitleBar,
        BorderSizePixel = 0,
        Parent          = titleBar,
    })

    Util.Create("TextLabel", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = title,
        TextColor3      = COLORS.TitleText,
        TextSize        = 11,
        Font            = FONTS.Regular,
        Parent          = titleBar,
    })

    -- Close button
    local closeBtn = Util.Create("TextButton", {
        Size            = UDim2.new(0, 28, 0, 28),
        Position        = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Text            = "×",
        TextColor3      = COLORS.TextDim,
        TextSize        = 18,
        Font            = FONTS.Regular,
        Parent          = titleBar,
    })
    closeBtn.MouseButton1Click:Connect(function()
        self._gui:Destroy()
    end)
    closeBtn.MouseEnter:Connect(function()
        Util.Tween(closeBtn, { TextColor3 = Color3.fromRGB(255, 80, 80) })
    end)
    closeBtn.MouseLeave:Connect(function()
        Util.Tween(closeBtn, { TextColor3 = COLORS.TextDim })
    end)

    -- Body (below title bar)
    local body = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 1, -28),
        Position        = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent          = self._main,
    })

    -- Tab bar at bottom
    self._tabBar = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 30),
        Position        = UDim2.new(0, 0, 1, -30),
        BackgroundColor3 = COLORS.TabBar,
        BorderSizePixel = 0,
        Parent          = body,
    })
    Util.AddStroke(self._tabBar, COLORS.Border)
    -- separator line on top of tab bar
    Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0,
        Parent          = self._tabBar,
    })

    self._tabButtonContainer = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent          = self._tabBar,
    })
    Util.AddListLayout(self._tabButtonContainer, Enum.FillDirection.Horizontal, 0, Enum.HorizontalAlignment.Center)

    -- Content area
    self._contentArea = Util.Create("Frame", {
        Size            = UDim2.new(1, 0, 1, -30),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent          = body,
    })

    -- Make draggable by title bar
    Util.MakeDraggable(titleBar, self._main)

    return self
end

function Window:AddTab(name)
    local tab = Tab.new(name)
    tab.ContentFrame.Parent = self._contentArea
    table.insert(self._tabs, tab)

    -- Tab button
    local tabCount   = #self._tabs
    local btnWidth   = math.max(80, math.floor(self._main.AbsoluteSize.X / math.max(tabCount, 1)))

    local tabBtn = Util.Create("TextButton", {
        Size            = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 1,
        Text            = name,
        TextColor3      = COLORS.TabText,
        TextSize        = 11,
        Font            = FONTS.Regular,
        Parent          = self._tabButtonContainer,
    })

    -- Underline indicator
    local underline = Util.Create("Frame", {
        Size            = UDim2.new(1, -20, 0, 1),
        Position        = UDim2.new(0, 10, 1, -1),
        BackgroundColor3 = COLORS.TabUnderline,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent          = tabBtn,
    })

    tab._tabBtn     = tabBtn
    tab._underline  = underline

    tabBtn.MouseButton1Click:Connect(function()
        self:_selectTab(tab)
    end)

    tabBtn.MouseEnter:Connect(function()
        if self._activeTab ~= tab then
            Util.Tween(tabBtn, { TextColor3 = COLORS.TabTextActive })
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self._activeTab ~= tab then
            Util.Tween(tabBtn, { TextColor3 = COLORS.TabText })
        end
    end)

    -- Auto-select first tab
    if #self._tabs == 1 then
        self:_selectTab(tab)
    end

    return tab
end

function Window:_selectTab(tab)
    -- Deselect all
    for _, t in ipairs(self._tabs) do
        t.ContentFrame.Visible = false
        Util.Tween(t._tabBtn,    { TextColor3 = COLORS.TabText })
        Util.Tween(t._underline, { BackgroundTransparency = 1 })
    end
    -- Select target
    tab.ContentFrame.Visible = true
    self._activeTab = tab
    Util.Tween(tab._tabBtn,    { TextColor3 = COLORS.TabTextActive })
    Util.Tween(tab._underline, { BackgroundTransparency = 0 })
end

function Window:Destroy()
    self._gui:Destroy()
end

-- ─── Public API ─────────────────────────────────────────────────────────────
function UILibrary:CreateWindow(config)
    return Window.new(config)
end

-- Convenience: expose component builders for advanced use
UILibrary.Component = Component
UILibrary.Colors    = COLORS

return UILibrary

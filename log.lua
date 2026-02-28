--[[
    ╔══════════════════════════════════════════════╗
    ║        Novoline Key System Framework         ║
    ║        Powered by Junkie SDK                 ║
    ║        Version 2.0                           ║
    ╚══════════════════════════════════════════════╝

    SETUP:
    ──────
    1. Fill in your Junkie credentials below (Service, Identifier, Provider).
    2. Fill in your actual Junkie script URL in ScriptURL.
    3. Optionally set DiscordLink for the "Get Key" button.
    4. Host this file and loadstring it — done.
]]

-- ══════════════════════════════════════════════
--  CONFIGURATION  ← edit this section only
-- ══════════════════════════════════════════════

local Config = {

    -- ── GUI labels ──────────────────────────────
    Title    = "N",
    Subtitle = "ovoline",

    -- ── Junkie SDK credentials ──────────────────
    JunkieService    = "novoline",   -- your service name on jnkie.com
    JunkieIdentifier = "1039196",          -- your identifier
    JunkieProvider   = "novoline",          -- key provider ("Mixed", "Linkvertise", etc.)

    -- ── Your actual script to run after auth ────
    ScriptURL = "https://api.jnkie.com/api/v1/luascripts/public/5902f7965d5f765b3e260878aca470bb160335208330ec7d94d9cc45adc42c36/download",

    -- ── Key saving between sessions ─────────────
    SaveKey      = true,
    SaveFileName = "novoline_key.txt",

    -- ── "Get Key" button ────────────────────────
    DiscordLink = "https://discord.gg/Nd87T78Wr9",
}

-- ══════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════

local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")

local function tw(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    local ti  = TweenInfo.new(t, style, dir)
    local tw_ = TweenService:Create(obj, ti, props)
    tw_:Play()
    return tw_
end

-- ══════════════════════════════════════════════
--  JUNKIE SDK LOADER
-- ══════════════════════════════════════════════

local Junkie
local junkieLoaded = false

local function loadJunkie()
    if junkieLoaded then return true end
    local ok, result = pcall(function()
        Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
        Junkie.service    = Config.JunkieService
        Junkie.identifier = Config.JunkieIdentifier
        Junkie.provider   = Config.JunkieProvider
    end)
    if ok then
        junkieLoaded = true
        return true
    else
        warn("[Novoline] Failed to load Junkie SDK: " .. tostring(result))
        return false
    end
end

-- ══════════════════════════════════════════════
--  KEY SAVE / LOAD  (executor writefile)
-- ══════════════════════════════════════════════

local function saveKey(key)
    if not Config.SaveKey then return end
    pcall(function() writefile(Config.SaveFileName, key) end)
end

local function loadSavedKey()
    if not Config.SaveKey then return nil end
    local ok, data = pcall(function() return readfile(Config.SaveFileName) end)
    if ok and data and data ~= "" then
        return data:match("^%s*(.-)%s*$")
    end
    return nil
end

-- ══════════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════════

local function buildGui()

    pcall(function()
        local old = CoreGui:FindFirstChild("__index")
        if old then old:Destroy() end
    end)

    -- Root
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "__index"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent         = CoreGui

    -- Dim overlay
    local Overlay = Instance.new("Frame")
    Overlay.Size                   = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel        = 0
    Overlay.ZIndex                 = 1
    Overlay.Parent                 = ScreenGui

    -- Main container
    local MainCont = Instance.new("Frame")
    MainCont.Name                   = "__mainCont"
    MainCont.Size                   = UDim2.new(0, 530, 0, 300)
    MainCont.Position               = UDim2.new(0.5, -265, 0.5, -170)
    MainCont.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    MainCont.BorderSizePixel        = 0
    MainCont.ZIndex                 = 2
    MainCont.BackgroundTransparency = 1
    MainCont.Parent                 = ScreenGui

    -- Drop shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size                   = UDim2.new(1, 40, 1, 40)
    Shadow.Position               = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image                  = "rbxassetid://6014261993"
    Shadow.ImageColor3            = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency      = 0.5
    Shadow.ScaleType              = Enum.ScaleType.Slice
    Shadow.SliceCenter            = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex                 = 1
    Shadow.Parent                 = MainCont

    -- Inner frame
    local Cont = Instance.new("Frame")
    Cont.Name             = "Cont__"
    Cont.Size             = UDim2.new(0, 520, 0, 290)
    Cont.Position         = UDim2.new(0, 5, 0, 5)
    Cont.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    Cont.BorderColor3     = Color3.fromRGB(59, 59, 59)
    Cont.BorderSizePixel  = 1
    Cont.ZIndex           = 2
    Cont.Parent           = MainCont

    -- Top accent line
    local AccentLine = Instance.new("Frame")
    AccentLine.Size             = UDim2.new(1, 0, 0, 2)
    AccentLine.Position         = UDim2.new(0, 0, 0, 0)
    AccentLine.BackgroundColor3 = Color3.fromRGB(91, 173, 236)
    AccentLine.BorderSizePixel  = 0
    AccentLine.ZIndex           = 3
    AccentLine.Parent           = Cont

    -- Logo N
    local N = Instance.new("TextLabel")
    N.Font                   = Enum.Font.GothamBold
    N.Text                   = Config.Title
    N.TextColor3             = Color3.fromRGB(91, 173, 236)
    N.TextScaled             = true
    N.BackgroundTransparency = 1
    N.BorderSizePixel        = 0
    N.Position               = UDim2.new(0, 0, 0.679, 0)
    N.Size                   = UDim2.new(0, 79, 0, 93)
    N.ZIndex                 = 3
    N.Parent                 = Cont

    -- Logo ovoline
    local Ovoline = Instance.new("TextLabel")
    Ovoline.Font                   = Enum.Font.Gotham
    Ovoline.Text                   = Config.Subtitle
    Ovoline.TextColor3             = Color3.fromRGB(200, 200, 200)
    Ovoline.TextScaled             = true
    Ovoline.BackgroundTransparency = 1
    Ovoline.BorderSizePixel        = 0
    Ovoline.Position               = UDim2.new(0.121, 0, 0.858, 0)
    Ovoline.Size                   = UDim2.new(0, 77, 0, 32)
    Ovoline.ZIndex                 = 3
    Ovoline.Parent                 = Cont

    -- Status label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Font                   = Enum.Font.Gotham
    StatusLabel.Text                   = "enter your key to continue"
    StatusLabel.TextColor3             = Color3.fromRGB(120, 120, 120)
    StatusLabel.TextSize               = 12
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.BorderSizePixel        = 0
    StatusLabel.Position               = UDim2.new(0.251, 0, 0.08, 0)
    StatusLabel.Size                   = UDim2.new(0, 255, 0, 30)
    StatusLabel.ZIndex                 = 3
    StatusLabel.Parent                 = Cont

    -- Key input
    local KeyInput = Instance.new("TextBox")
    KeyInput.Font              = Enum.Font.Gotham
    KeyInput.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    KeyInput.PlaceholderText   = "Enter key..."
    KeyInput.Text              = ""
    KeyInput.TextColor3        = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize          = 13
    KeyInput.TextWrapped       = false
    KeyInput.ClearTextOnFocus  = false
    KeyInput.BackgroundColor3  = Color3.fromRGB(14, 14, 14)
    KeyInput.BorderColor3      = Color3.fromRGB(59, 59, 59)
    KeyInput.BorderSizePixel   = 1
    KeyInput.Position          = UDim2.new(0.251, 0, 0.172, 0)
    KeyInput.Size              = UDim2.new(0, 255, 0, 50)
    KeyInput.ZIndex            = 3
    KeyInput.Parent            = Cont

    local InputPad = Instance.new("UIPadding")
    InputPad.PaddingLeft = UDim.new(0, 10)
    InputPad.Parent      = KeyInput

    -- Load button
    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Font             = Enum.Font.GothamBold
    LoadBtn.Text             = "Load"
    LoadBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    LoadBtn.TextSize         = 13
    LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    LoadBtn.BorderColor3     = Color3.fromRGB(59, 59, 59)
    LoadBtn.BorderSizePixel  = 1
    LoadBtn.Position         = UDim2.new(0.376, 0, 0.413, 0)
    LoadBtn.Size             = UDim2.new(0, 127, 0, 50)
    LoadBtn.ZIndex           = 3
    LoadBtn.AutoButtonColor  = false
    LoadBtn.Parent           = Cont

    -- Get Key button — calls Junkie.get_key_link() and copies it
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Font                   = Enum.Font.Gotham
    GetKeyBtn.Text                   = "Get Key  →"
    GetKeyBtn.TextColor3             = Color3.fromRGB(91, 173, 236)
    GetKeyBtn.TextSize               = 12
    GetKeyBtn.BackgroundTransparency = 1
    GetKeyBtn.BorderSizePixel        = 0
    GetKeyBtn.Position               = UDim2.new(0.376, 0, 0.68, 0)
    GetKeyBtn.Size                   = UDim2.new(0, 127, 0, 25)
    GetKeyBtn.ZIndex                 = 3
    GetKeyBtn.Parent                 = Cont

    -- ══════════════════════════════════════════
    --  INTRO ANIMATION
    -- ══════════════════════════════════════════

    tw(Overlay,  { BackgroundTransparency = 0.55 }, 0.4)
    tw(MainCont, { BackgroundTransparency = 0, Position = UDim2.new(0.5, -265, 0.5, -150) }, 0.45,
        Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    -- ══════════════════════════════════════════
    --  HELPERS
    -- ══════════════════════════════════════════

    local function setStatus(msg, color)
        StatusLabel.Text       = msg
        StatusLabel.TextColor3 = color or Color3.fromRGB(120, 120, 120)
    end

    local function setAccent(r, g, b)
        tw(AccentLine, { BackgroundColor3 = Color3.fromRGB(r, g, b) }, 0.25)
    end

    local function shakeFrame()
        local offsets = {8, -8, 6, -6, 4, -4, 0}
        for _, ox in ipairs(offsets) do
            tw(MainCont, { Position = UDim2.new(0.5, -265 + ox, 0.5, -150) }, 0.04)
            task.wait(0.04)
        end
        MainCont.Position = UDim2.new(0.5, -265, 0.5, -150)
    end

    local function closeSuccess()
        tw(Overlay,  { BackgroundTransparency = 1 }, 0.4)
        tw(MainCont, { Position = UDim2.new(0.5, -265, 0.5, -120), BackgroundTransparency = 1 }, 0.4,
            Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.45)
        ScreenGui:Destroy()
    end

    -- ══════════════════════════════════════════
    --  HOVER FX
    -- ══════════════════════════════════════════

    LoadBtn.MouseEnter:Connect(function()
        tw(LoadBtn, { BackgroundColor3 = Color3.fromRGB(20, 20, 20) }, 0.15)
        tw(LoadBtn, { BorderColor3     = Color3.fromRGB(91, 173, 236) }, 0.15)
    end)
    LoadBtn.MouseLeave:Connect(function()
        tw(LoadBtn, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) }, 0.15)
        tw(LoadBtn, { BorderColor3     = Color3.fromRGB(59, 59, 59) }, 0.15)
    end)
    KeyInput.Focused:Connect(function()
        tw(KeyInput, { BorderColor3 = Color3.fromRGB(91, 173, 236) }, 0.15)
    end)
    KeyInput.FocusLost:Connect(function()
        tw(KeyInput, { BorderColor3 = Color3.fromRGB(59, 59, 59) }, 0.15)
    end)

    -- ══════════════════════════════════════════
    --  GET KEY BUTTON → Junkie.get_key_link()
    -- ══════════════════════════════════════════

    GetKeyBtn.MouseButton1Click:Connect(function()
        GetKeyBtn.Text = "loading..."

        task.spawn(function()
            if not loadJunkie() then
                GetKeyBtn.Text = "Get Key  →"
                setStatus("✗  failed to reach Junkie", Color3.fromRGB(236, 91, 91))
                return
            end

            local link = Junkie.get_key_link()

            if link then
                pcall(function() setclipboard(link) end)
                GetKeyBtn.Text = "Link Copied!"
                setStatus("link copied — complete it, then paste key here", Color3.fromRGB(91, 173, 236))
                task.wait(3)
                GetKeyBtn.Text = "Get Key  →"
                setStatus("enter your key to continue")
            else
                -- Junkie returns nil when cooldown is active
                GetKeyBtn.Text = "Get Key  →"
                setStatus("⚠  wait 5 minutes before getting a new link", Color3.fromRGB(236, 160, 91))
                task.wait(3)
                setStatus("enter your key to continue")
            end
        end)
    end)

    -- ══════════════════════════════════════════
    --  LOAD BUTTON → Junkie.check_key()
    -- ══════════════════════════════════════════

    local function checkKey()
        local input = KeyInput.Text:match("^%s*(.-)%s*$")

        if input == "" then
            setStatus("⚠  key cannot be empty", Color3.fromRGB(236, 160, 91))
            return
        end

        -- Lock UI while checking
        LoadBtn.Text   = "..."
        LoadBtn.Active = false
        setStatus("validating key...", Color3.fromRGB(150, 150, 150))

        task.spawn(function()

            -- Ensure Junkie is loaded
            if not loadJunkie() then
                LoadBtn.Text   = "Load"
                LoadBtn.Active = true
                setStatus("✗  failed to reach Junkie", Color3.fromRGB(236, 91, 91))
                shakeFrame()
                return
            end

            -- Validate with Junkie
            local ok, validation = pcall(function()
                return Junkie.check_key(input)
            end)

            if ok and validation and validation.valid then
                -- ✅ Valid
                saveKey(input)
                getgenv().SCRIPT_KEY = input   -- store globally for the Junkie script

                setStatus("✓  key accepted", Color3.fromRGB(91, 200, 120))
                setAccent(91, 200, 120)
                LoadBtn.Text = "✓"

                task.wait(0.8)
                closeSuccess()

                -- Fire the actual script
                task.spawn(function()
                    local scriptOk, scriptErr = pcall(function()
                        loadstring(game:HttpGet(Config.ScriptURL))()
                    end)
                    if not scriptOk then
                        warn("[Novoline] Script load error: " .. tostring(scriptErr))
                    end
                end)

            else
                -- ❌ Invalid — pull error message from Junkie if available
                local errMsg = "invalid key"
                if ok and validation and validation.error then
                    errMsg = validation.error
                elseif not ok then
                    errMsg = "connection error"
                end

                LoadBtn.Text   = "Load"
                LoadBtn.Active = true
                setStatus("✗  " .. errMsg, Color3.fromRGB(236, 91, 91))
                setAccent(236, 91, 91)
                shakeFrame()

                task.wait(1.5)
                setAccent(91, 173, 236)
                setStatus("enter your key to continue")
            end
        end)
    end

    LoadBtn.MouseButton1Click:Connect(checkKey)
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then checkKey() end
    end)

    -- ══════════════════════════════════════════
    --  AUTO-FILL SAVED KEY
    -- ══════════════════════════════════════════

    task.spawn(function()
        local saved = loadSavedKey()
        if saved then
            KeyInput.Text = saved
            setStatus("saved key loaded — press Load", Color3.fromRGB(91, 173, 236))
        end
    end)
end

-- ══════════════════════════════════════════════
--  BOOT
-- ══════════════════════════════════════════════

task.spawn(loadJunkie)  -- pre-load SDK in background
buildGui()

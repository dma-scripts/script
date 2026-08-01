--[[
    ================================================================
    DESERTSTORM [EXTRACTION] — SANDSTORM PRIVATE SUITE v1.0 (FIXED)
    ================================================================
    PlaceId: 115872975504419
    Fixes applied:
    - Restored missing `Config.World.ExtractionTracker` state.
    - Added missing Extraction Tracker UI Toggle in World tab.
    - Purged trailing illegal syntax string breaking parsers.
    - Ensured safe nil checks on Character & RootPart indexing.
    ================================================================
]]
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════════════════════════
local Config = {
    UIVisible = true,
    Aimbot = {
        Enabled = false,
        TargetPart = "Head",
        FOV = 160,
        Smoothness = 0.12,
        ShowFOV = false,
        TeamCheck = true,
        WallCheck = false,
        TargetBots = true
    },
    ESP = {
        Enabled = false,
        Players = true,
        Bots = true,
        Containers = true,
        DeadBodies = true,
        Extractions = true,
        QuestItems = false,
        KeyLocations = true,
        MaxDistance = 2000,
        ShowBoxes = true,
        ShowHealth = true,
        ShowNames = true,
        ShowSkeleton = true,
        ShowHeadDot = true,
        ShowWeapon = true,
        ShowArmor = true,
        ShowDistance = true,
        ColorPlayer = Color3.fromRGB(255, 45, 85),
        ColorPlayerOccluded = Color3.fromRGB(255, 255, 255),
        ColorBot = Color3.fromRGB(255, 160, 30),
        ColorContainer = Color3.fromRGB(80, 220, 255),
        ColorDeadBody = Color3.fromRGB(180, 120, 255),
        ColorExtraction = Color3.fromRGB(50, 255, 120),
        ColorQuestItem = Color3.fromRGB(255, 215, 0),
        ColorKeyLocation = Color3.fromRGB(142, 186, 228)
    },
    World = {
        Fullbright = false,
        ExtractionTracker = true
    }
}
local ScriptAlive = true

-- ══════════════════════════════════════════════════════════════
-- ORIGINAL LIGHTING CACHE
-- ══════════════════════════════════════════════════════════════
local OriginalLighting = {}
pcall(function()
    OriginalLighting.Ambient = Lighting.Ambient
    OriginalLighting.Brightness = Lighting.Brightness
    OriginalLighting.FogEnd = Lighting.FogEnd
    OriginalLighting.FogStart = Lighting.FogStart
    OriginalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
    OriginalLighting.ClockTime = Lighting.ClockTime
end)

-- ══════════════════════════════════════════════════════════════
-- SCREEN GUI + GRAPHITE UI
-- ══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Sandstorm_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

local Theme = {
    Background = Color3.fromRGB(16, 17, 21),
    Surface = Color3.fromRGB(24, 26, 32),
    SurfaceHover = Color3.fromRGB(31, 34, 42),
    SurfaceActive = Color3.fromRGB(40, 44, 53),
    Border = Color3.fromRGB(59, 63, 74),
    Text = Color3.fromRGB(238, 240, 244),
    Muted = Color3.fromRGB(151, 156, 168),
    Accent = Color3.fromRGB(151, 163, 184),
    AccentBright = Color3.fromRGB(208, 213, 224),
    Good = Color3.fromRGB(112, 196, 150)
}

local function Round(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function Stroke(parent, color, transparency, thickness)
    local border = Instance.new("UIStroke")
    border.Color = color or Theme.Border
    border.Transparency = transparency or 0
    border.Thickness = thickness or 1
    border.Parent = parent
    return border
end

local function Tween(object, properties, duration, style, direction)
    return TweenService:Create(
        object,
        TweenInfo.new(duration or 0.18, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        properties
    )
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(790, 520)
MainFrame.Position = UDim2.new(0.5, -395, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Round(MainFrame, 12)
Stroke(MainFrame, Theme.Border, 0.12, 1)

local WindowScale = Instance.new("UIScale")
WindowScale.Name = "WindowScale"
WindowScale.Scale = 1
WindowScale.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 54)
Header.BackgroundColor3 = Theme.Surface
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = Theme.Border
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local Brand = Instance.new("TextLabel")
Brand.Size = UDim2.fromOffset(230, 28)
Brand.Position = UDim2.fromOffset(20, 9)
Brand.BackgroundTransparency = 1
Brand.RichText = true
Brand.Text = "SANDSTORM <font color=\"#d0d5e0\">PREMIUM</font>"
Brand.TextColor3 = Theme.Text
Brand.Font = Enum.Font.GothamBold
Brand.TextSize = 16
Brand.TextXAlignment = Enum.TextXAlignment.Left
Brand.Parent = Header

local SubBrand = Instance.new("TextLabel")
SubBrand.Size = UDim2.fromOffset(320, 16)
SubBrand.Position = UDim2.fromOffset(20, 32)
SubBrand.BackgroundTransparency = 1
SubBrand.Text = "Extraction toolkit  •  INSERT / DELETE to toggle"
SubBrand.TextColor3 = Theme.Muted
SubBrand.Font = Enum.Font.Gotham
SubBrand.TextSize = 10
SubBrand.TextXAlignment = Enum.TextXAlignment.Left
SubBrand.Parent = Header

local HeaderStatus = Instance.new("TextLabel")
HeaderStatus.Size = UDim2.fromOffset(210, 22)
HeaderStatus.Position = UDim2.new(1, -230, 0, 16)
HeaderStatus.BackgroundTransparency = 1
HeaderStatus.Text = "READY"
HeaderStatus.TextColor3 = Theme.Good
HeaderStatus.Font = Enum.Font.GothamMedium
HeaderStatus.TextSize = 11
HeaderStatus.TextXAlignment = Enum.TextXAlignment.Right
HeaderStatus.Parent = Header

local function SetStatus(text, good)
    HeaderStatus.Text = text
    HeaderStatus.TextColor3 = good == false and Color3.fromRGB(218, 128, 128) or Theme.Good
end

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 174, 1, -54)
Sidebar.Position = UDim2.fromOffset(0, 54)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = Theme.Border
SidebarLine.BackgroundTransparency = 0.3
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

local NavLabel = Instance.new("TextLabel")
NavLabel.Size = UDim2.new(1, -28, 0, 18)
NavLabel.Position = UDim2.fromOffset(14, 16)
NavLabel.BackgroundTransparency = 1
NavLabel.Text = "NAVIGATION"
NavLabel.TextColor3 = Theme.Muted
NavLabel.Font = Enum.Font.GothamBold
NavLabel.TextSize = 9
NavLabel.TextXAlignment = Enum.TextXAlignment.Left
NavLabel.Parent = Sidebar

local NavList = Instance.new("Frame")
NavList.Size = UDim2.new(1, -24, 0, 258)
NavList.Position = UDim2.fromOffset(12, 42)
NavList.BackgroundTransparency = 1
NavList.Parent = Sidebar
local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 6)
NavLayout.Parent = NavList

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -28, 0, 34)
Footer.Position = UDim2.new(0, 14, 1, -48)
Footer.BackgroundTransparency = 1
Footer.Text = "v2.0  •  LOCAL SESSION"
Footer.TextColor3 = Theme.Muted
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 9
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.Parent = Sidebar

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -198, 1, -78)
PageContainer.Position = UDim2.fromOffset(186, 66)
PageContainer.BackgroundTransparency = 1
PageContainer.ClipsDescendants = true
PageContainer.Parent = MainFrame

local Pages = {}
local CurrentPage
local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.fromOffset(0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = PageContainer
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.Parent = page
    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 7)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = page
    Pages[name] = page
    return page
end

local CombatPage = CreatePage("Combat")
local VisualsPage = CreatePage("Visuals")
local WorldPage = CreatePage("World")
local QuestPage = CreatePage("Quests")
local ConfigPage = CreatePage("Configs")
local IntelPage = CreatePage("Intel")

local function SwitchPage(name)
    local target = Pages[name]
    if not target or target == CurrentPage then return end
    local outgoing = CurrentPage
    CurrentPage = target
    if outgoing then
        local outTween = Tween(outgoing, {Position = UDim2.fromOffset(-18, 0)}, 0.14)
        outTween:Play()
        outTween.Completed:Once(function()
            outgoing.Visible = false
            outgoing.Position = UDim2.fromOffset(0, 0)
        end)
    end
    target.Position = UDim2.fromOffset(18, 0)
    target.Visible = true
    Tween(target, {Position = UDim2.fromOffset(0, 0)}, 0.2, Enum.EasingStyle.Quart):Play()
end

local activeTab
local function CreateTab(label, pageName)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = Theme.Surface
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = label
    button.TextColor3 = Theme.Muted
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = NavList
    Round(button, 7)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 16)
    indicator.Position = UDim2.new(0, 7, 0.5, -8)
    indicator.BackgroundColor3 = Theme.AccentBright
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    Round(indicator, 2)

    local function selectTab()
        if activeTab and activeTab ~= button then
            local oldIndicator = activeTab:FindFirstChild("Indicator")
            Tween(activeTab, {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted}, 0.16):Play()
            if oldIndicator then Tween(oldIndicator, {BackgroundTransparency = 1}, 0.16):Play() end
        end
        activeTab = button
        Tween(button, {BackgroundColor3 = Theme.SurfaceActive, TextColor3 = Theme.Text}, 0.16):Play()
        Tween(indicator, {BackgroundTransparency = 0}, 0.16):Play()
        SwitchPage(pageName)
    end

    button.MouseEnter:Connect(function()
        if button ~= activeTab then Tween(button, {BackgroundColor3 = Theme.SurfaceHover, TextColor3 = Theme.Text}, 0.12):Play() end
    end)
    button.MouseLeave:Connect(function()
        if button ~= activeTab then Tween(button, {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Muted}, 0.16):Play() end
    end)
    button.MouseButton1Click:Connect(selectTab)
    indicator.Name = "Indicator"

    if not activeTab then selectTab() end
    return button
end

CreateTab("  Combat", "Combat")
CreateTab("  Visuals", "Visuals")
CreateTab("  World", "World")
CreateTab("  Quests", "Quests")
CreateTab("  Configs", "Configs")
CreateTab("  Intel", "Intel")

local function CreateCard(parent, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.BackgroundColor3 = Theme.Surface
    card.BorderSizePixel = 0
    card.Parent = parent
    Round(card, 8)
    local outline = Stroke(card, Theme.Border, 0.45, 1)
    card.MouseEnter:Connect(function()
        Tween(card, {BackgroundColor3 = Theme.SurfaceHover}, 0.14):Play()
        Tween(outline, {Transparency = 0.18}, 0.14):Play()
    end)
    card.MouseLeave:Connect(function()
        Tween(card, {BackgroundColor3 = Theme.Surface}, 0.16):Play()
        Tween(outline, {Transparency = 0.45}, 0.16):Play()
    end)
    return card
end

local function AddSectionLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text:upper()
    label.TextColor3 = Theme.AccentBright
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
end

local function AddToggle(parent, text, default, callback)
    local card = CreateCard(parent, 46)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -86, 1, 0)
    label.Position = UDim2.fromOffset(14, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card

    local state = default == true
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(38, 20)
    toggle.Position = UDim2.new(1, -52, 0.5, -10)
    toggle.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 59, 69)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = ""
    toggle.Parent = card
    Round(toggle, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    Round(knob, 7)

    toggle.MouseButton1Click:Connect(function()
        state = not state
        Tween(toggle, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55, 59, 69)}, 0.14):Play()
        Tween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.18, Enum.EasingStyle.Back):Play()
        callback(state)
    end)
    return card
end

local function AddSlider(parent, text, minimum, maximum, default, callback)
    local card = CreateCard(parent, 54)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -72, 0, 22)
    label.Position = UDim2.fromOffset(14, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.fromOffset(56, 22)
    valueLabel.Position = UDim2.new(1, -68, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.AccentBright
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 11
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = card

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -28, 0, 5)
    track.Position = UDim2.fromOffset(14, 37)
    track.BackgroundColor3 = Color3.fromRGB(54, 58, 68)
    track.BorderSizePixel = 0
    track.AutoButtonColor = false
    track.Text = ""
    track.Parent = card
    Round(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - minimum) / (maximum - minimum), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Round(fill, 3)

    local dragging = false
    local function setFromInput(input)
        local fraction = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(minimum + ((maximum - minimum) * fraction))
        fill.Size = UDim2.new(fraction, 0, 1, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; setFromInput(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then setFromInput(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    return card
end

local function AddButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Theme.SurfaceActive
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = text
    button.TextColor3 = Theme.Text
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.Parent = parent
    Round(button, 8)
    local outline = Stroke(button, Theme.Border, 0.25, 1)
    button.MouseEnter:Connect(function()
        Tween(button, {BackgroundColor3 = Color3.fromRGB(52, 57, 68)}, 0.13):Play()
        Tween(outline, {Color = Theme.Accent, Transparency = 0.05}, 0.13):Play()
    end)
    button.MouseLeave:Connect(function()
        Tween(button, {BackgroundColor3 = Theme.SurfaceActive}, 0.16):Play()
        Tween(outline, {Color = Theme.Border, Transparency = 0.25}, 0.16):Play()
    end)
    button.MouseButton1Click:Connect(callback)
    return button
end

local function AddInfoLine(parent, text, color)
    local card = CreateCard(parent, 34)
    card.BackgroundColor3 = Color3.fromRGB(21, 23, 29)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Theme.Muted
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card
    return card
end

local fpsFrames, fpsValue = 0, 0
local FpsConnection = RunService.RenderStepped:Connect(function()
    if ScriptAlive then fpsFrames += 1 end
end)
task.spawn(function()
    while task.wait(1) do
        fpsValue = fpsFrames
        fpsFrames = 0
        if string.sub(HeaderStatus.Text, 1, 5) == "READY" then
            HeaderStatus.Text = "READY  •  " .. fpsValue .. " FPS"
        end
    end
end)

-- POPULATE TABS
AddSectionLabel(CombatPage, "Aim assistance")
AddToggle(CombatPage, "Enable aim assist", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
AddToggle(CombatPage, "Show FOV radius", Config.Aimbot.ShowFOV, function(v) Config.Aimbot.ShowFOV = v end)
AddToggle(CombatPage, "Include AI targets", Config.Aimbot.TargetBots, function(v) Config.Aimbot.TargetBots = v end)
AddToggle(CombatPage, "Require line of sight", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end)
AddSlider(CombatPage, "FOV radius", 50, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
AddSlider(CombatPage, "Aim smoothing", 5, 50, math.floor(Config.Aimbot.Smoothness * 100), function(v) Config.Aimbot.Smoothness = v / 100 end)

AddSectionLabel(VisualsPage, "Overlay")
AddToggle(VisualsPage, "Enable overlay", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
AddSlider(VisualsPage, "Maximum distance", 200, 5000, Config.ESP.MaxDistance, function(v) Config.ESP.MaxDistance = v end)
AddSectionLabel(VisualsPage, "Entity filters")
AddToggle(VisualsPage, "Players", Config.ESP.Players, function(v) Config.ESP.Players = v end)
AddToggle(VisualsPage, "AI bots", Config.ESP.Bots, function(v) Config.ESP.Bots = v end)
AddToggle(VisualsPage, "Loot containers", Config.ESP.Containers, function(v) Config.ESP.Containers = v end)
AddToggle(VisualsPage, "Lootable bodies", Config.ESP.DeadBodies, function(v) Config.ESP.DeadBodies = v end)
AddToggle(VisualsPage, "Extraction zones", Config.ESP.Extractions, function(v) Config.ESP.Extractions = v end)
AddToggle(VisualsPage, "Quest items", Config.ESP.QuestItems, function(v) Config.ESP.QuestItems = v end)
AddToggle(VisualsPage, "Keys & locked access", Config.ESP.KeyLocations, function(v) Config.ESP.KeyLocations = v end)
AddSectionLabel(VisualsPage, "Drawing")
AddToggle(VisualsPage, "Boxes", Config.ESP.ShowBoxes, function(v) Config.ESP.ShowBoxes = v end)
AddToggle(VisualsPage, "Health bars", Config.ESP.ShowHealth, function(v) Config.ESP.ShowHealth = v end)
AddToggle(VisualsPage, "Skeleton", Config.ESP.ShowSkeleton, function(v) Config.ESP.ShowSkeleton = v end)
AddToggle(VisualsPage, "Head marker", Config.ESP.ShowHeadDot, function(v) Config.ESP.ShowHeadDot = v end)
AddToggle(VisualsPage, "Weapon label", Config.ESP.ShowWeapon, function(v) Config.ESP.ShowWeapon = v end)
AddToggle(VisualsPage, "Armor indicator", Config.ESP.ShowArmor, function(v) Config.ESP.ShowArmor = v end)

AddSectionLabel(WorldPage, "Environment")
AddToggle(WorldPage, "Extraction tracker HUD", Config.World.ExtractionTracker, function(v) Config.World.ExtractionTracker = v end)
AddToggle(WorldPage, "Fullbright", Config.World.Fullbright, function(v)
    Config.World.Fullbright = v
    if v then
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 3
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    else
        pcall(function()
            Lighting.Ambient = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
            Lighting.Brightness = OriginalLighting.Brightness
            Lighting.FogEnd = OriginalLighting.FogEnd
            Lighting.FogStart = OriginalLighting.FogStart
        end)
    end
end)

local QuestList = Instance.new("Frame")
QuestList.Size = UDim2.new(1, 0, 0, 0)
QuestList.AutomaticSize = Enum.AutomaticSize.Y
QuestList.BackgroundTransparency = 1
QuestList.Parent = QuestPage
local QuestLayout = Instance.new("UIListLayout")
QuestLayout.Padding = UDim.new(0, 6)
QuestLayout.Parent = QuestList
local QuestRows = {}
local PinnedQuest = nil

local function ClearQuestRows()
    for _, row in ipairs(QuestRows) do row:Destroy() end
    QuestRows = {}
end

local function QuestSnapshot()
    local lines, entries = {"SANDSTORM QUEST SNAPSHOT"}, {}
    local folders = {Workspace:FindFirstChild("QuestItems"), ReplicatedStorage:FindFirstChild("QuestItems")}
    for _, folder in ipairs(folders) do
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                local distance = 0
                if part and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    distance = math.floor((part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                end
                table.insert(entries, {Name = item.Name, Distance = distance, Instance = item, Part = part})
            end
        end
    end
    table.sort(entries, function(a, b) return a.Distance < b.Distance end)
    for _, entry in ipairs(entries) do table.insert(lines, string.format("%s — %dm", entry.Name, entry.Distance)) end
    return lines, entries
end

local function RefreshQuestList()
    ClearQuestRows()
    local _, entries = QuestSnapshot()
    if #entries == 0 then
        table.insert(QuestRows, AddInfoLine(QuestList, "No quest items found in the known folders."))
    else
        for _, entry in ipairs(entries) do
            table.insert(QuestRows, AddButton(QuestList, string.format("Pin  •  %s  •  %dm", entry.Name, entry.Distance), function()
                PinnedQuest = {Name = entry.Name, Instance = entry.Instance}
                SetStatus("PINNED  •  " .. entry.Name, true)
            end))
        end
    end
    SetStatus(string.format("QUEST SCAN  •  %d FOUND", #entries), true)
end

AddSectionLabel(QuestPage, "Quest helper")
AddToggle(QuestPage, "Quest item overlay", Config.ESP.QuestItems, function(v) Config.ESP.QuestItems = v end)
AddButton(QuestPage, "Refresh quest scan", RefreshQuestList)
AddButton(QuestPage, "Clear pinned quest", function()
    PinnedQuest = nil
    SetStatus("PIN CLEARED", true)
end)
AddButton(QuestPage, "Copy quest snapshot", function()
    local lines = QuestSnapshot()
    if setclipboard then setclipboard(table.concat(lines, "\n")); SetStatus("QUEST SNAPSHOT COPIED", true) else SetStatus("CLIPBOARD NOT AVAILABLE", false) end
end)
AddSectionLabel(QuestPage, "Detected quest items")
RefreshQuestList()

local HttpService = game:GetService("HttpService")
local ConfigPath = "sandstorm_premium_config.json"
local function MakeConfigSnapshot()
    return {
        Aimbot = {
            Enabled = Config.Aimbot.Enabled, FOV = Config.Aimbot.FOV, Smoothness = Config.Aimbot.Smoothness,
            ShowFOV = Config.Aimbot.ShowFOV, TeamCheck = Config.Aimbot.TeamCheck, WallCheck = Config.Aimbot.WallCheck,
            TargetBots = Config.Aimbot.TargetBots
        },
        ESP = {
            Enabled = Config.ESP.Enabled, Players = Config.ESP.Players, Bots = Config.ESP.Bots, Containers = Config.ESP.Containers,
            DeadBodies = Config.ESP.DeadBodies, Extractions = Config.ESP.Extractions, QuestItems = Config.ESP.QuestItems, KeyLocations = Config.ESP.KeyLocations,
            MaxDistance = Config.ESP.MaxDistance, ShowBoxes = Config.ESP.ShowBoxes, ShowHealth = Config.ESP.ShowHealth,
            ShowNames = Config.ESP.ShowNames, ShowSkeleton = Config.ESP.ShowSkeleton, ShowHeadDot = Config.ESP.ShowHeadDot,
            ShowWeapon = Config.ESP.ShowWeapon, ShowArmor = Config.ESP.ShowArmor, ShowDistance = Config.ESP.ShowDistance
        },
        World = {Fullbright = Config.World.Fullbright, ExtractionTracker = Config.World.ExtractionTracker}
    }
end

local function ApplyConfig(snapshot)
    for groupName, groupValues in pairs(snapshot) do
        if Config[groupName] and type(groupValues) == "table" then
            for key, value in pairs(groupValues) do
                if Config[groupName][key] ~= nil then Config[groupName][key] = value end
            end
        end
    end
end

AddSectionLabel(ConfigPage, "Session configuration")
AddInfoLine(ConfigPage, "Save/load uses sandstorm_premium_config.json when your executor supports local files.")
local function ApplyProfile(name)
    if name == "Loot" then
        Config.Aimbot.Enabled = false
        Config.ESP.Enabled = true
        Config.ESP.Players = false
        Config.ESP.Bots = false
        Config.ESP.Containers = true
        Config.ESP.DeadBodies = true
        Config.ESP.QuestItems = true
        Config.ESP.KeyLocations = true
    elseif name == "Quest" then
        Config.Aimbot.Enabled = false
        Config.ESP.Enabled = true
        Config.ESP.Players = false
        Config.ESP.Bots = false
        Config.ESP.Containers = false
        Config.ESP.DeadBodies = false
        Config.ESP.QuestItems = true
        Config.ESP.KeyLocations = true
    else
        Config.Aimbot.Enabled = false
        Config.ESP.Enabled = false
        Config.ESP.QuestItems = false
        Config.ESP.KeyLocations = false
    end
    SetStatus(string.upper(name) .. " PROFILE APPLIED", true)
end
AddSectionLabel(ConfigPage, "Quick profiles")
AddButton(ConfigPage, "Loot profile", function() ApplyProfile("Loot") end)
AddButton(ConfigPage, "Quest profile", function() ApplyProfile("Quest") end)
AddButton(ConfigPage, "Minimal profile", function() ApplyProfile("Minimal") end)
AddButton(ConfigPage, "Save configuration", function()
    local ok, data = pcall(function() return HttpService:JSONEncode(MakeConfigSnapshot()) end)
    if not ok then SetStatus("CONFIG SERIALIZE FAILED", false); return end
    if writefile then writefile(ConfigPath, data); SetStatus("CONFIG SAVED", true)
    elseif setclipboard then setclipboard(data); SetStatus("CONFIG COPIED", true)
    else SetStatus("FILE API NOT AVAILABLE", false) end
end)
AddButton(ConfigPage, "Load configuration", function()
    if not (isfile and readfile and isfile(ConfigPath)) then SetStatus("NO LOCAL CONFIG FOUND", false); return end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigPath)) end)
    if ok then ApplyConfig(decoded); SetStatus("CONFIG LOADED  •  REOPEN MENU", true) else SetStatus("CONFIG LOAD FAILED", false) end
end)
AddButton(ConfigPage, "Copy configuration", function()
    local ok, data = pcall(function() return HttpService:JSONEncode(MakeConfigSnapshot()) end)
    if ok and setclipboard then setclipboard(data); SetStatus("CONFIG COPIED", true) else SetStatus("CLIPBOARD NOT AVAILABLE", false) end
end)

local function BuildWorkspaceIndex()
    local lines = {"SANDSTORM WORLD SNAPSHOT", "PlaceId: " .. tostring(game.PlaceId), ""}
    for _, item in ipairs(Workspace:GetChildren()) do
        if not item:IsA("Terrain") then table.insert(lines, string.format("%s [%s] — %d children", item.Name, item.ClassName, #item:GetChildren())) end
    end
    return table.concat(lines, "\n")
end

AddSectionLabel(ConfigPage, "Data tools")
AddInfoLine(ConfigPage, "Exports a readable index of Workspace objects; it does not alter the game.")
AddButton(ConfigPage, "Copy world snapshot", function()
    if setclipboard then setclipboard(BuildWorkspaceIndex()); SetStatus("WORLD SNAPSHOT COPIED", true) else SetStatus("CLIPBOARD NOT AVAILABLE", false) end
end)
AddSectionLabel(ConfigPage, "Session")
AddButton(ConfigPage, "Unload script", function()
    if getgenv and getgenv().SandstormPremiumUnload then
        getgenv().SandstormPremiumUnload()
    else
        SetStatus("UNLOAD NOT READY", false)
    end
end)

AddSectionLabel(IntelPage, "Game intel")
AddInfoLine(IntelPage, "Place ID  •  115872975504419", Theme.Text)
AddInfoLine(IntelPage, "Known bots  •  Workspace.IngameBots")
AddInfoLine(IntelPage, "Known loot  •  Workspace.Containers")
AddInfoLine(IntelPage, "Known extraction zones  •  Workspace.Extractions")
AddInfoLine(IntelPage, "Known quest items  •  ReplicatedStorage.QuestItems")
AddSectionLabel(IntelPage, "Controls")
AddInfoLine(IntelPage, "INSERT / DELETE / RIGHT CTRL  •  toggle menu")
AddInfoLine(IntelPage, "RIGHT MOUSE  •  aim assist lock")

-- UI TOGGLE (INSERT / DELETE / RIGHT CTRL)
-- ══════════════════════════════════════════════════════════════
local isTweening = false
local function ToggleUI()
    if isTweening then return end
    isTweening = true
    Config.UIVisible = not Config.UIVisible
    if Config.UIVisible then
        MainFrame.Visible = true
        WindowScale.Scale = 0.94
        MainFrame.Position = UDim2.new(0.5, -395, 0.5, -246)
        local scaleTween = Tween(WindowScale, {Scale = 1}, 0.24, Enum.EasingStyle.Back)
        Tween(MainFrame, {Position = UDim2.new(0.5, -395, 0.5, -260)}, 0.22, Enum.EasingStyle.Quart):Play()
        scaleTween:Play()
        scaleTween.Completed:Once(function() isTweening = false end)
    else
        local scaleTween = Tween(WindowScale, {Scale = 0.94}, 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        Tween(MainFrame, {Position = UDim2.new(0.5, -395, 0.5, -246)}, 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
        scaleTween:Play()
        scaleTween.Completed:Once(function()
            MainFrame.Visible = false
            WindowScale.Scale = 1
            MainFrame.Position = UDim2.new(0.5, -395, 0.5, -260)
            isTweening = false
        end)
    end
end
local ToggleInputConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
        ToggleUI()
    end
end)

-- FOV CIRCLE
-- ══════════════════════════════════════════════════════════════
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 45, 85)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 40
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Transparency = 0.6

-- ══════════════════════════════════════════════════════════════
-- RAYCAST WALL CHECK
-- ══════════════════════════════════════════════════════════════
local function IsVisible(part, character)
    if not part or not character then return false end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, character, Camera}
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, direction, params)
    return result == nil
end

-- ══════════════════════════════════════════════════════════════
-- R15 SKELETON BONES
-- ══════════════════════════════════════════════════════════════
local R15Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

-- ══════════════════════════════════════════════════════════════
-- ESP DRAWING CACHE
-- ══════════════════════════════════════════════════════════════
local ESPCache = {}
local function GetESP(id)
    if not ESPCache[id] then
        local boxOut = Drawing.new("Square")
        boxOut.Thickness = 3; boxOut.Color = Color3.fromRGB(0, 0, 0); boxOut.Filled = false; boxOut.Visible = false
        local box = Drawing.new("Square")
        box.Thickness = 1.5; box.Filled = false; box.Visible = false
        local nameLabel = Drawing.new("Text")
        nameLabel.Size = 13; nameLabel.Center = true; nameLabel.Outline = true; nameLabel.Font = 2; nameLabel.Visible = false
        local hpBg = Drawing.new("Line")
        hpBg.Thickness = 4; hpBg.Color = Color3.fromRGB(15, 15, 20); hpBg.Visible = false
        local hpBar = Drawing.new("Line")
        hpBar.Thickness = 2; hpBar.Visible = false
        local hpText = Drawing.new("Text")
        hpText.Size = 11; hpText.Center = true; hpText.Outline = true; hpText.Color = Color3.fromRGB(255, 255, 255); hpText.Visible = false
        local headDot = Drawing.new("Circle")
        headDot.Radius = 3; headDot.Filled = true; headDot.Visible = false
        local weaponLabel = Drawing.new("Text")
        weaponLabel.Size = 11; weaponLabel.Center = true; weaponLabel.Outline = true; weaponLabel.Color = Color3.fromRGB(255, 200, 80); weaponLabel.Visible = false
        local armorLabel = Drawing.new("Text")
        armorLabel.Size = 11; armorLabel.Center = true; armorLabel.Outline = true; armorLabel.Color = Color3.fromRGB(100, 180, 255); armorLabel.Visible = false
        local lines = {}
        for i = 1, 14 do
            local line = Drawing.new("Line")
            line.Thickness = 1.6; line.Visible = false
            table.insert(lines, line)
        end
        ESPCache[id] = {
            BoxOut = boxOut, Box = box, Name = nameLabel,
            HPBg = hpBg, HP = hpBar, HPText = hpText,
            HeadDot = headDot, WeaponLabel = weaponLabel, ArmorLabel = armorLabel,
            Skeleton = lines
        }
    end
    return ESPCache[id]
end
local function HideESP(id)
    if ESPCache[id] then
        local e = ESPCache[id]
        e.BoxOut.Visible = false; e.Box.Visible = false; e.Name.Visible = false
        e.HPBg.Visible = false; e.HP.Visible = false; e.HPText.Visible = false
        e.HeadDot.Visible = false; e.WeaponLabel.Visible = false; e.ArmorLabel.Visible = false
        for _, l in ipairs(e.Skeleton) do l.Visible = false end
    end
end

local SimpleESPCache = {}
local function GetSimpleESP(id)
    if not SimpleESPCache[id] then
        local label = Drawing.new("Text")
        label.Size = 13; label.Center = true; label.Outline = true; label.Font = 2; label.Visible = false
        SimpleESPCache[id] = {Label = label}
    end
    return SimpleESPCache[id]
end
local function HideSimpleESP(id)
    if SimpleESPCache[id] then SimpleESPCache[id].Label.Visible = false end
end

-- ══════════════════════════════════════════════════════════════
-- ENTITY DETECTION HELPERS
-- ══════════════════════════════════════════════════════════════
local function IsPlayer(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end
local function GetWeaponName(character)
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then return child.Name end
    end
    return nil
end
local function HasArmor(character)
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("BoolValue") and desc.Name == "BodyArmor" and desc.Value == true then
            return true
        end
    end
    return false
end
local function IsDeadBody(model)
    return string.find(model.Name, "_Dead_") ~= nil
end

-- ══════════════════════════════════════════════════════════════
-- AIMBOT TARGET ACQUISITION
-- ══════════════════════════════════════════════════════════════
local function GetAimbotTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local closest, minDist = nil, Config.Aimbot.FOV
    local camPos = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = plr.Character:FindFirstChild(Config.Aimbot.TargetPart) or plr.Character:FindFirstChild("Head")
            if hum and targetPart and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < minDist then
                        if not Config.Aimbot.WallCheck or IsVisible(targetPart, plr.Character) then
                            minDist = dist
                            closest = targetPart
                        end
                    end
                end
            end
        end
    end
    if Config.Aimbot.TargetBots then
        local botFolder = Workspace:FindFirstChild("IngameBots")
        if botFolder then
            for _, bot in ipairs(botFolder:GetChildren()) do
                if bot:IsA("Model") then
                    local hum = bot:FindFirstChildOfClass("Humanoid")
                    local targetPart = bot:FindFirstChild(Config.Aimbot.TargetPart) or bot:FindFirstChild("Head")
                    if hum and targetPart and hum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < minDist then
                                if not Config.Aimbot.WallCheck or IsVisible(targetPart, bot) then
                                    minDist = dist
                                    closest = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ══════════════════════════════════════════════════════════════
-- EXTRACTION TRACKER HUD
-- ══════════════════════════════════════════════════════════════
local ExtractHUD = Instance.new("Frame")
ExtractHUD.Size = UDim2.new(0, 260, 0, 0)
ExtractHUD.Position = UDim2.new(1, -280, 0, 190)
ExtractHUD.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
ExtractHUD.BackgroundTransparency = 0.15
ExtractHUD.BorderSizePixel = 0
ExtractHUD.Visible = false
ExtractHUD.AutomaticSize = Enum.AutomaticSize.Y
ExtractHUD.Parent = ScreenGui
Instance.new("UICorner", ExtractHUD).CornerRadius = UDim.new(0, 8)
local ExtHudStroke = Instance.new("UIStroke", ExtractHUD)
ExtHudStroke.Color = Color3.fromRGB(50, 255, 120)
ExtHudStroke.Thickness = 1
ExtHudStroke.Transparency = 0.4
local ExtHudLayout = Instance.new("UIListLayout", ExtractHUD)
ExtHudLayout.Padding = UDim.new(0, 2)
local ExtHudTitle = Instance.new("TextLabel")
ExtHudTitle.Size = UDim2.new(1, 0, 0, 26)
ExtHudTitle.BackgroundTransparency = 1
ExtHudTitle.Text = "  EXTRACTION ZONES"
ExtHudTitle.TextColor3 = Color3.fromRGB(50, 255, 120)
ExtHudTitle.Font = Enum.Font.GothamBold
ExtHudTitle.TextSize = 12
ExtHudTitle.TextXAlignment = Enum.TextXAlignment.Left
ExtHudTitle.Parent = ExtractHUD
local ExtractLabels = {}
local nextExtractionHudUpdate = 0
local function UpdateExtractionHUD(camPos)
    if os.clock() < nextExtractionHudUpdate then return end
    nextExtractionHudUpdate = os.clock() + 0.25
    local extractModel = Workspace:FindFirstChild("Extractions")
    if not extractModel then return end

    local sorted = {}
    for _, zone in ipairs(extractModel:GetChildren()) do
        if zone:IsA("BasePart") then
            table.insert(sorted, {Name = zone.Name, Dist = (zone.Position - camPos).Magnitude})
        end
    end
    table.sort(sorted, function(a, b) return a.Dist < b.Dist end)

    for index, info in ipairs(sorted) do
        local label = ExtractLabels[index]
        if not label then
            label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -12, 0, 20)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = ExtractHUD
            ExtractLabels[index] = label
        end
        label.Text = string.format("  %s  •  %dm", info.Name, math.floor(info.Dist))
        label.TextColor3 = info.Dist < 200 and Color3.fromRGB(112, 196, 150) or Color3.fromRGB(184, 189, 202)
        label.Visible = true
    end
    for index = #sorted + 1, #ExtractLabels do ExtractLabels[index].Visible = false end
end

-- ══════════════════════════════════════════════════════════════
-- QUEST HUD & CONTROLS
-- ══════════════════════════════════════════════════════════════
local QuestHUD = Instance.new("Frame")
QuestHUD.Name = "QuestObjectiveHUD"
QuestHUD.Size = UDim2.fromOffset(280, 112)
QuestHUD.Position = UDim2.new(1, -300, 0, 58)
QuestHUD.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
QuestHUD.BackgroundTransparency = 0.08
QuestHUD.BorderSizePixel = 0
QuestHUD.Active = true
QuestHUD.Parent = ScreenGui
Round(QuestHUD, 9)
Stroke(QuestHUD, Theme.Border, 0.25, 1)

local QuestHudTitle = Instance.new("TextLabel")
QuestHudTitle.Size = UDim2.new(1, -26, 0, 24)
QuestHudTitle.Position = UDim2.fromOffset(13, 8)
QuestHudTitle.BackgroundTransparency = 1
QuestHudTitle.Text = "QUEST OBJECTIVE"
QuestHudTitle.TextColor3 = Theme.AccentBright
QuestHudTitle.Font = Enum.Font.GothamBold
QuestHudTitle.TextSize = 10
QuestHudTitle.TextXAlignment = Enum.TextXAlignment.Left
QuestHudTitle.Parent = QuestHUD

local QuestHudObjective = Instance.new("TextLabel")
QuestHudObjective.Size = UDim2.new(1, -26, 0, 22)
QuestHudObjective.Position = UDim2.fromOffset(13, 31)
QuestHudObjective.BackgroundTransparency = 1
QuestHudObjective.Text = "Scanning for an active objective..."
QuestHudObjective.TextColor3 = Theme.Text
QuestHudObjective.Font = Enum.Font.GothamMedium
QuestHudObjective.TextSize = 12
QuestHudObjective.TextWrapped = true
QuestHudObjective.TextXAlignment = Enum.TextXAlignment.Left
QuestHudObjective.Parent = QuestHUD

local QuestHudDescription = Instance.new("TextLabel")
QuestHudDescription.Size = UDim2.new(1, -26, 0, 42)
QuestHudDescription.Position = UDim2.fromOffset(13, 57)
QuestHudDescription.BackgroundTransparency = 1
QuestHudDescription.Text = "Open the Quests tab to refresh the detected items."
QuestHudDescription.TextColor3 = Theme.Muted
QuestHudDescription.Font = Enum.Font.Gotham
QuestHudDescription.TextSize = 10
QuestHudDescription.TextWrapped = true
QuestHudDescription.TextXAlignment = Enum.TextXAlignment.Left
QuestHudDescription.TextYAlignment = Enum.TextYAlignment.Top
QuestHudDescription.Parent = QuestHUD

local function MakeDraggable(handle, target)
    local dragging, startInput, startPosition = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging, startInput, startPosition = true, input.Position, target.Position
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = input.Position - startInput
        target.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end
MakeDraggable(QuestHUD, QuestHUD)

local function GetRelativeDirection(targetPosition)
    if not targetPosition then return "unknown direction" end
    local offset = targetPosition - Camera.CFrame.Position
    local flatOffset = Vector3.new(offset.X, 0, offset.Z)
    if flatOffset.Magnitude < 1 then return "at your position" end
    local look = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
    local right = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z).Unit
    local forward = look:Dot(flatOffset.Unit)
    local sideways = right:Dot(flatOffset.Unit)
    if forward > 0.55 then return "ahead" end
    if forward < -0.55 then return "behind you" end
    return sideways > 0 and "to your right" or "to your left"
end

local function UpdateQuestObjective()
    local _, entries = QuestSnapshot()
    local quest = entries[1]
    if PinnedQuest then
        for _, entry in ipairs(entries) do
            if entry.Instance == PinnedQuest.Instance or entry.Name == PinnedQuest.Name then
                quest = entry
                break
            end
        end
        if not quest or (quest.Instance ~= PinnedQuest.Instance and quest.Name ~= PinnedQuest.Name) then
            PinnedQuest = nil
            quest = entries[1]
        end
    end
    if quest then
        local pinned = PinnedQuest ~= nil
        QuestHudTitle.Text = pinned and "PINNED QUEST" or "QUEST OBJECTIVE"
        QuestHudObjective.Text = "Collect " .. quest.Name
        QuestHudDescription.Text = string.format("%dm away  •  %s%s", quest.Distance, GetRelativeDirection(quest.Part and quest.Part.Position), pinned and "  •  pinned" or "")
        return
    end
    local tasks = Workspace:FindFirstChild("TasksObjects")
    if tasks and #tasks:GetChildren() > 0 then
        QuestHudObjective.Text = "Investigate " .. tasks:GetChildren()[1].Name
        QuestHudDescription.Text = "A task object is loaded in the world. Reach it and follow the in-game interaction prompt."
        return
    end
    QuestHudTitle.Text = "QUEST OBJECTIVE"
    QuestHudObjective.Text = "No active quest item detected"
    QuestHudDescription.Text = "Quest items will appear here as soon as they load in Workspace or ReplicatedStorage."
end

task.spawn(function()
    while ScriptAlive and QuestHUD.Parent do
        UpdateQuestObjective()
        task.wait(0.75)
    end
end)

local KeyLocationCache = {}
local nextKeyLocationScan = 0
local function AccessLabel(name)
    local lower = string.lower(name)
    if string.find(lower, "tunnel") then return "Tunnel keycard" end
    if string.find(lower, "power") then return "Power station keycard" end
    if string.find(lower, "keycard") then return "Keycard access" end
    return "Locked access"
end

local function UpdateKeyLocationCache()
    if os.clock() < nextKeyLocationScan then return end
    nextKeyLocationScan = os.clock() + 3
    local roots = {Workspace:FindFirstChild("LockedRooms"), Workspace:FindFirstChild("LockedRoomsZones"), Workspace:FindFirstChild("TasksObjects"), Workspace:FindFirstChild("Containers")}
    local found, seen = {}, {}
    for _, root in ipairs(roots) do
        if root then
            for _, instance in ipairs(root:GetDescendants()) do
                local lower = string.lower(instance.Name)
                if string.find(lower, "keycard") or string.find(lower, "tunnel") or string.find(lower, "power") or string.find(lower, "locked") then
                    local part = instance:IsA("BasePart") and instance or instance:FindFirstChildWhichIsA("BasePart", true)
                    if part and not seen[part] then
                        seen[part] = true
                        table.insert(found, {Part = part, Label = AccessLabel(instance.Name)})
                    end
                end
            end
        end
    end
    KeyLocationCache = found
end

local activePlayerIDs = {}
local activeBotIDs = {}
local function GetCharacterScreenBounds(character)
    local boxCFrame, boxSize = character:GetBoundingBox()
    local half = boxSize * 0.5
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local visibleCorners = 0

    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local worldPoint = boxCFrame:PointToWorldSpace(Vector3.new(half.X * x, half.Y * y, half.Z * z))
                local screenPoint, visible = Camera:WorldToViewportPoint(worldPoint)
                if visible then
                    visibleCorners += 1
                    minX = math.min(minX, screenPoint.X)
                    minY = math.min(minY, screenPoint.Y)
                    maxX = math.max(maxX, screenPoint.X)
                    maxY = math.max(maxY, screenPoint.Y)
                end
            end
        end
    end

    if visibleCorners == 0 then return nil end
    return minX, minY, maxX, maxY
end

local function RenderCharacterESP(id, character, color, colorOccluded, isBot)
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    if not hrp or not hum or hum.Health <= 0 then
        HideESP(id)
        return
    end
    local camPos = Camera.CFrame.Position
    local dist = (hrp.Position - camPos).Magnitude
    if dist > Config.ESP.MaxDistance then HideESP(id) return end
    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    local topX, topY, bottomX, bottomY = GetCharacterScreenBounds(character)
    if not onScreen or not topX then HideESP(id) return end
    local esp = GetESP(id)
    local visible = IsVisible(head or hrp, character)
    local drawColor = visible and color or colorOccluded
    local sizeX = math.max(2, bottomX - topX)
    local sizeY = math.max(2, bottomY - topY)

    if Config.ESP.ShowBoxes then
        esp.BoxOut.Size = Vector2.new(sizeX + 2, sizeY + 2)
        esp.BoxOut.Position = Vector2.new(topX - 1, topY - 1)
        esp.BoxOut.Visible = true
        esp.Box.Size = Vector2.new(sizeX, sizeY)
        esp.Box.Position = Vector2.new(topX, topY)
        esp.Box.Color = drawColor
        esp.Box.Visible = true
    else
        esp.BoxOut.Visible = false
        esp.Box.Visible = false
    end

    if Config.ESP.ShowNames then
        local displayName = character.Name
        if isBot then displayName = "[BOT] " .. displayName end
        local armorStr = ""
        if Config.ESP.ShowArmor and HasArmor(character) then armorStr = " [A]" end
        esp.Name.Position = Vector2.new(screenPos.X, topY - 16)
        esp.Name.Text = string.format("%s [%dm]%s", displayName, math.floor(dist), armorStr)
        esp.Name.Color = drawColor
        esp.Name.Visible = true
    else
        esp.Name.Visible = false
    end

    if Config.ESP.ShowHealth then
        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local hpColor = Color3.fromRGB(255 * (1 - pct), 255 * pct, 0)
        esp.HPBg.From = Vector2.new(topX - 6, topY + sizeY)
        esp.HPBg.To = Vector2.new(topX - 6, topY)
        esp.HPBg.Visible = true
        esp.HP.From = Vector2.new(topX - 6, topY + sizeY)
        esp.HP.To = Vector2.new(topX - 6, (topY + sizeY) - (sizeY * pct))
        esp.HP.Color = hpColor
        esp.HP.Visible = true
        esp.HPText.Position = Vector2.new(topX - 20, (topY + sizeY) - (sizeY * pct) - 6)
        esp.HPText.Text = tostring(math.floor(hum.Health))
        esp.HPText.Visible = true
    else
        esp.HPBg.Visible = false
        esp.HP.Visible = false
        esp.HPText.Visible = false
    end

    if Config.ESP.ShowHeadDot and head then
        local headPos, hVis = Camera:WorldToViewportPoint(head.Position)
        if hVis then
            esp.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
            esp.HeadDot.Color = drawColor
            esp.HeadDot.Visible = true
        else esp.HeadDot.Visible = false end
    else esp.HeadDot.Visible = false end

    if Config.ESP.ShowWeapon then
        local wepName = GetWeaponName(character)
        if wepName then
            esp.WeaponLabel.Position = Vector2.new(screenPos.X, topY + sizeY + 3)
            esp.WeaponLabel.Text = wepName
            esp.WeaponLabel.Visible = true
        else esp.WeaponLabel.Visible = false end
    else esp.WeaponLabel.Visible = false end
    
    esp.ArmorLabel.Visible = false

    if Config.ESP.ShowSkeleton then
        for idx, pair in ipairs(R15Bones) do
            local pA, pB = character:FindFirstChild(pair[1]), character:FindFirstChild(pair[2])
            local line = esp.Skeleton[idx]
            if pA and pB and line then
                local posA, visA = Camera:WorldToViewportPoint(pA.Position)
                local posB, visB = Camera:WorldToViewportPoint(pB.Position)
                if visA and visB then
                    line.From = Vector2.new(posA.X, posA.Y)
                    line.To = Vector2.new(posB.X, posB.Y)
                    line.Color = drawColor
                    line.Visible = true
                else line.Visible = false end
            elseif line then line.Visible = false end
        end
    else
        for _, l in ipairs(esp.Skeleton) do l.Visible = false end
    end
end

-- ══════════════════════════════════════════════════════════════
-- RENDER LOOP
-- ══════════════════════════════════════════════════════════════
local RenderConnection = RunService.RenderStepped:Connect(function()
    if not ScriptAlive then return end
    local mouseLoc = UserInputService:GetMouseLocation()
    FOVCircle.Position = mouseLoc
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
    local camPos = Camera.CFrame.Position

    if Config.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetAimbotTarget()
        if target then
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aimbot.Smoothness)
        end
    end

    if not Config.ESP.Enabled then
        for id in pairs(ESPCache) do HideESP(id) end
        for id in pairs(SimpleESPCache) do HideSimpleESP(id) end
        ExtractHUD.Visible = false
        return
    end

    local currentPlayerIDs = {}
    local currentBotIDs = {}
    local currentSimpleIDs = {}

    if Config.ESP.Players then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local id = "P_" .. plr.Name
                currentPlayerIDs[id] = true
                RenderCharacterESP(id, plr.Character, Config.ESP.ColorPlayer, Config.ESP.ColorPlayerOccluded, false)
            end
        end
    end
    for id in pairs(activePlayerIDs) do
        if not currentPlayerIDs[id] then HideESP(id) end
    end
    activePlayerIDs = currentPlayerIDs

    if Config.ESP.Bots then
        local botFolder = Workspace:FindFirstChild("IngameBots")
        if botFolder then
            for _, bot in ipairs(botFolder:GetChildren()) do
                if bot:IsA("Model") then
                    local id = "B_" .. bot.Name
                    currentBotIDs[id] = true
                    RenderCharacterESP(id, bot, Config.ESP.ColorBot, Config.ESP.ColorBot, true)
                end
            end
        end
    end
    for id in pairs(activeBotIDs) do
        if not currentBotIDs[id] then HideESP(id) end
    end
    activeBotIDs = currentBotIDs

    if Config.ESP.Containers then
        local containerFolder = Workspace:FindFirstChild("Containers")
        if containerFolder then
            for _, container in ipairs(containerFolder:GetChildren()) do
                if container:IsA("Model") and not IsDeadBody(container) then
                    local prompt = container:FindFirstChildOfClass("ProximityPrompt", true)
                    if prompt then
                        local part = container.PrimaryPart or container:FindFirstChildOfClass("BasePart")
                        if part then
                            local id = "C_" .. container.Name .. tostring(container:GetDebugId())
                            currentSimpleIDs[id] = true
                            local dist = (part.Position - camPos).Magnitude
                            if dist <= Config.ESP.MaxDistance then
                                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local esp = GetSimpleESP(id)
                                    esp.Label.Position = Vector2.new(screenPos.X, screenPos.Y)
                                    esp.Label.Text = string.format("[%s] %dm", container.Name, math.floor(dist))
                                    esp.Label.Color = Config.ESP.ColorContainer
                                    esp.Label.Visible = true
                                else HideSimpleESP(id) end
                            else HideSimpleESP(id) end
                        end
                    end
                end
            end
        end
    end

    if Config.ESP.DeadBodies then
        local containerFolder = Workspace:FindFirstChild("Containers")
        if containerFolder then
            for _, body in ipairs(containerFolder:GetChildren()) do
                if body:IsA("Model") and IsDeadBody(body) then
                    local part = body:FindFirstChild("HumanoidRootPart") or body:FindFirstChildOfClass("BasePart")
                    if part then
                        local id = "D_" .. tostring(body:GetDebugId())
                        currentSimpleIDs[id] = true
                        local dist = (part.Position - camPos).Magnitude
                        if dist <= Config.ESP.MaxDistance then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local esp = GetSimpleESP(id)
                                local deadName = string.match(body.Name, "(.+)_Dead_") or body.Name
                                esp.Label.Position = Vector2.new(screenPos.X, screenPos.Y)
                                esp.Label.Text = string.format("[BODY] %s %dm", deadName, math.floor(dist))
                                esp.Label.Color = Config.ESP.ColorDeadBody
                                esp.Label.Visible = true
                            else HideSimpleESP(id) end
                        else HideSimpleESP(id) end
                    end
                end
            end
        end
    end

    if Config.ESP.Extractions then
        local extractModel = Workspace:FindFirstChild("Extractions")
        if extractModel then
            for _, zone in ipairs(extractModel:GetChildren()) do
                if zone:IsA("BasePart") then
                    local id = "E_" .. zone.Name
                    currentSimpleIDs[id] = true
                    local dist = (zone.Position - camPos).Magnitude
                    if dist <= Config.ESP.MaxDistance + 2000 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(zone.Position)
                        if onScreen then
                            local esp = GetSimpleESP(id)
                            esp.Label.Position = Vector2.new(screenPos.X, screenPos.Y)
                            esp.Label.Text = string.format("[EXTRACT] %s %dm", zone.Name, math.floor(dist))
                            esp.Label.Color = Config.ESP.ColorExtraction
                            esp.Label.Visible = true
                        else HideSimpleESP(id) end
                    else HideSimpleESP(id) end
                end
            end
        end
    end

    if Config.ESP.QuestItems then
        local questFolder = ReplicatedStorage:FindFirstChild("QuestItems")
        if questFolder then
            for _, item in ipairs(questFolder:GetChildren()) do
                local part = item:FindFirstChildOfClass("MeshPart") or item:FindFirstChildOfClass("BasePart")
                if part and part.Parent and part.Parent.Parent then
                    local isPinnedQuest = PinnedQuest and (PinnedQuest.Instance == item or PinnedQuest.Name == item.Name)
                    local id = "Q_" .. item.Name
                    currentSimpleIDs[id] = true
                    local dist = (part.Position - camPos).Magnitude
                    if dist <= Config.ESP.MaxDistance then
                        loadScreenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local esp = GetSimpleESP(id)
                            esp.Label.Position = Vector2.new(loadScreenPos.X, loadScreenPos.Y)
                            esp.Label.Text = string.format(isPinnedQuest and "[PINNED] %s %dm" or "[QUEST] %s %dm", item.Name, math.floor(dist))
                            esp.Label.Color = isPinnedQuest and Theme.AccentBright or Config.ESP.ColorQuestItem
                            esp.Label.Visible = true
                        else HideSimpleESP(id) end
                    else HideSimpleESP(id) end
                end
            end
        end
    end

    if Config.ESP.KeyLocations then
        UpdateKeyLocationCache()
        for _, marker in ipairs(KeyLocationCache) do
            local part = marker.Part
            if part and part.Parent then
                local id = "K_" .. tostring(part:GetDebugId())
                currentSimpleIDs[id] = true
                local dist = (part.Position - camPos).Magnitude
                if dist <= Config.ESP.MaxDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local esp = GetSimpleESP(id)
                        esp.Label.Position = Vector2.new(screenPos.X, screenPos.Y)
                        esp.Label.Text = string.format("[ACCESS] %s  %dm", marker.Label, math.floor(dist))
                        esp.Label.Color = Config.ESP.ColorKeyLocation
                        esp.Label.Visible = true
                    else HideSimpleESP(id) end
                else HideSimpleESP(id) end
            end
        end
    end

    for id in pairs(SimpleESPCache) do
        if not currentSimpleIDs[id] then HideSimpleESP(id) end
    end

    ExtractHUD.Visible = Config.World.ExtractionTracker
    if Config.World.ExtractionTracker then
        UpdateExtractionHUD(camPos)
    end
end)

-- ══════════════════════════════════════════════════════════════
-- CLEANUP
-- ══════════════════════════════════════════════════════════════
local function Cleanup()
    if not ScriptAlive then return end
    ScriptAlive = false
    Config.ESP.Enabled = false
    if FpsConnection then FpsConnection:Disconnect() end
    if ToggleInputConnection then ToggleInputConnection:Disconnect() end
    if RenderConnection then RenderConnection:Disconnect() end
    pcall(function() FOVCircle:Remove() end)
    for _, e in pairs(ESPCache) do
        pcall(function() e.BoxOut:Remove(); e.Box:Remove(); e.Name:Remove() end)
        pcall(function() e.HPBg:Remove(); e.HP:Remove(); e.HPText:Remove() end)
        pcall(function() e.HeadDot:Remove(); e.WeaponLabel:Remove(); e.ArmorLabel:Remove() end)
        for _, l in ipairs(e.Skeleton) do pcall(function() l:Remove() end) end
    end
    for _, e in pairs(SimpleESPCache) do pcall(function() e.Label:Remove() end) end
    pcall(function() ScreenGui:Destroy() end)
end
if getgenv then getgenv().SandstormPremiumUnload = Cleanup end
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if not ScriptAlive then return end
    for id in pairs(ESPCache) do HideESP(id) end
    for id in pairs(SimpleESPCache) do HideSimpleESP(id) end
end)

print("[+] Sandstorm Private Suite v1.0 Loaded — DesertStorm [EXTRACTION]")
print("[+] Toggle UI: INSERT / DELETE | Aimbot: Hold Right-Click")

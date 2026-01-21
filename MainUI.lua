local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- [[ GITHUB CONFIG ]] --
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/nabimadridgg-source/Rob-It/refs/heads/main/ESP.lua?t=" .. tick()
local ESP = nil
local Toggles = { NPC = false, Items = false, Vaults = false }

-- [[ UI STATE ]] --
local UI_VISIBLE = true

-- [[ CORE UI CONSTRUCTION ]] --
if LocalPlayer.PlayerGui:FindFirstChild("NabiModern") then LocalPlayer.PlayerGui.NabiModern:Destroy() end

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiModern"
ScreenGui.ResetOnSpawn = false

-- Draggable Helper Function
local function MakeDraggable(frame, parent)
    parent = parent or frame
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- [[ MINIMIZED ICON (Moveable) ]] --
local MinimizedIcon = Instance.new("Frame", ScreenGui)
MinimizedIcon.Size = UDim2.new(0, 45, 0, 45)
MinimizedIcon.Position = UDim2.new(0.05, 0, 0.4, 0)
MinimizedIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MinimizedIcon.Visible = false
Instance.new("UICorner", MinimizedIcon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MinimizedIcon).Color = Color3.fromRGB(0, 255, 255)
MakeDraggable(MinimizedIcon)

local IconBtn = Instance.new("TextButton", MinimizedIcon)
IconBtn.Size = UDim2.new(1, 0, 1, 0)
IconBtn.BackgroundTransparency = 1
IconBtn.Text = "N"
IconBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
IconBtn.Font = Enum.Font.GothamBold
IconBtn.TextSize = 18

-- [[ MAIN DASHBOARD ]] --
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 380, 0, 320)
Main.Position = UDim2.new(0.5, -190, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(40, 40, 45)
MainStroke.Thickness = 1.5

-- Header (Draggable Area)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)
MakeDraggable(Header, Main)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "NABI ROB-IT // TERMINAL v6"
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 12
Title.TextXAlignment = "Left"
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold

-- Navigation
local Nav = Instance.new("Frame", Main)
Nav.Size = UDim2.new(1, 0, 0, 30)
Nav.Position = UDim2.new(0, 0, 0, 35)
Nav.BackgroundColor3 = Color3.fromRGB(12, 12, 15)

local MainTab = Instance.new("TextButton", Nav)
MainTab.Size = UDim2.new(0.5, 0, 1, 0)
MainTab.Text = "DASHBOARD"
MainTab.Font = Enum.Font.GothamBold
MainTab.TextSize = 10
MainTab.TextColor3 = Color3.new(1,1,1)
MainTab.BackgroundTransparency = 1

local ESPTab = Instance.new("TextButton", Nav)
ESPTab.Size = UDim2.new(0.5, 0, 1, 0)
ESPTab.Position = UDim2.new(0.5, 0, 0, 0)
ESPTab.Text = "SENSORY (ESP)"
ESPTab.Font = Enum.Font.GothamBold
ESPTab.TextSize = 10
ESPTab.TextColor3 = Color3.fromRGB(100, 100, 100)
ESPTab.BackgroundTransparency = 1

-- Content Pages
local MainContent = Instance.new("Frame", Main)
MainContent.Size = UDim2.new(1, -20, 1, -85)
MainContent.Position = UDim2.new(0, 10, 0, 75)
MainContent.BackgroundTransparency = 1

local ESPContent = Instance.new("Frame", Main)
ESPContent.Size = UDim2.new(1, -20, 1, -85)
ESPContent.Position = UDim2.new(0, 10, 0, 75)
ESPContent.BackgroundTransparency = 1
ESPContent.Visible = false

Instance.new("UIListLayout", MainContent).Padding = UDim.new(0, 8)
Instance.new("UIListLayout", ESPContent).Padding = UDim.new(0, 8)

-- [[ TOGGLE COMPONENT ]] --
local function CreateToggle(name, parent, callback)
    local t = Instance.new("Frame", parent)
    t.Size = UDim2.new(1, 0, 0, 40)
    t.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 4)
    
    local l = Instance.new("TextLabel", t)
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.Text = name:upper()
    l.TextColor3 = Color3.fromRGB(200, 200, 200)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = "Left"
    l.BackgroundTransparency = 1
    
    local b = Instance.new("TextButton", t)
    b.Size = UDim2.new(0, 50, 0, 22)
    b.Position = UDim2.new(1, -60, 0.5, -11)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.Text = "OFF"
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    Instance.new("UICorner", b)
    
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = active and "ON" or "OFF"
        b.BackgroundColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(35, 35, 40)
        b.TextColor3 = active and Color3.new(0,0,0) or Color3.new(1,1,1)
        callback(active)
    end)
end

-- [[ LOGIC & EVENTS ]] --
local function ToggleUI()
    UI_VISIBLE = not UI_VISIBLE
    Main.Visible = UI_VISIBLE
    MinimizedIcon.Visible = not UI_VISIBLE
end

CloseBtn.MouseButton1Click:Connect(ToggleUI)
IconBtn.MouseButton1Click:Connect(ToggleUI)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then ToggleUI() end
end)

MainTab.MouseButton1Click:Connect(function()
    MainContent.Visible, ESPContent.Visible = true, false
    MainTab.TextColor3, ESPTab.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(100, 100, 100)
end)

ESPTab.MouseButton1Click:Connect(function()
    MainContent.Visible, ESPContent.Visible = false, true
    ESPTab.TextColor3, MainTab.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(100, 100, 100)
end)

-- Initialize Content
local Welcome = Instance.new("TextLabel", MainContent)
Welcome.Size = UDim2.new(1, 0, 0, 60)
Welcome.Text = "CONNECTION ESTABLISHED\nPRESS [K] TO TOGGLE INTERFACE"
Welcome.TextColor3 = Color3.fromRGB(100, 100, 110)
Welcome.Font = Enum.Font.GothamMedium
Welcome.TextSize = 11
Welcome.BackgroundTransparency = 1

-- Fetch ESP Logic
task.spawn(function()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(GITHUB_RAW_URL))()
    end)
    if success and type(result) == "table" then
        ESP = result
        CreateToggle("Visual: NPCs", ESPContent, function(s) Toggles.NPC = s if not s then ESP.Clear() end end)
        CreateToggle("Visual: Valuables", ESPContent, function(s) Toggles.Items = s if not s then ESP.Clear() end end)
        CreateToggle("Visual: Vaults", ESPContent, function(s) Toggles.Vaults = s if not s then ESP.Clear() end end)
    end
end)

-- Global Loop
task.spawn(function()
    while task.wait(3) do
        if ESP then
            if Toggles.NPC then pcall(ESP.ScanNPCs) end
            if Toggles.Items then pcall(ESP.ScanItems) end
            if Toggles.Vaults then pcall(ESP.ScanVaults) end
        end
    end
end)

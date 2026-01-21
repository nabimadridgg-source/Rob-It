local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- [[ GITHUB CONFIG ]] --
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/nabimadridgg-source/Rob-It/refs/heads/main/ESP.lua?t=" .. tick()
local ESP = nil
local Toggles = { NPC = false, Items = false, Vaults = false }
local UI_VISIBLE = true

-- [[ UI ROOT ]] --
if LocalPlayer.PlayerGui:FindFirstChild("NabiModern") then LocalPlayer.PlayerGui.NabiModern:Destroy() end
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiModern"
ScreenGui.ResetOnSpawn = false

-- [[ DRAG SYSTEM ]] --
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [[ MINIMIZED ICON (Moveable) ]] --
local Icon = Instance.new("Frame", ScreenGui)
Icon.Size = UDim2.new(0, 50, 0, 50)
Icon.Position = UDim2.new(0.05, 0, 0.4, 0)
Icon.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Icon.Visible = false
Icon.Active = true
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)
local IconStroke = Instance.new("UIStroke", Icon)
IconStroke.Color = Color3.fromRGB(0, 255, 255)
IconStroke.Thickness = 1.5
MakeDraggable(Icon)

local IconBtn = Instance.new("TextButton", Icon)
IconBtn.Size = UDim2.new(1, 0, 1, 0)
IconBtn.BackgroundTransparency = 1
IconBtn.Text = "N"
IconBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
IconBtn.Font = Enum.Font.GothamBold
IconBtn.TextSize = 20

-- [[ MAIN DASHBOARD ]] --
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 380, 0, 320)
Main.Position = UDim2.new(0.5, -190, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.ClipsDescendants = true
Main.Active = true
Main.Visible = false
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(40, 40, 45)
MakeDraggable(Main)

-- [[ ANIMATION CONTROLLER ]] --
local function AnimateUI(visible)
    if visible then
        Main.Visible = true
        Main:TweenSize(UDim2.new(0, 380, 0, 320), "Out", "Elastic", 0.6, true)
        Icon:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 0.3, true, function() Icon.Visible = false end)
    else
        Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 0.4, true, function() Main.Visible = false end)
        Icon.Visible = true
        Icon:TweenSize(UDim2.new(0, 50, 0, 50), "Out", "Elastic", 0.6, true)
    end
end

-- [[ LOADING SEQUENCE ]] --
local LoadLabel = Instance.new("TextLabel", ScreenGui)
LoadLabel.Size = UDim2.new(1, 0, 1, 0)
LoadLabel.BackgroundTransparency = 1
LoadLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
LoadLabel.Font = Enum.Font.GothamBold
LoadLabel.TextSize = 20
LoadLabel.Text = "INITIALIZING NABI..."

task.spawn(function()
    task.wait(1)
    LoadLabel.Text = "SYNCING WITH REPOSITORY..."
    task.wait(1)
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(GITHUB_RAW_URL))()
    end)
    
    if success and type(result) == "table" then
        ESP = result
        LoadLabel.Text = "SYSTEMS READY"
        TweenService:Create(LoadLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        AnimateUI(true)
    else
        LoadLabel.Text = "FAILURE: CHECK CONSOLE"
        LoadLabel.TextColor3 = Color3.new(1,0,0)
    end
end)

-- [[ BUILD INTERFACE CONTENT ]] --
-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "NABI SENSORY // V6"
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = "Left"
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold

-- Tabs & Toggles
local ESPContent = Instance.new("Frame", Main)
ESPContent.Size = UDim2.new(1, -20, 1, -60)
ESPContent.Position = UDim2.new(0, 10, 0, 50)
ESPContent.BackgroundTransparency = 1
local List = Instance.new("UIListLayout", ESPContent)
List.Padding = UDim.new(0, 10)

local function CreateToggle(name, callback)
    local t = Instance.new("Frame", ESPContent)
    t.Size = UDim2.new(1, 0, 0, 45)
    t.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel", t)
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Text = name:upper()
    l.TextColor3 = Color3.fromRGB(150, 150, 150)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = "Left"
    l.BackgroundTransparency = 1
    
    local b = Instance.new("TextButton", t)
    b.Size = UDim2.new(0, 60, 0, 26)
    b.Position = UDim2.new(1, -70, 0.5, -13)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = "OFF"
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    Instance.new("UICorner", b)
    
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = active and "ON" or "OFF"
        TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(30, 30, 35)}):Play()
        b.TextColor3 = active and Color3.new(0,0,0) or Color3.new(1,1,1)
        callback(active)
    end)
end

-- Keybinds & Logic
local function ToggleMain()
    UI_VISIBLE = not UI_VISIBLE
    AnimateUI(UI_VISIBLE)
end

CloseBtn.MouseButton1Click:Connect(ToggleMain)
IconBtn.MouseButton1Click:Connect(ToggleMain)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then ToggleMain() end
end)

-- Background Refresh
task.spawn(function()
    while task.wait(3) do
        if ESP then
            if Toggles.NPC then pcall(ESP.ScanNPCs) end
            if Toggles.Items then pcall(ESP.ScanItems) end
            if Toggles.Vaults then pcall(ESP.ScanVaults) end
        end
    end
end)

-- Initialize Toggles (After loading finishes)
repeat task.wait() until ESP ~= nil
CreateToggle("Show NPCs", function(s) Toggles.NPC = s if s then ESP.ScanNPCs() end end)
CreateToggle("Show Valuables", function(s) Toggles.Items = s if s then ESP.ScanItems() end end)
CreateToggle("Show Vaults", function(s) Toggles.Vaults = s if s then ESP.ScanVaults() end end)

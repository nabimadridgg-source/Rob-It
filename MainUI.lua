-- [[ MainUI.lua - Tabbed Version ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GITHUB CONFIG
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/nabimadridgg-source/Rob-It/refs/heads/main/ESP.lua"
local ESP = nil

-- State Management for Toggles
local Toggles = {
    NPC = false,
    Items = false,
    Vaults = false
}

-- Load Logic
local success, result = pcall(function()
    return loadstring(game:HttpGet(GITHUB_RAW_URL))()
end)
if success then ESP = result end

-- [[ UI CONSTRUCTION ]] --
if LocalPlayer.PlayerGui:FindFirstChild("NabiDash") then LocalPlayer.PlayerGui.NabiDash:Destroy() end

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiDash"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 300)
Main.Position = UDim2.new(0.5, -175, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 55)

-- Tab Navigation
local TabFrame = Instance.new("Frame", Main)
TabFrame.Size = UDim2.new(1, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", TabFrame)

local MainTabBtn = Instance.new("TextButton", TabFrame)
MainTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
MainTabBtn.Text = "MAIN"
MainTabBtn.Font = Enum.Font.GothamBold
MainTabBtn.TextColor3 = Color3.new(1,1,1)
MainTabBtn.BackgroundTransparency = 1

local ESPTabBtn = Instance.new("TextButton", TabFrame)
ESPTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
ESPTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
ESPTabBtn.Text = "ESP"
ESPTabBtn.Font = Enum.Font.GothamBold
ESPTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
ESPTabBtn.BackgroundTransparency = 1

-- Content Pages
local MainContent = Instance.new("Frame", Main)
MainContent.Size = UDim2.new(1, 0, 1, -40)
MainContent.Position = UDim2.new(0, 0, 0, 40)
MainContent.BackgroundTransparency = 1

local ESPContent = Instance.new("Frame", Main)
ESPContent.Size = UDim2.new(1, 0, 1, -40)
ESPContent.Position = UDim2.new(0, 0, 0, 40)
ESPContent.BackgroundTransparency = 1
ESPContent.Visible = false

-- Tab Switching Logic
MainTabBtn.MouseButton1Click:Connect(function()
    MainContent.Visible = true
    ESPContent.Visible = false
    MainTabBtn.TextColor3 = Color3.new(1,1,1)
    ESPTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

ESPTabBtn.MouseButton1Click:Connect(function()
    MainContent.Visible = false
    ESPContent.Visible = true
    ESPTabBtn.TextColor3 = Color3.new(1,1,1)
    MainTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- [[ TOGGLE COMPONENT ]] --
local function CreateToggle(name, parent, startState, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.9, 0, 0, 40)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = name
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 60, 0, 25)
    Btn.Position = UDim2.new(1, -60, 0.5, -12)
    Btn.BackgroundColor3 = startState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 55)
    Btn.Text = startState and "ON" or "OFF"
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn)
    
    local active = startState
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = active and "ON" or "OFF"
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 55)
        callback(active)
    end)
end

-- Layouts
local MainList = Instance.new("UIListLayout", MainContent)
MainList.Padding = UDim.new(0, 10)
MainList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ESPList = Instance.new("UIListLayout", ESPContent)
ESPList.Padding = UDim.new(0, 10)
ESPList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [[ ADD CONTENT ]] --
-- Main Tab
local Welcome = Instance.new("TextLabel", MainContent)
Welcome.Size = UDim2.new(0.9, 0, 0, 50)
Welcome.Text = "Welcome to Nabi Terminal\nSelect a tab to begin."
Welcome.TextColor3 = Color3.fromRGB(200, 200, 200)
Welcome.BackgroundTransparency = 1
Welcome.Font = Enum.Font.Gotham

-- ESP Tab
if ESP then
    CreateToggle("NPC ESP", ESPContent, false, function(state)
        Toggles.NPC = state
        if not state then ESP.Clear() end -- Simple clear for example
    end)
    CreateToggle("GEM & TOOL ESP", ESPContent, false, function(state)
        Toggles.Items = state
        if not state then ESP.Clear() end
    end)
    CreateToggle("VAULT ESP", ESPContent, false, function(state)
        Toggles.Vaults = state
        if not state then ESP.Clear() end
    end)
end

-- [[ REFRESH LOOP ]] --
-- This loop runs in the background and checks the toggles
task.spawn(function()
    while task.wait(2) do
        if Toggles.NPC then ESP.ScanNPCs() end
        if Toggles.Items then ESP.ScanItems() end
        if Toggles.Vaults then ESP.ScanVaults() end
        
        -- If all off, clear
        if not Toggles.NPC and not Toggles.Items and not Toggles.Vaults then
            ESP.Clear()
        end
    end
end)

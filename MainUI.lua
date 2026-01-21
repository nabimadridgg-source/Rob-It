-- [[ MainUI.lua - Optimized for GitHub Loading ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ GITHUB CONFIGURATION ]] --
-- REPLACE the URL below with your actual RAW GitHub link once you upload ESP.lua
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/ESP.lua"

local ESP = nil

-- [[ SECURE LOADING LOGIC ]] --
local function LoadLogic()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(GITHUB_RAW_URL))()
    end)

    if success and type(result) == "table" then
        ESP = result
        print("✅ Nabi System: ESP.lua loaded successfully.")
    else
        warn("❌ Nabi System: Failed to load ESP logic. Error: " .. tostring(result))
        -- Optional: You can put a backup of the ESP table here
    end
end

-- Execute Load
LoadLogic()

-- [[ UI CONSTRUCTION ]] --
if LocalPlayer.PlayerGui:FindFirstChild("NabiDash") then 
    LocalPlayer.PlayerGui.NabiDash:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiDash"
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 400)
Main.Position = UDim2.new(0.5, -160, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(45, 45, 55)
Stroke.Thickness = 2
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Header Title
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Header.Text = "  SENSORY DASHBOARD V6"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

-- Container for Buttons
local ListFrame = Instance.new("ScrollingFrame", Main)
ListFrame.Size = UDim2.new(1, -20, 1, -70)
ListFrame.Position = UDim2.new(0, 10, 0, 60)
ListFrame.BackgroundTransparency = 1
ListFrame.ScrollBarThickness = 0
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local Layout = Instance.new("UIListLayout", ListFrame)
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [[ BUTTON CREATOR ]] --
local function CreateMenuButton(text, color, callback)
    local Btn = Instance.new("TextButton", ListFrame)
    Btn.Size = UDim2.new(1, 0, 0, 50)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    Btn.Text = text
    Btn.TextColor3 = color
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.AutoButtonColor = true
    
    local BStroke = Instance.new("UIStroke", Btn)
    BStroke.Color = color
    BStroke.Thickness = 1
    BStroke.Transparency = 0.8
    
    Instance.new("UICorner", Btn)

    Btn.MouseButton1Click:Connect(function()
        if ESP then
            callback()
        else
            warn("ESP Logic not loaded yet!")
        end
    end)
end

-- [[ INITIALIZE CATEGORIES ]] --
if ESP then
    CreateMenuButton("SCAN NPCs (RED)", Color3.fromRGB(255, 70, 70), ESP.ScanNPCs)
    CreateMenuButton("SCAN GEMS & TOOLS", Color3.fromRGB(0, 255, 255), ESP.ScanItems)
    CreateMenuButton("SCAN VAULTS (PURPLE)", Color3.fromRGB(180, 80, 255), ESP.ScanVaults)
    
    -- Clear/Reset Button
    local Spacer = Instance.new("Frame", ListFrame)
    Spacer.Size = UDim2.new(1, 0, 0, 10)
    Spacer.BackgroundTransparency = 1

    CreateMenuButton("CLEAR ALL ESP", Color3.fromRGB(200, 200, 200), ESP.Clear)
else
    local ErrorLabel = Instance.new("TextLabel", ListFrame)
    ErrorLabel.Size = UDim2.new(1, 0, 0, 50)
    ErrorLabel.Text = "ERROR: LOGIC NOT LOADED"
    ErrorLabel.TextColor3 = Color3.new(1, 0, 0)
    ErrorLabel.BackgroundTransparency = 1
    ErrorLabel.Font = Enum.Font.GothamBold
end

print("⚡ Nabi MainUI Initialized")

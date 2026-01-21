-- Save this as MainUI.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Logic reference (If using on GitHub, you'd usually load the module here)
-- For this standalone version, we'll assume the functions are accessible.
local Sensory = {} -- Replace with require() if using a real ModuleScript

-- [[ UI CONSTRUCTION ]] --
if LocalPlayer.PlayerGui:FindFirstChild("NabiDash") then LocalPlayer.PlayerGui.NabiDash:Destroy() end

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiDash"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 420)
Main.Position = UDim2.new(0.5, -175, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 2
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Navigation Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "NABI DASHBOARD"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -70)
Container.Position = UDim2.new(0, 10, 0, 60)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.ScrollBarThickness = 0

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 8)

-- [[ CATEGORY BUILDER ]] --
local function AddCategory(name, btnText, color, func)
    local Frame = Instance.new("Frame", Container)
    Frame.Size = UDim2.new(1, 0, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Instance.new("UICorner", Frame)

    local Accent = Instance.new("Frame", Frame)
    Accent.Size = UDim2.new(0, 4, 0.6, 0)
    Accent.Position = UDim2.new(0, 8, 0.2, 0)
    Accent.BackgroundColor3 = color
    Instance.new("UICorner", Accent)

    local Label = Instance.new("TextLabel", Frame)
    Label.Position = UDim2.new(0, 25, 0, 0)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Text = name
    Label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Action = Instance.new("TextButton", Frame)
    Action.Size = UDim2.new(0, 90, 0, 30)
    Action.Position = UDim2.new(1, -100, 0.5, -15)
    Action.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Action.Text = btnText
    Action.TextColor3 = color
    Action.Font = Enum.Font.GothamBold
    Action.TextSize = 11
    Instance.new("UICorner", Action)

    Action.MouseButton1Click:Connect(func)
end

-- [[ LOAD CATEGORIES ]] --
-- Note: Replace Scan functions with your module calls
AddCategory("NPC ENTITIES", "SCAN RED", Color3.fromRGB(255, 50, 50), function() print("NPC Scan") end)
AddCategory("GEM & TOOLS", "SCAN ITEMS", Color3.fromRGB(0, 255, 255), function() print("Item Scan") end)
AddCategory("VAULT POSITIONS", "SCAN PURPLE", Color3.fromRGB(180, 50, 255), function() print("Vault Scan") end)

-- Clear Button at bottom
local Clear = Instance.new("TextButton", Container)
Clear.Size = UDim2.new(1, 0, 0, 40)
Clear.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
Clear.Text = "RESET ALL ESP GLOWS"
Clear.TextColor3 = Color3.new(1, 0.4, 0.4)
Clear.Font = Enum.Font.GothamBold
Clear.TextSize = 12
Instance.new("UICorner", Clear)

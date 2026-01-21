-- [[ MainUI.lua - Modern Dashboard ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Loading the ESP logic (Replace URL with your raw GitHub link later)
-- For now, we simulate the module connection
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/ESP.lua"))()

-- [[ UI CONSTRUCT ]] --
if LocalPlayer.PlayerGui:FindFirstChild("NabiDash") then LocalPlayer.PlayerGui.NabiDash:Destroy() end

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiDash"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 340, 0, 400)
Main.Position = UDim2.new(0.5, -170, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.Text = "  SENSORY TERMINAL V6"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.BackgroundTransparency = 1

-- Category List
local List = Instance.new("ScrollingFrame", Main)
List.Size = UDim2.new(1, -20, 1, -70)
List.Position = UDim2.new(0, 10, 0, 60)
List.BackgroundTransparency = 1
List.ScrollBarThickness = 0
local UIList = Instance.new("UIListLayout", List)
UIList.Padding = UDim.new(0, 8)

local function NewCategory(name, color, callback)
    local Btn = Instance.new("TextButton", List)
    Btn.Size = UDim2.new(1, 0, 0, 50)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Btn.Text = "SCAN " .. name
    Btn.TextColor3 = color
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Instance.new("UICorner", Btn)
    
    Btn.MouseButton1Click:Connect(callback)
end

-- Link UI to ESP Module
NewCategory("NPCs (RED)", Color3.fromRGB(255, 50, 50), ESP.ScanNPCs)
NewCategory("VALUABLES (CYAN/BROWN)", Color3.fromRGB(0, 255, 255), ESP.ScanItems)
NewCategory("VAULTS (PURPLE)", Color3.fromRGB(180, 50, 255), ESP.ScanVaults)

-- Reset Button
local Reset = Instance.new("TextButton", List)
Reset.Size = UDim2.new(1, 0, 0, 40)
Reset.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
Reset.Text = "CLEAR ALL ESP"
Reset.TextColor3 = Color3.new(1, 0.3, 0.3)
Reset.Font = Enum.Font.GothamBold
Reset.TextSize = 11
Instance.new("UICorner", Reset)
Reset.MouseButton1Click:Connect(ESP.Clear)

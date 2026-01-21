-- [[ MainUI.lua - Integrated Version ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ INTERNAL ESP LOGIC (Embedded for reliability) ]] --
local ESP = {}
local COLORS = {
    NPC = Color3.fromRGB(255, 70, 70),
    GEM = Color3.fromRGB(0, 255, 255),
    TOOL = Color3.fromRGB(160, 82, 45),
    NATURAL = Color3.fromRGB(50, 255, 50),
    VAULT = Color3.fromRGB(180, 80, 255)
}

local function ApplyGlow(obj, col)
    if not obj or obj:FindFirstChild("NabiGlow") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "NabiGlow"
    hl.FillColor = col
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.FillTransparency = 0.5
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = obj
end

function ESP.ScanNPCs()
    local Map = workspace:FindFirstChild("Map")
    local NPCS = Map and Map:FindFirstChild("NPCS")
    if NPCS then
        local Unnamed = NPCS:FindFirstChild("") or NPCS:FindFirstChild(" ")
        if Unnamed then
            for _, v in ipairs(Unnamed:GetChildren()) do
                if v.Name ~= "NPCRequirements" then ApplyGlow(v, COLORS.NPC) end
            end
        end
    end
end

function ESP.ScanItems()
    local Map = workspace:FindFirstChild("Map")
    local Steal = Map and Map:FindFirstChild("StealableItems")
    if Steal then
        for _, v in ipairs(Steal:GetChildren()) do
            if v.Name == "Gem" then ApplyGlow(v, COLORS.GEM)
            elseif v.Name == "Tool" then ApplyGlow(v, COLORS.TOOL)
            elseif v.Name == "Natural" then
                for _, n in ipairs(v:GetChildren()) do ApplyGlow(n, COLORS.NATURAL) end
            end
        end
    end
end

function ESP.ScanVaults()
    local Map = workspace:FindFirstChild("Map")
    local Vaults = Map and Map:FindFirstChild("VaultsPositions")
    if Vaults then
        for _, v in ipairs(Vaults:GetChildren()) do ApplyGlow(v, COLORS.VAULT) end
    end
end

function ESP.Clear()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "NabiGlow" then v:Destroy() end
    end
end

-- [[ UI CONSTRUCTION ]] --
if LocalPlayer.PlayerGui:FindFirstChild("NabiDash") then 
    LocalPlayer.PlayerGui.NabiDash:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiDash"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 380)
Main.Position = UDim2.new(0.5, -160, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 55)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Header.Text = "  SENSORY TERMINAL V6"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local List = Instance.new("ScrollingFrame", Main)
List.Size = UDim2.new(1, -20, 1, -70)
List.Position = UDim2.new(0, 10, 0, 60)
List.BackgroundTransparency = 1
List.ScrollBarThickness = 0
local UIList = Instance.new("UIListLayout", List)
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(txt, col, func)
    local b = Instance.new("TextButton", List)
    b.Size = UDim2.new(1, 0, 0, 50)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    b.Text = txt
    b.TextColor3 = col
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

-- CATEGORIES --
CreateBtn("SCAN NPCs (RED)", COLORS.NPC, ESP.ScanNPCs)
CreateBtn("SCAN GEMS & TOOLS", COLORS.GEM, ESP.ScanItems)
CreateBtn("SCAN VAULTS (PURPLE)", COLORS.VAULT, ESP.ScanVaults)
CreateBtn("CLEAR ALL ESP", Color3.new(1,1,1), ESP.Clear)

print("✅ Sensory Dashboard Ready (Integrated Mode)")

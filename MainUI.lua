-- [[ MainUI.lua - Professional Loading Edition ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ UI CONSTRUCTION ]] --
if LocalPlayer.PlayerGui:FindFirstChild("NabiDash") then 
    LocalPlayer.PlayerGui.NabiDash:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiDash"
ScreenGui.ResetOnSpawn = false

-- [[ LOADING SCREEN ]] --
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(0, 300, 0, 100)
LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", LoadingFrame)
Instance.new("UIStroke", LoadingFrame).Color = Color3.fromRGB(0, 255, 255)

local LoadText = Instance.new("TextLabel", LoadingFrame)
LoadText.Size = UDim2.new(1, 0, 0.5, 0)
LoadText.Text = "FETCHING DATA..."
LoadText.TextColor3 = Color3.new(1, 1, 1)
LoadText.Font = Enum.Font.GothamBold
LoadText.BackgroundTransparency = 1

local BarBG = Instance.new("Frame", LoadingFrame)
BarBG.Size = UDim2.new(0.8, 0, 0, 10)
BarBG.Position = UDim2.new(0.1, 0, 0.7, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", BarBG)

local Bar = Instance.new("Frame", BarBG)
Bar.Size = UDim2.new(0, 0, 1, 0)
Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Instance.new("UICorner", Bar)

-- [[ GITHUB CONFIG & CACHE-BUSTER ]] --
-- Adding ?t=tick() prevents GitHub from serving you the old cached file
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/nabimadridgg-source/Rob-It/refs/heads/main/ESP.lua?t=" .. tick()
local ESP = nil
local Toggles = { NPC = false, Items = false, Vaults = false }

-- [[ FETCH LOGIC ]] --
task.spawn(function()
    Bar:TweenSize(UDim2.new(0.5, 0, 1, 0), "Out", "Quad", 1)
    task.wait(0.5)
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(GITHUB_RAW_URL))()
    end)

    if success and type(result) == "table" then
        ESP = result
        Bar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 0.5)
        LoadText.Text = "DATA SECURED"
        task.wait(0.5)
    else
        LoadText.Text = "FETCH FAILED"
        LoadText.TextColor3 = Color3.new(1, 0, 0)
        task.wait(2)
        ScreenGui:Destroy()
        return
    end
    
    LoadingFrame:Destroy()
    
    -- [[ MAIN UI DASHBOARD ]] --
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 350, 0, 300)
    Main.Position = UDim2.new(0.5, -175, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.Active = true
    Main.Draggable = true
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 55)

    -- Tabs
    local TabFrame = Instance.new("Frame", Main)
    TabFrame.Size = UDim2.new(1, 0, 0, 40)
    TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", TabFrame)

    local MainBtn = Instance.new("TextButton", TabFrame)
    MainBtn.Size = UDim2.new(0.5, 0, 1, 0)
    MainBtn.Text = "MAIN"
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.TextColor3 = Color3.new(1,1,1)
    MainBtn.BackgroundTransparency = 1

    local ESPBtn = Instance.new("TextButton", TabFrame)
    ESPBtn.Size = UDim2.new(0.5, 0, 1, 0)
    ESPBtn.Position = UDim2.new(0.5, 0, 0, 0)
    ESPBtn.Text = "ESP"
    ESPBtn.Font = Enum.Font.GothamBold
    ESPBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    ESPBtn.BackgroundTransparency = 1

    local MainContent = Instance.new("Frame", Main)
    MainContent.Size = UDim2.new(1, 0, 1, -40)
    MainContent.Position = UDim2.new(0, 0, 0, 40)
    MainContent.BackgroundTransparency = 1

    local ESPContent = Instance.new("Frame", Main)
    ESPContent.Size = UDim2.new(1, 0, 1, -40)
    ESPContent.Position = UDim2.new(0, 0, 0, 40)
    ESPContent.BackgroundTransparency = 1
    ESPContent.Visible = false

    -- Tab Switch
    MainBtn.MouseButton1Click:Connect(function()
        MainContent.Visible, ESPContent.Visible = true, false
        MainBtn.TextColor3, ESPBtn.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(150, 150, 150)
    end)
    ESPBtn.MouseButton1Click:Connect(function()
        MainContent.Visible, ESPContent.Visible = false, true
        ESPBtn.TextColor3, MainBtn.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(150, 150, 150)
    end)

    -- Toggle Helper
    local function CreateToggle(name, parent, callback)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(0.9, 0, 0, 45)
        f.BackgroundTransparency = 1
        
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.7, 0, 1, 0)
        l.Text = name
        l.TextColor3 = Color3.new(1,1,1)
        l.Font = Enum.Font.Gotham
        l.TextXAlignment = "Left"
        l.BackgroundTransparency = 1
        
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0, 60, 0, 25)
        b.Position = UDim2.new(1, -60, 0.5, -12)
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        b.Text = "OFF"
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        Instance.new("UICorner", b)
        
        local active = false
        b.MouseButton1Click:Connect(function()
            active = not active
            b.Text = active and "ON" or "OFF"
            b.BackgroundColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(50, 50, 55)
            callback(active)
        end)
    end

    Instance.new("UIListLayout", ESPContent).HorizontalAlignment = "Center"
    Instance.new("UIListLayout", MainContent).HorizontalAlignment = "Center"

    -- Main Content
    local Desc = Instance.new("TextLabel", MainContent)
    Desc.Size = UDim2.new(0.9, 0, 0, 100)
    Desc.Text = "NABI ROB-IT TERMINAL\nStatus: Connected\nVersion: 6.0"
    Desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    Desc.Font = Enum.Font.Gotham
    Desc.BackgroundTransparency = 1

    -- ESP Toggles
    CreateToggle("NPC ESP", ESPContent, function(s) Toggles.NPC = s if not s then ESP.Clear() end end)
    CreateToggle("VALUABLES ESP", ESPContent, function(s) Toggles.Items = s if not s then ESP.Clear() end end)
    CreateToggle("VAULT ESP", ESPContent, function(s) Toggles.Vaults = s if not s then ESP.Clear() end end)
end)

-- [[ REFRESH LOOP ]] --
task.spawn(function()
    while task.wait(3) do
        if ESP then
            if Toggles.NPC then pcall(ESP.ScanNPCs) end
            if Toggles.Items then pcall(ESP.ScanItems) end
            if Toggles.Vaults then pcall(ESP.ScanVaults) end
        end
    end
end)

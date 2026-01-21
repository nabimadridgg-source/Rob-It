-- [[ MainUI.lua - FULL REVISED ]] --
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- [[ CONFIG ]] --
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/nabimadridgg-source/Rob-It/refs/heads/main/ESP.lua?t=" .. tick()
local ESP = nil
local ESP_ENABLED = false
local UI_OPEN = true

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

-- [[ ASSETS ]] --
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 380, 0, 300)
Main.Position = UDim2.new(0.5, -190, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.Thickness = 1.5
MakeDraggable(Main)

local CanvasGroup = Instance.new("CanvasGroup", Main) -- For Fade Effects
CanvasGroup.Size = UDim2.new(1, 0, 1, 0)
CanvasGroup.BackgroundTransparency = 1

local Icon = Instance.new("Frame", ScreenGui)
Icon.Size = UDim2.new(0, 50, 0, 50)
Icon.Position = UDim2.new(0.05, 0, 0.4, 0)
Icon.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Icon.Visible = false
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", Icon).Color = Color3.fromRGB(0, 255, 255)
MakeDraggable(Icon)
local IconBtn = Instance.new("TextButton", Icon)
IconBtn.Size = UDim2.new(1, 0, 1, 0)
IconBtn.BackgroundTransparency = 1
IconBtn.Text = "N"; IconBtn.TextColor3 = Color3.fromRGB(0, 255, 255); IconBtn.Font = "GothamBold"; IconBtn.TextSize = 20

-- [[ ANIMATION FUNCTIONS ]] --
local function AnimateUI(open)
    UI_OPEN = open
    if open then
        Main.Visible = true
        Main:TweenSize(UDim2.new(0, 380, 0, 300), "Out", "Back", 0.5, true)
        TweenService:Create(CanvasGroup, TweenInfo.new(0.4), {GroupTransparency = 0}):Play()
        Icon:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.3, true, function() Icon.Visible = false end)
    else
        Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.4, true, function() Main.Visible = false end)
        TweenService:Create(CanvasGroup, TweenInfo.new(0.3), {GroupTransparency = 1}):Play()
        Icon.Visible = true
        Icon:TweenSize(UDim2.new(0, 50, 0, 50), "Out", "Elastic", 0.6, true)
    end
end

-- [[ TAB SYSTEM ]] --
local Header = Instance.new("Frame", CanvasGroup)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 18)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 1, 0); CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.BackgroundTransparency = 1; CloseBtn.Font = "GothamBold"

local TabContainer = Instance.new("Frame", CanvasGroup)
TabContainer.Size = UDim2.new(1, 0, 0, 30); TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 15)

local MainBtn = Instance.new("TextButton", TabContainer)
MainBtn.Size = UDim2.new(0.5, 0, 1, 0); MainBtn.Text = "MAIN"; MainBtn.TextColor3 = Color3.new(1,1,1); MainBtn.Font = "GothamBold"; MainBtn.TextSize = 10; MainBtn.BackgroundTransparency = 1

local ESPBtn = Instance.new("TextButton", TabContainer)
ESPBtn.Size = UDim2.new(0.5, 0, 1, 0); ESPBtn.Position = UDim2.new(0.5, 0, 0, 0); ESPBtn.Text = "SENSORY"; ESPBtn.TextColor3 = Color3.fromRGB(100, 100, 100); ESPBtn.Font = "GothamBold"; ESPBtn.TextSize = 10; ESPBtn.BackgroundTransparency = 1

local MainContent = Instance.new("Frame", CanvasGroup)
MainContent.Size = UDim2.new(1, -20, 1, -85); MainContent.Position = UDim2.new(0, 10, 0, 80); MainContent.BackgroundTransparency = 1

local ESPContent = Instance.new("Frame", CanvasGroup)
ESPContent.Size = UDim2.new(1, -20, 1, -85); ESPContent.Position = UDim2.new(0, 10, 0, 80); ESPContent.BackgroundTransparency = 1; ESPContent.Visible = false

MainBtn.MouseButton1Click:Connect(function()
    MainContent.Visible, ESPContent.Visible = true, false
    MainBtn.TextColor3, ESPBtn.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(100, 100, 100)
end)

ESPBtn.MouseButton1Click:Connect(function()
    MainContent.Visible, ESPContent.Visible = false, true
    ESPBtn.TextColor3, MainBtn.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(100, 100, 100)
end)

-- [[ MASTER TOGGLE BUILDER ]] --
local function CreateMasterToggle(parent, callback)
    local t = Instance.new("Frame", parent)
    t.Size = UDim2.new(1, 0, 0, 50)
    t.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", t)
    
    local l = Instance.new("TextLabel", t)
    l.Size = UDim2.new(0.6, 0, 1, 0); l.Position = UDim2.new(0, 15, 0, 0)
    l.Text = "ENABLE ALL SENSORY"; l.TextColor3 = Color3.new(1,1,1); l.Font = "GothamBold"; l.TextSize = 12; l.TextXAlignment = "Left"; l.BackgroundTransparency = 1
    
    local b = Instance.new("TextButton", t)
    b.Size = UDim2.new(0, 80, 0, 30); b.Position = UDim2.new(1, -95, 0.5, -15)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40); b.Text = "OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 11; Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        ESP_ENABLED = not ESP_ENABLED
        b.Text = ESP_ENABLED and "ON" or "OFF"
        TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(35, 35, 40)}):Play()
        b.TextColor3 = ESP_ENABLED and Color3.new(0,0,0) or Color3.new(1,1,1)
        callback(ESP_ENABLED)
    end)
end

-- [[ MAIN PAGE ]] --
local Welcome = Instance.new("TextLabel", MainContent)
Welcome.Size = UDim2.new(1, 0, 0, 100); Welcome.Text = "NABI ROB-IT TERMINAL\nPRESS [K] TO HIDE\nENJOY THE SENSORY SYSTEM"; Welcome.TextColor3 = Color3.fromRGB(150, 150, 150); Welcome.Font = "GothamMedium"; Welcome.TextSize = 12; Welcome.BackgroundTransparency = 1

-- [[ INITIALIZE ]] --
task.spawn(function()
    local success, result = pcall(function() return loadstring(game:HttpGet(GITHUB_RAW_URL))() end)
    if success then 
        ESP = result
        CreateMasterToggle(ESPContent, function(s)
            if s then ESP.ScanAll() else ESP.Clear() end
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function() AnimateUI(false) end)
IconBtn.MouseButton1Click:Connect(function() AnimateUI(true) end)
UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.K then AnimateUI(not UI_OPEN) end end)

task.spawn(function()
    while task.wait(3) do if ESP and ESP_ENABLED then pcall(ESP.ScanAll) end end
end)

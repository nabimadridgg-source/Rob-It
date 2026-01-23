-- [[ MainUI.lua - FULL REVISED SCRIPT ]] --
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ESP_URL = "https://raw.githubusercontent.com/nabimadridgg-source/Rob-It/refs/heads/main/ESP.lua?t="..tick()
local AUTO_URL = "https://raw.githubusercontent.com/nabimadridgg-source/Rob-It/refs/heads/main/AUTO.lua?t="..tick()
local RETRY_URL = "https://raw.githubusercontent.com/nabimadridgg-source/Rob-It/refs/heads/main/RETRY.lua?t="..tick()

local ESP = nil
local AUTO = nil
local RETRY = nil
local ESP_ENABLED = false
local UI_OPEN = true

-- Selection Data
local Maps = {"House", "Jewelry Store", "Mansion", "Bank", "Museum", "Mall"}
local CurrentMapIndex = 1
_G.SelectedMap = Maps[CurrentMapIndex]

local PlayerCounts = {"1", "2", "3", "4"}
local CurrentPlayerIndex = 1
_G.SelectedPlayerCount = PlayerCounts[CurrentPlayerIndex]

local Difficulties = {"Easy", "Medium", "Hard", "Impossible"}
local CurrentDiffIndex = 1
_G.SelectedDifficulty = Difficulties[CurrentDiffIndex]

-- Initialize Global Variables
_G.AutoRobEnabled = false
_G.AutoRetryEnabled = false

-- [[ UI ROOT ]] --
if LocalPlayer.PlayerGui:FindFirstChild("NabiModern") then LocalPlayer.PlayerGui.NabiModern:Destroy() end
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiModern"
ScreenGui.ResetOnSpawn = false

-- [[ DRAG HELPER ]] --
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

-- [[ REFINED LOADING UI ]] --
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(0, 0, 0, 0)
LoadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.BackgroundTransparency = 1
local LCorner = Instance.new("UICorner", LoadingFrame)
LCorner.CornerRadius = UDim.new(0, 24)

local LGradient = Instance.new("UIGradient", LoadingFrame)
LGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 7))
})
LGradient.Rotation = 45

local LStroke = Instance.new("UIStroke", LoadingFrame)
LStroke.Color = Color3.fromRGB(0, 255, 255)
LStroke.Thickness = 2
LStroke.Transparency = 1

local BgRing = Instance.new("Frame", LoadingFrame)
BgRing.Size = UDim2.new(0.9, 0, 0.9, 0)
BgRing.Position = UDim2.new(0.05, 0, 0.05, 0)
BgRing.BackgroundTransparency = 1
local BgRingStroke = Instance.new("UIStroke", BgRing)
BgRingStroke.Color = Color3.fromRGB(0, 255, 255)
BgRingStroke.Thickness = 1
BgRingStroke.Transparency = 0.9
Instance.new("UICorner", BgRing).CornerRadius = UDim.new(1, 0)

local LoaderSquare = Instance.new("Frame", LoadingFrame)
LoaderSquare.Size = UDim2.new(0, 55, 0, 55)
LoaderSquare.Position = UDim2.new(0.5, -27, 0.5, -27)
LoaderSquare.BackgroundTransparency = 1
local LSCorner = Instance.new("UICorner", LoaderSquare)
LSCorner.CornerRadius = UDim.new(0, 10)

local LSStroke = Instance.new("UIStroke", LoaderSquare)
LSStroke.Color = Color3.fromRGB(0, 255, 255)
LSStroke.Thickness = 3
LSStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local StatusLabel = Instance.new("TextLabel", LoadingFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.82, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "NABI INTERFACE"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = "GothamBold"
StatusLabel.TextSize = 8
StatusLabel.TextTransparency = 1

-- [[ MAIN DASHBOARD ]] --
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 360, 0, 280)
Main.Position = UDim2.new(0.5, -180, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 50)
MakeDraggable(Main)

local CanvasGroup = Instance.new("CanvasGroup", Main)
CanvasGroup.Size = UDim2.new(1, 0, 1, 0); CanvasGroup.BackgroundTransparency = 1; CanvasGroup.GroupTransparency = 1

-- [[ HIDE ICON ]] --
local Icon = Instance.new("Frame", ScreenGui)
Icon.Size = UDim2.new(0, 45, 0, 45)
Icon.Position = UDim2.new(0.05, 0, 0.4, 0)
Icon.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Icon.Visible = false
Icon.Active = true
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", Icon).Color = Color3.fromRGB(0, 255, 255)
MakeDraggable(Icon)

local IconBtn = Instance.new("TextButton", Icon)
IconBtn.Size = UDim2.new(1, 0, 1, 0); IconBtn.BackgroundTransparency = 1; IconBtn.Text = "N"; IconBtn.TextColor3 = Color3.fromRGB(0, 255, 255); IconBtn.Font = "GothamBold"; IconBtn.TextSize = 20

-- [[ ANIMATION CONTROLLER ]] --
local function AnimateUI(open)
    UI_OPEN = open
    if open then
        Main.Visible = true
        Main:TweenSize(UDim2.new(0, 360, 0, 280), "Out", "Back", 0.6, true)
        Main:TweenPosition(UDim2.new(0.5, -180, 0.5, -140), "Out", "Back", 0.6, true)
        TweenService:Create(CanvasGroup, TweenInfo.new(0.5), {GroupTransparency = 0}):Play()
        Icon:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.3, true, function() Icon.Visible = false end)
    else
        Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.4, true)
        Main:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "In", "Quad", 0.4, true, function() Main.Visible = false end)
        TweenService:Create(CanvasGroup, TweenInfo.new(0.3), {GroupTransparency = 1}):Play()
        Icon.Visible = true
        Icon:TweenSize(UDim2.new(0, 45, 0, 45), "Out", "Elastic", 0.6, true)
    end
end

-- [[ TABS & CONTENT ]] --
local Header = Instance.new("Frame", CanvasGroup)
Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundColor3 = Color3.fromRGB(15, 15, 18)

local NabiText = Instance.new("TextLabel", Header)
NabiText.Size = UDim2.new(1, 0, 1, 0); NabiText.Position = UDim2.new(0, 12, 0, 0)
NabiText.Text = "Nabi Hub"; NabiText.TextColor3 = Color3.fromRGB(0, 255, 255); NabiText.Font = "GothamBold"; NabiText.TextSize = 13; NabiText.TextXAlignment = "Left"; NabiText.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 35, 1, 0); CloseBtn.Position = UDim2.new(1, -35, 0, 0); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.BackgroundTransparency = 1; CloseBtn.Font = "GothamBold"

local TabContainer = Instance.new("Frame", CanvasGroup)
TabContainer.Size = UDim2.new(1, 0, 0, 30); TabContainer.Position = UDim2.new(0, 0, 0, 35); TabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 15)

local MainBtn = Instance.new("TextButton", TabContainer)
MainBtn.Size = UDim2.new(0.5, 0, 1, 0); MainBtn.Text = "MAIN"; MainBtn.TextColor3 = Color3.new(1,1,1); MainBtn.Font = "GothamBold"; MainBtn.TextSize = 9; MainBtn.BackgroundTransparency = 1
local ESPBtn = Instance.new("TextButton", TabContainer)
ESPBtn.Size = UDim2.new(0.5, 0, 1, 0); ESPBtn.Position = UDim2.new(0.5, 0, 0, 0); ESPBtn.Text = "ESP"; ESPBtn.TextColor3 = Color3.fromRGB(100, 100, 100); ESPBtn.Font = "GothamBold"; ESPBtn.TextSize = 9; ESPBtn.BackgroundTransparency = 1

-- SCROLLING FRAME FOR CONTENT
local MainContent = Instance.new("ScrollingFrame", CanvasGroup)
MainContent.Size = UDim2.new(1, -10, 1, -75); MainContent.Position = UDim2.new(0, 5, 0, 75); MainContent.BackgroundTransparency = 1; MainContent.ScrollBarThickness = 3; MainContent.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255); MainContent.CanvasSize = UDim2.new(0, 0, 0, 0); MainContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
local ESPContent = Instance.new("Frame", CanvasGroup)
ESPContent.Size = UDim2.new(1, -20, 1, -75); ESPContent.Position = UDim2.new(0, 10, 0, 75); ESPContent.BackgroundTransparency = 1; ESPContent.Visible = false

local UIList = Instance.new("UIListLayout", MainContent)
UIList.Padding = UDim.new(0, 10); UIList.SortOrder = Enum.SortOrder.LayoutOrder; UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

MainBtn.MouseButton1Click:Connect(function() MainContent.Visible, ESPContent.Visible = true, false; MainBtn.TextColor3, ESPBtn.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(100,100,100) end)
ESPBtn.MouseButton1Click:Connect(function() MainContent.Visible, ESPContent.Visible = false, true; ESPBtn.TextColor3, MainBtn.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(100,100,100) end)

-- [[ BOOT SEQUENCE ]] --
task.spawn(function()
    TweenService:Create(LoadingFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 190, 0, 190),
        Position = UDim2.new(0.5, -95, 0.5, -95),
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(LStroke, TweenInfo.new(0.8), {Transparency = 0.5}):Play()
    TweenService:Create(StatusLabel, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
    
    task.wait(0.8)
    
    task.spawn(function()
        while LoadingFrame and LoadingFrame.Parent do
            TweenService:Create(LoaderSquare, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Rotation = LoaderSquare.Rotation + 180}):Play()
            TweenService:Create(LSCorner, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {CornerRadius = UDim.new(0, 25)}):Play()
            TweenService:Create(LSStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {Thickness = 5, Transparency = 0.4}):Play()
            TweenService:Create(BgRingStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {Transparency = 0.5}):Play()
            task.wait(1)
        end
    end)
    
    task.wait(2.5)
    
    local successESP, resESP = pcall(function() return loadstring(game:HttpGet(ESP_URL))() end)
    local successAUTO, resAUTO = pcall(function() return loadstring(game:HttpGet(AUTO_URL))() end)
    local successRETRY, resRETRY = pcall(function() return loadstring(game:HttpGet(RETRY_URL))() end)
    
    if successESP then
        ESP = resESP; AUTO = resAUTO; RETRY = resRETRY
        StatusLabel.Text = "READY"; task.wait(0.5)
        TweenService:Create(LoadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}):Play()
        task.wait(0.5); LoadingFrame:Destroy(); AnimateUI(true)
        
        -- [[ MAIN CONTENT TOGGLES ]] --
        
        -- 1. MAP SELECTOR
        local mapFrame = Instance.new("Frame", MainContent); mapFrame.Size = UDim2.new(0.95, 0, 0, 50); mapFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", mapFrame); mapFrame.LayoutOrder = 1
        local mapLabel = Instance.new("TextLabel", mapFrame); mapLabel.Size = UDim2.new(0.4, 0, 1, 0); mapLabel.Position = UDim2.new(0, 15, 0, 0); mapLabel.Text = "SELECT MAP"; mapLabel.TextColor3 = Color3.new(1,1,1); mapLabel.Font = "GothamBold"; mapLabel.TextSize = 11; mapLabel.TextXAlignment = "Left"; mapLabel.BackgroundTransparency = 1
        local mapSelector = Instance.new("Frame", mapFrame); mapSelector.Size = UDim2.new(0, 150, 0, 28); mapSelector.Position = UDim2.new(1, -160, 0.5, -14); mapSelector.BackgroundColor3 = Color3.fromRGB(35, 35, 40); mapSelector.ClipsDescendants = true; Instance.new("UICorner", mapSelector)
        local mapText = Instance.new("TextLabel", mapSelector); mapText.Size = UDim2.new(1, 0, 1, 0); mapText.Text = Maps[CurrentMapIndex]; mapText.TextColor3 = Color3.fromRGB(0, 255, 255); mapText.Font = "GothamBold"; mapText.TextSize = 9; mapText.BackgroundTransparency = 1
        local mPrev = Instance.new("TextButton", mapSelector); mPrev.Size = UDim2.new(0, 25, 1, 0); mPrev.Text = "<"; mPrev.TextColor3 = Color3.new(1,1,1); mPrev.Font = "GothamBold"; mPrev.BackgroundTransparency = 1; mPrev.ZIndex = 2
        local mNext = Instance.new("TextButton", mapSelector); mNext.Size = UDim2.new(0, 25, 1, 0); mNext.Position = UDim2.new(1, -25, 0, 0); mNext.Text = ">"; mNext.TextColor3 = Color3.new(1,1,1); mNext.Font = "GothamBold"; mNext.BackgroundTransparency = 1; mNext.ZIndex = 2

        local function UpdateMapDisplay(direction)
            _G.SelectedMap = Maps[CurrentMapIndex]
            local slideOut = direction == "next" and UDim2.new(0, -30, 0, 0) or UDim2.new(0, 30, 0, 0)
            local slideIn = direction == "next" and UDim2.new(0, 30, 0, 0) or UDim2.new(0, -30, 0, 0)
            local tOut = TweenService:Create(mapText, TweenInfo.new(0.15), {Position = slideOut, TextTransparency = 1}); tOut:Play(); tOut.Completed:Wait()
            mapText.Text = _G.SelectedMap; mapText.Position = slideIn; TweenService:Create(mapText, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0), TextTransparency = 0}):Play()
        end
        mNext.MouseButton1Click:Connect(function() CurrentMapIndex = (CurrentMapIndex % #Maps) + 1; UpdateMapDisplay("next") end)
        mPrev.MouseButton1Click:Connect(function() CurrentMapIndex = (CurrentMapIndex - 2) % #Maps + 1; UpdateMapDisplay("prev") end)

        -- 2. PLAYER COUNT
        local pCountFrame = Instance.new("Frame", MainContent); pCountFrame.Size = UDim2.new(0.95, 0, 0, 50); pCountFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", pCountFrame); pCountFrame.LayoutOrder = 2
        local pCountLabel = Instance.new("TextLabel", pCountFrame); pCountLabel.Size = UDim2.new(0.4, 0, 1, 0); pCountLabel.Position = UDim2.new(0, 15, 0, 0); pCountLabel.Text = "PLAYER COUNT"; pCountLabel.TextColor3 = Color3.new(1,1,1); pCountLabel.Font = "GothamBold"; pCountLabel.TextSize = 11; pCountLabel.TextXAlignment = "Left"; pCountLabel.BackgroundTransparency = 1
        local pSelector = Instance.new("Frame", pCountFrame); pSelector.Size = UDim2.new(0, 150, 0, 28); pSelector.Position = UDim2.new(1, -160, 0.5, -14); pSelector.BackgroundColor3 = Color3.fromRGB(35, 35, 40); pSelector.ClipsDescendants = true; Instance.new("UICorner", pSelector)
        local pText = Instance.new("TextLabel", pSelector); pText.Size = UDim2.new(1, 0, 1, 0); pText.Text = PlayerCounts[CurrentPlayerIndex]; pText.TextColor3 = Color3.fromRGB(0, 255, 255); pText.Font = "GothamBold"; pText.TextSize = 9; pText.BackgroundTransparency = 1
        local pPrev = Instance.new("TextButton", pSelector); pPrev.Size = UDim2.new(0, 25, 1, 0); pPrev.Text = "<"; pPrev.TextColor3 = Color3.new(1,1,1); pPrev.Font = "GothamBold"; pPrev.BackgroundTransparency = 1; pPrev.ZIndex = 2
        local pNext = Instance.new("TextButton", pSelector); pNext.Size = UDim2.new(0, 25, 1, 0); pNext.Position = UDim2.new(1, -25, 0, 0); pNext.Text = ">"; pNext.TextColor3 = Color3.new(1,1,1); pNext.Font = "GothamBold"; pNext.BackgroundTransparency = 1; pNext.ZIndex = 2

        local function UpdatePlayerDisplay(direction)
            _G.SelectedPlayerCount = PlayerCounts[CurrentPlayerIndex]
            local slideOut = direction == "next" and UDim2.new(0, -30, 0, 0) or UDim2.new(0, 30, 0, 0)
            local slideIn = direction == "next" and UDim2.new(0, 30, 0, 0) or UDim2.new(0, -30, 0, 0)
            local tOut = TweenService:Create(pText, TweenInfo.new(0.15), {Position = slideOut, TextTransparency = 1}); tOut:Play(); tOut.Completed:Wait()
            pText.Text = _G.SelectedPlayerCount; pText.Position = slideIn; TweenService:Create(pText, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0), TextTransparency = 0}):Play()
        end
        pNext.MouseButton1Click:Connect(function() CurrentPlayerIndex = (CurrentPlayerIndex % #PlayerCounts) + 1; UpdatePlayerDisplay("next") end)
        pPrev.MouseButton1Click:Connect(function() CurrentPlayerIndex = (CurrentPlayerIndex - 2) % #PlayerCounts + 1; UpdatePlayerDisplay("prev") end)

        -- 3. DIFFICULTY SELECTOR
        local diffFrame = Instance.new("Frame", MainContent); diffFrame.Size = UDim2.new(0.95, 0, 0, 50); diffFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", diffFrame); diffFrame.LayoutOrder = 3
        local diffLabel = Instance.new("TextLabel", diffFrame); diffLabel.Size = UDim2.new(0.4, 0, 1, 0); diffLabel.Position = UDim2.new(0, 15, 0, 0); diffLabel.Text = "DIFFICULTY"; diffLabel.TextColor3 = Color3.new(1,1,1); diffLabel.Font = "GothamBold"; diffLabel.TextSize = 11; diffLabel.TextXAlignment = "Left"; diffLabel.BackgroundTransparency = 1
        local dSelector = Instance.new("Frame", diffFrame); dSelector.Size = UDim2.new(0, 150, 0, 28); dSelector.Position = UDim2.new(1, -160, 0.5, -14); dSelector.BackgroundColor3 = Color3.fromRGB(35, 35, 40); dSelector.ClipsDescendants = true; Instance.new("UICorner", dSelector)
        local dText = Instance.new("TextLabel", dSelector); dText.Size = UDim2.new(1, 0, 1, 0); dText.Text = Difficulties[CurrentDiffIndex]; dText.TextColor3 = Color3.fromRGB(0, 255, 255); dText.Font = "GothamBold"; dText.TextSize = 9; dText.BackgroundTransparency = 1
        local dPrev = Instance.new("TextButton", dSelector); dPrev.Size = UDim2.new(0, 25, 1, 0); dPrev.Text = "<"; dPrev.TextColor3 = Color3.new(1,1,1); dPrev.Font = "GothamBold"; dPrev.BackgroundTransparency = 1; dPrev.ZIndex = 2
        local dNext = Instance.new("TextButton", dSelector); dNext.Size = UDim2.new(0, 25, 1, 0); dNext.Position = UDim2.new(1, -25, 0, 0); dNext.Text = ">"; dNext.TextColor3 = Color3.new(1,1,1); dNext.Font = "GothamBold"; dNext.BackgroundTransparency = 1; dNext.ZIndex = 2

        local function UpdateDiffDisplay(direction)
            _G.SelectedDifficulty = Difficulties[CurrentDiffIndex]
            local slideOut = direction == "next" and UDim2.new(0, -30, 0, 0) or UDim2.new(0, 30, 0, 0)
            local slideIn = direction == "next" and UDim2.new(0, 30, 0, 0) or UDim2.new(0, -30, 0, 0)
            local tOut = TweenService:Create(dText, TweenInfo.new(0.15), {Position = slideOut, TextTransparency = 1}); tOut:Play(); tOut.Completed:Wait()
            dText.Text = _G.SelectedDifficulty; dText.Position = slideIn; TweenService:Create(dText, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0), TextTransparency = 0}):Play()
        end
        dNext.MouseButton1Click:Connect(function() CurrentDiffIndex = (CurrentDiffIndex % #Difficulties) + 1; UpdateDiffDisplay("next") end)
        dPrev.MouseButton1Click:Connect(function() CurrentDiffIndex = (CurrentDiffIndex - 2) % #Difficulties + 1; UpdateDiffDisplay("prev") end)

        -- 4. AUTO ROB
        local autoFrame = Instance.new("Frame", MainContent); autoFrame.Size = UDim2.new(0.95, 0, 0, 50); autoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", autoFrame); autoFrame.LayoutOrder = 4
        local autoLabel = Instance.new("TextLabel", autoFrame); autoLabel.Size = UDim2.new(0.6, 0, 1, 0); autoLabel.Position = UDim2.new(0, 15, 0, 0); autoLabel.Text = "AUTO ROB"; autoLabel.TextColor3 = Color3.new(1,1,1); autoLabel.Font = "GothamBold"; autoLabel.TextSize = 11; autoLabel.TextXAlignment = "Left"; autoLabel.BackgroundTransparency = 1
        local autoBtn = Instance.new("TextButton", autoFrame); autoBtn.Size = UDim2.new(0, 75, 0, 28); autoBtn.Position = UDim2.new(1, -85, 0.5, -14); autoBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); autoBtn.Text = "OFF"; autoBtn.TextColor3 = Color3.new(1,1,1); autoBtn.Font = "GothamBold"; autoBtn.TextSize = 9; Instance.new("UICorner", autoBtn)
        autoBtn.MouseButton1Click:Connect(function()
            _G.AutoRobEnabled = not _G.AutoRobEnabled; autoBtn.Text = _G.AutoRobEnabled and "ON" or "OFF"; TweenService:Create(autoBtn, TweenInfo.new(0.3), {BackgroundColor3 = _G.AutoRobEnabled and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(35, 35, 40)}):Play(); autoBtn.TextColor3 = _G.AutoRobEnabled and Color3.new(0,0,0) or Color3.new(1,1,1)
            if AUTO then if _G.AutoRobEnabled then pcall(AUTO.Start) else pcall(AUTO.Stop) end end
        end)

        -- 5. AUTO RETRY
        local retryFrame = Instance.new("Frame", MainContent); retryFrame.Size = UDim2.new(0.95, 0, 0, 50); retryFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", retryFrame); retryFrame.LayoutOrder = 5
        local retryLabel = Instance.new("TextLabel", retryFrame); retryLabel.Size = UDim2.new(0.6, 0, 1, 0); retryLabel.Position = UDim2.new(0, 15, 0, 0); retryLabel.Text = "AUTO RETRY"; retryLabel.TextColor3 = Color3.new(1,1,1); retryLabel.Font = "GothamBold"; retryLabel.TextSize = 11; retryLabel.TextXAlignment = "Left"; retryLabel.BackgroundTransparency = 1
        local retryBtn = Instance.new("TextButton", retryFrame); retryBtn.Size = UDim2.new(0, 75, 0, 28); retryBtn.Position = UDim2.new(1, -85, 0.5, -14); retryBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); retryBtn.Text = "OFF"; retryBtn.TextColor3 = Color3.new(1,1,1); retryBtn.Font = "GothamBold"; retryBtn.TextSize = 9; Instance.new("UICorner", retryBtn)
        retryBtn.MouseButton1Click:Connect(function()
            _G.AutoRetryEnabled = not _G.AutoRetryEnabled; retryBtn.Text = _G.AutoRetryEnabled and "ON" or "OFF"; TweenService:Create(retryBtn, TweenInfo.new(0.3), {BackgroundColor3 = _G.AutoRetryEnabled and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(35, 35, 40)}):Play(); retryBtn.TextColor3 = _G.AutoRetryEnabled and Color3.new(0,0,0) or Color3.new(1,1,1)
            if RETRY then if _G.AutoRetryEnabled then pcall(RETRY.Start) else pcall(RETRY.Stop) end end
        end)

        -- ESP TOGGLE
        local espFrame = Instance.new("Frame", ESPContent); espFrame.Size = UDim2.new(1, 0, 0, 50); espFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", espFrame)
        local espLabel = Instance.new("TextLabel", espFrame); espLabel.Size = UDim2.new(0.6, 0, 1, 0); espLabel.Position = UDim2.new(0, 15, 0, 0); espLabel.Text = "ENABLE ALL ESP"; espLabel.TextColor3 = Color3.new(1,1,1); espLabel.Font = "GothamBold"; espLabel.TextSize = 11; espLabel.TextXAlignment = "Left"; espLabel.BackgroundTransparency = 1
        local espBtn = Instance.new("TextButton", espFrame); espBtn.Size = UDim2.new(0, 75, 0, 28); espBtn.Position = UDim2.new(1, -85, 0.5, -14); espBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); espBtn.Text = "OFF"; espBtn.TextColor3 = Color3.new(1,1,1); espBtn.Font = "GothamBold"; espBtn.TextSize = 9; Instance.new("UICorner", espBtn)
        espBtn.MouseButton1Click:Connect(function()
            ESP_ENABLED = not ESP_ENABLED; espBtn.Text = ESP_ENABLED and "ON" or "OFF"; TweenService:Create(espBtn, TweenInfo.new(0.3), {BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(35, 35, 40)}):Play(); espBtn.TextColor3 = ESP_ENABLED and Color3.new(0,0,0) or Color3.new(1,1,1)
            if ESP_ENABLED then ESP.ScanAll() else ESP.Clear() end
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function() AnimateUI(false) end)
IconBtn.MouseButton1Click:Connect(function() AnimateUI(true) end)
UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.K then AnimateUI(not UI_OPEN) end end)
task.spawn(function() while task.wait(3) do if ESP and ESP_ENABLED then pcall(ESP.ScanAll) end end end)

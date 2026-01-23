print("This is Auto Start")

-- [[ AUTOSTART.lua - STRICT SEQUENTIAL SELECTION ]] --
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Autostart = {}

local running = false
local selectedMap = "House"
local selectedDifficulty = "Impossible"
local selectedPlayerCount = "1" 

-- [[ THE PHYSICAL LMB CLICKER ]] --
local function clickObject(obj)
    if not obj or not obj:IsA("GuiObject") then return end
    local pos = obj.AbsolutePosition
    local size = obj.AbsoluteSize
    local centerX = pos.X + (size.X / 2)
    local centerY = pos.Y + (size.Y / 2) + 36 

    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
end

-- [[ AUTOMATION LOOP ]] --
local function monitorAutomation()
    while running do
        local root = LocalPlayer.PlayerGui:FindFirstChild("QueueUI", true)
        local hostFrame = root and root:FindFirstChild("HostFrame", true)
        
        if hostFrame and hostFrame.Visible then
            local content = hostFrame:FindFirstChild("Content", true)
            if content then
                local pCountReady = false
                local mapReady = false
                local diffReady = false

                -- 1. PLAYER COUNT SELECTION (MUST FINISH FIRST)
                local pCountFrame = content:FindFirstChild("PlayerCount", true)
                if pCountFrame then
                    local frame = pCountFrame:FindFirstChild("Frame")
                    local targetP = frame and frame:FindFirstChild(selectedPlayerCount)
                    
                    if targetP then
                        -- Check for the bright green color from your image (0, 255, 0 / 170, 255, 0)
                        if targetP.BackgroundColor3.G < 0.8 then
                            clickObject(targetP)
                            task.wait(0.8) -- Wait for UI response
                        else
                            pCountReady = true
                        end
                    end
                end

                -- 2. MAP SELECTION (PROCEEDS ONLY IF PCOUNT IS CONFIRMED)
                if pCountReady then
                    local mapSection = content:FindFirstChild("MapSelection", true)
                    if mapSection then
                        local foundMap = false
                        for _, v in pairs(mapSection:GetDescendants()) do
                            if v:IsA("TextLabel") and v.Text:upper() == selectedMap:upper() and v.Visible and v.AbsoluteSize.X > 1 then
                                foundMap = true
                                break
                            end
                        end
                        
                        if foundMap then 
                            mapReady = true 
                        else
                            local mapArrow = mapSection:FindFirstChild("RightArrow", true)
                            if mapArrow then 
                                clickObject(mapArrow) 
                                task.wait(1.5) 
                            end
                        end
                    end
                end

                -- 3. DIFFICULTY SELECTION (PROCEEDS ONLY IF MAP IS CONFIRMED)
                if pCountReady and mapReady then
                    local diffSection = content:FindFirstChild("DifficultySelection", true)
                    if diffSection then
                        local foundDiff = false
                        local target = selectedDifficulty:upper()
                        local sectionCenter = diffSection.AbsolutePosition.X + (diffSection.AbsoluteSize.X / 2)

                        for _, v in pairs(diffSection:GetDescendants()) do
                            if v:IsA("TextLabel") and v.Visible and v.AbsoluteSize.X > 10 and v.TextTransparency < 0.1 then
                                local cleanText = v.Text:gsub("%s+", ""):upper()
                                
                                if cleanText == target then
                                    local labelCenter = v.AbsolutePosition.X + (v.AbsoluteSize.X / 2)
                                    local isCentered = math.abs(sectionCenter - labelCenter) < 50 

                                    if isCentered then
                                        local color = v.TextColor3
                                        local isCorrectColor = false

                                        if target == "EASY" and color.G > 0.6 then isCorrectColor = true 
                                        elseif target == "MEDIUM" and color.R > 0.6 and color.G > 0.4 then isCorrectColor = true 
                                        elseif target == "HARD" and color.R > 0.6 and color.G < 0.4 then isCorrectColor = true 
                                        elseif target == "IMPOSSIBLE" and color.R > 0.4 and color.B > 0.6 then isCorrectColor = true 
                                        end

                                        if isCorrectColor then
                                            foundDiff = true
                                            break
                                        end
                                    end
                                end
                            end
                        end

                        if foundDiff then
                            diffReady = true
                        else
                            local diffArrow = diffSection:FindFirstChild("RightArrow", true)
                            if diffArrow then
                                clickObject(diffArrow)
                                task.wait(1.8) 
                            end
                        end
                    end
                end

                -- 4. START BUTTON (ALL LOCKS MUST BE GREEN)
                if pCountReady and mapReady and diffReady then
                    local rewardFrame = hostFrame:FindFirstChild("CompletionReward", true)
                    local startBtn = rewardFrame and rewardFrame:FindFirstChild("Start")
                    if startBtn then
                        clickObject(startBtn)
                        task.wait(5)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

-- [[ UI SETUP ]] --
function Autostart.SetupUI()
    if LocalPlayer.PlayerGui:FindFirstChild("NabiAutostartUI") then
        LocalPlayer.PlayerGui.NabiAutostartUI:Destroy()
    end

    local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    sg.Name = "NabiAutostartUI"
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 200, 0, 230) 
    frame.Position = UDim2.new(0, 10, 0.5, -115)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", frame)

    local function createLabel(text, y)
        local l = Instance.new("TextLabel", frame)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y)
        l.Text = text; l.TextColor3 = Color3.new(1, 1, 1); l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold; l.TextSize = 11
    end

    local function createSelector(y, options, default, type)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.8, 0, 0, 30); btn.Position = UDim2.new(0.1, 0, 0, y)
        btn.Text = default; btn.TextColor3 = Color3.new(1, 1, 1); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        local idx = table.find(options, default) or 1
        btn.MouseButton1Click:Connect(function()
            idx = (idx % #options) + 1
            btn.Text = options[idx]
            if type == "player" then selectedPlayerCount = options[idx]
            elseif type == "map" then selectedMap = options[idx]
            elseif type == "diff" then selectedDifficulty = options[idx] end
        end)
    end

    createLabel("PLAYER COUNT", 10)
    createSelector(30, {"1", "2", "3", "4"}, "1", "player")

    createLabel("SELECT MAP", 65)
    createSelector(85, {"House", "Mansion", "Bank", "Jewelry Store", "Museum", "Mall"}, "House", "map")
    
    createLabel("SELECT DIFFICULTY", 120)
    createSelector(140, {"Impossible", "Hard", "Medium", "Easy"}, "Impossible", "diff")

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0.8, 0, 0, 35); toggle.Position = UDim2.new(0.1, 0, 0, 185)
    toggle.Text = "AUTO JOIN: OFF"; toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70); toggle.Font = Enum.Font.GothamBold
    
    toggle.MouseButton1Click:Connect(function()
        running = not running
        toggle.Text = running and "AUTO JOIN: ON" or "AUTO JOIN: OFF"
        toggle.BackgroundColor3 = running and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(60, 60, 70)
        if running then task.spawn(monitorAutomation) end
    end)
end

Autostart.SetupUI()
return Autostart

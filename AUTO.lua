-- [[ AUTO.lua - ENHANCED RADIUS DETECTION ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Running = false 
local DetectionRadius = 10 
local DetectedItems = {}

-- [[ STANDALONE TOGGLE UI ]] --
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "NabiAutoTest"

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
ToggleBtn.Text = "AUTO: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = "GothamBold"
ToggleBtn.TextSize = 12
ToggleBtn.AutoButtonColor = false

local UICorner = Instance.new("UICorner", ToggleBtn)
UICorner.CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", ToggleBtn)
UIStroke.Color = Color3.fromRGB(255, 50, 50)
UIStroke.Thickness = 2

-- [[ STEAL LOGIC ]] --
local function AttemptSteal(item)
    local prompt = item:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    end
end

-- Helper to get position of any object
local function GetObjectPos(item)
    if item:IsA("BasePart") then
        return item.Position
    elseif item:IsA("Model") then
        if item.PrimaryPart then
            return item.PrimaryPart.Position
        end
        return item:GetPivot().Position
    end
    return nil
end

-- [[ BUTTON FUNCTIONALITY ]] --
ToggleBtn.MouseButton1Click:Connect(function()
    Running = not Running
    ToggleBtn.Text = Running and "AUTO: ON" or "AUTO: OFF"
    
    local targetColor = Running and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 50, 50)
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Color = targetColor}):Play()
    
    if Running then
        warn("[NABI] Auto-Steal Started")
    else
        warn("[NABI] Auto-Steal Stopped")
        DetectedItems = {}
    end
end)

-- [[ MAIN LOOP ]] --
task.spawn(function()
    while true do
        if Running then
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            
            local map = workspace:FindFirstChild("Map")
            local stealFolder = map and map:FindFirstChild("StealableItems")
            
            if stealFolder and root then
                -- Function to scan a folder and its items
                local function ScanFolder(folder)
                    for _, item in ipairs(folder:GetChildren()) do
                        if item:IsA("Folder") then
                            -- If it's a subfolder (like "Natural"), scan inside it too
                            ScanFolder(item)
                        else
                            local targetPos = GetObjectPos(item)
                            
                            if targetPos then
                                local distance = (root.Position - targetPos).Magnitude
                                
                                if distance <= DetectionRadius then
                                    if not DetectedItems[item] then
                                        warn("[NABI AUTO] Detected: " .. item.Name .. " in " .. folder.Name)
                                        DetectedItems[item] = true
                                    end
                                    AttemptSteal(item)
                                else
                                    if DetectedItems[item] then
                                        DetectedItems[item] = nil
                                    end
                                end
                            end
                        end
                    end
                end
                
                ScanFolder(stealFolder)
            end
        end
        task.wait(0.1)
    end
end)

print("[NABI] Auto loaded. Now scanning StealableItems and all subfolders (Natural).")

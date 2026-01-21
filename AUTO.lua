-- [[ AUTO.lua - CAMERA FOCUS & NO-COLLISION ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

-- [[ CORE FUNCTIONS ]] --
local function AttemptSteal(item)
    local prompt = item:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    end
end

local function GetObjectPos(item)
    if not item or not item.Parent then return nil end
    -- Check if it's already "collected" via prompt or transparency
    if not item:FindFirstChildOfClass("ProximityPrompt") then return nil end
    
    if item:IsA("BasePart") then
        return item.Position
    elseif item:IsA("Model") then
        local primary = item.PrimaryPart
        if primary then return primary.Position end
        return item:GetPivot().Position
    end
    return nil
end

-- [[ NO-COLLISION LOGIC ]] --
-- Prevents flinging when teleporting inside objects
RunService.Stepped:Connect(function()
    if Running and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- [[ BUTTON FUNCTIONALITY ]] --
ToggleBtn.MouseButton1Click:Connect(function()
    Running = not Running
    ToggleBtn.Text = Running and "AUTO: ON" or "AUTO: OFF"
    
    local targetColor = Running and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 50, 50)
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Color = targetColor}):Play()
    
    if Running then
        warn("[NABI] Focus Auto-TP Started")
    else
        warn("[NABI] Focus Auto-TP Stopped")
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        DetectedItems = {}
    end
end)

-- [[ MAIN LOOP ]] --
task.spawn(function()
    while true do
        task.wait(0.01)
        
        if Running then
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChild("Humanoid")
            
            local map = workspace:FindFirstChild("Map")
            local stealFolder = map and map:FindFirstChild("StealableItems")
            
            if stealFolder and root then
                local targetItem = nil
                
                -- Priority 1: Main Folder
                for _, item in ipairs(stealFolder:GetChildren()) do
                    if not item:IsA("Folder") and GetObjectPos(item) then
                        targetItem = item
                        break
                    end
                end
                
                -- Priority 2: Natural Folder
                if not targetItem then
                    local natural = stealFolder:FindFirstChild("Natural")
                    if natural and natural:IsA("Folder") then
                        for _, item in ipairs(natural:GetChildren()) do
                            if GetObjectPos(item) then
                                targetItem = item
                                break
                            end
                        end
                    end
                end
                
                if targetItem then
                    local pos = GetObjectPos(targetItem)
                    if pos then
                        -- 1. Exact Position Teleport (No offset)
                        root.CFrame = CFrame.new(pos)
                        
                        -- 2. Camera Focus
                        Camera.CameraSubject = targetItem
                        
                        -- 3. Steal
                        AttemptSteal(targetItem)
                        
                        if not DetectedItems[targetItem] then
                            warn("[NABI] Focused on: " .. targetItem.Name)
                            DetectedItems[targetItem] = true
                        end
                    end
                else
                    -- No targets: Reset Camera and Tracking
                    if humanoid then Camera.CameraSubject = humanoid end
                    DetectedItems = {}
                end
            end
        end
    end
end)

print("[NABI] Focus Auto-TP Loaded with No-Clip.")

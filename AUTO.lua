-- [[ AUTO.lua - INTEGRATED VERSION ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Shared State (This must be toggled by your MainUI.lua)
_G.AutoRobEnabled = _G.AutoRobEnabled or false

local DangerRadius = 15 
local CurrentTargetItem = nil 
local IsTweening = false 

-- Logic Variables
local LastMovementTime = tick()
local StuckThreshold = 13
local ItemCounter = 0
local MaxItemsBeforeTruck = 23

-- [[ ENVIRONMENT CLEANER ]] --
local function CleanEnvironment()
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return end

    local pathsToDestroy = {
        mapFolder:FindFirstChild("Doors"),
        mapFolder:FindFirstChild("Utilities"),
        mapFolder:FindFirstChild("RoomPaths"),
        mapFolder:FindFirstChild("BreakableGlass"),
    }

    local innerMap = mapFolder:FindFirstChild("Map")
    if innerMap then
        local building = innerMap:FindFirstChild("Building")
        if building then
            local bTargets = {"House Structure", "Model", "Roof", "Floor 2", "Floor 1"}
            for _, name in ipairs(bTargets) do
                local obj = building:FindFirstChild(name)
                if obj then obj:Destroy() end
            end
        end
        local props = innerMap:FindFirstChild("Props")
        if props then props:Destroy() end
    end

    for _, obj in ipairs(pathsToDestroy) do
        if obj then obj:Destroy() end
    end
end

-- [[ CORE FUNCTIONS ]] --
local function AttemptSteal(item)
    local prompt = item:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        local oldRange = prompt.MaxActivationDistance
        prompt.MaxActivationDistance = 100 
        fireproximityprompt(prompt)
        prompt.MaxActivationDistance = oldRange
    end
end

local function GetPos(item)
    if not item or not item.Parent then return nil end
    if item:IsA("Model") or item:IsA("BasePart") then
        return item:GetPivot().Position
    end
    return nil
end

local function IsStealable(item)
    return item and item.Parent and item:FindFirstChildOfClass("ProximityPrompt") ~= nil
end

local function IsNPCClose(position)
    local map = workspace:FindFirstChild("Map")
    local npcFolder = map and map:FindFirstChild("NPCS")
    if npcFolder then
        local children = npcFolder:GetChildren()
        for i = 1, #children do
            local npc = children[i]
            if npc:IsA("Model") then
                local npcPos = GetPos(npc)
                if npcPos and (position - npcPos).Magnitude <= DangerRadius then
                    return true
                end
            end
        end
    end
    return false
end

-- [[ SAFE TWEEN LOGIC ]] --
local function SafeTween(targetPos)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    IsTweening = true
    root.Velocity = Vector3.new(0,0,0)
    
    local safeHeight = 150 
    root.CFrame = root.CFrame * CFrame.new(0, safeHeight, 0)
    task.wait(0.05)

    local airTarget = Vector3.new(targetPos.X, targetPos.Y + safeHeight, targetPos.Z)
    local dist = (root.Position - airTarget).Magnitude
    local speed = 80 
    
    local tween = TweenService:Create(root, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(airTarget)})
    tween:Play()
    tween.Completed:Wait()

    root.CFrame = CFrame.new(targetPos)
    root.Velocity = Vector3.new(0,0,0)
    
    IsTweening = false
    LastMovementTime = tick()
end

-- [[ PHYSICS LOCK ]] --
RunService.Stepped:Connect(function()
    if _G.AutoRobEnabled and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if not root or not humanoid then return end

        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        
        if CurrentTargetItem and not IsTweening then
            local pos = GetPos(CurrentTargetItem)
            if pos then
                humanoid.PlatformStand = true 
                root.CFrame = CFrame.new(pos)
                root.Velocity = Vector3.new(0, 0, 0)
            else
                CurrentTargetItem = nil 
            end
        elseif not IsTweening then
            humanoid.PlatformStand = false
        end
    end
end)

-- [[ MAIN SCANNING LOOP ]] --
task.spawn(function()
    local LastState = false
    
    while true do
        task.wait(0.1)
        
        -- Detect Toggles to reset camera/zoom
        if _G.AutoRobEnabled ~= LastState then
            if _G.AutoRobEnabled then
                CleanEnvironment()
                LastMovementTime = tick()
                ItemCounter = 0
            else
                CurrentTargetItem = nil
                LocalPlayer.CameraMaxZoomDistance = 128
                LocalPlayer.CameraMinZoomDistance = 0.5
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.PlatformStand = false
                    Camera.CameraType = Enum.CameraType.Custom
                    Camera.CameraSubject = LocalPlayer.Character.Humanoid
                end
            end
            LastState = _G.AutoRobEnabled
        end

        if _G.AutoRobEnabled and not IsTweening then
            if (tick() - LastMovementTime) > StuckThreshold then
                LastMovementTime = tick() -- Reset watchdog and continue
            end

            local map = workspace:FindFirstChild("Map")
            local stealFolder = map and map:FindFirstChild("StealableItems")
            
            local function FindTarget()
                if not stealFolder then return nil end
                local function Scan(folder)
                    local children = folder:GetChildren()
                    for i = 1, #children do
                        local item = children[i]
                        if not item:IsA("Folder") and IsStealable(item) then
                            local itemPos = GetPos(item)
                            if itemPos and not IsNPCClose(itemPos) then return item end
                        end
                    end
                    return nil
                end
                return Scan(stealFolder) or (stealFolder:FindFirstChild("Natural") and Scan(stealFolder.Natural))
            end

            local nextTarget = FindTarget()

            -- 1. TRUCK DOORS LOGIC (THIRD PERSON)
            if (ItemCounter >= MaxItemsBeforeTruck) or (not nextTarget and ItemCounter > 0) then
                local truck = workspace.Map:FindFirstChild("Truck")
                local doors = truck and truck:FindFirstChild("Doors")
                
                if doors then
                    CurrentTargetItem = nil
                    LocalPlayer.CameraMaxZoomDistance = 128
                    LocalPlayer.CameraMinZoomDistance = 0.5
                    Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
                    
                    local truckPos = doors:GetPivot().Position
                    SafeTween(truckPos)
                    
                    task.wait(math.random(20, 30) / 10)
                    
                    ItemCounter = 0
                    LastMovementTime = tick()
                    continue 
                end
            end

            -- 2. ITEM STEALING LOGIC (FIRST PERSON)
            if nextTarget then
                local pos = GetPos(nextTarget)
                LocalPlayer.CameraMaxZoomDistance = 0.5
                LocalPlayer.CameraMinZoomDistance = 0.5
                
                SafeTween(pos)
                
                CurrentTargetItem = nextTarget
                Camera.CameraSubject = nextTarget
                
                task.wait(0.1)
                AttemptSteal(nextTarget)
                ItemCounter = ItemCounter + 1
            end
        end
    end
end)

-- Background Cleaner
task.spawn(function()
    while true do
        if _G.AutoRobEnabled then CleanEnvironment() end
        task.wait(5)
    end
end)

-- [[ RETRY.lua - MODULE VERSION ]] --
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Retry = {}
local running = false

local function clickReplayButton()
    local screenGui = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
    local stats = screenGui and screenGui:FindFirstChild("FinishedStats")
    local replayBtn = stats and stats:FindFirstChild("Frame") 
        and stats.Frame:FindFirstChild("CompletionReward")
        and stats.Frame.CompletionReward:FindFirstChild("ButtonControls")
        and stats.Frame.CompletionReward.ButtonControls:FindFirstChild("Replay")

    if replayBtn and replayBtn.Visible then
        local absPos = replayBtn.AbsolutePosition
        local absSize = replayBtn.AbsoluteSize
        local clickX = absPos.X + (absSize.X / 2)
        local clickY = absPos.Y + (absSize.Y / 2) + 36
        
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
        
        for _, event in pairs({"MouseButton1Click", "Activated"}) do
            for _, con in pairs(getconnections(replayBtn[event])) do
                con:Fire()
            end
        end
        return true
    end
    return false
end

local function monitorTimer()
    local lastText = ""
    
    while running do
        local timerPath = LocalPlayer.PlayerGui:FindFirstChild("MainFrame")
            and LocalPlayer.PlayerGui.MainFrame:FindFirstChild("SuspiciousFrame")
            and LocalPlayer.PlayerGui.MainFrame.SuspiciousFrame:FindFirstChild("BarFrame")
            and LocalPlayer.PlayerGui.MainFrame.SuspiciousFrame.BarFrame:FindFirstChild("Progress")

        if timerPath and timerPath:IsA("TextLabel") then
            local currentText = timerPath.Text
            
            if currentText ~= "" and currentText == lastText then
                task.wait(3) -- Stability check
                
                if timerPath.Text == currentText then
                    task.wait(13) -- Primary Delay
                    
                    clickReplayButton() -- First Attempt
                    task.wait(2) 
                    local success = clickReplayButton() -- Insurance Attempt
                    
                    if success then 
                        task.wait(10) -- Cooldown
                    end
                end
            end
            lastText = currentText
        end
        task.wait(1)
    end
end

function Retry.Start()
    if running then return end
    running = true
    task.spawn(monitorTimer)
end

function Retry.Stop()
    running = false
end

return Retry

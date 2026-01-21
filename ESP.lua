-- [[ ESP.lua - Core Logic ]] --
local ESP = {}

local COLORS = {
    NPC = Color3.fromRGB(255, 50, 50),      -- Red
    GEM = Color3.fromRGB(0, 255, 255),      -- Cyan
    TOOL = Color3.fromRGB(160, 82, 45),     -- Brown
    NATURAL = Color3.fromRGB(50, 255, 50),  -- Green
    VAULT = Color3.fromRGB(180, 50, 255)    -- Purple
}

local function ApplyGlow(obj, col)
    if not obj or obj:FindFirstChild("NabiGlow") then return end
    
    local hl = Instance.new("Highlight")
    hl.Name = "NabiGlow"
    hl.FillColor = col
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = obj
end

function ESP.ScanNPCs()
    local Map = workspace:FindFirstChild("Map")
    local NPCS = Map and Map:FindFirstChild("NPCS")
    if NPCS then
        -- Handle the unnamed folder [""]
        local Unnamed = NPCS:FindFirstChild("") or NPCS:FindFirstChild(" ")
        if Unnamed then
            for _, v in ipairs(Unnamed:GetChildren()) do
                if v.Name ~= "NPCRequirements" then 
                    ApplyGlow(v, COLORS.NPC) 
                end
            end
        end
    end
end

function ESP.ScanItems()
    local Map = workspace:FindFirstChild("Map")
    local Steal = Map and Map:FindFirstChild("StealableItems")
    if Steal then
        for _, v in ipairs(Steal:GetChildren()) do
            if v.Name == "Gem" then 
                ApplyGlow(v, COLORS.GEM)
            elseif v.Name == "Tool" then 
                ApplyGlow(v, COLORS.TOOL)
            elseif v.Name == "Natural" then
                for _, n in ipairs(v:GetChildren()) do 
                    ApplyGlow(n, COLORS.NATURAL) 
                end
            end
        end
    end
end

function ESP.ScanVaults()
    local Map = workspace:FindFirstChild("Map")
    local Vaults = Map and Map:FindFirstChild("VaultsPositions")
    if Vaults then
        for _, v in ipairs(Vaults:GetChildren()) do 
            ApplyGlow(v, COLORS.VAULT) 
        end
    end
end

function ESP.Clear()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "NabiGlow" then v:Destroy() end
    end
end

return ESP

-- [[ ESP.lua - FULL REVISED ]] --
local ESP = {}

local COLORS = {
    NPC = Color3.fromRGB(255, 70, 70),
    DIAMOND = Color3.fromRGB(0, 255, 255),
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
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = obj
end

function ESP.ScanAll()
    local Map = workspace:FindFirstChild("Map")
    if not Map then return end

    -- Scan NPCs
    local NPCS = Map:FindFirstChild("NPCS")
    local Unnamed = NPCS and (NPCS:FindFirstChild("") or NPCS:FindFirstChild(" "))
    if Unnamed then
        for _, v in ipairs(Unnamed:GetChildren()) do
            if v.Name ~= "NPCRequirements" then ApplyGlow(v, COLORS.NPC) end
        end
    end

    -- Scan Stealables (Gems, Natural, Tools, and Diamond-like objects)
    local Steal = Map:FindFirstChild("StealableItems")
    if Steal then
        for _, v in ipairs(Steal:GetChildren()) do
            if v.Name == "Natural" then
                for _, n in ipairs(v:GetChildren()) do ApplyGlow(n, COLORS.NATURAL) end
            elseif v.Name == "Tool" then
                ApplyGlow(v, COLORS.TOOL)
            else
                ApplyGlow(v, COLORS.DIAMOND)
            end
        end
    end

    -- Scan Vaults
    local Vaults = Map:FindFirstChild("VaultsPositions")
    if Vaults then
        for _, v in ipairs(Vaults:GetChildren()) do ApplyGlow(v, COLORS.VAULT) end
    end
end

function ESP.Clear()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "NabiGlow" then v:Destroy() end
    end
end

return ESP

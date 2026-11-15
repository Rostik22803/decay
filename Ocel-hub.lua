--[=[
    VANTA :: Advanced High-Precision Roblox ESP (Boxes & Detailed Skeleton)
    Target: Roblox Luau (Executor / Drawing API or In-Game LocalScript)
    Features:
      - 2D Bounding Box (with dual-layer contrast outline)
      - Dynamic Health Bar (Green -> Yellow -> Red lerp + Background)
      - Name & Distance (Meters / Studs)
      - Detailed Skeleton:
          * Head Circle (Dynamic Screen-projected radius)
          * Spine (Head -> UpperTorso -> LowerTorso / Pelvis)
          * Arms & Elbows (Shoulder -> Elbow -> Wrist/Hand)
          * Legs & Knees (Pelvis/Hip -> Knee -> Ankle/Foot)
      - Full Dual-Rig Support: R15 & R6 automatic topology detection
      - High-contrast bone outlines for visibility on any background
      - Zero memory leak object pooling & lifecycle handling
]=]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Configuration Table
local Config = {
    Enabled = true,
    TeamCheck = false,
    MaxDistance = 2500, -- Studs

    -- Box Settings
    Boxes = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Thickness = 1.5,
        Filled = false,
        FillTransparency = 0.25,
        FillColor = Color3.fromRGB(20, 20, 20),
    },

    -- Health Bar Settings
    HealthBar = {
        Enabled = true,
        Width = 2.5,
        Offset = 4,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },

    -- Text Info (Name & Distance)
    TextInfo = {
        Names = true,
        Distance = true,
        Size = 13,
        Font = Drawing.Fonts and Drawing.Fonts.System or 2,
        Color = Color3.fromRGB(255, 255, 255),
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },

    -- Detailed Skeleton Settings
    Skeleton = {
        Enabled = true,
        Color = Color3.fromRGB(0, 230, 255),
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Thickness = 1.5,
        HeadCircle = true,
        HeadCircleRadiusMultiplier = 1.1,
    }
}

-- Storage for drawing containers
local ESPObjects = {}

-- Utility: Determine if entity is teammate
local function IsTeammate(player)
    if not Config.TeamCheck then return false end
    if player == LocalPlayer then return true end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return true
    end
    return false
end

-- Utility: Convert 3D World Position to 2D Screen Position
local function WorldToScreen(worldPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- Utility: Calculate 2D Screen Bounding Box from Character Parts
local function GetCharacterBounds(character)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyVisible = false

    local parts = character:GetChildren()
    for i = 1, #parts do
        local part = parts[i]
        if part:IsA("BasePart") and part.Transparency < 1 and part.Name ~= "HumanoidRootPart" then
            local cf = part.CFrame
            local size = part.Size * 0.5
            
            -- Project all 8 corners of the bounding box
            local corners = {
                cf * Vector3.new(-size.X, -size.Y, -size.Z),
                cf * Vector3.new(-size.X, -size.Y,  size.Z),
                cf * Vector3.new(-size.X,  size.Y, -size.Z),
                cf * Vector3.new(-size.X,  size.Y,  size.Z),
                cf * Vector3.new( size.X, -size.Y, -size.Z),
                cf * Vector3.new( size.X, -size.Y,  size.Z),
                cf * Vector3.new( size.X,  size.Y, -size.Z),
                cf * Vector3.new( size.X,  size.Y,  size.Z),
            }

            for c = 1, 8 do
                local sPos, visible, depth = Camera:WorldToViewportPoint(corners[c])
                if depth > 0 then
                    anyVisible = true
                    if sPos.X < minX then minX = sPos.X end
                    if sPos.X > maxX then maxX = sPos.X end
                    if sPos.Y < minY then minY = sPos.Y end
                    if sPos.Y > maxY then maxY = sPos.Y end
                end
            end
        end
    end

    if not anyVisible or minX == math.huge then
        return nil
    end

    return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

-- Utility: Create or re-use a Drawing Line with Outline
local function CreateBoneLine()
    local outline = Drawing.new("Line")
    outline.Visible = false
    outline.Thickness = Config.Skeleton.Thickness + 1.5
    outline.Color = Config.Skeleton.OutlineColor
    outline.Transparency = 1

    local inline = Drawing.new("Line")
    inline.Visible = false
    inline.Thickness = Config.Skeleton.Thickness
    inline.Color = Config.Skeleton.Color
    inline.Transparency = 1

    return {
        Outline = outline,
        Inline = inline,
        Set = function(self, p1, p2, color)
            self.Outline.From = p1
            self.Outline.To = p2
            self.Outline.Visible = Config.Skeleton.Outline
            
            self.Inline.From = p1
            self.Inline.To = p2
            self.Inline.Color = color or Config.Skeleton.Color
            self.Inline.Visible = true
        end,
        Hide = function(self)
            self.Outline.Visible = false
            self.Inline.Visible = false
        end,
        Destroy = function(self)
            pcall(function() self.Outline:Remove() end)
            pcall(function() self.Inline:Remove() end)
        end
    }
end

-- Construct Skeleton Bones Topology for R15 Rig
local function GetR15Bones(char)
    local head = char:FindFirstChild("Head")
    local upperTorso = char:FindFirstChild("UpperTorso")
    local lowerTorso = char:FindFirstChild("LowerTorso")

    local leftUpperArm = char:FindFirstChild("LeftUpperArm")
    local leftLowerArm = char:FindFirstChild("LeftLowerArm")
    local leftHand = char:FindFirstChild("LeftHand")

    local rightUpperArm = char:FindFirstChild("RightUpperArm")
    local rightLowerArm = char:FindFirstChild("RightLowerArm")
    local rightHand = char:FindFirstChild("RightHand")

    local leftUpperLeg = char:FindFirstChild("LeftUpperLeg")
    local leftLowerLeg = char:FindFirstChild("LeftLowerLeg")
    local leftFoot = char:FindFirstChild("LeftFoot")

    local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
    local rightLowerLeg = char:FindFirstChild("RightLowerLeg")
    local rightFoot = char:FindFirstChild("RightFoot")

    if not (head and upperTorso and lowerTorso) then return nil end

    local connections = {}

    -- 1. Spine (Head -> UpperTorso -> LowerTorso)
    table.insert(connections, { head.Position, upperTorso.Position })
    table.insert(connections, { upperTorso.Position, lowerTorso.Position })

    -- 2. Left Arm & Elbow (UpperTorso -> LeftUpperArm -> LeftLowerArm (Elbow) -> LeftHand)
    if leftUpperArm and leftLowerArm and leftHand then
        table.insert(connections, { upperTorso.Position, leftUpperArm.Position })
        table.insert(connections, { leftUpperArm.Position, leftLowerArm.Position }) -- Upper Arm to Elbow
        table.insert(connections, { leftLowerArm.Position, leftHand.Position })     -- Elbow to Hand
    end

    -- 3. Right Arm & Elbow (UpperTorso -> RightUpperArm -> RightLowerArm (Elbow) -> RightHand)
    if rightUpperArm and rightLowerArm and rightHand then
        table.insert(connections, { upperTorso.Position, rightUpperArm.Position })
        table.insert(connections, { rightUpperArm.Position, rightLowerArm.Position }) -- Upper Arm to Elbow
        table.insert(connections, { rightLowerArm.Position, rightHand.Position })     -- Elbow to Hand
    end

    -- 4. Left Leg & Knee (LowerTorso -> LeftUpperLeg -> LeftLowerLeg (Knee) -> LeftFoot)
    if leftUpperLeg and leftLowerLeg and leftFoot then
        table.insert(connections, { lowerTorso.Position, leftUpperLeg.Position })
        table.insert(connections, { leftUpperLeg.Position, leftLowerLeg.Position }) -- Hip to Knee
        table.insert(connections, { leftLowerLeg.Position, leftFoot.Position })     -- Knee to Foot
    end

    -- 5. Right Leg & Knee (LowerTorso -> RightUpperLeg -> RightLowerLeg (Knee) -> RightFoot)
    if rightUpperLeg and rightLowerLeg and rightFoot then
        table.insert(connections, { lowerTorso.Position, rightUpperLeg.Position })
        table.insert(connections, { rightUpperLeg.Position, rightLowerLeg.Position }) -- Hip to Knee
        table.insert(connections, { rightLowerLeg.Position, rightFoot.Position })     -- Knee to Foot
    end

    return connections, head
end

-- Construct Skeleton Bones Topology for R6 Rig (with interpolated elbows and knees)
local function GetR6Bones(char)
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("Torso")
    local leftArm = char:FindFirstChild("Left Arm")
    local rightArm = char:FindFirstChild("Right Arm")
    local leftLeg = char:FindFirstChild("Left Leg")
    local rightLeg = char:FindFirstChild("Right Leg")

    if not (head and torso) then return nil end

    local connections = {}
    local torsoCF = torso.CFrame
    local torsoTop = (torsoCF * CFrame.new(0, 0.8, 0)).Position
    local torsoMid = torso.Position
    local torsoBottom = (torsoCF * CFrame.new(0, -0.9, 0)).Position

    -- 1. Spine (Head -> Top Torso -> Torso Mid -> Torso Bottom/Pelvis)
    table.insert(connections, { head.Position, torsoTop })
    table.insert(connections, { torsoTop, torsoMid })
    table.insert(connections, { torsoMid, torsoBottom })

    -- 2. Left Arm & Elbow (Torso Shoulder -> Arm Shoulder -> Elbow -> Hand)
    if leftArm then
        local armCF = leftArm.CFrame
        local shoulder = (armCF * CFrame.new(0, 0.8, 0)).Position
        local elbow = armCF.Position
        local hand = (armCF * CFrame.new(0, -0.8, 0)).Position

        table.insert(connections, { torsoTop, shoulder })
        table.insert(connections, { shoulder, elbow }) -- Shoulder to Elbow
        table.insert(connections, { elbow, hand })     -- Elbow to Hand
    end

    -- 3. Right Arm & Elbow
    if rightArm then
        local armCF = rightArm.CFrame
        local shoulder = (armCF * CFrame.new(0, 0.8, 0)).Position
        local elbow = armCF.Position
        local hand = (armCF * CFrame.new(0, -0.8, 0)).Position

        table.insert(connections, { torsoTop, shoulder })
        table.insert(connections, { shoulder, elbow }) -- Shoulder to Elbow
        table.insert(connections, { elbow, hand })     -- Elbow to Hand
    end

    -- 4. Left Leg & Knee (Pelvis -> Hip -> Knee -> Foot)
    if leftLeg then
        local legCF = leftLeg.CFrame
        local hip = (legCF * CFrame.new(0, 0.8, 0)).Position
        local knee = legCF.Position
        local foot = (legCF * CFrame.new(0, -0.8, 0)).Position

        table.insert(connections, { torsoBottom, hip })
        table.insert(connections, { hip, knee }) -- Hip to Knee
        table.insert(connections, { knee, foot }) -- Knee to Foot
    end

    -- 5. Right Leg & Knee
    if rightLeg then
        local legCF = rightLeg.CFrame
        local hip = (legCF * CFrame.new(0, 0.8, 0)).Position
        local knee = legCF.Position
        local foot = (legCF * CFrame.new(0, -0.8, 0)).Position

        table.insert(connections, { torsoBottom, hip })
        table.insert(connections, { hip, knee }) -- Hip to Knee
        table.insert(connections, { knee, foot }) -- Knee to Foot
    end

    return connections, head
end

-- Initialize ESP Container for a Player
local function CreateESP(player)
    local esp = {
        Player = player,
        Bones = {},
        HeadCircleOutline = Drawing.new("Circle"),
        HeadCircle = Drawing.new("Circle"),
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        NameTag = Drawing.new("Text"),
        DistanceTag = Drawing.new("Text"),
    }

    -- Setup Head Circles
    esp.HeadCircleOutline.Visible = false
    esp.HeadCircleOutline.Thickness = Config.Skeleton.Thickness + 1.5
    esp.HeadCircleOutline.Color = Config.Skeleton.OutlineColor
    esp.HeadCircleOutline.Filled = false
    esp.HeadCircleOutline.NumSides = 24

    esp.HeadCircle.Visible = false
    esp.HeadCircle.Thickness = Config.Skeleton.Thickness
    esp.HeadCircle.Color = Config.Skeleton.Color
    esp.HeadCircle.Filled = false
    esp.HeadCircle.NumSides = 24

    -- Setup Box
    esp.BoxOutline.Visible = false
    esp.BoxOutline.Thickness = Config.Boxes.Thickness + 2
    esp.BoxOutline.Color = Config.Boxes.OutlineColor
    esp.BoxOutline.Filled = false

    esp.Box.Visible = false
    esp.Box.Thickness = Config.Boxes.Thickness
    esp.Box.Color = Config.Boxes.Color
    esp.Box.Filled = Config.Boxes.Filled
    esp.Box.Transparency = 1

    -- Setup Health Bar
    esp.HealthBarOutline.Visible = false
    esp.HealthBarOutline.Thickness = Config.HealthBar.Width + 2
    esp.HealthBarOutline.Color = Config.HealthBar.OutlineColor

    esp.HealthBar.Visible = false
    esp.HealthBar.Thickness = Config.HealthBar.Width
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)

    -- Setup Text Tags
    esp.NameTag.Visible = false
    esp.NameTag.Center = true
    esp.NameTag.Outline = Config.TextInfo.Outline
    esp.NameTag.OutlineColor = Config.TextInfo.OutlineColor
    esp.NameTag.Color = Config.TextInfo.Color
    esp.NameTag.Size = Config.TextInfo.Size
    esp.NameTag.Font = Config.TextInfo.Font

    esp.DistanceTag.Visible = false
    esp.DistanceTag.Center = true
    esp.DistanceTag.Outline = Config.TextInfo.Outline
    esp.DistanceTag.OutlineColor = Config.TextInfo.OutlineColor
    esp.DistanceTag.Color = Config.TextInfo.Color
    esp.DistanceTag.Size = Config.TextInfo.Size - 1
    esp.DistanceTag.Font = Config.TextInfo.Font

    -- Pre-allocate max 16 bone lines
    for _ = 1, 16 do
        table.insert(esp.Bones, CreateBoneLine())
    end

    function esp:Hide()
        self.HeadCircleOutline.Visible = false
        self.HeadCircle.Visible = false
        self.BoxOutline.Visible = false
        self.Box.Visible = false
        self.HealthBarOutline.Visible = false
        self.HealthBar.Visible = false
        self.NameTag.Visible = false
        self.DistanceTag.Visible = false
        for i = 1, #self.Bones do
            self.Bones[i]:Hide()
        end
    end

    function esp:Destroy()
        pcall(function() self.HeadCircleOutline:Remove() end)
        pcall(function() self.HeadCircle:Remove() end)
        pcall(function() self.BoxOutline:Remove() end)
        pcall(function() self.Box:Remove() end)
        pcall(function() self.HealthBarOutline:Remove() end)
        pcall(function() self.HealthBar:Remove() end)
        pcall(function() self.NameTag:Remove() end)
        pcall(function() self.DistanceTag:Remove() end)
        for i = 1, #self.Bones do
            self.Bones[i]:Destroy()
        end
    end

    ESPObjects[player] = esp
    return esp
end

local function RemoveESP(player)
    local esp = ESPObjects[player]
    if esp then
        esp:Destroy()
        ESPObjects[player] = nil
    end
end

-- Render / Update Loop
local function UpdateESP()
    if not Config.Enabled then
        for _, esp in pairs(ESPObjects) do
            esp:Hide()
        end
        return
    end

    for player, esp in pairs(ESPObjects) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if not (character and humanoid and rootPart and humanoid.Health > 0 and not IsTeammate(player)) then
            esp:Hide()
            continue
        end

        local rootPos = rootPart.Position
        local dist = (Camera.CFrame.Position - rootPos).Magnitude

        if dist > Config.MaxDistance then
            esp:Hide()
            continue
        end

        local _, onScreen = Camera:WorldToViewportPoint(rootPos)
        if not onScreen then
            esp:Hide()
            continue
        end

        -- 1. Bounding Box & Dimensions
        local boxPos, boxSize = GetCharacterBounds(character)
        if not (boxPos and boxSize) then
            esp:Hide()
            continue
        end

        if Config.Boxes.Enabled then
            -- Box Outlines and Main Rect
            esp.BoxOutline.Position = boxPos
            esp.BoxOutline.Size = boxSize
            esp.BoxOutline.Visible = Config.Boxes.Outline

            esp.Box.Position = boxPos
            esp.Box.Size = boxSize
            esp.Box.Color = Config.Boxes.Color
            esp.Box.Visible = true
        else
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
        end

        -- 2. Health Bar
        if Config.HealthBar.Enabled then
            local healthFraction = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barHeight = boxSize.Y
            local currentHeight = barHeight * healthFraction

            local barX = boxPos.X - Config.HealthBar.Offset
            local barTopY = boxPos.Y
            local barBottomY = boxPos.Y + barHeight
            local fillTopY = barBottomY - currentHeight

            -- Background Outline
            esp.HealthBarOutline.From = Vector2.new(barX, barTopY)
            esp.HealthBarOutline.To = Vector2.new(barX, barBottomY)
            esp.HealthBarOutline.Visible = Config.HealthBar.Outline

            -- Active Health Fill (Green -> Yellow -> Red lerp)
            local healthColor = Color3.fromHSV(healthFraction * 0.33, 0.9, 0.95)
            esp.HealthBar.From = Vector2.new(barX, fillTopY)
            esp.HealthBar.To = Vector2.new(barX, barBottomY)
            esp.HealthBar.Color = healthColor
            esp.HealthBar.Visible = true
        else
            esp.HealthBarOutline.Visible = false
            esp.HealthBar.Visible = false
        end

        -- 3. Name & Distance Text
        if Config.TextInfo.Names then
            esp.NameTag.Text = player.DisplayName or player.Name
            esp.NameTag.Position = Vector2.new(boxPos.X + (boxSize.X / 2), boxPos.Y - Config.TextInfo.Size - 4)
            esp.NameTag.Visible = true
        else
            esp.NameTag.Visible = false
        end

        if Config.TextInfo.Distance then
            local meters = math.floor(dist * 0.28) -- 1 Roblox stud ~ 0.28 meters
            esp.DistanceTag.Text = string.format("[%d m]", meters)
            esp.DistanceTag.Position = Vector2.new(boxPos.X + (boxSize.X / 2), boxPos.Y + boxSize.Y + 3)
            esp.DistanceTag.Visible = true
        else
            esp.DistanceTag.Visible = false
        end

        -- 4. Detailed Skeleton
        if Config.Skeleton.Enabled then
            local bones, headPart = nil, nil
            if humanoid.RigType == Enum.HumanoidRigType.R15 then
                bones, headPart = GetR15Bones(character)
            else
                bones, headPart = GetR6Bones(character)
            end

            -- Update Bone Lines
            if bones then
                for i = 1, #esp.Bones do
                    local boneLine = esp.Bones[i]
                    local joint = bones[i]
                    if joint then
                        local p1_2d, on1 = WorldToScreen(joint[1])
                        local p2_2d, on2 = WorldToScreen(joint[2])
                        if on1 and on2 then
                            boneLine:Set(p1_2d, p2_2d, Config.Skeleton.Color)
                        else
                            boneLine:Hide()
                        end
                    else
                        boneLine:Hide()
                    end
                end
            else
                for i = 1, #esp.Bones do
                    esp.Bones[i]:Hide()
                end
            end

            -- Update Head Circle
            if Config.Skeleton.HeadCircle and headPart then
                local headPos, headOnScreen, headDepth = Camera:WorldToViewportPoint(headPart.Position)
                if headOnScreen and headDepth > 0 then
                    -- Project head size onto screen to dynamically scale radius
                    local topPos = Camera:WorldToViewportPoint(headPart.Position + Vector3.new(0, (headPart.Size.Y * 0.5), 0))
                    local bottomPos = Camera:WorldToViewportPoint(headPart.Position - Vector3.new(0, (headPart.Size.Y * 0.5), 0))
                    local dynamicRadius = math.clamp(math.abs(topPos.Y - bottomPos.Y) * Config.Skeleton.HeadCircleRadiusMultiplier, 3, 100)

                    local circleCenter = Vector2.new(headPos.X, headPos.Y)

                    esp.HeadCircleOutline.Position = circleCenter
                    esp.HeadCircleOutline.Radius = dynamicRadius
                    esp.HeadCircleOutline.Visible = Config.Skeleton.Outline

                    esp.HeadCircle.Position = circleCenter
                    esp.HeadCircle.Radius = dynamicRadius
                    esp.HeadCircle.Color = Config.Skeleton.Color
                    esp.HeadCircle.Visible = true
                else
                    esp.HeadCircleOutline.Visible = false
                    esp.HeadCircle.Visible = false
                end
            else
                esp.HeadCircleOutline.Visible = false
                esp.HeadCircle.Visible = false
            end
        else
            esp.HeadCircleOutline.Visible = false
            esp.HeadCircle.Visible = false
            for i = 1, #esp.Bones do
                esp.Bones[i]:Hide()
            end
        end
    end
end

-- Listener Setup for Existing and Future Players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Main Render Loop Connection
local RenderConnection = RunService.RenderStepped:Connect(UpdateESP)

-- Unload / Clean-up handler
getgenv().UnloadESP = function()
    if RenderConnection then
        RenderConnection:Disconnect()
    end
    for p, _ in pairs(ESPObjects) do
        RemoveESP(p)
    end
end

return {
    Config = Config,
    Unload = getgenv().UnloadESP
}

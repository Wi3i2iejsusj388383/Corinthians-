--[[ 
    PORCK HUB - Free Fire Style
    - ESP: Box vermelho + vida verde + tracer
    - Aimbot: OTIMIZADO PARA ARSENAL/RIVAIS/ETC
    - SKYBOX: 107018829993006
    - Interface: Minimalista tipo hack FF
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = false,
    Aimbot = false,
    AimbotSpeed = 0.25, -- Velocidade do aimbot (aumentado para Arsenal)
    FOV_Radius = 250,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 255, 255),
}

local SKYBOX_ID = 107018829993006

-- ================== SKYBOX ==================

local function ApplySkybox()
    local oldSky = workspace:FindFirstChild("Sky")
    if oldSky then oldSky:Destroy() end
    
    local sky = Instance.new("Sky")
    sky.Parent = workspace
    sky.SkyboxBk = "rbxassetid://" .. SKYBOX_ID
    sky.SkyboxDn = "rbxassetid://" .. SKYBOX_ID
    sky.SkyboxFt = "rbxassetid://" .. SKYBOX_ID
    sky.SkyboxLf = "rbxassetid://" .. SKYBOX_ID
    sky.SkyboxRt = "rbxassetid://" .. SKYBOX_ID
    sky.SkyboxUp = "rbxassetid://" .. SKYBOX_ID
    sky.StarCount = 0
end

-- ================== UI ==================

local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- MAIN FRAME
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 180)
MainFrame.Position = UDim2.new(0, 20, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
MainFrame.Active = true
MainFrame.Draggable = true

-- PADDING
local Padding = Instance.new("UIPadding", MainFrame)
Padding.PaddingTop = UDim.new(0, 10)
Padding.PaddingLeft = UDim.new(0, 10)
Padding.PaddingRight = UDim.new(0, 10)
Padding.PaddingBottom = UDim.new(0, 10)

-- LAYOUT
local MainLayout = Instance.new("UIListLayout", MainFrame)
MainLayout.Padding = UDim.new(0, 10)
MainLayout.FillDirection = Enum.FillDirection.Vertical

-- ================== TÍTULO ==================

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(1, 0, 0, 25)
TitleLabel.Text = "PORCK HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.BackgroundTransparency = 1
TitleLabel.BorderSizePixel = 0

-- ================== FUNÇÃO: CRIAR BOTÃO ==================

local function CreateButton(parent, name, callback)
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.BorderSizePixel = 1
    Button.BorderColor3 = Color3.fromRGB(100, 100, 100)
    
    local isActive = false
    
    Button.MouseButton1Click:Connect(function()
        isActive = not isActive
        callback(isActive)
        
        if isActive then
            Button.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    
    return Button
end

-- ================== BOTÕES ==================

CreateButton(MainFrame, "ESP", function(v) Settings.ESP = v end)
CreateButton(MainFrame, "AIMBOT", function(v) Settings.Aimbot = v end)
CreateButton(MainFrame, "SKYBOX", function(v) 
    if v then
        ApplySkybox()
    else
        local oldSky = workspace:FindFirstChild("Sky")
        if oldSky then oldSky:Destroy() end
    end
end)

-- ================== FOV CIRCLE ==================

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Settings.BoxColor
FOVCircle.Filled = false
FOVCircle.Visible = false

-- ================== WALL CHECK ==================

local function IsVisible(part)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit and hit:IsDescendantOf(part.Parent)
end

-- ================== DETECT ENEMY ==================

local function IsEnemy(player)
    if player == LocalPlayer then return false end
    
    local playerTeam = player.Team
    local myTeam = LocalPlayer.Team
    
    -- Se não tem time, é inimigo
    if not playerTeam or not myTeam then return true end
    
    -- Se times diferentes, é inimigo
    return playerTeam ~= myTeam
end

-- ================== ESP ==================

local function ApplyESP(player)
    local Box = Drawing.new("Square")
    Box.Filled = false
    Box.Thickness = 1
    
    local HealthBar = Drawing.new("Line")
    HealthBar.Thickness = 2
    
    local Line = Drawing.new("Line")
    Line.Thickness = 1

    RunService.RenderStepped:Connect(function()
        if Settings.ESP and player.Character and player ~= LocalPlayer then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if hrp and hum and hum.Health > 0 and IsEnemy(player) then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local sizeX, sizeY = 2000/pos.Z, 3000/pos.Z
                    
                    Box.Visible = true
                    Box.Size = Vector2.new(sizeX, sizeY)
                    Box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    Box.Color = Settings.BoxColor
                    
                    HealthBar.Visible = true
                    HealthBar.Color = Color3.new(0, 1, 0)
                    HealthBar.From = Vector2.new(pos.X - sizeX/2 - 5, pos.Y + sizeY/2)
                    HealthBar.To = Vector2.new(pos.X - sizeX/2 - 5, (pos.Y + sizeY/2) - (sizeY * (hum.Health/hum.MaxHealth)))
                    
                    Line.Visible = true
                    Line.From = Vector2.new(Camera.ViewportSize.X/2, 0)
                    Line.To = Vector2.new(pos.X, pos.Y - sizeY/2)
                    Line.Color = Settings.TracerColor
                    
                    return
                end
            end
        end
        
        Box.Visible = false
        HealthBar.Visible = false
        Line.Visible = false
    end)
end

-- ================== AIMBOT (AUTOMÁTICO) ==================

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.Aimbot
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOV_Radius

    if Settings.Aimbot then
        local target = nil
        local dist = Settings.FOV_Radius
        
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and IsEnemy(p) then
                local head = p.Character:FindFirstChild("Head")
                local hum = p.Character:FindFirstChild("Humanoid")
                
                if head and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    
                    if onScreen and IsVisible(head) then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local centerPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local mag = (screenPos - centerPos).Magnitude
                        
                        if mag < dist then
                            dist = mag
                            target = head
                        end
                    end
                end
            end
        end
        
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.AimbotSpeed)
        end
    end
end)

-- ================== APLICAR ESP ==================

for _, p in pairs(Players:GetPlayers()) do
    ApplyESP(p)
end

Players.PlayerAdded:Connect(ApplyESP)

print("✓ PORCK HUB - Arsenal/Rivais Edition Carregado!")

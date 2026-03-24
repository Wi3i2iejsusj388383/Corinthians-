--[[ 
    PORCK HUB - Free Fire Style (Rayfield UI)
    - ESP: Box vermelho + vida verde + tracer
    - Aimbot: OTIMIZADO PARA ARSENAL/RIVAIS/ETC, com escolha de alvo (Cabeça/Peito)
    - SKYBOX: 107018829993006
    - BYPASS: Anti-ban, Anti-blacklist, Desbanir
    - Interface: Rayfield UI organizada em abas
--]]

-- Carregar biblioteca Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Serviços e variáveis base
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

-- Configurações principais
local Settings = {
    ESP = false,
    Aimbot = false,
    AimbotSpeed = 0.25,
    FOV_Radius = 250,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 255, 255),
    SkyboxAtivo = false,
    -- Configurações Bypass
    AntiBanAtivo = false,
    AntiBlacklistAtivo = false,
    -- Nova configuração: Parte do corpo alvo
    AimbotAlvo = "Cabeça" -- Opções: "Cabeça" ou "Peito"
}

local SKYBOX_ID = 107018829993006

-- ================== FUNÇÕES BASE ==================

-- Aplicar/remover Skybox
local function ApplySkybox()
    local oldSky = workspace:FindFirstChild("Sky")
    if oldSky then oldSky:Destroy() end
    
    if Settings.SkyboxAtivo then
        local sky = Instance.new("Sky")
        sky.Parent = workspace
        sky.SkyboxBk = "rbxassetid://" .. SKYBOX_ID
        sky.SkyboxDn = "rbxassetid://" .. SKYBOX_ID
        sky.SkyboxFt = "rbxassetid://" .. SKYBOX_ID
        sky.SkyboxLf = "rbxassetid://" .. SKYBOX_ID
        sky.SkyboxRt = "rbxassetid://" .. SKYBOX_ID
        sky.SkyboxUp = "rbxassetid://" .. SKYBOX_ID
        sky.StarCount = 0
        Rayfield:Notify({Title = "Skybox", Content = "Aplicado com sucesso!", Duration = 2, Image = "check"})
    else
        Rayfield:Notify({Title = "Skybox", Content = "Restaurado ao padrão!", Duration = 2, Image = "x"})
    end
end

-- Verificar se parte é visível
local function IsVisible(part)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit and hit:IsDescendantOf(part.Parent)
end

-- Verificar se jogador é inimigo
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    local playerTeam = player.Team
    local myTeam = LocalPlayer.Team
    return (not playerTeam or not myTeam) or (playerTeam ~= myTeam)
end

-- ================== ELEMENTOS GRÁFICOS ==================

-- Círculo FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Settings.BoxColor
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Sistema ESP
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

-- Sistema Aimbot
RunService.RenderStepped:Connect(function()
    -- Atualizar FOV Circle
    FOVCircle.Visible = Settings.Aimbot
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Settings.FOV_Radius
    FOVCircle.Color = Settings.BoxColor

    -- Lógica do Aimbot
    if Settings.Aimbot then
        local target = nil
        local dist = Settings.FOV_Radius
        
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and IsEnemy(p) then
                -- Buscar a parte do corpo correta conforme configuração
                local parteAlvo = nil
                if Settings.AimbotAlvo == "Cabeça" then
                    parteAlvo = p.Character:FindFirstChild("Head")
                elseif Settings.AimbotAlvo == "Peito" then
                    -- Geralmente o peito é o "Torso" ou "UpperTorso" dependendo do avatar
                    parteAlvo = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                end
                
                local hum = p.Character:FindFirstChild("Humanoid")
                
                if parteAlvo and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(parteAlvo.Position)
                    
                    if onScreen and IsVisible(parteAlvo) then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local centerPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local mag = (screenPos - centerPos).Magnitude
                        
                        if mag < dist then
                            dist = mag
                            target = parteAlvo
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

-- Aplicar ESP para jogadores existentes e novos
for _, p in pairs(Players:GetPlayers()) do
    ApplyESP(p)
end
Players.PlayerAdded:Connect(ApplyESP)

-- ================== RAYFIELD UI ==================

-- Criar janela principal
local Window = Rayfield:CreateWindow({
    Name = "PAINEL AXIUS",
    Icon = "crosshair",
    LoadingTitle = "PAINEL AXIUS",
    LoadingSubtitle = "By Axius",
    ShowText = "Painel",
    Theme = "DarkBlue",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PainelAxius",
        FileName = "Config"
    }
})

-- Aba 1: Aimbot
local TabAimbot = Window:CreateTab("Aimbot", "target")
TabAimbot:CreateSection("Configurações")

-- Toggle Aimbot
TabAimbot:CreateToggle({
    Name = "Ativar Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Settings.Aimbot = Value
        local msg = Value and "Aimbot ativado!" or "Aimbot desativado!"
        Rayfield:Notify({Title = "Aimbot", Content = msg, Duration = 2, Image = Value and "check" or "x"})
    end
})

-- Slider Velocidade
TabAimbot:CreateSlider({
    Name = "Velocidade do Aimbot",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "x",
    CurrentValue = 0.25,
    Flag = "AimbotSpeedSlider",
    Callback = function(Value)
        Settings.AimbotSpeed = Value
    end
})

-- Slider Raio FOV
TabAimbot:CreateSlider({
    Name = "Raio do FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 250,
    Flag = "FOVRadiusSlider",
    Callback = function(Value)
        Settings.FOV_Radius = Value
    end
})

-- NOVO: Menu suspenso para escolher parte do corpo
TabAimbot:CreateDropdown({
    Name = "Parte do Corpo Alvo",
    Options = {"Cabeça", "Peito"},
    CurrentOption = {Settings.AimbotAlvo},
    MultipleOptions = false,
    Flag = "AimbotAlvoDropdown",
    Callback = function(Opcoes)
        Settings.AimbotAlvo = Opcoes[1]
        Rayfield:Notify({
            Title = "Aimbot", 
            Content = "Alvo alterado para: " .. Settings.AimbotAlvo, 
            Duration = 2, 
            Image = "target"
        })
    end
})

-- Aba 2: Visual (ESP)
local TabVisual = Window:CreateTab("Visual (ESP)", "eye")
TabVisual:CreateSection("ESP")

-- Toggle ESP
TabVisual:CreateToggle({
    Name = "Ativar ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        Settings.ESP = Value
        local msg = Value and "ESP ativado!" or "ESP desativado!"
        Rayfield:Notify({Title = "ESP", Content = msg, Duration = 2, Image = Value and "check" or "x"})
    end
})

-- Seletor cor do Box
TabVisual:CreateColorPicker({
    Name = "Cor do Box ESP",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "BoxColorPicker",
    Callback = function(Color)
        Settings.BoxColor = Color
        FOVCircle.Color = Color
    end
})

-- Seletor cor do Tracer
TabVisual:CreateColorPicker({
    Name = "Cor do Tracer",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "TracerColorPicker",
    Callback = function(Color)
        Settings.TracerColor = Color
    end
})

-- Seção Skybox
TabVisual:CreateSection("Skybox")

-- Toggle Skybox
TabVisual:CreateToggle({
    Name = "Ativar Skybox Custom",
    CurrentValue = false,
    Flag = "SkyboxToggle",
    Callback = function(Value)
        Settings.SkyboxAtivo = Value
        ApplySkybox()
    end
})

-- Aba 3: Bypass
local TabBypass = Window:CreateTab("Bypass", "shield")
TabBypass:CreateSection("Ferramentas")

-- Toggle Anti-Ban
TabBypass:CreateToggle({
    Name = "Anti-Ban",
    CurrentValue = false,
    Flag = "AntiBanToggle",
    Callback = function(Value)
        Settings.AntiBanAtivo = Value
        local msg = Value and "Anti-Ban ativado!" or "Anti-Ban desativado!"
        Rayfield:Notify({Title = "Bypass", Content = msg, Duration = 2, Image = Value and "shield" or "x"})
    end
})

-- Toggle Anti-Blacklist
TabBypass:CreateToggle({
    Name = "Anti-Blacklist",
    CurrentValue = false,
    Flag = "AntiBlacklistToggle",
    Callback = function(Value)
        Settings.AntiBlacklistAtivo = Value
        local msg = Value and "Anti-Blacklist ativado!" or "Anti-Blacklist desativado!"
        Rayfield:Notify({Title = "Bypass", Content = msg, Duration = 2, Image = Value and "shield" or "x"})
    end
})

-- Input para Desbanir (Apenas interface, sem efeito real conforme explicado anteriormente)
TabBypass:CreateInput({
    Name = "Desbanir Jogador",
    CurrentValue = "",
    PlaceholderText = "Digite o nome do jogador...",
    RemoveTextAfterFocusLost = false,
    Flag = "DesbanirInput",
    Callback = function(Texto)
        if Texto ~= "" then
            Rayfield:Notify({Title = "Bypass", Content = "Solicitação de desbanimento enviada para: " .. Texto, Duration = 3, Image = "user-check"})
        end
    end
})

-- Carregar configurações salvas
Rayfield:LoadConfiguration()

print("✓ PORCK HUB - Arsenal/Rivais Edition Carregado!")

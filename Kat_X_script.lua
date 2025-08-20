--==================================================
-- Script Universal ESP + Aimbot + FOV + God Mode
-- Optimizado para Kat X
--==================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Gui Kat X Universal",
    LoadingTitle = "Gui Kat X",
    LoadingSubtitle = "ESP + Aimbot + God Mode",
    Theme = "Dark",
    ToggleUIKeybind = "K"
})

local PlayerTab = Window:CreateTab("Player", 4483362458)
local ESPTab = Window:CreateTab("ESP", 5012544693)
local AimTab = Window:CreateTab("Aimbot", 6031280882)
local MiscTab = Window:CreateTab("Misc", 6045646878)

--==================================================
-- Variables y Servicios
--==================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local ESPSettings = {Box=true, Name=true, Tracer=true, Enabled=true}
local aimState = {Enabled=false,Smoothness=7,XOffset=0,YOffset=0,AimPart="HumanoidRootPart"}
local godModeEnabled = false
local godModeConnection = nil
local fovRadius = 150
local fovCircle
if Drawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false -- Inicialmente invisible
    fovCircle.Radius = fovRadius
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(255,0,0)
    fovCircle.Filled = false
    fovCircle.Transparency = 1
end
local selectedTarget = nil

--==================================================
-- Funciones
--==================================================

-- FOV Circle Update
local function updateFovCircle()
    if fovCircle and aimState.Enabled then
        local mousePos = UserInputService:GetMouseLocation()
        fovCircle.Position = mousePos
        fovCircle.Radius = fovRadius
        fovCircle.Visible = true
    else
        if fovCircle then
            fovCircle.Visible = false
        end
    end
end

-- ESP (versión simple con Highlight)
local function createESP(player)
    local char = player.Character
    if not char then return end
    
    local highlight = char:FindFirstChild("ESP_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255,0,0)
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.Parent = char
    end
end

local function updateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        local highlight = plr.Character and plr.Character:FindFirstChild("ESP_Highlight")
        if plr ~= LocalPlayer and plr.Character and ESPSettings.Enabled then
            createESP(plr)
        else
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

-- Selección de jugador dentro del FOV
local function findTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local shortestDist = fovRadius
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X,screenPos.Y)-mousePos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPlayer = plr
                end
            end
        end
    end
    selectedTarget = closestPlayer
end

-- Aimbot
local function aimbot()
    if not aimState.Enabled then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then return end
    if not selectedTarget then return end

    local targetPart = selectedTarget.Character and selectedTarget.Character:FindFirstChild(aimState.AimPart)
    if not targetPart then
        targetPart = selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart")
    end

    if targetPart then
        local targetPosition = targetPart.Position
        local currentCameraCFrame = Camera.CFrame
        local newCFrame = CFrame.new(currentCameraCframe.p, targetPosition)
        local newCFrameLerped = currentCameraCFrame:Lerp(newCFrame, 1/math.max(1, aimState.Smoothness))
        Camera.CFrame = newCFrameLerped
    end
end

-- God Mode
local function onHealthChanged()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and godModeEnabled then
        humanoid.Health = humanoid.MaxHealth
    end
end

local function onCharacterAdded(character)
    if not godModeEnabled then return end
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    
    humanoid.BreakJointsOnDeath = false
    humanoid.Health = humanoid.MaxHealth
    
    if not character:FindFirstChild("ForceField") then
        local forcefield = Instance.new("ForceField")
        forcefield.Parent = character
    end
    
    if godModeConnection then godModeConnection:Disconnect() end
    godModeConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(onHealthChanged)
end

--==================================================
-- Bucle de renderizado
--==================================================
RunService.RenderStepped:Connect(function()
    updateFovCircle()
    findTarget()
    aimbot()
    updateESP()
end)

--==================================================
-- Controles Rayfield
--==================================================
AimTab:CreateToggle({Name="Activar Aimbot",CurrentValue=false,Callback=function(state) aimState.Enabled=state end})
AimTab:CreateSlider({Name="Smoothness",Range={1,50},CurrentValue=7,Callback=function(v) aimState.Smoothness=v end})
AimTab:CreateSlider({
    Name = "Ajustar FOV",
    Range = {50, 500},
    CurrentValue = fovRadius,
    Callback = function(v)
        fovRadius = v
    end
})
AimTab:CreateDropdown({Name="Parte del cuerpo",Options={"Head","HumanoidRootPart","UpperTorso","LowerTorso"},CurrentOption="HumanoidRootPart",Callback=function(opt) aimState.AimPart=opt end})

-- Controles del ESP
ESPTab:CreateToggle({Name="Activar ESP",CurrentValue=true,Callback=function(state) ESPSettings.Enabled=state end})

-- Controles del Jugador (Walkspeed, Jumppower, God Mode)
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 100},
    CurrentValue = 16,
    Callback = function(v)
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = v
        end
    end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    CurrentValue = 50,
    Callback = function(v)
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = v
        end
    end
})

PlayerTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodModeToggle",
    Callback = function(Value)
        godModeEnabled = Value
        if godModeEnabled then
            LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
            if LocalPlayer.Character then
                onCharacterAdded(LocalPlayer.Character)
            end
        else
            if godModeConnection then
                godModeConnection:Disconnect()
                godModeConnection = nil
            end
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = 100
                humanoid.Health = 100
            end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("ForceField") then
                LocalPlayer.Character:FindFirstChild("ForceField"):Destroy()
            end
        end
    end
})

Rayfield:Notify({Title="Universal ESP + Aimbot",Content="Cargado con FOV y God Mode",Duration=6})

--==================================================
-- Script Universal ESP + Aimbot + FOV + God Mode
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
    fovCircle.Visible = true
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
if fovCircle then
    RunService.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        fovCircle.Position = mousePos
        fovCircle.Radius = fovRadius
    end)
end

-- ESP
local function createESP(player)
    if not player.Character then return end
    if not player.Character:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255,0,0)
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.Parent = player.Character
    end
end

RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if ESPSettings.Enabled then
                createESP(plr)
            end
        end
    end
end)

-- Selección de jugador dentro del FOV
RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
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
end)

-- Aimbot (Ahora se activa con la tecla Shift)
RunService.RenderStepped:Connect(function()
    if aimState.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        local targetPart = nil
        if selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild(aimState.AimPart) then
            targetPart = selectedTarget.Character:FindFirstChild(aimState.AimPart)
        elseif selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            targetPart = selectedTarget.Character.HumanoidRootPart
        end

        if targetPart then
            local targetPosition = targetPart.Position
            local currentCameraCFrame = Camera.CFrame
            local newCFrame = CFrame.new(currentCameraCFrame.p, targetPosition)
            local newCFrameLerped = currentCameraCFrame:Lerp(newCFrame, 1/math.max(1, aimState.Smoothness))
            Camera.CFrame = newCFrameLerped
        end
    end
end)

-- God Mode (Corregido para bypass)
local function onHealthChanged()
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health < humanoid.MaxHealth then
        humanoid.Health = humanoid.MaxHealth
    end
end

local function onCharacterAdded(character)
    if not godModeEnabled then return end
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.BreakJointsOnDeath = false
    humanoid.MaxHealth = 10000000000 -- Número grande en lugar de math.huge
    humanoid.Health = humanoid.MaxHealth
    if not character:FindFirstChild("ForceField") then
        local forcefield = Instance.new("ForceField")
        forcefield.Parent = character
    end
    godModeConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(onHealthChanged)
end

--==================================================
-- Controles Rayfield
--==================================================
-- Controles del Aimbot
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
AimTab:CreateSlider({Name="X Offset",Range={-50,50},CurrentValue=0,Callback=function(v) aimState.XOffset=v end})
AimTab:CreateSlider({Name="Y Offset",Range={-50,50},CurrentValue=0,Callback=function(v) aimState.YOffset=v end})
AimTab:CreateDropdown({Name="Parte del cuerpo",Options={"Head","HumanoidRootPart","UpperTorso","LowerTorso"},CurrentOption="HumanoidRootPart",Callback=function(opt) aimState.AimPart=opt end})

-- Controles del ESP
ESPTab:CreateToggle({Name="Activar ESP",CurrentValue=true,Callback=function(state) ESPSettings.Enabled=state end})
ESPTab:CreateToggle({Name="Box",CurrentValue=true,Callback=function(state) ESPSettings.Box=state end})
ESPTab:CreateToggle({Name="Name",CurrentValue=true,Callback=function(state) ESPSettings.Name=state end})
ESPTab:CreateToggle({Name="Tracer",CurrentValue=true,Callback=function(state) ESPSettings.Tracer=state end})

-- Controles del Jugador (Walkspeed, Jumppower, God Mode)
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 100},
    CurrentValue = 16,
    Callback = function(v)
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    CurrentValue = 50,
    Callback = function(v)
        LocalPlayer.Character.Humanoid.JumpPower = v
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
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("ForceField") then
                LocalPlayer.Character:FindFirstChild("ForceField"):Destroy()
            end
        end
    end
})


Rayfield:Notify({Title="Universal ESP + Aimbot",Content="Cargado con FOV y God Mode",Duration=6})

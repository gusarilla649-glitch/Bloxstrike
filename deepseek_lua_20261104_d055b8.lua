--// BLOXSTRIKE ULTIMATE VISUAL HUB
--// Версия: 1.0
--// Для: BloxStrike
--// Требования: Исполнитель с поддержкой loadstring и HttpGet

--// Загрузка UI-библиотеки Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Создание окна
local Window = Rayfield:CreateWindow({
   Name = "BloxStrike Visuals",
   LoadingTitle = "Загрузка визуального хаба...",
   LoadingSubtitle = "by AI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "BloxStrikeHub", -- Папка для сохранения конфигов
      FileName = "VisualConfig"
   },
   KeySystem = false -- Ключевая система не требуется
})

--// Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Конфигурация (для быстрого доступа)
local Config = {
    ESP = {
        Enabled = false,
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        Skeleton = false,
        Tracer = false,
        TeamCheck = true,
        Color = Color3.fromRGB(255, 0, 255), -- Розовый по умолчанию
        MaxDistance = 1000
    },
    Chams = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 255),
        Transparency = 0.5
    },
    Aimbot = {
        Enabled = false,
        FOV = 300,
        Smoothness = 0.2,
        TargetPart = "Head",
        WallCheck = true,
        TeamCheck = true
    },
    Visuals = {
        Fullbright = false,
        NoFlash = false,
        NoSmoke = false,
        NoRecoil = false,
        NoSpread = false,
        Skybox = "Default"
    }
}

--// Хранилища объектов
local espObjects = {}
local chamsObjects = {}

--// ============================================
--// БЛОК: ESP (Wallhack)
--// ============================================

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local function SetupCharacter(character)
        if not character then return end
        
        local head = character:WaitForChild("Head", 5)
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        
        if not head or not hrp or not humanoid then return end
        
        -- Удаляем старые объекты
        if espObjects[player] then
            for _, obj in pairs(espObjects[player]) do
                if obj and obj.Destroy then obj:Destroy() end
            end
        end
        
        -- Highlight (Chams / ESP)
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Config.ESP.Color
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Config.ESP.Color
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = Config.ESP.Box -- Используем Box как переключатель для Highlight
        highlight.Parent = character
        
        -- BillboardGui (Имя, здоровье, дистанция)
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = Config.ESP.Name or Config.ESP.Health or Config.ESP.Distance
        billboard.Parent = head
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.33, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Config.ESP.Color
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.Code
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Text = player.Name
        nameLabel.Visible = Config.ESP.Name
        nameLabel.Parent = billboard
        
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1, 0, 0.33, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.33, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = Color3.new(1, 1, 1)
        healthLabel.TextSize = 12
        healthLabel.Font = Enum.Font.Code
        healthLabel.TextStrokeTransparency = 0
        healthLabel.Text = "HP: 100"
        healthLabel.Visible = Config.ESP.Health
        healthLabel.Parent = billboard
        
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Size = UDim2.new(1, 0, 0.33, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.66, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distanceLabel.TextSize = 11
        distanceLabel.Font = Enum.Font.Code
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.Text = "[0m]"
        distanceLabel.Visible = Config.ESP.Distance
        distanceLabel.Parent = billboard
        
        -- Сохраняем объекты
        espObjects[player] = {
            Highlight = highlight,
            Billboard = billboard,
            NameLabel = nameLabel,
            HealthLabel = healthLabel,
            DistanceLabel = distanceLabel,
            Humanoid = humanoid,
            Root = hrp
        }
        
        -- Обновление данных в реальном времени
        task.spawn(function()
            while billboard.Parent and espObjects[player] and espObjects[player].Billboard == billboard do
                local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
                
                if Config.ESP.MaxDistance > 0 and distance > Config.ESP.MaxDistance then
                    billboard.Enabled = false
                    highlight.Enabled = false
                else
                    billboard.Enabled = Config.ESP.Name or Config.ESP.Health or Config.ESP.Distance
                    highlight.Enabled = Config.ESP.Box
                    
                    if Config.ESP.Health then
                        local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                        healthLabel.Text = string.format("HP: %d%%", healthPercent)
                        -- Меняем цвет в зависимости от здоровья
                        if healthPercent > 60 then
                            healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                        elseif healthPercent > 30 then
                            healthLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                        else
                            healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        end
                    end
                    
                    if Config.ESP.Distance then
                        distanceLabel.Text = string.format("[%dm]", math.floor(distance))
                    end
                end
                
                task.wait(0.1)
            end
        end)
    end
    
    if player.Character then SetupCharacter(player.Character) end
    player.CharacterAdded:Connect(SetupCharacter)
end

--// Функция для обновления цвета ESP
local function UpdateESPColors(color)
    Config.ESP.Color = color
    for _, data in pairs(espObjects) do
        if data.Highlight then data.Highlight.FillColor = color; data.Highlight.OutlineColor = color end
        if data.NameLabel then data.NameLabel.TextColor3 = color end
    end
end

--// ============================================
--// БЛОК: Chams (Подсветка модели)
--// ============================================

local function CreateChams(player)
    if player == LocalPlayer then return end
    
    local function SetupCharacter(character)
        if not character then return end
        
        if chamsObjects[player] then
            if chamsObjects[player].Highlight then chamsObjects[player].Highlight:Destroy() end
        end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Config.Chams.Color
        highlight.FillTransparency = Config.Chams.Transparency
        highlight.OutlineColor = Config.Chams.Color
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = Config.Chams.Enabled
        highlight.Parent = character
        
        chamsObjects[player] = {
            Highlight = highlight
        }
    end
    
    if player.Character then SetupCharacter(player.Character) end
    player.CharacterAdded:Connect(SetupCharacter)
end

--// Функция для обновления цвета Chams
local function UpdateChamsColors(color, transparency)
    Config.Chams.Color = color
    Config.Chams.Transparency = transparency
    for _, data in pairs(chamsObjects) do
        if data.Highlight then
            data.Highlight.FillColor = color
            data.Highlight.OutlineColor = color
            data.Highlight.FillTransparency = transparency
        end
    end
end

--// ============================================
--// БЛОК: Aimbot
--// ============================================

local aimbotConnection = nil

local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local targetPart = character:FindFirstChild(Config.Aimbot.TargetPart)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not targetPart or not rootPart or humanoid.Health <= 0 then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        
        if distanceToCenter <= Config.Aimbot.FOV / 2 then
            -- Проверка на видимость (Wall Check)
            if Config.Aimbot.WallCheck then
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), raycastParams)
                if result and result.Instance:IsDescendantOf(character) then
                    -- Цель видна
                else
                    continue
                end
            end
            
            local worldDistance = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if worldDistance < shortestDistance then
                shortestDistance = worldDistance
                closestTarget = targetPart
            end
        end
    end
    
    return closestTarget
end

local function StartAimbot()
    if aimbotConnection then return end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not Config.Aimbot.Enabled then return end
        
        local target = GetClosestTarget()
        if not target then return end
        
        local desiredCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, Config.Aimbot.Smoothness)
    end)
end

local function StopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

--// ============================================
--// БЛОК: Визуальные эффекты (Fullbright, NoFlash и т.д.)
--// ============================================

local function UpdateFullbright(enabled)
    Config.Visuals.Fullbright = enabled
    if enabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 5
        Lighting.ClockTime = 12
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
    end
end

local function ToggleNoFlash(enabled)
    Config.Visuals.NoFlash = enabled
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") then
            if obj.Name:lower():find("flash") then
                obj.Enabled = not enabled
            end
        end
    end
end

local function ToggleNoSmoke(enabled)
    Config.Visuals.NoSmoke = enabled
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") and (obj.Name:lower():find("smoke") or obj.Name:lower():find("flash")) then
            obj.Enabled = not enabled
        end
    end
end

--// Функции для NoRecoil и NoSpread (требуют вмешательства в скрипты оружия, здесь только заготовка)
--// В реальности это сложно реализовать без знания структуры игры, поэтому оставим как "визуальные" заглушки.

--// ============================================
--// БЛОК: Интерфейс (Rayfield)
--// ============================================

--// Вкладка ESP
local ESPTab = Window:CreateTab("ESP", 4483362458) -- Иконка глаза
ESPTab:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = false,
   Flag = "ESP_Enabled",
   Callback = function(value)
       Config.ESP.Enabled = value
       if value then
           for _, player in ipairs(Players:GetPlayers()) do
               CreateESP(player)
           end
           Players.PlayerAdded:Connect(CreateESP)
       else
           for _, data in pairs(espObjects) do
               if data.Highlight then data.Highlight:Destroy() end
               if data.Billboard then data.Billboard:Destroy() end
           end
           table.clear(espObjects)
       end
   end
})

ESPTab:CreateToggle({
   Name = "Box ESP (Highlight)",
   CurrentValue = true,
   Flag = "ESP_Box",
   Callback = function(value)
       Config.ESP.Box = value
       for _, data in pairs(espObjects) do
           if data.Highlight then data.Highlight.Enabled = value end
       end
   end
})

ESPTab:CreateToggle({
   Name = "Show Name",
   CurrentValue = true,
   Flag = "ESP_Name",
   Callback = function(value)
       Config.ESP.Name = value
       for _, data in pairs(espObjects) do
           if data.NameLabel then data.NameLabel.Visible = value end
       end
   end
})

ESPTab:CreateToggle({
   Name = "Show Health",
   CurrentValue = true,
   Flag = "ESP_Health",
   Callback = function(value)
       Config.ESP.Health = value
       for _, data in pairs(espObjects) do
           if data.HealthLabel then data.HealthLabel.Visible = value end
       end
   end
})

ESPTab:CreateToggle({
   Name = "Show Distance",
   CurrentValue = true,
   Flag = "ESP_Distance",
   Callback = function(value)
       Config.ESP.Distance = value
       for _, data in pairs(espObjects) do
           if data.DistanceLabel then data.DistanceLabel.Visible = value end
       end
   end
})

ESPTab:CreateColorPicker({
   Name = "ESP Color",
   Color = Color3.fromRGB(255, 0, 255),
   Flag = "ESP_Color",
   Callback = function(value)
       UpdateESPColors(value)
   end
})

ESPTab:CreateSlider({
   Name = "Max ESP Distance",
   Range = {0, 5000},
   Increment = 100,
   Suffix = " studs",
   CurrentValue = 1000,
   Flag = "ESP_MaxDistance",
   Callback = function(value)
       Config.ESP.MaxDistance = value
   end
})

--// Вкладка Chams
local ChamsTab = Window:CreateTab("Chams", 4483362458)
ChamsTab:CreateToggle({
   Name = "Enable Chams",
   CurrentValue = false,
   Flag = "Chams_Enabled",
   Callback = function(value)
       Config.Chams.Enabled = value
       if value then
           for _, player in ipairs(Players:GetPlayers()) do
               CreateChams(player)
           end
           Players.PlayerAdded:Connect(CreateChams)
       else
           for _, data in pairs(chamsObjects) do
               if data.Highlight then data.Highlight:Destroy() end
           end
           table.clear(chamsObjects)
       end
   end
})

ChamsTab:CreateColorPicker({
   Name = "Chams Color",
   Color = Color3.fromRGB(255, 0, 255),
   Flag = "Chams_Color",
   Callback = function(value)
       UpdateChamsColors(value, Config.Chams.Transparency)
   end
})

ChamsTab:CreateSlider({
   Name = "Chams Transparency",
   Range = {0, 1},
   Increment = 0.1,
   CurrentValue = 0.5,
   Flag = "Chams_Transparency",
   Callback = function(value)
       UpdateChamsColors(Config.Chams.Color, value)
   end
})

--// Вкладка Aimbot
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
AimbotTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Flag = "Aimbot_Enabled",
   Callback = function(value)
       Config.Aimbot.Enabled = value
       if value then StartAimbot() else StopAimbot() end
   end
})

AimbotTab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {10, 800},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 300,
   Flag = "Aimbot_FOV",
   Callback = function(value)
       Config.Aimbot.FOV = value
   end
})

AimbotTab:CreateSlider({
   Name = "Smoothness",
   Range = {0.05, 1},
   Increment = 0.05,
   CurrentValue = 0.2,
   Flag = "Aimbot_Smoothness",
   Callback = function(value)
       Config.Aimbot.Smoothness = value
   end
})

AimbotTab:CreateDropdown({
   Name = "Target Part",
   Options = {"Head", "HumanoidRootPart", "UpperTorso"},
   CurrentOption = "Head",
   Flag = "Aimbot_TargetPart",
   Callback = function(option)
       Config.Aimbot.TargetPart = option
   end
})

AimbotTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Flag = "Aimbot_WallCheck",
   Callback = function(value)
       Config.Aimbot.WallCheck = value
   end
})

--// Вкладка Visuals
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "Visuals_Fullbright",
   Callback = function(value)
       UpdateFullbright(value)
   end
})

VisualsTab:CreateToggle({
   Name = "No Flash",
   CurrentValue = false,
   Flag = "Visuals_NoFlash",
   Callback = function(value)
       ToggleNoFlash(value)
   end
})

VisualsTab:CreateToggle({
   Name = "No Smoke",
   CurrentValue = false,
   Flag = "Visuals_NoSmoke",
   Callback = function(value)
       ToggleNoSmoke(value)
   end
})

--// Запуск ESP и Chams для всех игроков при старте (если включено)
for _, player in ipairs(Players:GetPlayers()) do
    if Config.ESP.Enabled then CreateESP(player) end
    if Config.Chams.Enabled then CreateChams(player) end
end

Rayfield:Notify({
   Title = "BloxStrike Visuals",
   Content = "Скрипт успешно загружен!",
   Duration = 5,
   Image = 4483362458,
})
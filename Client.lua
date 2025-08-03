-- Client.lua
local client = {}
local shared = nil

-- Управление персонажем
local flyEnabled = false
local flyVelocity = nil
local spinEnabled = false
local teleportHistory = {}
local kindnessMode = false

-- Установка кастомной внешности
function client.setPlayerAppearance()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    -- Установка одежды
    local shirt = character:FindFirstChild("Shirt") or Instance.new("Shirt")
    shirt.ShirtTemplate = "rbxassetid://"..shared.Assets.Shirt
    shirt.Parent = character
    
    local pants = character:FindFirstChild("Pants") or Instance.new("Pants")
    pants.PantsTemplate = "rbxassetid://"..shared.Assets.Pants
    pants.Parent = character
    
    -- Замена частей тела
    local function replacePart(partName, assetId)
        local part = character:FindFirstChild(partName)
        if not part then return end
        
        local newPart = Instance.new("Part")
        newPart.Name = partName
        newPart.Size = part.Size
        newPart.CFrame = part.CFrame
        newPart.Anchored = false
        newPart.CanCollide = part.CanCollide
        newPart.Transparency = part.Transparency
        newPart.BrickColor = part.BrickColor
        newPart.Material = part.Material
        newPart.Parent = character
        
        local specialMesh = Instance.new("SpecialMesh")
        specialMesh.MeshType = Enum.MeshType.FileMesh
        specialMesh.MeshId = "rbxassetid://"..assetId
        specialMesh.TextureId = "rbxassetid://"..assetId
        specialMesh.Parent = newPart
        
        -- Перенос соединений
        for _, weld in ipairs(part:GetChildren()) do
            if weld:IsA("Weld") or weld:IsA("Motor6D") then
                weld.Part1 = newPart
                weld.Parent = newPart
            end
        end
        
        part:Destroy()
        return newPart
    end
    
    -- Заменяем все части тела
    replacePart("Left Leg", shared.Assets.BodyParts.LeftLeg)
    replacePart("Right Leg", shared.Assets.BodyParts.RightLeg)
    replacePart("Torso", shared.Assets.BodyParts.Torso)
    replacePart("Left Arm", shared.Assets.BodyParts.LeftArm)
    replacePart("Right Arm", shared.Assets.BodyParts.RightArm)
end

-- Функции управления
function client.toggleFly()
    flyEnabled = not flyEnabled
    local character = game.Players.LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if flyEnabled then
        -- Сохраняем историю позиций
        teleportHistory = {}
        
        -- Создаем контроллер полета
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        flyVelocity.P = 1000
        flyVelocity.Parent = root
        
        -- Обновление позиции
        game:GetService("RunService").Heartbeat:Connect(function()
            if not flyEnabled then return end
            
            -- Сохраняем позицию
            table.insert(teleportHistory, {
                position = root.Position,
                time = tick()
            })
            
            -- Удаляем старые записи
            while #teleportHistory > 0 and 
                  teleportHistory[1].time < tick() - shared.Settings.TeleportHistory do
                table.remove(teleportHistory, 1)
            end
        end)
    elseif flyVelocity then
        -- Телепорт в прошлую позицию
        if #teleportHistory > 0 then
            root.CFrame = CFrame.new(teleportHistory[1].position)
        end
        
        -- Отключаем полет
        flyVelocity:Destroy()
        flyVelocity = nil
        teleportHistory = {}
    end
end

function client.spamDecals()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            local decal = Instance.new("Decal")
            decal.Texture = "rbxassetid://"..shared.Assets.Decal
            decal.Face = "Top"
            decal.Parent = obj
            
            decal = decal:Clone()
            decal.Face = "Bottom"
            decal.Parent = obj
            
            decal = decal:Clone()
            decal.Face = "Front"
            decal.Parent = obj
            
            decal = decal:Clone()
            decal.Face = "Back"
            decal.Parent = obj
            
            decal = decal:Clone()
            decal.Face = "Left"
            decal.Parent = obj
            
            decal = decal:Clone()
            decal.Face = "Right"
            decal.Parent = obj
        end
    end
end

function client.toggleSpin()
    spinEnabled = not spinEnabled
    local character = game.Players.LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    while spinEnabled and root do
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(shared.Settings.SpinSpeed), 0)
        task.wait()
    end
end

function client.playGlobalSound()
    local soundId = tonumber(game:GetService("TextBox").Text) or shared.Assets.SpookySound
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://"..soundId
    sound.Parent = workspace
    sound:Play()
    
    -- Передача на сервер для всех игроков
    if shared.ServerFunctions.PlayGlobalSound then
        shared.ServerFunctions.PlayGlobalSound(soundId)
    end
end

function client.toggleKindnessMode()
    kindnessMode = not kindnessMode
    shared.Settings.KindnessMode = kindnessMode
    print("Режим доброты: "..(kindnessMode and "ВКЛ" or "ВЫКЛ"))
    
    if kindnessMode then
        -- Активация режима доброты
        -- (реализация банов, репортов и т.д.)
    end
end

-- GUI интерфейс
function client.createGUI(scriptGui)
    -- Очистка предыдущих элементов
    for _, child in ipairs(scriptGui:GetChildren()) do
        child:Destroy()
    end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.25, 0, 0.7, 0)
    frame.Position = UDim2.new(0.02, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scriptGui
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Text = "Универсальный скрипт v3.0"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SciFi
    title.TextScaled = true
    title.Parent = frame
    
    -- Кнопки
    local buttons = {
        {Name = "ВКЛ/ВЫКЛ Полет", Function = client.toggleFly},
        {Name = "Спам декалами", Function = client.spamDecals},
        {Name = "Вращение", Function = client.toggleSpin},
        {Name = "Режим доброты", Function = client.toggleKindnessMode}
    }
    
    for i, btn in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0.12, 0)
        button.Position = UDim2.new(0.05, 0, 0.12 + (i-1)*0.15, 0)
        button.Text = btn.Name
        button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.Parent = frame
        button.MouseButton1Click:Connect(btn.Function)
        
        -- Анимация кнопок
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.new(0.4, 0.4, 0.6)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
        end)
    end
    
    -- Поле ввода звука
    local soundBox = Instance.new("TextBox")
    soundBox.Size = UDim2.new(0.7, 0, 0.08, 0)
    soundBox.Position = UDim2.new(0.05, 0, 0.75, 0)
    soundBox.PlaceholderText = "ID звука"
    soundBox.Text = tostring(shared.Assets.SpookySound)
    soundBox.BackgroundColor3 = Color3.new(0.25, 0.25, 0.35)
    soundBox.TextColor3 = Color3.new(1, 1, 1)
    soundBox.Parent = frame
    
    local soundButton = Instance.new("TextButton")
    soundButton.Size = UDim2.new(0.25, 0, 0.08, 0)
    soundButton.Position = UDim2.new(0.75, 0, 0.75, 0)
    soundButton.Text = "Играть"
    soundButton.BackgroundColor3 = Color3.new(0.3, 0.5, 0.3)
    soundButton.TextColor3 = Color3.new(1, 1, 1)
    soundButton.Font = Enum.Font.GothamBold
    soundButton.Parent = frame
    soundButton.MouseButton1Click:Connect(client.playGlobalSound)
    
    -- Кнопка закрытия интерфейса
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.1, 0, 0.08, 0)
    closeButton.Position = UDim2.new(0.9, 0, 0, 0)
    closeButton.Text = "X"
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = frame
    closeButton.MouseButton1Click:Connect(function()
        scriptGui.Enabled = false
    end)
    
    -- Кнопка открытия интерфейса (для тестирования)
    local openButton = Instance.new("TextButton")
    openButton.Size = UDim2.new(0.1, 0, 0.05, 0)
    openButton.Position = UDim2.new(0, 0, 0.95, 0)
    openButton.Text = "Открыть меню"
    openButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.4)
    openButton.TextColor3 = Color3.new(1, 1, 1)
    openButton.Font = Enum.Font.Gotham
    openButton.Parent = scriptGui
    openButton.Visible = false
    openButton.MouseButton1Click:Connect(function()
        scriptGui.Enabled = true
    end)
end

-- Основная инициализация
function client.init(sharedModule, scriptGui)
    shared = sharedModule
    print("Клиентский модуль активирован")
    
    -- Установка кастомной внешности
    client.setPlayerAppearance()
    
    -- Применение при респавне
    game.Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1) -- Ожидаем загрузки
        client.setPlayerAppearance()
    end)
    
    -- Создание интерфейса
    client.createGUI(scriptGui)
    
    -- Активация кнопки открытия
    scriptGui:WaitForChild("Frame"):WaitForChild("TextButton").Visible = true
end

return client

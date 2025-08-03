-- Server.lua
local server = {}
local shared = nil

-- Античит система
local function setupAntiCheat(player)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    -- Статистика для детекции
    local lastPosition = root.Position
    local lastVelocity = root.Velocity
    local lastCheck = time()
    local rotationHistory = {}
    
    -- Проверка кастомных частей
    local function hasCustomAppearance()
        for partName, assetId in pairs(shared.Assets.BodyParts) do
            local part = character:FindFirstChild(partName)
            if not part or not part:FindFirstChildOfClass("SpecialMesh") then
                return false
            end
        end
        return true
    end
    
    -- Основной цикл проверки
    while character and character.Parent do
        task.wait(1)
        
        -- Проверка внешности
        if not hasCustomAppearance() then
            warn("[Античит] Игрок "..player.Name.." изменил внешность")
            shared.ServerFunctions.BanPlayer(player, "Читерство (модификация персонажа)")
            return
        end
        
        -- Проверка скорости
        local currentVelocity = root.Velocity
        local speed = currentVelocity.Magnitude
        
        if speed > shared.CheatDetection.SpeedThreshold and humanoid.MoveDirection.Magnitude < 0.1 then
            warn("[Античит] Игрок "..player.Name.." подозрительная скорость: "..speed)
            shared.ServerFunctions.ReportPlayer(player, "Читерство (скорость)")
        end
        
        -- Проверка полета
        local currentPosition = root.Position
        local distance = (currentPosition - lastPosition).Magnitude
        local timeDiff = time() - lastCheck
        
        if distance > shared.CheatDetection.FlyThreshold * timeDiff and
           humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and
           humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            warn("[Античит] Игрок "..player.Name.." возможный полет")
            shared.ServerFunctions.ReportPlayer(player, "Читерство (полет)")
        end
        
        -- Обновление истории
        lastPosition = currentPosition
        lastVelocity = currentVelocity
        lastCheck = time()
    end
end

-- Основная функция
function server.init(sharedModule)
    shared = sharedModule
    print("Серверный модуль активирован")
    
    -- Реализация серверных функций
    shared.ServerFunctions.BanPlayer = function(player, reason)
        print("[БАН] Игрок "..player.Name..": "..reason)
        player:Kick("Вы забанены за читерство: "..reason)
    end
    
    shared.ServerFunctions.ReportPlayer = function(player, reason)
        print("[РЕПОРТ] На игрока "..player.Name..": "..reason)
        -- Здесь можно добавить отправку репорта
    end
    
    -- Мониторинг игроков
    game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            setupAntiCheat(player)
        end)
    end)
    
    -- Применение к существующим игрокам
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character then
            setupAntiCheat(player)
        end
    end
end

return server

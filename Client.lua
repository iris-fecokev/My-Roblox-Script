-- Client.lua
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Загрузка зависимостей
local Shared = loadstring(game:HttpGet("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/main/Shared.lua", true))()
local AdminList = Shared.FetchAdmins()
local isAdmin = table.find(AdminList, Player.Name) ~= nil

-- Попытка запуска серверной части
local serverLoaded = false
local function LoadServerScript()
    if serverLoaded then return true end
    
    -- Попытка 1: через модуль
    local moduleSuccess, moduleResult = pcall(function()
        return shared.LoadServerScript()
    end)
    
    if moduleSuccess and moduleResult then
        serverLoaded = true
        return true
    end
    
    -- Попытка 2: прямой запуск
    local loadSuccess, loadError = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/main/Server.lua", true))()
    end)
    
    if loadSuccess then
        serverLoaded = true
        return true
    end
    
    warn("Failed to load server script: "..tostring(loadError))
    return false
end

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalHax"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок в стиле inc0mu
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(120, 80, 220)
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "UNIVERSAL HAX v5.0"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

-- Вкладки
local TabButtons = {}
local TabFrames = {}
local Tabs = {"Основное", "Доброта", "Админ", "Конфиг"}

for i, tabName in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Text = tabName
    btn.Size = UDim2.new(0.25, 0, 0, 30)
    btn.Position = UDim2.new(0.25 * (i-1), 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Parent = MainFrame
    table.insert(TabButtons, btn)
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, -10, 1, -70)
    frame.Position = UDim2.new(0, 5, 0, 65)
    frame.Visible = i == 1
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 5
    frame.CanvasSize = UDim2.new(0, 0, 0, 800)
    frame.Parent = MainFrame
    table.insert(TabFrames, frame)
    
    btn.MouseButton1Click:Connect(function()
        for _, f in ipairs(TabFrames) do f.Visible = false end
        frame.Visible = true
    end)
end

-- Функция создания элементов
local function CreateElement(parent, type, props)
    local element = Instance.new(type)
    for prop, value in pairs(props) do
        element[prop] = value
    end
    element.Parent = parent
    return element
end

-- Основные функции
local yOffset = 10
local function AddSection(parent, title)
    local section = CreateElement(parent, "TextLabel", {
        Text = "─── "..title.." ───",
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, yOffset),
        TextColor3 = Color3.fromRGB(120, 80, 220),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold
    })
    yOffset += 30
    return yOffset
end

yOffset = AddSection(TabFrames[1], "ПЕРЕДВИЖЕНИЕ")

local SpeedBox = CreateElement(TabFrames[1], "TextBox", {
    PlaceholderText = "Скорость (16)",
    Size = UDim2.new(0.9, 0, 0, 25),
    Position = UDim2.new(0.05, 0, 0, yOffset),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    TextColor3 = Color3.fromRGB(220, 220, 220)
})

local JumpBox = CreateElement(TabFrames[1], "TextBox", {
    PlaceholderText = "Прыжок (50)",
    Size = UDim2.new(0.9, 0, 0, 25),
    Position = UDim2.new(0.05, 0, 0, yOffset + 35),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    TextColor3 = Color3.fromRGB(220, 220, 220)
})

local ApplyBtn = CreateElement(TabFrames[1], "TextButton", {
    Text = "ПРИМЕНИТЬ",
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 70),
    BackgroundColor3 = Color3.fromRGB(80, 140, 240),
    TextColor3 = Color3.new(1, 1, 1)
})

ApplyBtn.MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = tonumber(SpeedBox.Text) or 16
        Player.Character.Humanoid.JumpPower = tonumber(JumpBox.Text) or 50
    end
end)

yOffset += 110
yOffset = AddSection(TabFrames[1], "ФУНКЦИИ")

-- Декал спам
local DecalBtn = CreateElement(TabFrames[1], "TextButton", {
    Text = "СПАМ ДЕКАЛАМИ",
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset),
    BackgroundColor3 = Color3.fromRGB(200, 60, 60),
    TextColor3 = Color3.new(1, 1, 1)
})

DecalBtn.MouseButton1Click:Connect(function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
                local decal = Instance.new("Decal")
                decal.Texture = "rbxassetid://"..Shared.DecalID
                decal.Face = face.Name
                decal.Parent = obj
            end
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
                        local decal = Instance.new("Decal")
                        decal.Texture = "rbxassetid://"..Shared.DecalID
                        decal.Face = face.Name
                        decal.Parent = part
                    end
                end
            end
        end
    end
end)

-- Летание
local FlyEnabled = false
local FlyHistory = {}
local FlyBtn = CreateElement(TabFrames[1], "TextButton", {
    Text = "ВКЛЮЧИТЬ ПОЛЕТ",
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 40),
    BackgroundColor3 = Color3.fromRGB(60, 150, 200),
    TextColor3 = Color3.new(1, 1, 1)
})

FlyBtn.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    FlyBtn.Text = FlyEnabled and "ВЫКЛЮЧИТЬ ПОЛЕТ" or "ВКЛЮЧИТЬ ПОЛЕТ"
    
    if FlyEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local root = Player.Character.HumanoidRootPart
        local flyThread = coroutine.create(function()
            while FlyEnabled and root do
                table.insert(FlyHistory, root.Position)
                if #FlyHistory > 100 then table.remove(FlyHistory, 1) end
                
                if #FlyHistory > 5 then
                    root.CFrame = CFrame.new(FlyHistory[#FlyHistory - 5])
                end
                RunService.Heartbeat:Wait()
            end
        end)
        coroutine.resume(flyThread)
    end
end)

-- Звуковой интерфейс
local SoundBox = CreateElement(TabFrames[1], "TextBox", {
    PlaceholderText = "ID звука",
    Size = UDim2.new(0.9, 0, 0, 25),
    Position = UDim2.new(0.05, 0, 0, yOffset + 80),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    TextColor3 = Color3.fromRGB(220, 220, 220)
})

local PlaySoundBtn = CreateElement(TabFrames[1], "TextButton", {
    Text = "ПРОИГРАТЬ ЗВУК",
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 115),
    BackgroundColor3 = Color3.fromRGB(80, 180, 120),
    TextColor3 = Color3.new(1, 1, 1)
})

local SpookyBtn = CreateElement(TabFrames[1], "TextButton", {
    Text = "SPOOKY SKELETONS",
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 155),
    BackgroundColor3 = Color3.fromRGB(180, 100, 220),
    TextColor3 = Color3.new(1, 1, 1)
})

PlaySoundBtn.MouseButton1Click:Connect(function()
    local soundId = SoundBox.Text
    if soundId and tonumber(soundId) then
        local soundEvent = game:GetService("ReplicatedStorage"):FindFirstChild("PlaySoundEvent")
        if soundEvent then
            soundEvent:FireServer(soundId)
        end
    end
end)

SpookyBtn.MouseButton1Click:Connect(function()
    SoundBox.Text = "3469774300"
    PlaySoundBtn:MouseButton1Click()
end)

-- Спин
local SpinEnabled = false
local SpinBtn = CreateElement(TabFrames[1], "TextButton", {
    Text = "SPIN MODE",
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 195),
    BackgroundColor3 = Color3.fromRGB(220, 120, 80),
    TextColor3 = Color3.new(1, 1, 1)
})

SpinBtn.MouseButton1Click:Connect(function()
    SpinEnabled = not SpinEnabled
    if SpinEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local root = Player.Character.HumanoidRootPart
        local spinThread = coroutine.create(function()
            while SpinEnabled and root do
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(30), 0)
                RunService.Heartbeat:Wait()
            end
        end)
        coroutine.resume(spinThread)
    end
end)

-- Проигрывание анимации для всех
local PlayAnimBtn = CreateElement(TabFrames[1], "TextButton", {
    Text = "PLAY ANIMATION FOR ALL",
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 235),
    BackgroundColor3 = Color3.fromRGB(220, 170, 50),
    TextColor3 = Color3.new(1, 1, 1)
})

PlayAnimBtn.MouseButton1Click:Connect(function()
    if isAdmin then
        local adminEvent = game:GetService("ReplicatedStorage"):FindFirstChild("AdminEvent")
        if adminEvent then
            adminEvent:FireServer("PlayAnimationForAll")
        end
    else
        warn("You need admin privileges to play animations for all players!")
    end
end)

-- Режим "Доброты"
yOffset = 10
yOffset = AddSection(TabFrames[2], "АНТИЧИТ СИСТЕМА")

local ReportBox = CreateElement(TabFrames[2], "TextBox", {
    PlaceholderText = "Имя читера",
    Size = UDim2.new(0.9, 0, 0, 25),
    Position = UDim2.new(0.05, 0, 0, yOffset),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    TextColor3 = Color3.fromRGB(220, 220, 220)
})

local ReportBtn = CreateElement(TabFrames[2], "TextButton", {
    Text = "СПАМ РЕПОРТАМИ",
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 35),
    BackgroundColor3 = Color3.fromRGB(200, 80, 80),
    TextColor3 = Color3.new(1, 1, 1)
})

ReportBtn.MouseButton1Click:Connect(function()
    local playerName = ReportBox.Text
    if playerName then
        for i = 1, 50 do
            -- Эмуляция отправки репортов
            wait(0.05)
        end
    end
end)

local BanBtn = CreateElement(TabFrames[2], "TextButton", {
    Text = "БАН ЧИТЕРОВ",
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 75),
    BackgroundColor3 = Color3.fromRGB(180, 60, 60),
    TextColor3 = Color3.new(1, 1, 1)
})

BanBtn.MouseButton1Click:Connect(function()
    if isAdmin then
        local adminEvent = game:GetService("ReplicatedStorage"):FindFirstChild("AdminEvent")
        if adminEvent then
            adminEvent:FireServer("KickAllCheaters")
        end
    end
end)

-- Админ-панель
if isAdmin then
    yOffset = 10
    yOffset = AddSection(TabFrames[3], "АДМИН КОМАНДЫ")
    
    for i, cmd in ipairs(Shared.AdminCommands) do
        local btn = CreateElement(TabFrames[3], "TextButton", {
            Text = cmd,
            Size = UDim2.new(0.9, 0, 0, 30),
            Position = UDim2.new(0.05, 0, 0, yOffset + (i-1)*40),
            BackgroundColor3 = Color3.fromRGB(120, 80, 220),
            TextColor3 = Color3.new(1, 1, 1)
        })
        
        btn.MouseButton1Click:Connect(function()
            local adminEvent = game:GetService("ReplicatedStorage"):FindFirstChild("AdminEvent")
            if adminEvent then
                if cmd == "ServerLock" then
                    adminEvent:FireServer(cmd, "Сервер заблокирован администратором!")
                else
                    adminEvent:FireServer(cmd)
                end
            end
        end)
    end
    
    -- Админский конфиг
    yOffset = 10
    yOffset = AddSection(TabFrames[4], "АДМИН КОНФИГ")
    
    local LockMessageBox = CreateElement(TabFrames[4], "TextBox", {
        PlaceholderText = "Сообщение блокировки",
        Size = UDim2.new(0.9, 0, 0, 25),
        Position = UDim2.new(0.05, 0, 0, yOffset),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        TextColor3 = Color3.fromRGB(220, 220, 220)
    })
    
    local LockToggle = CreateElement(TabFrames[4], "TextButton", {
        Text = "БЛОКИРОВКА СЕРВЕРА: "..(Shared.Settings.ServerLock and "ВКЛ" or "ВЫКЛ"),
        Size = UDim2.new(0.9, 0, 0, 30),
        Position = UDim2.new(0.05, 0, 0, yOffset + 40),
        BackgroundColor3 = Shared.Settings.ServerLock and Color3.fromRGB(80, 180, 120) or Color3.fromRGB(180, 80, 80),
        TextColor3 = Color3.new(1, 1, 1)
    })
    
    LockToggle.MouseButton1Click:Connect(function()
        Shared.Settings.ServerLock = not Shared.Settings.ServerLock
        LockToggle.Text = "БЛОКИРОВКА СЕРВЕРА: "..(Shared.Settings.ServerLock and "ВКЛ" or "ВЫКЛ")
        LockToggle.BackgroundColor3 = Shared.Settings.ServerLock and Color3.fromRGB(80, 180, 120) or Color3.fromRGB(180, 80, 80)
        
        local adminEvent = game:GetService("ReplicatedStorage"):FindFirstChild("AdminEvent")
        if adminEvent then
            adminEvent:FireServer("ServerLock", Shared.Settings.ServerLock, LockMessageBox.Text)
        end
    end)
    
    -- Кнопка ручной загрузки сервера
    local ServerLoadBtn = CreateElement(TabFrames[3], "TextButton", {
        Text = "ЗАГРУЗИТЬ СЕРВЕР",
        Size = UDim2.new(0.9, 0, 0, 30),
        Position = UDim2.new(0.05, 0, 0, yOffset + (#Shared.AdminCommands * 40 + 10)),
        BackgroundColor3 = Color3.fromRGB(60, 180, 100),
        TextColor3 = Color3.new(1, 1, 1)
    })
    
    ServerLoadBtn.MouseButton1Click:Connect(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/main/Server.lua", true))()
        end)
        if success then
            ServerLoadBtn.Text = "СЕРВЕР ЗАГРУЖЕН!"
            wait(2)
            ServerLoadBtn.Text = "ЗАГРУЗИТЬ СЕРВЕР"
        else
            warn("Failed to load server: "..tostring(err))
        end
    end)
end

-- Конфиг для всех
yOffset = 10
yOffset = AddSection(TabFrames[4], "НАСТРОЙКИ")

local ThemeToggle = CreateElement(TabFrames[4], "TextButton", {
    Text = "ТЕМА: "..Shared.Settings.Theme,
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset),
    BackgroundColor3 = Color3.fromRGB(80, 140, 240),
    TextColor3 = Color3.new(1, 1, 1)
})

ThemeToggle.MouseButton1Click:Connect(function()
    Shared.Settings.Theme = Shared.Settings.Theme == "Dark" and "Light" or "Dark"
    ThemeToggle.Text = "ТЕМА: "..Shared.Settings.Theme
    Shared.ApplyTheme(MainFrame, Shared.Settings.Theme)
end)

local BetaToggle = CreateElement(TabFrames[4], "TextButton", {
    Text = "БЕТА-ФУНКЦИИ: "..(Shared.Settings.BetaFeatures and "ВКЛ" or "ВЫКЛ"),
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 40),
    BackgroundColor3 = Shared.Settings.BetaFeatures and Color3.fromRGB(80, 180, 120) or Color3.fromRGB(180, 80, 80),
    TextColor3 = Color3.new(1, 1, 1)
})

BetaToggle.MouseButton1Click:Connect(function()
    Shared.Settings.BetaFeatures = not Shared.Settings.BetaFeatures
    BetaToggle.Text = "БЕТА-ФУНКЦИИ: "..(Shared.Settings.BetaFeatures and "ВКЛ" or "ВЫКЛ")
    BetaToggle.BackgroundColor3 = Shared.Settings.BetaFeatures and Color3.fromRGB(80, 180, 120) or Color3.fromRGB(180, 80, 80)
end)

local DebugToggle = CreateElement(TabFrames[4], "TextButton", {
    Text = "РЕЖИМ ДЕБАГА: "..(Shared.Settings.DebugMode and "ВКЛ" or "ВЫКЛ"),
    Size = UDim2.new(0.9, 0, 0, 30),
    Position = UDim2.new(0.05, 0, 0, yOffset + 80),
    BackgroundColor3 = Shared.Settings.DebugMode and Color3.fromRGB(80, 180, 120) or Color3.fromRGB(180, 80, 80),
    TextColor3 = Color3.new(1, 1, 1)
})

-- Дебаг информация
local DebugFrame = CreateElement(ScreenGui, "Frame", {
    Size = UDim2.new(0, 200, 0, 80),
    Position = UDim2.new(1, -210, 1, -90),
    BackgroundTransparency = 0.7,
    BackgroundColor3 = Color3.new(0, 0, 0),
    Visible = false
})

local DebugText = CreateElement(DebugFrame, "TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    Text = "FPS: ...\nPING: ...\nMEM: ...",
    TextColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
})

DebugToggle.MouseButton1Click:Connect(function()
    Shared.Settings.DebugMode = not Shared.Settings.DebugMode
    DebugToggle.Text = "РЕЖИМ ДЕБАГА: "..(Shared.Settings.DebugMode and "ВКЛ" or "ВЫКЛ")
    DebugToggle.BackgroundColor3 = Shared.Settings.DebugMode and Color3.fromRGB(80, 180, 120) or Color3.fromRGB(180, 80, 80)
    DebugFrame.Visible = Shared.Settings.DebugMode
end)

-- Обновление дебаг информации
if Shared.Settings.DebugMode then
    DebugFrame.Visible = true
    local lastUpdate = time()
    local frames = 0
    
    RunService.Heartbeat:Connect(function(delta)
        frames += 1
        if time() - lastUpdate >= 1 then
            local fps = frames
            local ping = math.random(30, 100) -- Для демонстрации
            local mem = math.floor((collectgarbage("count")/1024)*100)/100
            
            DebugText.Text = string.format("FPS: %d\nPING: %dms\nMEM: %.2fMB", fps, ping, mem)
            
            frames = 0
            lastUpdate = time()
        end
    end)
end

-- Автоматическая попытка загрузки сервера
if isAdmin then
    if not LoadServerScript() then
        warn("Automatic server load failed, use manual button")
    end
end

Shared.ApplyTheme(MainFrame, Shared.Settings.Theme)
